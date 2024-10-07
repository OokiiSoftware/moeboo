import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../provider/idiona_provider.dart';
import '../model/import.dart';
import '../res/import.dart';

class AlbunsFragment extends StatelessWidget {
  final List<Album> albuns;
  final bool gridMode;
  final bool canAddAlbum;
  final bool useKey;
  final ScrollController? controller;
  final void Function(Album)? onItemClick;
  final void Function(Album)? onItemLongClick;
  final void Function([Album?])? onAddFolderClick;

  const AlbunsFragment({
    required this.albuns,
    this.gridMode = true,
    this.canAddAlbum = true,
    this.useKey = true,
    this.controller,
    this.onItemClick,
    this.onItemLongClick,
    this.onAddFolderClick,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    bool isPortrait = query.orientation == Orientation.portrait;

    if (albuns.isEmpty && canAddAlbum) {
      return GestureDetector(
        onTap: onAddFolderClick,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            height: query.size.height - 80,
            color: Colors.transparent,
            child: Center(
              child: Text('+ ${idioma.addPasta}'),
            ),
          ),
        ),
      );
    }

    if (gridMode) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        itemCount: albuns.length,
        controller: controller,
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
          childAspectRatio: 1/1.4,
        ),
        itemBuilder: (context, index) => _getLayout(index),
      );
    }

    return MasonryGridView.count(
      padding: EdgeInsets.zero,
      itemCount: albuns.length,
      controller: controller,
      shrinkWrap: true,
      itemBuilder: (context, index) => _getLayout(index),
      crossAxisCount: isPortrait ? 2 : 3,
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
    );
  }

  Widget _getLayout(int index) {
    var item = albuns[index];

    return AlbumTile(
      album: item,
      useKey: useKey,
      onClick: onItemClick,
      onLongClick: onItemLongClick,
    );
  }
}