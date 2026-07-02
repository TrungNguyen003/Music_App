import 'dart:async';

import 'package:msapp/data/repository/repository.dart';

import '../../data/model/song.dart';

class MusicAppViewModel {
  StreamController<List<Song>> songStream = StreamController();
  StreamController<Song?> currentSongStream = StreamController();
  StreamController<bool> isPlayingStream = StreamController();

  Song? _currentSong;
  bool _isPlaying = false;

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;

  void loadSongs(){
    final repository = DefaultRepository();
    repository.LoadData().then((value) {
      print('Repository returned: ${value?.length ?? 0} songs');
      songStream.add(value ?? []);
    }).catchError((error) {
      print('Repository error: $error');
      songStream.addError(error);
    });
  }

  void playSong(Song song) {
    _currentSong = song;
    _isPlaying = true;
    currentSongStream.add(_currentSong);
    isPlayingStream.add(_isPlaying);
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    isPlayingStream.add(_isPlaying);
  }

  void stopSong() {
    _currentSong = null;
    _isPlaying = false;
    currentSongStream.add(null);
    isPlayingStream.add(false);
  }

  void dispose() {
    songStream.close();
    currentSongStream.close();
    isPlayingStream.close();
  }
}
