import 'package:msapp/data/model/song.dart';
import 'package:msapp/data/source/source.dart';

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
    try {
      final remoteSongs = await _remoteDataSource.loadData();
      if (remoteSongs != null && remoteSongs.isNotEmpty) {
        return remoteSongs;
      }
    } catch (e) {
      print('Remote data source error: $e');
    }
    
    try {
      final localSongs = await _localDataSource.loadData();
      if (localSongs != null && localSongs.isNotEmpty) {
        return localSongs;
      }
    } catch (e) {
      print('Local data source error: $e');
    }
    
    return [];
  }
}
