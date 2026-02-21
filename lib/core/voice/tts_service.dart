import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();
  static final TtsService _instance = TtsService._();
  static TtsService get instance => _instance;

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _currentLanguage = 'en-US';

  bool get isSpeaking => _isSpeaking;
  bool get isAvailable => _isInitialized;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      if (kIsWeb) {
        await _tts.setLanguage('en-US');
        _isInitialized = true;
        return true;
      }

      await _tts.setLanguage(_currentLanguage);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        _isSpeaking = true;
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _tts.setErrorHandler((error) {
        _isSpeaking = false;
        debugPrint('TTS error: $error');
      });

      _tts.setCancelHandler(() {
        _isSpeaking = false;
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS init failed: $e');
      _isInitialized = false;
    }
    return _isInitialized;
  }

  Future<void> setLanguage(String languageCode) async {
    switch (languageCode) {
      case 'hi':
        _currentLanguage = 'hi-IN';
        break;
      case 'mr':
        _currentLanguage = 'mr-IN';
        break;
      default:
        _currentLanguage = 'en-US';
    }
    if (_isInitialized) {
      try {
        await _tts.setLanguage(_currentLanguage);
      } catch (e) {
        debugPrint('Failed to set TTS language: $e');
      }
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return;
    }

    if (text.trim().isEmpty) return;

    try {
      if (_isSpeaking) {
        await stop();
      }
      _isSpeaking = true;
      await _tts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      debugPrint('TTS speak failed: $e');
    }
  }

  Future<void> stop() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
    }
  }

  Future<void> pause() async {
    if (_isSpeaking) {
      await _tts.pause();
    }
  }

  void dispose() {
    _tts.stop();
    _isSpeaking = false;
  }
}
