import 'package:flutter/material.dart';
import '../util/util.dart';
import '../res/import.dart';
import '../provider/import.dart';
import '../booru/import.dart';
import '../model/import.dart';
import '../oki/import.dart';
import '../pages/import.dart';

AlbunsProvider get _albunsMng => AlbunsProvider.i;
BooruProvider get _booru => BooruProvider.i;

class PopupAlbumOptions {
  final BuildContext context;
  final Album album;

  PopupAlbumOptions(this.context, this.album);

  Future<dynamic> show() async {
    ILanguage ui = idioma;

    final auth = AuthManager.auth;
    final isOculto = album.isOculto;

    var result = await DialogBox(
      context: context,
      title: album.nome,
      content: [
        ListTile(
          title: Text(ui.editarAlbum),
          leading: MenuIcon(ui.editarAlbum),
          onTap: () => Navigator.pop(context, DialogResult(1)),
        ), // 1
        ListTile(
          title: Text(ui.excluirAlbum),
          leading: MenuIcon(ui.excluirAlbum),
          onTap: () => Navigator.pop(context, DialogResult(2)),
        ), // 2
        ListTile(
          title: Text(ui.moverAlbum),
          leading: MenuIcon(ui.moverAlbum),
          onTap: () => Navigator.pop(context, DialogResult(3)),
        ), // 3

        if (!album.isCollection)
          ListTile(
            title: Text(ui.unirAlbuns),
            leading: MenuIcon(ui.unirAlbuns),
            onTap: () => Navigator.pop(context, DialogResult(12)),
          ), // 12

        if (auth.isAuthEnabled && auth.isAuthenticated)
          ListTile(
            title: Text(isOculto ? ui.desocultarAlbum : ui.ocultarAlbum),
            leading: MenuIcon(isOculto ? ui.desocultarAlbum : ui.ocultarAlbum),
            onTap: () => Navigator.pop(context, DialogResult(4)),
          ), // 4

        ListTile(
          title: Text(ui.info),
          leading: MenuIcon(ui.info),
          onTap: () => Navigator.pop(context, DialogResult(5)),
        ), // 5
      ],
    ).cancel();
    switch (result.value) {
      case 1:
        return await _onEditClick();
      case 2:
        return await _onDeleteClick();
      case 3:
        return await _onMoverClick();
      case 4:
        return await _onOcultClick();
      case 5:
        return await _onInfoClick();
      case 12:
        return await onUnirClick();
    }
    return null;
  }

  Future<Album?> _onAddAlbumClick() async {
    return await Navigate.push(context, AddAlbumPage(
      album: album,
      parent: album.parent,
      showCustomParent: false,
    ));
  }

  Future<dynamic> _onEditClick() async {
    if (album.isCollection) {
      return await popupRenameAlbum(context, album);
    } else {
      return await _onAddAlbumClick();
    }
  }

  Future<bool> _onDeleteClick() async {
    final result = await popupDeleteAlbum(context, album);
    if (result) {
      AlbunsProvider.i.save();
    }
    return result;
  }

  Future<bool> _onMoverClick() async {
    return await Navigate.push(context, MoverAlbumPage(album: album)) == true;
  }

  Future<bool> onUnirClick() async {
    albumParaUnir = album;
    // if (albumParaUnir == album) return false;
    //
    // if (!isUnindoAlbum) {
    //   albumParaUnir = album;
    // } else {
    //   final result = await DialogBox(
    //     context: context,
    //     title: idioma.unirAlbuns,
    //     content: [
    //       Text('${idioma.unir} \'${albumParaUnir?.nome}\' ${idioma.a} \'${album.nome}\'?')
    //     ],
    //   ).simNao();
    //   if (result.isPositive) {
    //     album.unirWith(albumParaUnir);
    //     albumParaUnir = null;
    //     _albunsMng.save();
    //   }
    // }
    return true;
  }

  Future<bool> _onOcultClick() async {
    album.isOculto = !album.isOculto;
    _albunsMng.save();
    return true;
  }

  Future<void> _onInfoClick() async {
    await album.computPosts(recursive: true);
    // ignore: use_build_context_synchronously
    popupAlbumInfo(context, album);
  }

}

void popupAlbumInfo(BuildContext context, Album album) {
  DialogBox(
    context: context,
    title: album.nome,
    content: [
      if (album.isCollection)...[
        ListTile(
          title: Text('${album.lengthNormalAlbuns} Albuns'),
        ),
        ListTile(
          title: Text('${album.lengthSubAlbuns} Sub Albuns'),
        ),
     ] else
        ListTile(
          title: Text('${album.lengthPostsOnline} Posts'),
        ),

      ListTile(
        title: Text('${album.lengthPosts} ${idioma.postsSalvos}'),
      ),
      ListTile(
        title: Text('${album.lengthFavoritos} ${idioma.favoritos}'),
      ),

      if (!album.isRoot)
      ListTile(
        title: Text('Path:\n${album.albumPath}'),
      ),

      if (!album.isCollection && album.tags.isNotEmpty && AuthManager.auth.isAuthenticated)
        ListTile(
          title: Text('Tags:\n${album.tagsString}'),
        ),
    ],
  ).ok();
}

