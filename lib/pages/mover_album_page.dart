import 'package:flutter/material.dart';
import '../provider/import.dart';
import '../model/import.dart';
import '../oki/import.dart';

class MoverAlbumPage extends StatefulWidget {
  final Album album;
  const MoverAlbumPage({required this.album, super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<MoverAlbumPage> {
  Album get album => widget.album;

  Album? _currentAlbum;

  final List<Album> _paths = [];

  @override
  void initState() {
    super.initState();
    _currentAlbum = AlbunsProvider.i.album;
  }

  @override
  Widget build(BuildContext context) {
    final albuns = _currentAlbum?.getAlbuns(recursive: false, onlyCollections: true,
        addOcultos: AuthManager.auth.isAuthenticated) ?? <Album>[];

    albuns.removeWhere((x) => x.id == album.id || x.id == _currentAlbum?.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentAlbum?.nome ?? idioma.titleMoverAlbum),
      ),
      body: Column(
        children: [
          if (!(_currentAlbum?.isRoot ?? false))
            ListTile(
              leading: const Icon(Icons.arrow_back_sharp),
              title: Text('${idioma.voltarPara} ${_paths.last.nome}'),
              onTap: _onVoltarClick,
            ),
          Expanded(
            child: ListView.builder(
              itemCount: albuns.length,
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 80),
              itemBuilder: (context, i) {
                final album = albuns[i];
                return ListTile(
                  title: Text(album.nome),
                  subtitle: Text('${idioma.em} ${album.parent?.nome}'),
                  onTap: () => _onAlbumClick(album),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(idioma.moverParaEsteAlbum,),
        onPressed: _onMoverClick,
      ),
    );
  }

  void _onVoltarClick() {
    _currentAlbum = _paths.last;
    _paths.remove(_currentAlbum);
    setState(() {});
  }

  void _onAlbumClick(Album album) {
    if (_currentAlbum != null) {
      _paths.add(_currentAlbum!);
    }

    _currentAlbum = album;
    setState(() {});
  }

  void _onMoverClick() {
    album.parent?.remove(album.id);
    _currentAlbum?.add(album);
    AlbunsProvider.i.save();
    Navigator.pop(context, true);
  }
}