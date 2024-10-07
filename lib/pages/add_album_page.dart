import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../util/util.dart';
import '../booru/import.dart';
import '../provider/import.dart';
import '../model/import.dart';
import '../res/import.dart';
import '../oki/import.dart';
import 'import.dart';

class AddAlbumPage extends StatefulWidget {
  final Album? album;
  final Album? parent;
  final bool showCustomParent;
  const AddAlbumPage({this.album, this.parent, this.showCustomParent = true, super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<AddAlbumPage> {
  Album? get parent => widget.parent;

  //region variaveis

  static const _log = Log('AddAlbumPage');

  static bool _showDica = true;
  static final List<String> _filtro = [];

  final TextEditingController _cNome = TextEditingController();
  final TextEditingController _cTags = TextEditingController();

  String _pageTitle = 'Novo Album';

  bool _inProgress = false;

  final List<Tag> _tagsSugestions = [];
  final Map<String, List<String>> _tags = {};

  String _currentQuery = '';
  late String _currentParenteOption;

  final FocusNode _focus = FocusNode();
  final ScrollController _controller = ScrollController();

  bool isDevUser = false;

  ILanguage get ui => idioma;

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    var album = widget.album;
    if (album != null) {
      _cNome.text = album.nome;
      album.tags.forEach((provider, tags) {
        for (var tag in tags) {
          if (_tags[provider] == null) {
            _tags[provider] = [];
          }
          _tags[provider]?.add(tag);
        }
      });

      _pageTitle = ui.titleEditAlbum;
    } else {
      _pageTitle = ui.titleAddAlbum;
    }
    _currentParenteOption = ui.parenteOptions(parent?.nome ?? '')[0];

    _controller.addListener(() {
      _focus.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tags = [..._tagsSugestions];
    if (_filtro.isNotEmpty) {
      tags.removeWhere((x) => !_filtro.contains(x.type.name));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        actions: [
          IconButton(
            tooltip: ui.filtro,
            icon: const Icon(Icons.filter_alt),
            onPressed: _onFilterTap,
          ),
          const SizedBox(width: 10,),
        ],
      ),
      body: ListView(
        controller: _controller,
        padding: const EdgeInsets.all(10),
        children: [
          // if (!autoManagerBooru)
            ListTile(
              title: Text('${ui.currentBooru}: $currentBooru'),
              subtitle: Text(ui.clickParaAlterar),
              // trailing: IconButton(
              //   tooltip: 'Ver Modelos',
              //   icon: Icon(Icons.source),
              //   onPressed: _onModelClick,
              // ),
              onTap: _onBooruTap,
            ), // Booru
          if (currentBooru == DeviantArt.name_)
            SwitchListTile(
              title: Text(ui.usuarioDev),
              value: isDevUser,
              onChanged: _onDevUserChanged,
            ), // Booru

          if (widget.showCustomParent && parent != null)
            Row(
              children: [
                Expanded(
                  child: OkiDropDown(
                    text: ui.fazerDesteAlbum,
                    vertical: true,
                    items: ui.parenteOptions(parent?.nome ?? ''),
                    value: _currentParenteOption,
                    onChanged: _onParentOptionChanged,
                  ),
                ),
                IconButton(
                  onPressed: _onChildInfoTap,
                  icon: const Icon(Icons.info),
                ),
              ],
            ),

          OkiTextField(
            hint: ui.nome,
            circularBorder: false,
            controller: _cNome,
            textInputType: TextType.name,
          ), // Nome

          OkiTextFieldSugestion(
            hint: ui.pesquisarTags,
            controller: _cTags,
            focus: _focus,
            textInputType: TextType.text.lowerCase,
            timeAwait: const Duration(seconds: 2),
            suggestionsCallback: _tagsSuggestionsCallback,
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: ui.add,
                  icon: const Icon(Icons.add),
                  onPressed: () => _onAddTagTap(Tag(id: 0, name: _cTags.text)),
                ),
                IconButton(
                  tooltip: ui.bloquear,
                  icon: const Icon(Icons.remove),
                  onPressed: () => _onAddTagTap(Tag(id: 0, name: _cTags.text), true),
                ),
              ],
            ),
          ),

          if (_inProgress)
            const LinearProgressIndicator(),

          if (_tags.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onShowTagsTap,
                child: Text('${ui.verTags} (${_getTagsCount()})'),
              ),
            ), // Ver Tags

          if (tags.isNotEmpty && _showDica)...[
            ListTile(
              title: Text(ui.clickParaVerPost),
              // subtitle: const Text('Clique longo para bloquear a tag.'),
              trailing: IconButton(
                tooltip: ui.dispensar,
                icon: const Icon(Icons.close),
                onPressed: () {
                  _showDica = false;
                  setState(() {});
                },
              ),
            ),
            const Divider(),
          ],

          ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: tags.length,
            itemBuilder: (context, index) {
              Tag item = tags[index];

              return TagTile(
                tag: item,
                query: _currentQuery,
                showProvider: true,
                onTap: _onTagTap,
                // onLongPress: _onLongPress,
                onAddClick: _onAddTagTap,
                onRemoveClick: (item) => _onAddTagTap(item, true),
              );
            },
          ), // Tags
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: ui.salvar,
        onPressed: _onSaveTap,
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _tagsList(String provider, List<String> tags, StateSetter setterProvider, StateSetter setterBoorus) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var tag in tags)...[
          ListTile(
            title: Text(tag),
            subtitle: Text(provider),
            trailing: IconButton(
              tooltip: ui.deleteTags,
              icon: const Icon(Icons.delete_forever),
              onPressed: () => _onTagDeleteTap(provider, tag, setterProvider, setterBoorus),
            ),
            leading: IconButton(
              tooltip: ui.editTags,
              icon: const Icon(Icons.edit),
              onPressed: () => _onTagEditTap(tag),
            ),
            // onTap: _onTagClick,
          )
        ]
      ],
    );
  }

  //endregion

  //region metodos

  void _onBooruTap() async {
    _hideKeyboard();
    if (await popupChangeBooru(context, currentBooru)) {
      setState(() {});
      final d = _currentQuery;
      _currentQuery = '';
      _tagsSuggestionsCallback(d);
    }
  }

  void _onSaveTap() {
    Album? album = widget.album;
    String name = _cNome.text.trimRight().trimLeft();
    album ??= Album(id: randomString(), nome: name,);

    album.nome = name;
    album.tags.clear();
    album.tags.addAll(_tags);

    var albuns = AlbunsProvider.i;
    if (parent == null) {
      if (album.isSalvo) {
        album.parent?.add(album);
      } else {
        albuns.album.add(album);
      }
    } else {
      if (_currentParenteOption == ui.parenteOptions(parent?.nome ?? '')[0]) { // Filho
        parent?.add(album);
        _log.d('onSaveClick', 'Filho', parent?.nome, album.nome);
      } else { // Pai
        parent?.parent?.remove(parent?.id);
        parent?.parent?.add(album);
        album.add(parent ?? album);
        _log.d('onSaveClick', 'Pai');
      }
    }

    Navigator.pop(context, album);
  }

  void _onTagTap(Tag tag) async {
    _hideKeyboard();
    if (isDevUser) {
      tag= tag.copy();
      tag.name = 'user:${tag.name}';
    }

    Album searchAlbum = Album(
      nome: tag.toName(),
      id: randomString(),
    )..tags.addAll({currentBooru: [tag.name]});

    await Navigate.push(context, AlbumPage(album: searchAlbum));
  }

  // ignore: unused_element
  void _onLongPress(Tag tag) async {
    _hideKeyboard();
    popupBloquearTag(context, tag.name);
  }

  void _onAddTagTap(Tag tag, [bool negative = false]) {
    if (isDevUser) {
      tag.name = 'user:${tag.name}';
    }

    // if (autoManagerBooru) {
    //   tag.provider.split(', ').forEach((prov) {
    //     if (!_tags.containsKey(prov)) {
    //       _tags[prov] = [];
    //     }
    //
    //     String tagMais = tag.name;
    //     String tagMenos = '-${tag.name}';
    //
    //     if (tagMais.isEmpty) {
    //       return;
    //     }
    //
    //     var booruTags = _tags[prov];
    //
    //     if (negative) {
    //       booruTags?.remove(tagMais);
    //
    //       if (!(booruTags?.contains(tagMenos) ?? true)) {
    //         booruTags?.add(tagMenos);
    //       }
    //     } else {
    //       booruTags?.remove(tagMenos);
    //
    //       if (!(booruTags?.contains(tagMais) ?? true)) {
    //         booruTags?.add(tagMais);
    //       }
    //     }
    //   });
    // } else {
    //
    // }
    if (!_tags.containsKey(currentBooru)) {
      _tags[currentBooru] = [];
    }

    var booruTags = _tags[currentBooru];

    String tagMais = tag.name;
    String tagMenos = '-${tag.name}';

    if (tagMais.isEmpty) {
      return;
    }

    if (negative) {
      booruTags?.remove(tagMais);

      if (!(booruTags?.contains(tagMenos) ?? true)) {
        booruTags?.add(tagMenos);
      }
    } else {
      booruTags?.remove(tagMenos);

      if (!(booruTags?.contains(tagMais) ?? true)) {
        booruTags?.add(tagMais);
      }
    }

    _setState();
    Log.snack(ui.tagAdicionada);
  }

  void _onTagEditTap(String tag) {
    Navigator.pop(context);
    Navigator.pop(context);

    _tags[currentBooru]?.remove(tag);
    _cTags.text = tag;

    _setState();
  }

  void _onTagDeleteTap(String provider, String tag, StateSetter setterProvider, StateSetter setterBoorus) {
    if (_tags.containsKey(provider)) {
      _tags[provider]?.remove(tag);
      setterProvider.call(() {});

      if (_tags[provider]?.isEmpty ?? true) {
        _tags.remove(provider);
        setterBoorus.call(() {});
      }
      setState(() {});
    }
  }

  void _onShowTagsTap() {
    _hideKeyboard();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBoorus) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                children: [
                  for(String provider in _tags.keys)
                    if (_tags[provider]?.isNotEmpty ?? false)
                      ListTile(
                        title: Text(provider),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => StatefulBuilder(
                              builder: (context, setStateProvider) {
                                return AlertDialog(
                                  title: Text(provider),
                                  content: SingleChildScrollView(
                                    child: _tagsList(provider, _tags[provider]??[], setStateProvider, setStateBoorus),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () => Navigator.pop(context),
                                    )
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        },
      ),
    );
  }

  void _onFilterTap() async {
    _hideKeyboard();
    void onChanged(bool? value, String tagType, void Function() setState) {
      if (value ?? false) {
        _filtro.add(tagType);
      } else {
        _filtro.remove(tagType);
      }
      setState();
    }

    Widget checkBox(String text, void Function() setState) => CheckboxListTile(
      title: Text(text),
      value: _filtro.contains(text),
      onChanged: (value) => onChanged(value, text, setState),
    );

    await showDialog(
      context: context,
      builder: (context) => OkiStatefulBuilder(
        builder: (context, setState, state) => AlertDialog(
          title: Text(ui.filtro),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              checkBox(TagType.trivia.name, setState),
              checkBox(TagType.metadata.name, setState),
              checkBox(TagType.artist.name, setState),
              checkBox(TagType.character.name, setState),
              checkBox(TagType.copyright.name, setState),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
    setState(() {});
  }

  /// Mostra como funciona a opção de fazer o album filho do outro
  void _onChildInfoTap() {
    List<String> ops = ui.parenteOptions(parent?.nome ?? '');
    const titleStyle = TextStyle(
      fontWeight: FontWeight.w600,
    );

    DialogBox(
      context: context,
      title: ui.fazerDesteAlbum,
      content: [
        Text(ops[0], style: titleStyle),
        Text('- ${parent?.nome} (${ui.pai})'),
        Text('   - ${ui.novoAlbum} (${ui.filho})'),
        const Divider(),
        Text(ops[1], style: titleStyle),
        Text('- ${ui.novoAlbum} (${ui.pai})'),
        Text('   - ${parent?.nome} (${ui.filho})'),
      ],
    ).close();
  }


  Future<List<String>> _tagsSuggestionsCallback(String value) async {
    if (_currentQuery == value.toLowerCase()) return [];

    _setInProgress(true);

    _currentQuery = value.toLowerCase();

    String query = value.toLowerCase().trimLeft().trimRight();

    if (query.trim().isEmpty) {
      _tagsSugestions.clear();
      _setInProgress(false);
      return [];
    }

    query = query.replaceAll(' ', '_');

    final List<Tag> tags = [];

    final localTagsFile = StorageManager.i.file('tags.json', path: Directorys.search, cache: true);
    // Tags salvas no dispositivo
    final Map<String, dynamic> localTags = {currentBooru: {}};

    await _lerTagsSalvas(localTags, localTagsFile, query)
        .then((value) => _setState());

    try {
      tags.addAll(await BooruProvider.i.booru.findTags(query));
      _tagsSugestions.clear();
      _tagsSugestions.addAll(tags);
    } catch(e) {
      _onSearchError(e);
      _setInProgress(false);
      return [];
    }

    _salvarTagsSalvas(localTags, tags, localTagsFile)
        .then((value) => _setState());

    tags.clear();
    localTags.clear();

    if (_tagsSugestions.length > 500) {
      final temp = [..._tagsSugestions];
      _tagsSugestions.clear();
      _tagsSugestions.addAll(temp.sublist(0, 500));
      temp.clear();
    }

    _tagsSugestions.sort((a, b) {
      if (a.name == _currentQuery) {
        return -1;
      }
      if (b.name == _currentQuery) {
        return 1;
      }
      return a.name.compareTo(b.name);
    });
    _setInProgress(false);
    return [];
  }

  void _onParentOptionChanged(String? value) {
    _currentParenteOption = value ?? '';
    _setState();
  }

  void _onDevUserChanged(bool? value) {
    isDevUser = value ?? false;
    _setState();
  }

  void _onSearchError(e) {
    _log.d('_tagsSuggestionsCallback', '_onSearchError', e);
    Log.snack(ui.erroPesquisaTag, isError: true, actionClick: () {
      DialogBox(
        context: context,
        title: ui.erroTitle,
        content: [
          const Text('tagsSuggestionsCallback\n'),
          SelectableText(e.toString()),
        ],
      ).ok();
    });
  }

  Future<void> _lerTagsSalvas(Map<String, dynamic> localTags, File file, String query) async {
    if (!await file.exists())  return;

    try {
      _tagsSugestions.clear();
      localTags.addAll(jsonDecode(await file.readAsString()));

      for (String key in localTags[currentBooru]!.keys) {
        localTags[currentBooru]![key]!['id'] = int.parse(key);
        final tag = Tag.fromJson(localTags[currentBooru]![key]);
        if (tag.name.contains(query)) {
          _tagsSugestions.add(tag);
          if (_tagsSugestions.length > 500) break;
        }
      }
    } catch (e) {
      _log.e('_lerTagsSalvas', e);
    }
  }

  Future<void> _salvarTagsSalvas(Map<String, dynamic> localTags, List<Tag> tags, File file) async {
    if (!saveTags) return;

    try {
      Map<String, dynamic> data = {};
      for (var tag in tags) {
        data['${tag.id}'] = tag.toJson(includeAll: false);
      }

      localTags[currentBooru]!.addAll({...data});

      await file.writeAsString(jsonEncode(localTags));
      data.clear();
    } catch (e) {
      _log.e('_salvarTagsSalvas', e);
    }
  }

  void _hideKeyboard() {
    if (isMobile) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void _setInProgress(bool b) {
    _inProgress = b;
    _setState();
  }

  int _getTagsCount() {
    int i = 0;
    _tags.forEach((key, value) {
      i += value.length;
    });
    return i;
  }

  void _setState() {
    if(mounted) {
      setState(() {});
    }
  }

  //endregion

}

/*void _onModelClick() async {
    Map<int, String> teste = Map();
    var albums = AlbunsModel.i.albuns.values.toList();

    for (int i = 0; i < albums.length; i++) {
      teste[i] = albums[i].id;
    }

    var title = 'Modelos';
    var content = [
      for (int i = 0; i < teste.length; i++)
        ListTile(
          title: Text(albums[i].nome),
          trailing: Text('Ver'),
          onTap: () => Navigator.pop(context, DialogResult(i)),
        ),
    ];
    var result = await DialogBox(
      context: context,
      title: title,
      content: content,
    ).cancel();
    if (result.isNegative || result.isNone) return;

    Album selectedAlbum = albums[result.value];
    if (selectedAlbum != null) {
      push(context, AlbumPage(album: selectedAlbum));
    }
  }*/
