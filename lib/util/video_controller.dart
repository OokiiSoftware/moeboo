import 'dart:typed_data';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../model/import.dart';
import '../oki/import.dart';

class MediaController {

  static const _log = Log('VideoController');

  // final Post _post;

  final Player player = Player();
  late final controller = VideoController(player);

  MediaController();

  Future? initializeVideoPlayerFuture;

  Duration get _duration => Duration.zero;

  Duration get duration {
    return player.platform?.state.duration ?? _duration;
  }
  Duration get position {
    return player.platform?.state.position ?? _duration;
  }

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  void open({required String? url, bool mute = false, Map<String, String>? headers}) {
    // if (!_post.isVideo) return;

    // File? file;
    // String? url;

    // if (_post.hasPostSampleFile) {
    //   file = _post.postSampleFile;
    // } else if (_post.hasPostOriginalFile) {
    //   file = _post.postOriginalFile;
    // } else if ((_post.fileUrl?.contains('http')) ?? false) {
    //   url = _post.fileUrl;
    // }

    try {

      initializeVideoPlayerFuture = player.open(Media(url ?? '', httpHeaders: headers))
        ..then((e) {
          player.setPlaylistMode(PlaylistMode.loop);
          setMute(mute);
        _isLoaded = true;
      });
    } catch(e) {
      _log.e('initialize', e);
    }
  }

  void play() {
    player.play();
  }
  void pause() {
    player.pause();
  }
  void stop() {
    player.stop();
  }
  void playOrPause() {
    player.playOrPause();
  }

  void dispose() {
    player.dispose();
    _isLoaded = false;
  }

  void seek(Duration duration) {
    player.seek(duration);
  }

  void setMute(bool value) {
    player.setVolume(value ? 0 : 100);
  }

  Future<Uint8List?> takeSnapshot() async {
    return await player.screenshot();
  }

  bool get isPlaying {
    return player.platform?.state.playing ?? false;
  }

  double get ratio {
    return player.platform?.state.videoParams.aspect ?? 1/1;
  }

  Stream<Duration> get positionStream {
    return player.stream.position;
  }
}