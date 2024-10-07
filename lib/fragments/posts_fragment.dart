import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../provider/import.dart';
import '../model/import.dart';
import '../oki/import.dart';
import '../res/import.dart';

class PostsFragment extends StatelessWidget {
  final List<PostG> posts;
  final Widget Function(PostG) builder;

  final void Function()? onEditTap;
  final void Function()? onDeleteTap;

  final ScrollController? controller;

  final bool showOnline;
  final bool showBooruOptions;
  final bool gridMode;

  const PostsFragment({
    super.key,
    required this.posts,
    required this.builder,
    this.controller,
    this.gridMode = false,
    this.showOnline = false,
    this.showBooruOptions = false,
    this.onEditTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      if (showBooruOptions) {
        return _booruOptions(context);
      }
      return const Center(child: Text(''),);
    }

    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isWindows = Platform.isWindows;

    int crossAxisCount = isPortrait ? 2 : isWindows ? 5 : 3;

    if (gridMode) {
      return GridView.builder(
        itemCount: posts.length,
        controller: controller,
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 50),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
          childAspectRatio: 1/1.4,
        ),
        itemBuilder: (context, index) => builder(posts[index]),
      );
    }

    return MasonryGridView.count(
      itemCount: posts.length,
      controller: controller,
      shrinkWrap: true,
      // physics: const BouncingScrollPhysics(
      //   parent: AlwaysScrollableScrollPhysics(),
      // ),
      padding: EdgeInsets.only(bottom: 50, top: isWindows ? 80 : 110),
      itemBuilder: (context, index) => builder(posts[index]),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
    );
  }

  Widget _booruOptions(BuildContext context) {
    Map<int, String> teste = {};
    for (int i = 0; i < Boorus.list.length; i++) {
      teste[i] = Boorus.list[i].name;
    }

    void onBooruselect(int i) {
      var temp = Boorus.get(teste[i]);
      if (temp != null) {
        BooruProvider.i.setBooru(temp);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 110),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${idioma.semResult} ',
                  style: const TextStyle(fontSize: 18),
                ),
                const Icon(Icons.info_outline, size: 20,),
              ],
            ),
            if (showOnline)...[ // showMarker = showOnline
              const SizedBox(height: 20,),

              Text(idioma.tenteOutroProvedor,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        ListTile(
                          title: Align(
                            alignment: Alignment.centerRight,
                            child: Text(idioma.editarAlbum),
                          ),
                          trailing: MenuIcon(idioma.editarAlbum),
                          // subtitle: Align(
                          //   alignment: Alignment.centerRight,
                          //   child: Text(menuSubtitle(Menus.editarAlbum)),
                          // ),
                          onTap: onEditTap,
                        ),

                        const Divider(),

                        for (int i = 0; i < teste.length ~/ 2; i++)
                          ListTile(
                            title: Center(
                              child: Text(teste[i] ?? '',
                                style: TextStyle(
                                  color: Boorus.list[i].name == currentBooru ? disabledTextColor : null,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            onTap: Boorus.list[i].name == currentBooru ? null : () => onBooruselect(i),
                          ),

                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(idioma.excluirAlbum),
                          leading: MenuIcon(idioma.excluirAlbum),
                          // subtitle: Text(menuSubtitle(Menus.excluirAlbum)),
                          onTap: onDeleteTap,
                        ),

                        const Divider(),

                        for (int i = teste.length ~/ 2; i < teste.length; i++)
                          ListTile(
                            title: Center(
                              child: Text(teste[i] ?? '',
                                style: TextStyle(
                                  color: Boorus.list[i].name == currentBooru ? disabledTextColor : null,
                                  fontSize: 18
                                ),
                              ),
                            ),
                            onTap: Boorus.list[i].name == currentBooru? null : () => onBooruselect(i),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
