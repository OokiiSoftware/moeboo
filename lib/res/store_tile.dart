import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import '../model/import.dart';
import '../oki/import.dart';

class StoreTile extends StatelessWidget{
  final Store store;
  final void Function(Store)? onTap;
  final void Function(Store)? onLongTap;
  const StoreTile({
    required this.store,
    this.onTap,
    this.onLongTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    int index = -1;
    return Hero(
      tag: store.hashCode,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 150,
          width: 100,
          margin: const EdgeInsets.all(1),
          child: GridTile(
            header: Row(
              children: store.posts.map((e) {
                index++;
                bool b = index < store.storePosition;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 3,
                        color: b ? tintColor : Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            footer: Padding(
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  color: backgroundColor.withOpacity(0.6),
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Center(
                    child: Text(
                      store.album.nome,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 13,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              // child: OkiShadowText(store.album.nome, maxLines: 1,),
            ),
            child: Card(
              margin: EdgeInsets.zero,
              color: Colors.grey,
              child: GestureDetector(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    fit: StackFit.passthrough,
                    children: [
                      getPostImage(store.current),

                      if (store.todosVistos)
                        Container(
                          height: 150,
                          width: 100,
                          color: Colors.white60,
                        ),
                    ],
                  ),
                ),
                onTap: () => onTap?.call(store),
                onLongPress: () => onLongTap?.call(store),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getPostImage(Post post) {
    Widget errorBuilder(c, o, e) => const Icon(Icons.image_not_supported_sharp, size: 100,);

    BoxFit boxFit = BoxFit.cover;

    return Image(
      image: NetworkToFileImage(
        url: post.previewUrl,
        file: post.previewFile,
        debug: showImagesDebugLogError,
        headers: post.booru.headers,
      ),
      errorBuilder: errorBuilder,
      fit: boxFit,
    );
  }
}