import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Chat Service - Handles API communication with the farmer chatbot backend
/// Base URL: https://farmer-scheme-api.onrender.com
/// Handles Render cold-start (free tier sleeps) with 35s timeout
class ChatService {
  static const String _baseUrl = 'https://farmer-scheme-api.onrender.com';
  static const Duration _timeout = Duration(seconds: 35);

  ChatService._();
  static final ChatService _instance = ChatService._();
  static ChatService get instance => _instance;

  /// Initialize a new chat session
  /// Returns the session_id from /api/session
  Future<String?> initSession() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/session'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['session_id'] as String?;
      }
      return null;
    } on TimeoutException {
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Send a message to the chat API
  /// Returns the response text, or null on failure
  Future<String?> sendMessage(String message, {String? sessionId}) async {
    try {
      final body = <String, dynamic>{
        'message': message,
      };
      if (sessionId != null) {
        body['session_id'] = sessionId;
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Try common response fields
        return data['response'] as String? ??
            data['message'] as String? ??
            data['reply'] as String? ??
            data.toString();
      }
      return null;
    } on TimeoutException {
      return null;
    } catch (e) {
      return null;
    }
  }
}

