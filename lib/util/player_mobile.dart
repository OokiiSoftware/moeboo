import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../oki/import.dart';

class PlayerMobile extends ChangeNotifier {

  static const _log = Log('PlayerMobile');

  final List<MediaMobile> videos;
  final Map<String, String>? headers;

  final Map<int, VideoPlayerController> _controllers = {};

  VideoPlayerController? get _controller => _controllers[_currentIndex];

  VideoPlayerController? get controller => _controller;

  VideoPlayerValue? get value => _controller?.value;
  Future<void>? initializeVideoPlayerFuture;

  MediaMobile get _currentVideo => videos[_currentIndex];

  bool get isPlaying => _controller?.value.isPlaying ?? false;

  int _currentIndex = 0;

  final PositionStateMobile position = PositionStateMobile();

  final StreamController<PositionStateMobile> positionController = StreamController<PositionStateMobile>.broadcast();
  late Stream<PositionStateMobile> positionStream;

  PlayerMobile({required this.videos, bool mute = false, this.headers}) {
    positionStream = positionController.stream;

    _onListener();
    initializeVideoPlayerFuture = controller?.initialize()?..then((value) {
      if (controller?.value.hasError ?? true) {
        throw(controller?.value.errorDescription ?? '');
      }
      play();
    });
    controller?.setLooping(true);
    controller?.setVolume(mute ? 0 : 100);
  }

  void _onListener() {
    if (_controller == null) {
      try {
        VideoPlayerController value;
        if (_currentVideo.isFile) {
          value = VideoPlayerController.file(_currentVideo.file!, httpHeaders: headers ?? const <String, String>{});
        } else {
          value = VideoPlayerController.networkUrl(Uri.parse(_currentVideo.url!), httpHeaders: headers ?? const <String, String>{});
        }

        value.addListener(() {
          position.position += const Duration(milliseconds: 300);

          if (!positionController.isClosed) {
            positionController.add(position);
          }
        });
        _controllers[_currentIndex] = value;

        notifyListeners();
      } catch(e) {
        _log.e('_onListener', e);
      }
    }
  }

  void play() {
    _controller?.play();
    notifyListeners();
  }

  void pause() {
    _controller?.pause();
    notifyListeners();
  }

  void playOrPause() {
    if (_controller?.value.isPlaying ?? false) {
      pause();
    } else {
      play();
    }
    notifyListeners();
  }

  void next() {
    _currentIndex++;
    if (_currentIndex >= videos.length) {
      _currentIndex = videos.length -1;
    }
    _onListener();
  }

  void back() {
    _currentIndex--;
    if (_currentIndex < 0) {
      _currentIndex = 0;
    }
    _onListener();
  }

  void jump(int index) {
    if (index < 0 || index >= videos.length) {
      throw('PlayerMobile > jump: index inválido');
    }

    _currentIndex = index;
    _onListener();
  }

  void seek(Duration duration) {
    _controller?.seekTo(duration);
    notifyListeners();
  }

  void setVolume(double volume) {
    _controller?.setVolume(volume);
    notifyListeners();
  }

  void setLoop(bool value) {
    _controller?.setLooping(value);
    notifyListeners();
  }

  Future<Uint8List> takeSnapshot() async {
    // return await _controller.takeSnapshot();
    throw ('Não implementado');
  }

  void add(MediaMobile source) {
    videos.add(source);
    notifyListeners();
  }

  void remove(int index) {
    videos.removeAt(index);
    notifyListeners();
  }

  @override
  void dispose() async {
    for(var c in _controllers.values) {
      await c.pause();
      await c.dispose();
    }
    _controllers.clear();
    videos.clear();
    positionController.close();

    super.dispose();
  }

}

class MediaMobile {
  File? file;
  String? url;

  bool get isFile => file != null;

  MediaMobile.file(this.file);

  MediaMobile.network(this.url);

}

class PositionStateMobile {
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
}