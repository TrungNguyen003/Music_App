import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../../data/model/song.dart';

class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();

  factory AudioPlayerManager() {
    return _instance;
  }

  AudioPlayerManager._internal();

  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  List<Song> _songs = [];
  int _currentIndex = 0;
  
  // Thêm stream để thông báo bài hát hiện tại thay đổi
  final _currentSongSubject = BehaviorSubject<Song?>();
  Stream<Song?> get currentSongStream => _currentSongSubject.stream;

  void init(List<Song> songs, int currentIndex) {
    _songs = songs;
    _currentIndex = currentIndex;
    _currentSongSubject.add(_songs[_currentIndex]);
    player.setUrl(_songs[_currentIndex].source);
    
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        player.positionStream,
        player.playbackEventStream,
        (position, playbackEvent) => DurationState(
            progress: position,
            buffered: playbackEvent.bufferedPosition,
            total: playbackEvent.duration));
  }

  Future<void> playNext() async {
    if (_currentIndex < _songs.length - 1) {
      _currentIndex++;
      _currentSongSubject.add(_songs[_currentIndex]);
      await player.setUrl(_songs[_currentIndex].source);
      player.play();
    }
  }

  Future<void> playPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      _currentSongSubject.add(_songs[_currentIndex]);
      await player.setUrl(_songs[_currentIndex].source);
      player.play();
    }
  }

  Future<void> setShuffleMode(bool enabled) async {
    await player.setShuffleModeEnabled(enabled);
  }

  Future<void> setRepeatMode(LoopMode loopMode) async {
    await player.setLoopMode(loopMode);
  }

  Future<void> stop() async {
    await player.stop();
    _currentSongSubject.add(null); 
  }

  Future<void> dispose() async {
    await player.dispose();
    await _currentSongSubject.close();
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });

  final Duration progress;
  final Duration buffered;
  final Duration? total;
}
