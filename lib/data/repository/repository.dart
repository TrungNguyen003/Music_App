import 'package:untitled/data/model/song.dart';
import 'package:untitled/data/source/source.dart';

abstract interface class Repository {
  // ignore: non_constant_identifier_names
  Future<List<Song>?> LoadData();
}

class DefaultRepository implements Repository {
  final _localDataSource = LocalDataSource();
  final _remoteDataSource = RemoteDataSource();
  @override
  // ignore: non_constant_identifier_names
  Future<List<Song>?> LoadData() async {
    List<Song> songs = [];
    await _remoteDataSource.loadData().then((remoteSongs) => {
      if (remoteSongs == null)
        {
          _localDataSource.loadData().then((localSongs) => {
            if (localSongs != null) {songs.addAll(localSongs)}
          })
        }else{
        songs.addAll(remoteSongs)
      }
    });
    return songs;
  }
}
