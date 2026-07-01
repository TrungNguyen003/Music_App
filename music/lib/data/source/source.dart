import 'dart:convert';

import 'package:msapp/data/model/song.dart';
import 'package:http/http.dart' as http;

abstract interface class DataSource {
  Future<List<Song>?> loadData();
}

class RemoteDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    try {
      // Dùng backend proxy (localhost:3000/api/songs)
      final uri = Uri.parse("http://localhost:3000/api/songs");
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final bodyContent = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(bodyContent) as Map;
        final songList = (jsonData['songs'] as List?) ?? [];
        
        List<Song> songs = songList
            .map((song) => Song.fromJson(song as Map<String, dynamic>))
            .toList();
        return songs;
      } else {
        print('API Error: Status ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      print('RemoteDataSource Error: $e');
      print('StackTrace: $stackTrace');
      return null;
    }
  }
}

class LocalDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    // Placeholder implementation - returns null for now
    // In a real app, this would load from local storage
    return null;
  }
}
