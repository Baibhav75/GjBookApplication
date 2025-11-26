// services/survey_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/Model/survey_model.dart';

class SurveyService {
  static const String _endpoint =
      "https://gj.realhomes.co.in/API/SurveyFormList/GetSurveyFormList";
  static const String _cacheKey = "survey_cache_v1";
  static const Duration cacheTTL = Duration(minutes: 30);

  // Fetch from network. If successful, cache raw JSON.
  static Future<List<SchoolData>> fetchSurveyList({bool forceRefresh = false}) async {
    // Try to return cache first if available and not forced
    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh) {
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        try {
          final SurveyResponse resp = SurveyResponse.fromRawJson(cached);
          if (resp.schoolList.isNotEmpty) {
            return resp.schoolList;
          }
        } catch (_) {
          // ignore and continue to network fetch
        }
      }
    }

    final uri = Uri.parse(_endpoint);
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      // Normalize possible empty responses
      if ((response.body ?? '').trim().isEmpty) {
        throw Exception('Empty response body from server');
      }
      final SurveyResponse survey = SurveyResponse.fromRawJson(response.body);
      // Cache JSON string
      await prefs.setString(_cacheKey, response.body);
      return survey.schoolList;
    } else {
      // If network fails, try to return cached data (if any)
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        final SurveyResponse resp = SurveyResponse.fromRawJson(cached);
        return resp.schoolList;
      }
      throw Exception('Failed to load survey list (status ${response.statusCode})');
    }
  }

  // Optional: clear cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
