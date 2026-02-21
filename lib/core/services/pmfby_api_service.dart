import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/state_model.dart';
import '../../data/models/district_model.dart';
import '../../data/models/crop_model.dart';

/// Custom exception for API errors
class PMFBYApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  PMFBYApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'PMFBYApiException: $message';
}

/// PMFBY API Service - Handles all API calls to PMFBY endpoints
/// Includes caching, retry logic, and error handling
class PMFBYApiService {
  static const String baseUrl = 'https://pmfby.gov.in';
  static const Duration timeout = Duration(seconds: 15);
  static const int maxRetries = 3;

  // Cache keys
  static const String _cacheKeyStates = 'pmfby_states_cache';
  static const String _cacheKeyDistricts = 'pmfby_districts_cache_';
  static const String _cacheKeyCrops = 'pmfby_crops_cache_';
  static const String _cacheTimestamp = '_timestamp';
  static const Duration cacheValidity = Duration(hours: 24);

  // Singleton instance
  static final PMFBYApiService _instance = PMFBYApiService._internal();
  factory PMFBYApiService() => _instance;
  PMFBYApiService._internal();

  /// Fetch list of all states
  Future<List<StateModel>> fetchStates({bool forceRefresh = false}) async {
    final cacheKey = _cacheKeyStates;

    // Try to get from cache first
    if (!forceRefresh) {
      final cached = await _getFromCache<List<StateModel>>(
        cacheKey,
        (json) => (json as List).map((e) => StateModel.fromJson(e as Map<String, dynamic>)).toList(),
      );
      if (cached != null) {
        debugPrint('PMFBYApiService: Returning cached states (${cached.length} items)');
        return cached;
      }
    }

    // Fetch from API
    final url = '$baseUrl/landingPage/stateList';
    final response = await _makeRequest(url);

    try {
      final List<dynamic> data = json.decode(response);
      final states = data.map((json) => StateModel.fromJson(json as Map<String, dynamic>)).toList();

      // Sort states alphabetically
      states.sort((a, b) => a.stateName.compareTo(b.stateName));

      // Cache the result
      await _saveToCache(cacheKey, states.map((s) => s.toJson()).toList());

      debugPrint('PMFBYApiService: Fetched ${states.length} states from API');
      return states;
    } catch (e) {
      throw PMFBYApiException('Failed to parse states response', details: e.toString());
    }
  }

