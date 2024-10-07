import 'package:flutter/material.dart';
import '../fragments/import.dart';
import '../provider/import.dart';
import '../pages/import.dart';
import '../model/import.dart';
import 'import.dart';
import '../oki/import.dart';

class DataSearch extends SearchDelegate<String> {

  AlbunsProvider get albunsMng => AlbunsProvider.i;
  final List<Album> listResults = [];

  // @override
  // String get searchFieldLabel => Strings.pesquisar;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeManager.i.themeData();
  }

  @override
  List<Widget> buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (listResults.isEmpty) {
      Navigator.pop(context);
    }
    return results();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    listResults.clear();
    if (query.isNotEmpty) {
      listResults.addAll(albunsMng.find(query));
    }

    return results();
  }

  Widget results() {
    return StatefulBuilder(
      builder: (context, setState) => AlbunsFragment(
        albuns: listResults,
        canAddAlbum: false,
        useKey: false,
        onItemClick: (album, [w]) async {
          if (!album.isCollection && isUnindoAlbum) {
            await PopupAlbumOptions(context, album).onUnirClick();
          } else if (album.isCollection) {
            await Navigate.push(context, AlbumCollectionPage(album: album));
          } else {
            await Navigate.push(context, AlbumPage(album: album));
          }
          query = query;
          setState(() {});
        },
        onItemLongClick: (album) async {
          await PopupAlbumOptions(context, album).show();
          query = query;
          setState(() {});
        },
      ),
    );
  }
}