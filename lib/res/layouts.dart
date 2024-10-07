import 'dart:io';
import 'package:flutter/material.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import '../util/util.dart';
import '../provider/import.dart';
import '../booru/import.dart';
import '../model/import.dart';
import '../oki/import.dart';
import 'import.dart';

Map<String, IconData> _menuIcon(BuildContext context) {

  ILanguage ui = idioma;

  return {
    ui.fechar: Icons.close,
    ui.novoAlbum: Icons.create_new_folder_rounded,
    ui.capaAlbum: Icons.image_outlined,
    ui.wallpaper: Icons.smartphone,
    ui.findParents: Icons.join_full,
    ui.refreshPost: Icons.replay_circle_filled_rounded,
    ui.refreshGroup: Icons.replay_circle_filled_rounded,
    ui.share: Icons.share,
    ui.analizarGrupo: Icons.saved_search,
    ui.openLink: Icons.open_in_browser,
    ui.excluirImagem: Icons.delete_outlined,
    ui.unirPosts: Icons.join_inner,
    ui.removeDoGrupo: Icons.remove_circle_outline,

    ui.tagsCount: Icons.looks_one_outlined,
    ui.postsSalvos: Icons.style,
    ui.favoritos: Icons.favorite,
    ui.editarAlbum: Icons.edit_outlined,
    ui.salvarAlbum: Icons.save_outlined,
    ui.excluirAlbum: Icons.delete_forever_outlined,
    ui.moverAlbum: Icons.drive_file_move_outline,
    ui.unirAlbuns: Icons.join_full,
    ui.ocultarAlbum: Icons.visibility_off,
    ui.desocultarAlbum: Icons.visibility,
    ui.resetCapa: Icons.refresh,
    ui.goToPage: Icons.pageview_outlined,
    ui.useAlbumAsCapa: Icons.call_to_action_outlined,
    ui.filtro: Icons.filter_alt_outlined,
    ui.config: Icons.settings_outlined,
    ui.info: Icons.info_outlined,
    ui.recriarMiniatura: Icons.image_outlined,
    ui.sobrescrever: Icons.reply_all,
    ui.updatePosts: Icons.refresh,
    ui.maturidade: Icons.whatshot_outlined,
    '': Icons.tag,
  };
}

class MenuIcon extends StatelessWidget {
  final String value;
  final Color? color;
  final double? size;
  const MenuIcon(this.value, {this.color, this.size, super.key});

  @override
  Widget build(BuildContext context) {
    IconData? data = _menuIcon(context)[value];

    for (var bName in Boorus.allValues.values) {
      if (bName.name == value) {
        data = Icons.wb_sunny;
        break;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (data != null)
          Icon(data, color: color, size: size,),
      ],
    );
  }
}

class ImageWidet extends StatelessWidget {
  final Post post;
  final int? index;
  final void Function(Post)? onLoadComplete;
  final void Function(ImageChunkEvent)? loadingProgress;
  const ImageWidet({required this.post, this.index, this.onLoadComplete, this.loadingProgress, super.key});

  @override
  Widget build(BuildContext context) {
    // print(item.previewUrl);
    // print(item.sampleUrl);
    // print(item.fileUrl);

    Map<String, String>? headers = post.booru.headers;

    // ImageProvider compressedProvider() => FileImage(post.postCompressedFile);
    ImageProvider sampleProvider() => NetworkToFileImage(
      url: post.sampleUrl,
      file: post.postSampleFile,
      debug: showImagesDebugLogError,
      headers: headers,
    );
    ImageProvider originalProvider() => NetworkToFileImage(
      url: post.fileUrl,
      file: post.postOriginalFile,
      debug: showImagesDebugLogError,
      headers: headers,
    );

    Widget loading(c, w, p) => LoadingBuilder(
      widget: w,
      event: p,
      post: post,
      onProgress: loadingProgress,
      onComplete: onLoadComplete,
    );
    Widget widget(ImageProvider provider, [Widget? onError]) {
      return Center(
        child: Image(
          image: provider,
          fit:BoxFit.fitWidth,
          loadingBuilder: loading,
          errorBuilder: (c, o, e) {
            if (post.isVideo && post.hasAnyFile) {
              return imageErrorBuilder(c, o, e);
            }

            return onError ?? imageErrorBuilder(c, o, e);
          },
        ),
      );
    }

    Widget auto() => widget(sampleProvider(), widget(originalProvider()));

    if (post.isSalvo) {
      return Center(
        key: ValueKey(post.id),
        child: Image(
          image: FileImage(post.postSalvoFile),
          fit:BoxFit.fitWidth,
          errorBuilder: (c, o, e) => auto(),
          loadingBuilder: loading,
        ),
      );
    }

    Widget original() => widget(originalProvider());
    Widget sample() => widget(sampleProvider());

    switch (index) {
      case 0:
        return sample();
      case 1:
        return original();
      default:
        return auto();
    }
  }
}

class LoadingBuilder extends StatelessWidget {
  final Widget widget;
  final Post post;
  final ImageChunkEvent? event;
  final void Function(Post)? onComplete;
  final void Function(ImageChunkEvent)? onProgress;

