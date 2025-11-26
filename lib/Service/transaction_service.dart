// services/transaction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Model/transaction_models.dart';

class TransactionService {
  static const String baseUrl = 'https://gj.realhomes.co.in/API/DaybookLadger/GetLedger';
  static const Duration cacheDuration = Duration(minutes: 5);

  Map<String, Map<String, dynamic>> _cache = {};
  Map<String, DateTime> _cacheTimestamps = {};

  Future<TransactionResponse> getTransactions({
    DateTime? fromDate,
    DateTime? toDate,
    bool forceRefresh = false,
  }) async {
    final String cacheKey = _generateCacheKey(fromDate, toDate);

    // Check cache
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      return TransactionResponse.fromJson(_cache[cacheKey]!['data']);
    }

    try {
      final Map<String, String> queryParams = {};

      if (fromDate != null) {
        queryParams['fromDate'] = _formatDateTimeForApi(fromDate);
      }
      if (toDate != null) {
        queryParams['toDate'] = _formatDateTimeForApi(toDate);
      }


      final Uri uri = Uri.parse(baseUrl).replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Update cache
        _cache[cacheKey] = {
          'data': responseData,
          'timestamp': DateTime.now(),
        };
        _cacheTimestamps[cacheKey] = DateTime.now();

        return TransactionResponse.fromJson(responseData);
      } else {
        throw HttpException('Failed to load transactions: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  String _generateCacheKey(DateTime? fromDate, DateTime? toDate) {
    final fromKey = fromDate?.toIso8601String() ?? 'all';
    final toKey = toDate?.toIso8601String() ?? 'all';
    return '$fromKey-$toKey';
  }

  bool _isCacheValid(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < cacheDuration;
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  String _formatDateTimeForApi(DateTime date) {
    // ISO 8601 without timezone (server might expect this). Use toIso8601String() if server accepts it.
    // Example output: 2025-11-26T23:59:59
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}T'
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}:'
        '${date.second.toString().padLeft(2, '0')}';
  }

}

// Custom exceptions
class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}