Future<bool> popupChangeRating(BuildContext context) async {
  final rating = _booru.rating;
  Widget item(Rating r, void Function() setState) {
    bool isSelected = rating.contains(r.value);
    return CheckboxListTile(
      title: Text('$r'),
      value: isSelected,
      onChanged: (bool? value) {
        if (value ?? false) {
          _booru.rating.add(r.value);
        } else {
          _booru.rating.remove(r.value);
        }
        setState.call();
      },
    );
  }

  await showDialog(
    context: context,
    builder: (context) {
      return OkiStatefulBuilder(
        builder: (context, setState, state) {
          return AlertDialog(
            title: const Text('Rating'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                item(Rating.safe, setState),
                item(Rating.questionable, setState),
                item(Rating.explicit, setState),
                // item(Rating.all, setState),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        }
      );
    },
  );

  if (_booru.rating.isEmpty) {
    _booru.rating.add(Rating.safeValue);
  }

  return true;
}

Future<bool> popupChangeBooru(BuildContext context, String currentBooru) async {
  Map<int, String> teste = {};
  for (int i = 0; i < Boorus.list.length; i++) {
    teste[i] = Boorus.list[i].name;
  }

  Widget coluna(int init, int fim) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = init; i < fim; i++)
            ListTile(
              title: Text(teste[i] ?? '',
                style: TextStyle(
                  color: Boorus.list[i].name == currentBooru ? disabledTextColor : null,
                ),
              ),
              onTap: Boorus.list[i].name == currentBooru? null : () => Navigator.pop(context, DialogResult(i)),
            ),
        ],
      ),
    );
  }

  var result = await DialogBox(
    context: context,
    title: '${idioma.selecionar} Booru',
    content: [
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          coluna(0, teste.length ~/ 2),
          coluna(teste.length ~/ 2, teste.length),
        ],
      ),
    ],
  ).cancel();
  if (result.isNegative || result.isNone) return false;

  var temp = Boorus.get(teste[result.value]);
  if (temp != null) {
    _booru.setBooru(temp);
    return true;
  }
  return false;
}

Future<bool> popupDeletePostDispositivo(BuildContext context, Post post) async {
  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(idioma.excluirArquivos),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.hasPreviewCacheFile /*|| post.hasPreviewCompressedFile || post.hasPreviewCompressedCacheFile*/)
                  ListTile(
                    title: Text(idioma.miniatura),
                    leading: const Icon(Icons.delete_forever),
                    onTap: () async {
                      if(post.hasPreviewCacheFile) {
                        await post.previewFile.delete();
                      }

                      setState(() {});
                    },
                  ),

                if (post.hasPostSampleFile)
                  ListTile(
                    title: Text(idioma.arquivoSample),
                    leading: const Icon(Icons.delete_forever),
                    onTap: () async {
                      await post.postSampleFile.delete();
                      setState(() {});
                    },
                  ),

                if (post.hasPostOriginalFile)
                  ListTile(
                    title: Text(idioma.arquivoOriginal),
                    leading: const Icon(Icons.delete_forever),
                    onTap: () async {
                      await post.postOriginalFile.delete();
                      setState(() {});
                    },
                  ),

                if (post.hasPostSalvoFile)
                  ListTile(
                    title: Text(idioma.arquivoSalvo),
                    leading: const Icon(Icons.delete_forever),
                    onTap: () async {
                      await post.postSalvoFile.delete();
                      setState(() {});
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    ),
  );

  return true;
}

Future<bool> popupDeletePosts(BuildContext context, Album? album, List<Post> posts, {bool isAnalize = false}) async {
  var result = await showDialog<DialogResult>(
    context: context,
    builder: (context) => StatefulBuilder(builder: (context, setState) {
      final s = posts.length == 1 ? '' : 's';
      return AlertDialog(
        title: Text('${idioma.removerPost}$s ${idioma.do_} ${isAnalize ? idioma.grupo : 'album'}?'),
        actions: [
          TextButton(
            child: Text(idioma.nao),
            onPressed: () => Navigator.pop(context, DialogResult.negative),
          ),
          TextButton(
            child: Text(idioma.sim),
            onPressed: () => Navigator.pop(context, DialogResult.positive),
          ),
        ],
      );
    }),
  ) ?? DialogResult.none;

  return result.isPositive;
}

