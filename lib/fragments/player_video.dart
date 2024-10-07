import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../oki/import.dart';
import '../provider/import.dart';
import '../util/util.dart';

class PlayerVideo extends StatefulWidget {
  final MediaController player;
  final double? aspectRatio;
  const PlayerVideo({required this.player, this.aspectRatio, super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<PlayerVideo> {

  static const _log = Log('PlayerVideo');

  double? get aspectRatio => widget.aspectRatio;
  MediaController get player => widget.player;

  @override
  Widget build(BuildContext context) {
    // if (Platform.isWindows) {
    //   final size = player.player!.videoDimensions;
    //   var ratio = size.width / size.height;
    //   if (ratio.isNaN || ratio <= 0) ratio = 1;
    //
    //   return AspectRatio(
    //     aspectRatio: aspectRatio ?? ratio,
    //     child: Video(
    //       player: player.playerWindows,
    //       showControls: false,
    //     ),
    //   );
    // }

    return FutureBuilder(
      future: player.initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          _log.e('build', snapshot.error);
          return Center(
            child: OkiShadowText(idioma.erroOpenVideo),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return Video(
          key: ValueKey('${player.hashCode}'),
          controller: player.controller,
          aspectRatio: aspectRatio ?? player.ratio,
          controls: null,
        );
      },
    );
  }

}