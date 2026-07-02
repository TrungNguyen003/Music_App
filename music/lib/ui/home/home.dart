import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:msapp/ui/discovery/discovery.dart';
import 'package:msapp/ui/home/viewmodel.dart';
import 'package:msapp/ui/settings/settings.dart';
import 'package:msapp/ui/user/user.dart';
import 'package:msapp/ui/mini_player/mini_player.dart';
import 'package:msapp/ui/now_playing/audio_player_manager.dart';
import '../../data/model/song.dart';
import '../now_playing/playing.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const SettingsTab(),
    const AccountTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Music App'),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.album), label: 'Discovery'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: getBody(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: StreamBuilder<Song?>(
              stream: AudioPlayerManager().currentSongStream,
              builder: (context, currentSongSnapshot) {
                return StreamBuilder<bool>(
                  stream: _viewModel.isPlayingStream.stream,
                  builder: (context, isPlayingSnapshot) {
                    return MiniPlayer(
                      currentSong: currentSongSnapshot.data,
                      isPlaying: isPlayingSnapshot.data ?? false,
                      onPlayPause: () async {
                        _viewModel.togglePlayPause();
                        if (_viewModel.isPlaying) {
                          await AudioPlayerManager().player.play();
                        } else {
                          await AudioPlayerManager().player.pause();
                        }
                        setState(() {});
                      },
                      onTap: () {
                        if (currentSongSnapshot.data != null) {
                          navigate(currentSongSnapshot.data!);
                        }
                      },
                      onClose: () async {
                        await AudioPlayerManager().stop();
                        _viewModel.stopSong();
                        setState(() {});
                      },
                      onNext: () {
                        AudioPlayerManager().playNext();
                      },
                      onPrevious: () {
                        AudioPlayerManager().playPrevious();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length,
      padding: const EdgeInsets.only(top: 20, bottom: 80),
    );
  }

  Widget getRow(int index) {
    return _SongItemSection(parent: this, song: songs[index]);
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      print('Songs loaded: ${songList.length}');
      setState(() {
        songs.addAll(songList);
      });
    }, onError: (error) {
      print('Stream error: $error');
    });
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 400,
              color: Colors.grey,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Model bottom sheet'),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('close bottom sheet'),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void navigate(Song song) {
    _viewModel.playSong(song);
    AudioPlayerManager().player.play();
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(
        songs: songs,
        playingSong: song,
      );
    }));
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.parent,
    required this.song,
  });

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    print('Song image URL: ${song.image}');
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 8,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          'http://localhost:3000/api/image?url=${Uri.encodeComponent(song.image)}',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 48,
              height: 48,
              color: Colors.grey[300],
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image $error');
            return Image.asset(
              'assets/hinhnen.jpg',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
      title: Text(
        song.title,
      ),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {
          parent.showBottomSheet();
        },
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}
