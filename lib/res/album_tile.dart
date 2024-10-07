import 'dart:io';
import 'package:flutter/material.dart';
import '../model/import.dart';
import '../oki/import.dart';
import 'import.dart';

class AlbumTile extends StatefulWidget {
  final Album album;
  final bool useKey;
  final Function(Album)? onClick;
  final Function(Album)? onLongClick;

  const AlbumTile({
    required this.album,
    this.useKey = true,
    this.onClick,
    this.onLongClick,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AlbumState();
}
class _AlbumState extends State<AlbumTile> {
  Album get album => widget.album;
  bool get useKey => widget.useKey;
  void Function(Album)? get onClick => widget.onClick;
  void Function(Album)? get onLongClick => widget.onLongClick;

  @override
  void dispose() {
    super.dispose();
    album.removeListener(_setState);
  }

  @override
  void initState() {
    super.initState();
    album.addListener(_setState);
  }

  @override
  Widget build(BuildContext context) {
    final isCollection = album.isCollection;

    Color backColor = isCollection ? Colors.white.withOpacity(0.9) : const Color.fromRGBO(46, 46, 46, 0.9);
    Color textColor = isCollection ? Colors.black : Colors.white;

    final auth = AuthManager.auth;

    return Hero(
      tag: album.id,
      key: useKey ? album.key : null,
      child: GestureDetector(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.passthrough,
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                getCapa(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: backColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Center(
                            child: Text(
                              album.nome,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 18,
                                color: textColor,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),  // Title

                if (album.isOculto && auth.isAuthEnabled && auth.isAuthenticated)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(blurRadius: 45,)
                        ],
                      ),
                      child: const Icon(Icons.visibility_off, color: Colors.white,),
                    ),
                  ),  // HideIcon
              ],
            ),
          ),
        ),
        onTap: () => onClick?.call(album),
        onLongPress: () => onLongClick?.call(album),
      ),
    );
  }

  Widget getCapa() {
    final capa = album.capa ?? '';
    BoxFit boxFit = BoxFit.cover;

    if (capa.isEmpty) {
      return imageErrorBuilder(context, 0, 0);
    }

    if (capa.contains(Ressources.appName)) {
      return Image.file(File(capa),
        errorBuilder: imageErrorBuilder,
        fit: boxFit,
      );
    }

    return Image(
      image: NetworkImage(capa),
      errorBuilder: imageErrorBuilder,
      fit: boxFit,
    );
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}