  /// Fetch districts for a given state and season
  Future<List<DistrictModel>> fetchDistricts({
    required String stateId,
    required String seasonId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$_cacheKeyDistricts${stateId}_$seasonId';

    // Try to get from cache first
    if (!forceRefresh) {
      final cached = await _getFromCache<List<DistrictModel>>(
        cacheKey,
        (json) => (json as List).map((e) => DistrictModel.fromJson(e as Map<String, dynamic>)).toList(),
      );
      if (cached != null) {
        debugPrint('PMFBYApiService: Returning cached districts for state $stateId (${cached.length} items)');
        return cached;
      }
    }

    // Fetch from API
    final url = '$baseUrl/landingPage/districtState?stateID=$stateId&sssyID=$seasonId';
    final response = await _makeRequest(url);

    try {
      final List<dynamic> data = json.decode(response);
      final districts = data.map((json) => DistrictModel.fromJson(json as Map<String, dynamic>)).toList();

      // Sort districts alphabetically
      districts.sort((a, b) => a.districtName.compareTo(b.districtName));

      // Cache the result
      await _saveToCache(cacheKey, districts.map((d) => d.toJson()).toList());

      debugPrint('PMFBYApiService: Fetched ${districts.length} districts from API');
      return districts;
    } catch (e) {
      throw PMFBYApiException('Failed to parse districts response', details: e.toString());
    }
  }

  /// Fetch crops for a given district and season
  Future<List<CropModel>> fetchCrops({
    required String districtId,
    required String seasonId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$_cacheKeyCrops${districtId}_$seasonId';

    // Try to get from cache first
    if (!forceRefresh) {
      final cached = await _getFromCache<List<CropModel>>(
        cacheKey,
        (json) => (json as List).map((e) => CropModel.fromJson(e as Map<String, dynamic>)).toList(),
      );
      if (cached != null) {
        debugPrint('PMFBYApiService: Returning cached crops for district $districtId (${cached.length} items)');
        return cached;
      }
    }

    // Fetch from API
    final url = '$baseUrl/cropNotification/cropList?sssyID=$seasonId&districtID=$districtId';
    final response = await _makeRequest(url);

    try {
      final List<dynamic> data = json.decode(response);
      final crops = data.map((json) => CropModel.fromJson(json as Map<String, dynamic>)).toList();

      // Sort crops alphabetically
      crops.sort((a, b) => a.cropName.compareTo(b.cropName));

      // Cache the result
      await _saveToCache(cacheKey, crops.map((c) => c.toJson()).toList());

      debugPrint('PMFBYApiService: Fetched ${crops.length} crops from API');
      return crops;
    } catch (e) {
      throw PMFBYApiException('Failed to parse crops response', details: e.toString());
    }
  }

  /// Make HTTP request with retry logic
  Future<String> _makeRequest(String url) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('PMFBYApiService: Request attempt $attempt - $url');

        final httpClient = HttpClient();
        httpClient.connectionTimeout = timeout;

        final request = await httpClient.getUrl(Uri.parse(url));
        request.headers.set('Accept', 'application/json');
        request.headers.set('Content-Type', 'application/json');

        final response = await request.close().timeout(timeout);

        if (response.statusCode == 200) {
          final responseBody = await response.transform(utf8.decoder).join();
          httpClient.close();
          return responseBody;
        } else {
          httpClient.close();
          throw PMFBYApiException(
            'HTTP Error',
            statusCode: response.statusCode,
            details: 'Status code: ${response.statusCode}',
          );
        }
      } on SocketException catch (e) {
        lastException = PMFBYApiException(
          'No internet connection',
          details: e.toString(),
        );
        debugPrint('PMFBYApiService: Network error on attempt $attempt');
      } on TimeoutException catch (e) {
        lastException = PMFBYApiException(
          'Request timeout. Please try again.',
          details: e.toString(),
        );
        debugPrint('PMFBYApiService: Timeout on attempt $attempt');
      } on PMFBYApiException {
        rethrow;
      } catch (e) {
        lastException = PMFBYApiException(
          'Network error',
          details: e.toString(),
        );
        debugPrint('PMFBYApiService: Error on attempt $attempt: $e');
      }

      // Wait before retry (exponential backoff)
      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    throw lastException ?? PMFBYApiException('Unknown error occurred');
  }

  /// Get data from cache if valid
  Future<T?> _getFromCache<T>(String key, T Function(dynamic) parser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(key);
      final timestamp = prefs.getInt('$key$_cacheTimestamp');

      if (cachedData == null || timestamp == null) return null;

      // Check if cache is still valid
      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cachedTime) > cacheValidity) {
        debugPrint('PMFBYApiService: Cache expired for $key');
        return null;
      }

      final decoded = json.decode(cachedData);
      return parser(decoded);
    } catch (e) {
      debugPrint('PMFBYApiService: Error reading cache: $e');
      return null;
    }
  }

  /// Save data to cache
  Future<void> _saveToCache(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json.encode(data));
      await prefs.setInt('$key$_cacheTimestamp', DateTime.now().millisecondsSinceEpoch);
      debugPrint('PMFBYApiService: Saved to cache: $key');
    } catch (e) {
      debugPrint('PMFBYApiService: Error saving to cache: $e');
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) =>
        key.startsWith('pmfby_') || key.contains('_cache')
      ).toList();

      for (final key in keys) {
        await prefs.remove(key);
      }
      debugPrint('PMFBYApiService: Cache cleared');
    } catch (e) {
      debugPrint('PMFBYApiService: Error clearing cache: $e');
    }
  }
}

