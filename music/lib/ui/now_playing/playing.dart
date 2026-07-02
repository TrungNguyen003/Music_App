import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../data/model/song.dart';
import '../../data/user_manager.dart';
import 'audio_player_manager.dart';
import '../user/user.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      songs: songs,
      playingSong: playingSong,
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key, required this.songs, required this.playingSong});

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimationController;
  late AudioPlayerManager _audioPlayerManager;
  Song? _currentSong;
  bool _isShuffleEnabled = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _imageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _audioPlayerManager = AudioPlayerManager();
    _currentSong = widget.playingSong;
    final index = widget.songs.indexOf(widget.playingSong);
    _audioPlayerManager.init(widget.songs, index);
    _imageAnimationController.repeat();
    
    _audioPlayerManager.currentSongStream.listen((song) {
      if (mounted) {
        setState(() {
          _currentSong = song;
          _checkFavorite();
        });
      }
    });
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    if (UserManager.loggedInEmail == null || _currentSong == null) return;
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/favorites/${UserManager.loggedInEmail}'));
      if (response.statusCode == 200) {
        final List<dynamic> favorites = jsonDecode(response.body);
        setState(() {
          _isFavorite = favorites.contains(_currentSong!.id);
        });
      }
    } catch (e) {
      print('Error checking favorite: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (UserManager.loggedInEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập để yêu thích')));
      return;
    }
    
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/favorites'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': UserManager.loggedInEmail, 'songId': _currentSong!.id}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isFavorite = data['isFavorite'];
        });
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSong == null) return const SizedBox.shrink();
    
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Now Playing'),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ),
        child: Scaffold(
          body: SingleChildScrollView(
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
               Text(_currentSong!.album),
               const SizedBox(height: 16),
               Text('_ ___ _'),
               const SizedBox(
                 height: 48,
               ),
               RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0)
                      .animate(_imageAnimationController),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/hinhnen.jpg',
                       image: 'http://localhost:3000/api/image?url=${Uri.encodeComponent(_currentSong!.image)}',
                      width: screenWidth - delta,
                      height: screenWidth - delta,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/hinhnen.jpg',
                          width: screenWidth - delta,
                          height: screenWidth - delta,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 64, bottom: 16),
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.share_outlined),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Column(
                          children: [
                            Text(
                              _currentSong!.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentSong!.artist,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_outline,
                            color: _isFavorite ? Colors.red : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 32,
                    left: 24,
                    right: 24,
                    bottom: 16,
                  ),
                  child: _progressBar(),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                    left: 24,
                    right: 24,
                  ),
                  child: _mediaButtons(),
                ),
              ],
             ),
           ),
         ),
        ));
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(progress: progress, total: total);
        });
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final playing = playState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.play();
              },
              icon: Icons.play_arrow,
              color: null,
              size: 48
          );
        }else if(processingState != ProcessingState.completed){
          return MediaButtonControl(function: (){
            _audioPlayerManager.player.pause();
          }, icon: Icons.pause, color: null, size: 48
          );
        }else{
          return MediaButtonControl(function: (){
            _audioPlayerManager.player.seek(Duration.zero);
          }, icon: Icons.replay, color: null, size: 48);
        }
      },
    );
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
              function: () {
                setState(() {
                  _isShuffleEnabled = !_isShuffleEnabled;
                });
                _audioPlayerManager.setShuffleMode(_isShuffleEnabled);
              },
              icon: Icons.shuffle,
              color: _isShuffleEnabled ? Colors.deepPurple : Colors.grey,
              size: 24),
          MediaButtonControl(
              function: () {
                _audioPlayerManager.playPrevious();
              },
              icon: Icons.skip_previous,
              color: Colors.deepPurple,
              size: 36),
          _playButton(),
          MediaButtonControl(
              function: () {
                _audioPlayerManager.playNext();
              },
              icon: Icons.skip_next,
              color: Colors.deepPurple,
              size: 36),
          MediaButtonControl(
              function: () {
                _audioPlayerManager.setRepeatMode(LoopMode.one);
              },
              icon: Icons.repeat,
              color: Colors.deepPurple,
              size: 24)
        ],
      ),
    );
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
