import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  SpeechService._();
  static final SpeechService _instance = SpeechService._();
  static SpeechService get instance => _instance;

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _currentLocaleId = 'en_US';

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    if (kIsWeb) {
      try {
        _isInitialized = await _speech.initialize(
          onError: (error) => debugPrint('Speech error: ${error.errorMsg}'),
          onStatus: (status) => debugPrint('Speech status: $status'),
        );
      } catch (e) {
        debugPrint('Web speech init failed: $e');
        _isInitialized = false;
      }
      return _isInitialized;
    }

    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => debugPrint('Speech error: ${error.errorMsg}'),
        onStatus: (status) => debugPrint('Speech status: $status'),
      );
    } catch (e) {
      debugPrint('Speech init failed: $e');
      _isInitialized = false;
    }
    return _isInitialized;
  }

  void setLanguage(String languageCode) {
    _currentLocaleId = languageCode == 'hi' ? 'hi_IN' : 'en_US';
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function() onDone,
    Function(String)? onError,
  }) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) {
        onError?.call('Speech recognition not available');
        return;
      }
    }

    if (_isListening) return;

    _isListening = true;

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          if (result.finalResult) {
            _isListening = false;
            onResult(result.recognizedWords);
            onDone();
          }
        },
        localeId: _currentLocaleId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        cancelOnError: true,
      );
    } catch (e) {
      _isListening = false;
      onError?.call('Failed to start listening: $e');
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
    }
  }

  void dispose() {
    _speech.stop();
    _isListening = false;
  }
}