  const LoadingBuilder({
    super.key,
    required this.widget,
    required this.post,
    this.event,
    this.onComplete,
    this.onProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (post.hasAnyFile) {
      if (event == null) {
        onComplete?.call(post);
      }
      return widget;
    }

    if (event == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final progress = event!.cumulativeBytesLoaded / (event!.expectedTotalBytes ?? 1);

    onProgress?.call(event!);

    return Center(
      child: Stack(
        children: [
          Center(
            child: Image(
              image: NetworkToFileImage(
                url: post.previewUrl,
                file: post.previewFile,
                headers: post.booru.headers,
              ),
              fit: BoxFit.fill,
              errorBuilder: (c, o, e) => const Icon(Icons.image_not_supported_sharp, size: 100,),
            ),
          ),
          LinearProgressIndicator(value: progress),
        ],
      ),
    );
  }
}


class TagsListView extends StatelessWidget {
  //region variaveis
  final Post post;
  final void Function(Tag)? onTap;
  final void Function(Tag)? onLongPress;
  final void Function(Tag)? onAddClick;
  final void Function(Tag)? onRemoveClick;
  final Color? textColor;
  final Color? backgroundColor;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  const TagsListView({
    required this.post,
    this.backgroundColor,
    this.onTap,
    this.onLongPress,
    this.onAddClick,
    this.onRemoveClick,
    this.controller,
    this.textColor,
    this.physics,
    super.key});
  //endregion

  @override
  Widget build(BuildContext context) {
    final tags = [...post.tags];
    final Future<List<Tag>> future = Future<List<Tag>>.delayed(const Duration(), () async {
      Map<String, Tag> items = {};

      int id = 0;
      for (var tag in tags) {
        items['$id'] = Tag(name: tag, id: id);
        id++;
      }

      return items.values.toList();
    });

    return FutureBuilder<List<Tag>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child:  CircularProgressIndicator(),
          );
        }

        final tags = snapshot.data;
        return Container(
          color: backgroundColor,
          child: SafeArea(
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: Text(idioma.detalhes)),

                        DataTable(
                          dataRowMaxHeight: 30,
                          dataRowMinHeight: 10,
                          dividerThickness: 0.5,
                          headingRowHeight: 5,
                          columns: const [
                            DataColumn(label: Text('')),
                            DataColumn(label: Text('')),
                          ],
                          rows: [
                            DataRow(
                              cells: [
                                DataCell(Text(idioma.tipo)),
                                DataCell(Text('${post.fileExt?.toUpperCase()}')),
                              ],
                            ),
                            DataRow(
                              cells: [
                                DataCell(Text(idioma.dimensao)),
                                DataCell(Text('${post.width} X ${post.height}')),
                              ],
                            ),
                            DataRow(
                              cells: [
                                const DataCell(Text('Original')),
                                DataCell(Text(post.originalSizeName())),
                              ],
                            ),
                            DataRow(
                              cells: [
                                const DataCell(Text('Sample')),
                                DataCell(Text(post.sampleSizeName())),
                              ],
                            ),
                            if (AuthManager.auth.isAuthenticated && !isPlayStory)
                              DataRow(
                                cells: [
                                  DataCell(Text(idioma.maturidade)),
                                  DataCell(Text('${post.rating}')),
                                ],
                              ),
                            if (post.isFavorito || post.isSalvo)...[
                              DataRow(
                                cells: [
                                  const DataCell(Text('Album')),
                                  DataCell(Text(post.album.nome)),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(Text('Provider')),
                                  DataCell(Text(post.booru.name)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),  // Detalhes

                const Center(
                  child: Text('Tags',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: Platform.isWindows,
                    controller: controller,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 40),
                      controller: controller,
                      itemCount: tags!.length,
                      physics: physics,
                      itemBuilder: (context, index) {
                        var item = tags[index];
                        return TagTile(
                          tag: item,
                          textColor: textColor,
                          onTap: onTap,
                          onLongPress: onLongPress,
                          onAddClick: onAddClick,
                          onRemoveClick: onRemoveClick,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget getImageWidget(Map map) {
  String booruName = map['booruName'];
  String previewUrl = map['previewUrl'];
  int? previewIndex = map['previewIndex'];
  int? previewLength = map['previewLength'];
  File previewCompressedCacheFile = map['previewCompressedCacheFile'];
  File previewCompressedFile = map['previewCompressedFile'];
  File previewCacheFile = map['previewCacheFile'];

  BoxFit boxFit = BoxFit.cover;
  double dif = 0;

  if (booruName == EHentai.name_) {
    int pos = previewIndex ?? 0;
    int len = previewLength ?? 0;
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
    // print('$pos, $len, $mid, $i');
  }

  final alignment = Alignment(dif, 0);

  return Image.file(
    previewCompressedCacheFile,
    alignment: alignment,
    fit: boxFit,
    errorBuilder: (c, o, e) {
      return Image.file(
        previewCompressedFile,
        alignment: alignment,
        fit: boxFit,
        errorBuilder: (c, o, e) {
          return Image(
            alignment: alignment,
            errorBuilder: imageErrorBuilder,
            fit: boxFit,
            image: NetworkToFileImage(
              url: previewUrl,
              file: previewCacheFile,
            ),
          );
        },
      );
    },
  );
}

Widget imageErrorBuilder(c, o, e) {
  const size = 80.0;
  return Stack(
    alignment: Alignment.center,
    children: [
      Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(Assets.icLauncher,
            width: size,
            height: size,
          ),
        ),
      ),

      Center(
        child: Transform.rotate(
          angle: 0.8,
          child: Text(idioma.noImage,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                BoxShadow(
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
