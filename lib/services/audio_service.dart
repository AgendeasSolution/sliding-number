import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static AudioService get instance => _instance;

  bool _isSoundEnabled = true;
  
  // Single audio player for all sounds to prevent collision
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Track last slide sound time to prevent audio spam
  DateTime _lastSlideTime = DateTime.now();
  static const Duration _slideCooldown = Duration(milliseconds: 80);

  /// Play button click sound (mouse_click_5)
  Future<void> playClickSound() async {
    if (!_isSoundEnabled) return;
    
    try {
      await _audioPlayer.stop(); // Stop any current sound
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.play(AssetSource('audio/mouse_click_5.mp3'));
    } catch (e) {
      // Silent error handling
    }
  }

  /// Play tile slide sound (mouse_click_3) with cooldown
  Future<void> playSlideSound() async {
    if (!_isSoundEnabled) return;
    
    final now = DateTime.now();
    if (now.difference(_lastSlideTime) < _slideCooldown) {
      return; // Skip if too soon since last slide sound
    }
    
    try {
      _lastSlideTime = now;
      await _audioPlayer.stop(); // Stop any current sound
      await _audioPlayer.setVolume(0.8);
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.play(AssetSource('audio/mouse_click_3.mp3'));
    } catch (e) {
      // Silent error handling
    }
  }

  /// Play win sound (win_2)
  Future<void> playWinSound() async {
    if (!_isSoundEnabled) return;
    
    try {
      await _audioPlayer.stop(); // Stop any current sound
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _audioPlayer.play(AssetSource('audio/win_2.mp3'));
    } catch (e) {
      // Silent error handling
    }
  }

  /// Toggle sound on/off
  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
  }

  /// Check if sound is enabled
  bool get isSoundEnabled => _isSoundEnabled;

  /// Set sound enabled state
  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  /// Initialize the audio service
  Future<void> initialize() async {
    try {
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    } catch (e) {
      // Silent error handling
    }
  }

  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
