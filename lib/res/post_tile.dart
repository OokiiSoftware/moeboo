import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:flutter/material.dart';
import '../provider/idiona_provider.dart';
import '../util/util.dart';
import '../model/import.dart';
import '../oki/import.dart';
import 'import.dart';

class PostTile extends StatefulWidget {
  final PostG post;
  final bool showMarker;
  final void Function(PostG)? onTap;
  final void Function(PostG)? onDoubleTap;
  final void Function(PostG)? onLongTap;
  final void Function(PostG)? onLongTapUp;

  const PostTile({
    required this.post,
    this.showMarker = true,
    this.onTap,
    this.onDoubleTap,
    this.onLongTap,
    this.onLongTapUp,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _PostState();

}
class _PostState extends State<PostTile> {
  PostG get post => widget.post;
  bool get showMarker => widget.showMarker;
  void Function(PostG)? get onTap => widget.onTap;
  void Function(PostG)? get onDoubleTap => widget.onDoubleTap;
  void Function(PostG)? get onLongTap => widget.onLongTap;
  void Function(PostG)? get onLongTapUp => widget.onLongTapUp;

  String? albumTagHero;

  @override
  void dispose() {
    post.removeListener(_setState);
    // for (var p in post.posts) {
    //   p.removeListener(_setState);
    // }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (post.album.getPostAt(showOnline.value, 0)?.id == post.id) {
      albumTagHero = post.album.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      post.addListener(_setState);

      double markerRadius = 10;
      double? markerSize = _canShowMarker ? 20 : null;
      Color? markerColor = getPostMarkerColor();

      final item = post.currentPost;

      final ratio = item.aspectRatioPreview ?? item.aspectRatio;

      final child = Card(
        margin: EdgeInsets.zero,
        child: Hero(
          tag: albumTagHero ?? item.idName,
          child: GestureDetector(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Stack(
                alignment: AlignmentDirectional.center,
                fit: StackFit.passthrough,
                children: [
                  getPreviewImage(item),

                  if (markerSize != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(markerRadius/3),
                          topRight: Radius.circular(markerRadius),
                          bottomLeft: Radius.circular(markerRadius),
                          bottomRight: Radius.circular(markerRadius),
                        ),
                        child: Container(
                          width: markerSize,
                          height: markerSize,
                          color: markerColor,
                          child: post.isGroup ? Center(
                            child: Text(post.length.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ) : null,
                        ),
                      ),
                    ),

                  if (post.isVideo)
                    Center(
                      child: Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 70,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white70,
                          size: 30,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            onTap: () => onTap?.call(post),
            onDoubleTap: () => onDoubleTap?.call(post),
            onLongPress: () => onLongTap?.call(post),
            onLongPressUp: () => onLongTapUp?.call(post),
          ),
        ),
      );

      if (ratio == null) return child;

      return AspectRatio(
        aspectRatio: ratio,
        child: child,
      );
    } catch(e) {
      const Log('PostTile').e('build', e);
      return AspectRatio(
        aspectRatio: 1 / 1,
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.grey, BlendMode.srcOut,
          ),
          child: Container(
            alignment: Alignment.center,
            color: Colors.transparent,
            padding: const EdgeInsets.all(10),
            child: Text(idioma.postIndisponivel,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget getPreviewImage(Post post) {
    BoxFit boxFit = BoxFit.cover;
    double dif = 0;
    double scale = 1;

    if (post.booru.isEHentai) {
      boxFit = BoxFit.none;
      int pos = (post.previewIndex ?? 0);
      int len = post.previewLength ?? 0;

      if (len >= 2) {
        dif = 2 / (len -1);
      } else if (len == 1) {
        dif = 2 / (len);
      }

      if (pos != 0) {
        // transforma por ex: 100 => 1
        pos = int.parse('$pos'.replaceAll('00', ''));
      }

      dif = (pos * dif) -1;
      scale = ((post.previewHeight ?? 0) * 0.525) / (post.maiorHeight ?? 150);
      var scaleW = .17 / ((post.previewHeight ?? 150) / (post.previewWidth ?? 100));
      scale -= scaleW;//-.21
    }

    final alignment = Alignment(dif, -1);

    final widget = Image(
      alignment: alignment,
      errorBuilder: imageErrorBuilder,
      loadingBuilder: (c, w, e) {
        if (post.hasPreviewCacheFile) {
          if (e == null) {
            post.computeDimensionPreview();
            return w;
          }
        }

        if (e == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final progress = e.cumulativeBytesLoaded / (e.expectedTotalBytes ?? 1);
        return Center(
          child: CircularProgressIndicator(value: progress),
        );
      },
      fit: boxFit,
      image: NetworkToFileImage(
        url: post.previewUrl,
        file: post.previewFile,
        headers: post.booru.headers,
        scale: scale,
      ),
    );

    if (post.isSalvo) {
      return Image(
        alignment: alignment,
        errorBuilder: (a, b, c) => widget,
        fit: boxFit,
        image: FileImage(
          post.previewSalvoFile,
          scale: scale,
        ),
      );
    }

    return widget;
  }

  Color? getPostMarkerColor() {
    int savedCount = post.savedCount;
    if (post.isSelected) return Colors.red;

    if (savedCount == post.length) return Colors.greenAccent;

    if (savedCount > 0) return Colors.green;

    if (post.length > 1) return Colors.cyanAccent;

    return null;
  }

  bool get _canShowMarker {
    if (post.isGroup || post.isSelected) return true;

    if (post.isAnalizing) return false;

    if (showMarker) return true;

    return false;
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}
