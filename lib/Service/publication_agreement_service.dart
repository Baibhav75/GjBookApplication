// publication_agreement_service.dart में
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../Model/publication_agreement_model.dart';

class PublicationService {
  static const String _baseUrl = "https://g17bookworld.com";

  static Future<PublicationListModel> getPublications() async {
    final url = Uri.parse("$_baseUrl/API/AgrementPublicationList/GetPublication");

    try {
      print('📡 Fetching data from: $url');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('✅ Data fetched successfully');

        // Debug: Print first few publications with image URLs
        if (decoded['PublicationList'] != null) {
          final List list = decoded['PublicationList'];
          for (int i = 0; i < min(3, list.length); i++) {
            final publication = list[i];
            print('📄 Publication ${i+1}: ${publication['PublicationName']}');
            print('   Agreement File: ${publication['AgrementFile']}');
            print('   Checks: ${publication['Checks']}');
            print('   Full Agreement URL: ${getFullImageUrl(publication['AgrementFile'])}');
            print('   Full Checks URL: ${getFullImageUrl(publication['Checks'])}');
          }
        }

        return PublicationListModel.fromJson(decoded);
      } else {
        print('❌ Server Error: ${response.statusCode}');
        throw Exception("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ Exception: $e');
      throw Exception("Error fetching publications: $e");
    }
  }

  static String getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      print('⚠️ Empty image path');
      return '';
    }

    print('🔗 Original path: $relativePath');

    // Check if it's already a full URL
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      print('✅ Already full URL: $relativePath');
      return relativePath;
    }

    // Fix common issues
    String fixedPath = relativePath;

    // Remove leading/trailing spaces
    fixedPath = fixedPath.trim();

    // Ensure it starts with /
    if (!fixedPath.startsWith('/')) {
      fixedPath = '/$fixedPath';
    }

    // Build full URL
    final fullUrl = "$_baseUrl$fixedPath";
    print('🔗 Full URL: $fullUrl');

    return fullUrl;
  }
}