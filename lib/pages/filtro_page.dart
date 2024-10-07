import 'package:flutter/material.dart';
import '../model/import.dart';
import '../oki/import.dart';
import '../provider/import.dart';

final OkiList<String> _tagsSelecionadas = OkiList();

class FiltroPage extends StatefulWidget {
  final Album album;
  final bool online;
  final List<String>? filtroAtual;
  const FiltroPage(this.album, {
    this.online = false,
    this.filtroAtual = const <String>[],
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<FiltroPage> {
  Album get album => widget.album;
  bool get online => widget.online;

  // static const permitirTags = 'Permitir tags selecionadas';
  // static const bloquearTags = 'Bloquear tags selecionadas';

  final List<String> tags = [];

  String _currentOpcao = '';

  @override
  void dispose() {
    super.dispose();
    _tagsSelecionadas.removeListener(_listener);
  }

  @override
  void initState() {
    super.initState();
    tags.addAll(album.getPostsTags(online));
    if (widget.filtroAtual != null) {
      _tagsSelecionadas.addAll(widget.filtroAtual ?? []);
    }

    if (_tagsSelecionadas.isEmpty) {
      _tagsSelecionadas.addAll(tags);
    }

    _setOpcap(album.blockTagsDoFiltro);

    _tagsSelecionadas.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentOpcao),
        actions: [
          IconButton(
            tooltip: idioma.pesquisar,
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _DataSearch(
                  sugestoes: tags,
                ),
              );
            },
          ), // Pesquisar
          Switch(
            value: _tagsSelecionadas.length == tags.length,
            activeColor: Colors.lightBlueAccent,
            onChanged: (value) {
              _tagsSelecionadas.clear();
              if (value) {
                _tagsSelecionadas.addAll(tags);
              }
              setState(() {});
            },
          ),
          const SizedBox(width: 15,),
        ],
      ),
      body: ListView.builder(
        itemCount: tags.length,
        padding: const EdgeInsets.only(bottom: 100),
        itemBuilder: (context, index) {
          final tag = tags[index];

          return SwitchListTile(
            title: Text(tag),
            value: _tagsSelecionadas.contains(tag),
            onChanged: (value) {
              if (value) {
                _tagsSelecionadas.add(tag);
              } else {
                _tagsSelecionadas.remove(tag);
              }
              setState(() {});
            },
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'tyuguiyfu',
            label: Text(idioma.opcoes),
            backgroundColor: Colors.grey,
            onPressed: _onOpcaoClick,
          ),
          const SizedBox(width: 10,),
          FloatingActionButton.extended(
            label: Text(idioma.aplicar),
            onPressed: () {
              if (_tagsSelecionadas.length == tags.length) {
                _tagsSelecionadas.clear();
              }// serve para reduzir processos desnecessários no método album.getPostsTags()

              Navigator.pop(context, _tagsSelecionadas);
            },
          ),
        ],
      ),
    );
  }

  void _listener() {
    setState(() {});
  }

  void _setOpcap(bool b) {
    _currentOpcao = b ? idioma.blouearTags : idioma.permitirTags;
    setState(() {});
  }

  void _onOpcaoClick() async {
    var r = await DialogBox(
      context: context,
      content: [
        ListTile(
          title: Text(idioma.permitirTags),
          onTap: () => Navigator.pop(context, DialogResult(1)),
        ),
        ListTile(
          title: Text(idioma.blouearTags),
          onTap: () => Navigator.pop(context, DialogResult(2)),
        ),
      ]
    ).cancel();
    if (r.value == 1) {
      album.blockTagsDoFiltro = false;
    } else if (r.value == 2) {
      album.blockTagsDoFiltro = true;
    }

    _setOpcap(album.blockTagsDoFiltro);
  }

}

class _DataSearch extends SearchDelegate<String> {

  final List<String> sugestoes;
  final List<String> listResults = [];

  _DataSearch({this.sugestoes = const []});

  // @override
  // String get searchFieldLabel => Strings.pesquisar;

  @override
  ThemeData appBarTheme(BuildContext context) => ThemeManager.i.themeData();

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () {query = '';})];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) {
    if (listResults.isEmpty) {
      return _msgSemResultados(context);
    }
    return listView(listResults);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _setQueryValues();
    if (listResults.isEmpty && query.isNotEmpty) {
      return _msgSemResultados(context);
    }

    return listView(listResults);
  }

  Widget _msgSemResultados(context) => ListTile(
    title: Text(idioma.semResult),
  );

  Widget listView(List<String> list) {
    return StatefulBuilder(
        builder: (context, setState) {
          return ListView.builder(
            // padding: EdgeInsets.only(),
            itemBuilder: (context, index) {
              final tag = list[index];
              return SwitchListTile(
                title: Text(tag),
                value: _tagsSelecionadas.contains(tag),
                onChanged: (value) {
                  if (value) {
                    _tagsSelecionadas.add(tag);
                  } else {
                    _tagsSelecionadas.remove(tag);
                  }
                  setState.call(() {});
                },
                // onClick: (item) => _onItemTap(context, item),
              );
            },
            itemCount: list.length,
          );
        },
    );
  }

  void _setQueryValues() {
    bool b(String x) {
      final q = query.toLowerCase();
      return x.toLowerCase().contains(q);
    }

    listResults.clear();
    listResults.addAll(query.isEmpty ? sugestoes : sugestoes.where(b).toList());
  }

}