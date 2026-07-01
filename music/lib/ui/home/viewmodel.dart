import 'dart:async';

import 'package:msapp/data/repository/repository.dart';

import '../../data/model/song.dart';

class MusicAppViewModel {
  StreamController<List<Song>> songStream = StreamController();


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
}
