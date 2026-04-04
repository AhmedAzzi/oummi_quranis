import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

/// Global audio handler — initialized once in main() via AudioService.init()
late AudioPlayerHandler audioHandler;

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  List<int> _timings = [];

  AudioPlayer get player => _player;

  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  AudioPlayerHandler() {
    // Forward just_audio playback state → audio_service PlaybackState
    _player.playbackEventStream.listen(_broadcastState);
    _player.playerStateStream.listen((_) => _broadcastState(null));

    // Listen to duration changes to update the notification progress bar
    _player.durationStream.listen((duration) {
      final item = mediaItem.value;
      if (item != null) {
        mediaItem.add(item.copyWith(duration: duration));
      }
    });
  }

  // ── Public API (called from UI) ──────────────────────────────────────────

  Future<void> playTrack(
    String? urlOrAsset, {
    bool isAsset = false,
    Duration? initialPosition,
    String surahName = '',
    List<int> timings = const [],
  }) async {
    if (urlOrAsset == null || urlOrAsset.isEmpty) return;
    _timings = timings;
    try {
      await _player.stop();

      // Update media item so the notification shows the Surah name
      mediaItem.add(
        MediaItem(
          id: urlOrAsset,
          title: surahName.isNotEmpty ? surahName : 'القرآن الكريم',
          artist: 'سعد الغامدي',
          album: 'القرآن الكريم',
        ),
      );

      if (isAsset) {
        await _player.setAudioSource(AudioSource.asset(urlOrAsset));
      } else {
        await _player.setUrl(urlOrAsset);
      }

      if (initialPosition != null && initialPosition != Duration.zero) {
        await _player.seek(initialPosition);
      }

      await _player.play();
    } catch (e) {
      debugPrint('Error playing track: $e');
    }
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  // ── BaseAudioHandler overrides ───────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_timings.isEmpty) return;

    final positionMs = _player.position.inMilliseconds + 150;
    int nextIndex = -1;

    for (int i = 0; i < _timings.length; i++) {
      if (_timings[i] > positionMs) {
        nextIndex = i;
        break;
      }
    }

    if (nextIndex != -1 && nextIndex < _timings.length) {
      final startTimeMs = _timings[nextIndex];
      await seek(Duration(milliseconds: startTimeMs));
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_timings.isEmpty) return;

    final positionMs = _player.position.inMilliseconds;
    int currentIndex = -1;

    for (int i = 0; i < _timings.length; i++) {
      if (_timings[i] > positionMs + 150) {
        currentIndex = i;
        break;
      }
    }

    if (currentIndex != -1) {
      final currentVerseStartTimeMs = currentIndex == 0
          ? 0
          : _timings[currentIndex - 1];

      if (positionMs - currentVerseStartTimeMs > 3000) {
        await seek(Duration(milliseconds: currentVerseStartTimeMs));
      } else if (currentIndex > 0) {
        final prevVerseStartTimeMs = currentIndex == 1
            ? 0
            : _timings[currentIndex - 2];
        await seek(Duration(milliseconds: prevVerseStartTimeMs));
      }
    }
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  void _broadcastState(PlaybackEvent? event) {
    final playing = _player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _processingState(),
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }

  AudioProcessingState _processingState() {
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }
}
