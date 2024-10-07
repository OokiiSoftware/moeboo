// import 'dart:io';
// import 'dart:typed_data';
// import '../model/import.dart';
// import '../oki/import.dart';
// import 'util.dart';
//
// class VideoController {
//
//   static const _log = Log('VideoController');
//
//   final Post _post;
//
//   late PlayerMobile? playerMobile;
//   Player? playerWindows;
//
//   final _isWindows = Platform.isWindows;
//
//   Future<void>? _initializeVideoPlayerFutureDesktop;
//
//   Future<void>? get initializeVideoPlayerFuture {
//     if (_isWindows) {
//       return _initializeVideoPlayerFutureDesktop;
//     } else {
//       return playerMobile?.initializeVideoPlayerFuture;
//     }
//   }
//
//   VideoController(this._post);
//
//   Duration get _duration => Duration.zero;
//
//   Duration get duration {
//     if (_isWindows) {
//       return playerWindows?.position.duration ?? _duration;
//     }
//     return playerMobile?.value?.duration ?? _duration;
//   }
//   Duration get position {
//     if (_isWindows) {
//       return playerWindows?.position.position ?? _duration;
//     }
//     return playerMobile?.value?.position ?? _duration;
//   }
//
//   bool _isLoaded = false;
//   bool get isLoaded => _isLoaded;
//
//   void initialize({bool mute = false, Map<String, String>? headers}) {
//     if (!_post.isVideo) return;
//
//     File? file;
//     String? url;
//
//     if (_post.hasPostSampleFile) {
//       file = _post.postSampleFile;
//     } else if (_post.hasPostOriginalFile) {
//       file = _post.postOriginalFile;
//     } else if ((_post.fileUrl?.contains('http')) ?? false) {
//       url = _post.fileUrl;
//     }
//
//     try {
//       if (_isWindows) {
//         playerWindows = Player(id: randomInt());
//         playerWindows?.open(
//           Playlist(
//             medias: [
//               if (file != null)
//                 Media.file(file),
//               if (url != null)
//                 Media.network(url),
//             ],
//           ),
//         );
//         playerWindows?.setPlaylistMode(PlaylistMode.repeat);
//         playerWindows?.setVolume(mute ? 0 : 100);
//       } else {
//         playerMobile = PlayerMobile(
//           headers: headers,
//           mute: mute,
//           videos: [
//             if (file != null)
//               MediaMobile.file(file),
//             if (url != null)
//               MediaMobile.network(url),
//           ],
//         );
//       }
//       _isLoaded = true;
//     } catch(e) {
//       _log.e('initialize', e);
//     }
//   }
//
//   void play() {
//     _isWindows ? playerWindows?.play() : playerMobile?.play();
//   }
//   void pause() {
//     _isWindows ? playerWindows?.pause() : playerMobile?.pause();
//   }
//   void stop() {
//     _isWindows ? playerWindows?.stop() : playerMobile?.pause();
//   }
//   void playOrPause() {
//     _isWindows ? playerWindows?.playOrPause() : playerMobile?.playOrPause();
//   }
//
//   void dispose() {
//     _isWindows ? playerWindows?.dispose() : playerMobile?.dispose();
//     _isLoaded = false;
//   }
//
//   void seek(Duration duration) {
//     _isWindows ? playerWindows?.seek(duration) : playerMobile?.seek(duration);
//   }
//
//   void setMute(bool value) {
//     _isWindows ? playerWindows?.setVolume(value ? 0 : 100) : playerMobile?.setVolume(value ? 0 : 100);
//   }
//
//   Future<Uint8List?> takeSnapshot() async {
//     if (_isWindows) {
//       final file = File('temp.jpg');
//       playerWindows?.takeSnapshot(file, _post.width ?? 0, _post.height ?? 0);
//       return await file.readAsBytes();
//     } else {
//       return await playerMobile?.takeSnapshot();
//     }
//   }
//
//   bool get isPlaying {
//     if (_isWindows) {
//       return playerWindows?.playback.isPlaying ?? false;
//     } else {
//       return playerMobile?.isPlaying ?? false;
//     }
//   }
//   bool get isInitialized {
//     if (!_isLoaded) return false;
//
//     if (_isWindows) {
//       return playerWindows?.playback.isSeekable ?? false;
//     } else {
//       return playerMobile?.value?.isInitialized ?? false;
//     }
//   }
//
//   Stream<dynamic> get positionStream {
//     if (_isWindows) {
//       return playerWindows!.positionStream;
//     } else {
//       return playerMobile!.positionStream;
//     }
//   }
// }