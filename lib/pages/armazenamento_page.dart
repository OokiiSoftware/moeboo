import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../res/import.dart';
import '../util/util.dart';
import '../provider/import.dart';
import '../oki/import.dart';

class ArmazenamentoPage extends StatefulWidget{
  const ArmazenamentoPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<ArmazenamentoPage> {

  //region variaveis

  AlbunsProvider get _albuns => AlbunsProvider.i;

  static const String size = 'sizeName';
  static const String filesCount = 'filesCount';

  static const String previews = Directorys.previews;
  // static const String previewsCompressed = Directorys.previewsCompressed;
  static const String posts = Directorys.posts;
  // static const String postsCompressed = Directorys.postsCompressed;
  static const String tags = 'tags';

  static const String previewsCache = '${Directorys.previews}cache';
  // static const String previewsCompressedCache = '${Directorys.previewsCompressed}cache';
  static const String postsCache = '${Directorys.posts}cache';
  // static const String postsCompressedCache = '${Directorys.postsCompressed}cache';

  final Map<String, Map<String, dynamic>> _dados = {
    previews: {size: 0, filesCount: 0},
    // previewsCompressed: {size: 0, filesCount: 0},
    posts: {size: 0, filesCount: 0},
    // postsCompressed: {size: 0, filesCount: 0},
    previewsCache: {size: 0, filesCount: 0},
    // previewsCompressedCache: {size: 0, filesCount: 0},
    postsCache: {size: 0, filesCount: 0},
    // postsCompressedCache: {size: 0, filesCount: 0},
    '${tags}cache': {size: 0, filesCount: 0},
  };

  ILanguage get ui => idioma;

  bool _inProgress = false;

  //endregion

  //region Widgets

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ui.titleArmazenamentoTape),),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 60),
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 15),
                  child: Text(ui.postsSalvos),
                ),

                ListTile(
                  title: Text(getValue(posts)),
                  subtitle: Text(ui.postsSalvos),
                  trailing: IconButton(
                    tooltip: ui.limpar,
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () => _onDeleteCacheClick(posts, false),
                  ),
                ),  // Posts salvos

                ListTile(
                  title: Text(getValue(previews)),
                  subtitle: Text(ui.previewsQualidade),
                  trailing: IconButton(
                    tooltip: ui.limpar,
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () => _onDeleteCacheClick(previews, false),
                  ),
                ),  // Previews comprimidos
              ],
            ),
          ),

          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 15),
                  child: Text(ui.postsEmCache),
                ),

                ListTile(
                  title: Text(getValue(previewsCache)),
                  subtitle: Text(ui.previewsEmCache),
                  trailing: IconButton(
                    tooltip: ui.limpar,
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () => _onDeleteCacheClick(previews, true),
                  ),
                ),  // Previews em cache

                ListTile(
                  title: Text(getValue(postsCache)),
                  subtitle: Text(ui.postsEmCache),
                  trailing: IconButton(
                    tooltip: ui.limpar,
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () => _onDeleteCacheClick(posts, true),
                  ),
                ),  // Posts em cache

                ListTile(
                  title: Text(getValue('${tags}cache', 'Tags')),
                  subtitle: Text(ui.tagsEmCache),
                  trailing: IconButton(
                    tooltip: ui.limpar,
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () => _onDeleteCacheClick(tags, true),
                  ),
                ),  // Tags em cache
              ],
            ),
          ),  // Posts em cache

          ListTile(
            subtitle: Text(ui.salvarImgDiferentesProvider),
          ),  // Info

          const Divider(),
          SwitchListTile(
            title: Text(idioma.criarPreviewQualidade),
            subtitle: Text(idioma.criarPreviewQualidadeTip),
            value: criarPreviewsDeQualidade,
            onChanged: _onCriarPreviewsDeQualidadeChanged,
          ),  // Criar previews

          SwitchListTile(
            title: Text(idioma.salvarTagsPesquisa),
            subtitle: Text(idioma.salvarTagsPesquisaTip),
            value: saveTags,
            onChanged: _onSaveTagsChanged,
          ),  // Salvar imagens reduzidas

          // SwitchListTile(
          //   title: const Text('Limpar cache ao fechar o app'),
          //   subtitle: const Text('Apaga todos os posts em cache, mas mantém as imagens comprimidas.'),
          //   value: limparCacheAoFecharApp,
          //   onChanged: _onlimparCacheChanged,
          // ),  // Limpar cache ao fechar app
        ],
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
    );
  }

  //endregion

  //region metodos

  void _init() async {
    _setInProgress(true);

    _dados[previews]!.addAll(await _albuns.getCacheSizeMap(Directorys.previews));
    _dados[previewsCache]!.addAll(await _albuns.getCacheSizeMap(Directorys.previews, true));
    // _dados[previewsCompressed]!.addAll(await _albuns.getCacheSizeMap(Directorys.previewsCompressed));
    // _dados[previewsCompressedCache]!.addAll(await _albuns.getCacheSizeMap(Directorys.previewsCompressed, true));

    _dados[posts]!.addAll(await _albuns.getCacheSizeMap(Directorys.posts));
    _dados[postsCache]!.addAll(await _albuns.getCacheSizeMap(Directorys.posts, true));
    // _dados[postsCompressed]!.addAll(await _albuns.getCacheSizeMap(Directorys.postsCompressed));
    // _dados[postsCompressedCache]!.addAll(await _albuns.getCacheSizeMap(Directorys.postsCompressed, true));

    if (await tagsFile.exists()) {
      int tagsSize = await tagsFile.length();
      int tagsCount = 0;

      Map tagsMap = jsonDecode(await tagsFile.readAsString());

      for (Map provider in tagsMap.values) {
        tagsCount += provider.length;
      }

      _dados['${tags}cache']![size] = StorageManager.i.convertBytesToMb(tagsSize);
      _dados['${tags}cache']![filesCount] = tagsCount;
    }
    _setInProgress(false);
  }

  void _onDeleteCacheClick(String path, bool cache) async {
    var result = await DialogBox(
      context: context,
      content: [
        Text('${idioma.excluirArquivosDe} $path?'),
      ],
    ).simNao();
    if (!result.isPositive) return;

    _setInProgress(true);

    if (path == tags) {
      if (await tagsFile.exists()) {
        await tagsFile.delete();
      }
    } else {
      await StorageManager.i.deleteFolder(path, cache: cache);
      await StorageManager.i.createFolder(path, cache: cache);
    }

    var map = _getMap(path, cache);
    map.addAll({size: '0 Mb', filesCount: 0});

    _setInProgress(false);
  }

  void _onSaveTagsChanged(bool value) {
    saveTags = value;
    setState(() {});
  }

  // void _onlimparCacheChanged(bool value) {
  //   limparCacheAoFecharApp = value;
  //   setState(() {});
  // }

  void _onCriarPreviewsDeQualidadeChanged(bool value) {
    criarPreviewsDeQualidade = value;
    setState(() {});
  }

  String getValue(String path, [String? arqName]) {
    return '${_dados[path]![size]} [${_dados[path]![filesCount]} ${arqName ?? ui.arquivos}]';
  }

  Map<String, dynamic> _getMap(String path, bool cache) {
    if (cache) {
      return _dados['${path}cache']!;
    }
    return _dados[path]!;
  }

  File get tagsFile => StorageManager.i.file('$tags.json', path: Directorys.search, cache: true);

  void _setInProgress(bool b) {
    _inProgress = b;
    if (mounted) {
      setState(() {});
    }
  }

  //endregion

}