Future<bool> popupRenameAlbum(BuildContext context, Album album) async {
  var controller = TextEditingController(text: album.nome);
  var result = await DialogBox(
    context: context,
    content: [
      OkiTextField(
        hint: idioma.nomeDoAlbum,
        controller: controller,
      ),
    ],
  ).cancelOK();
  if (!result.isPositive) return false;

  album.nome = controller.text.trimLeft().trimRight();
  await _albunsMng.save();
  return true;
}

Future<bool> popupOverrideAlbumComPosts(BuildContext context) async {
  final res = await DialogBox(
    context: context,
    title: idioma.aviso,
    content: [
      Text(idioma.popupOverrideAlbumComPostsInfo),
    ],
  ).simNao();
  return res.isPositive;
}

Future<bool> popupSalvarAlbum(BuildContext context, Album album, Album? preferencia) async {
  var result = await DialogBox(
    context: context,
    title: idioma.ondeSalvarAlbum,
    content: [
      ListTile(
        title: Text(idioma.pastaRaiz),
        onTap: () => Navigator.pop(context, DialogResult(1)),
      ),  // Pasta Raiz

      if (preferencia?.isSalvo ?? false)...[
        if (!(preferencia!.parent?.isRoot ?? false))
          ListTile(
            title: Text(' - ${preferencia.parent!.nome}'),
            onTap: () => Navigator.pop(context, DialogResult(2)),
          ),

        ListTile(
          title: Text('     - ${preferencia.nome}'),
          onTap: () => Navigator.pop(context, DialogResult(3)),
        ),
      ],
    ],
  ).cancel();

  switch(result.value) {
    case 1://pasta raiz
      _albunsMng.album.add(album);
      return true;
    case 2:// pai de preferencia
      if (!preferencia!.parent!.isCollection && preferencia.parent!.isPostsNotEmpty && context.mounted) {
        if (!await popupOverrideAlbumComPosts(context)) return false;
      }
      preferencia.parent?.add(album);
      return true;
    case 3://preferencia
      if (!preferencia!.isCollection && preferencia.isPostsNotEmpty && context.mounted) {
        if (!await popupOverrideAlbumComPosts(context)) return false;
      }
      preferencia.add(album);
      return true;
  }
  return false;
}

Future<bool> popupDeleteAlbum(BuildContext context, Album album) async {
  var result = await DialogBox(
    context: context,
    title: album.nome,
    content: [
      Text(idioma.desejaExcluirAlbum)
    ],
  ).simNao();
  if (!result.isPositive) return false;

  album.parent?.remove(album.id);
  if (context.mounted) {
    Log.snack(idioma.albumExcluido);
  }
  return true;
}

Future<bool> popupAlbumNaoSalvo(BuildContext context, Album album, Album? preferencia) async {
  final res = await DialogBox(
    context: context,
    title: idioma.albumNaoSalvo,
    content: [
      Text(idioma.albumNaoSalvoInfo),
    ],
  ).simNao();
  if (!res.isPositive) return false;

  if (!context.mounted) return false;

  return await popupSalvarAlbum(context, album, preferencia);
}

Future<bool> popupBloquearTag(BuildContext context, String tag) async {
  var result = await DialogBox(
    context: context,
    title: tag,
    content: [
      Text(idioma.bloquearEssaTag),
      Text(idioma.bloquearEssaTagTip),
    ],
  ).simNao();
  if (!result.isPositive) return false;

  if (!_booru.blackList.contains(tag)) {
    _booru.blackList.add(tag);
  }
  if (context.mounted) {
    Log.snack(idioma.tagBloqueada);
  }
  return true;
}

Future<void> popupSetWallpaper(BuildContext context, Post? post) async {
  final file = post?.anyFile;
  int locationId = 1;

  if (isMobile) {
    var result = await DialogBox(
      context: context,
      title: idioma.ondeAplicar,
      content: [
        ListTile(
          title: Text(idioma.papelParede),
          onTap: () => Navigator.pop(context, DialogResult(1)),
        ),
        ListTile(
          title: Text(idioma.telaBloqueio),
          onTap: () => Navigator.pop(context, DialogResult(2)),
        ),
        ListTile(
          title: Text(idioma.papelParede),
          subtitle: Text(idioma.telaBloqueio),
          onTap: () => Navigator.pop(context, DialogResult(3)),
        ),
      ],
    ).cancel();
    if (result.value <= 0 || result.value >= 4) {
      return;
    }
    locationId = result.value;
  }

  String? error;
  if (file == null) {
    error = await WallpaperProvider.i.setUrl(post?.sampleUrl ?? '', locationId: locationId);
  } else {
    error = await WallpaperProvider.i.setFile(file, locationId: locationId);
  }

  if (error != null) {
    Log.snack(error, isError: true);
  } else if (context.mounted) {
    Log.snack(idioma.aplicado);
  }
}
