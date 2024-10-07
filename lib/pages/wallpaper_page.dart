// import 'package:anialbum/booru/import.dart';
// import 'package:anialbum/manager/import.dart';
// import 'package:flutter/material.dart';
// import '../auxiliar/import.dart';
// import '../model/import.dart';
// import '../oki/import.dart';
//
// class WallpaperPage extends StatefulWidget {
//   const WallpaperPage({Key? key}) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() => _State();
// }
// class _State extends State<WallpaperPage> {
//
//   BackgroundManager get _bgMng => BackgroundManager.i;
//
//   final _location = const ['HomeScreen', 'LockScreen', 'Ambos'];
//   final _imagensSource = const ['Offline', 'Online', 'Ambos'];
//   final _intervaloType = const ['Minuto', 'Hora', 'Dia'];
//   final _intervalosMin = const [15, 20, 25, 30, 35, 40, 45, 50, 55];
//   final _intervalosHora = List<int>.generate(23, (index) => index + 1);
//   final _intervalosDia = List<int>.generate(30, (index) => index + 1);
//
//   AlbunsManager get _albunsMng => AlbunsManager.i;
//   final List<Album> _albuns = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _albuns.addAll(_albunsMng.wallpapers());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Papel de parede'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SwitchListTile(
//               title: const Text('Habilitar',
//                 style: TextStyle(
//                   fontSize: 22,
//                 ),
//               ),
//               value: enableWallpaper,
//               onChanged: _onActivateChanged,
//             ),  // Habilitar
//
//             OkiDropDown(
//               text: 'Local do Papel de parede',
//               items: _location,
//               value: _location[papelDeParedeLocation],
//               onChanged: _onWallpaperChanged,
//             ),  // Papel de parede
//
//             CheckboxListTile(
//               title: const Text('Mesma imagen para papel de parede e tela de bloqueio'),
//               value: coincidirWallpaperLockscreen,
//               onChanged: enableWallpaper && papelDeParedeLocation == 2 ? _onCoincidirChanged : null,
//             ),  // Coincidir
//
//             OkiDropDown(
//               text: 'Maturidade',
//               items: Rating.values,
//               value: Rating.values[wallpaperRating],
//               onChanged: _onRatingChanged,
//             ),  // Maturidade
//
//             const Divider(),
//
//             OkiDropDown(
//               text: 'Imagens Source',
//               items: _imagensSource,
//               value: _imagensSource[wallpaperSource],
//               onChanged: _onWallpaperOnlineChanged,
//             ),  // Source
//
//             OkiDropDown(
//               text: 'Intervalos',
//               items: _intervaloType,
//               value: _intervaloType[wallpaperIntervaloType],
//               onChanged: _onIntervaloTypeChanged,
//             ),  // Intervalos
//
//             if (wallpaperIntervaloType == 0)
//               Spinner<int>(
//                 values: _intervalosMin,
//                 value: wallpaperIntervalo,
//                 onChanged: _onIntervaloChanged,
//                 space: 10,
//               ),  // Min
//             if (wallpaperIntervaloType == 1)
//               Spinner<int>(
//                 values: _intervalosHora,
//                 value: wallpaperIntervalo,
//                 onChanged: _onIntervaloChanged,
//                 space: 10,
//               ),  // Hora
//             if (wallpaperIntervaloType == 2)
//               Spinner<int>(
//                 values: _intervalosDia,
//                 value: wallpaperIntervalo,
//                 onChanged: _onIntervaloChanged,
//                 space: 10,
//               ),  // Dia
//
//             const Divider(),
//
//             ListTile(
//               title: const Text('Add album'),
//               leading: const Icon(Icons.add),
//               onTap: _onAddAlbumClick,
//             ),
//
//             for(var album in _albuns)
//               ListTile(
//                 title: Text(album.nome),
//                 subtitle: Text(album.parent?.nome ?? '${album.lengthPosts} posts salvos'),
//                 trailing: IconButton(
//                   tooltip: 'Remover',
//                   icon: const Icon(Icons.delete_forever),
//                   onPressed: () => _onAlbumRemoveClick(album),
//                 ),
//               ),
//
//             ElevatedButton(
//               onPressed: enableWallpaper ? _onSaveClick : null,
//               child: const Text('Salvar'),
//             ),  // Save
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _onSaveClick() {
//     Duration? time;
//     switch(wallpaperIntervaloType) {
//       case 0:
//         time = Duration(minutes: wallpaperIntervalo);
//         break;
//       case 1:
//         time = Duration(hours: wallpaperIntervalo);
//         break;
//       case 2:
//         time = Duration(days: wallpaperIntervalo);
//         break;
//     }
//
//     // callbackDispatche();
//     // return;
//
//     Map<String, dynamic> inputData = {
//       'location': papelDeParedeLocation,
//       'source': wallpaperSource,
//       'rating': wallpaperRating,
//       'both': coincidirWallpaperLockscreen,
//     };
//     _bgMng.habilitarTeste(
//       inputData: inputData,
//     );
//     _bgMng.habilitarWallpaper(
//       frequency: time,
//       inputData: inputData,
//     );
//     Log.snack('Habilitado');
//   }
//
//   void _onActivateChanged(bool? value) {
//     enableWallpaper = value ?? false;
//     setState(() {});
//
//     if (value ?? false) {
//       // _bgMng.habilitarWallpaper();
//     } else {
//       _bgMng.cancelAll();
//     }
//   }
//
//   void _onWallpaperChanged(String? value) {
//     papelDeParedeLocation = _location.indexOf(value ?? '');
//     setState(() {});
//   }
//
//   void _onWallpaperOnlineChanged(String? value) {
//     wallpaperSource = _imagensSource.indexOf(value ?? '');
//     setState(() {});
//   }
//
//   void _onRatingChanged(String? value) {
//     wallpaperRating = Rating.values.indexOf(value ?? '');
//     setState(() {});
//   }
//
//   void _onIntervaloTypeChanged(String? value) {
//     wallpaperIntervaloType = _intervaloType.indexOf(value ?? '');
//     setState(() {});
//   }
//
//   void _onIntervaloChanged(int value) {
//     wallpaperIntervalo = value;
//   }
//
//   void _onCoincidirChanged(bool? value) {
//     coincidirWallpaperLockscreen = value ?? false;
//     setState(() {});
//   }
//
//
//   void _onAddAlbumClick() async {
//     await showSearch(context: context, delegate: _DataSearch());
//     _albuns.clear();
//     _albuns.addAll(_albunsMng.wallpapers());
//     setState(() {});
//   }
//
//   void _onAlbumRemoveClick(Album album) {
//     _albuns.remove(album);
//     _albunsMng.saveWallpapers(_albuns);
//     setState(() {});
//   }
//
//   // void _onLockscreenChanged(bool? value) {
//   //   enableLockscreen = value ?? false;
//   //   setState(() {});
//   // }
//
// }
//
//
// class _DataSearch extends SearchDelegate<String> {
//
//   AlbunsManager get albunsMng => AlbunsManager.i;
//   final List<Album> listResults = [];
//
//   @override
//   String get searchFieldLabel => Strings.pesquisar;
//
//   @override
//   ThemeData appBarTheme(BuildContext context) {
//     return ThemeManager.i.themeData();
//   }
//
//   @override
//   List<Widget> buildActions(BuildContext context) =>
//       [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
//
//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: AnimatedIcon(
//         icon: AnimatedIcons.menu_arrow,
//         progress: transitionAnimation,
//       ),
//       onPressed: () {
//         close(context, '');
//       },
//     );
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
//     if (listResults.isEmpty) {
//       Navigator.pop(context);
//     }
//     return results();
//   }
//
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     listResults.clear();
//     if (query.isNotEmpty) {
//       listResults.addAll(albunsMng.find(query));
//     }
//
//     return results();
//   }
//
//
//   Widget results() {
//     return StatefulBuilder(
//       builder: (context, setState) => ListView.builder(
//         itemCount: listResults.length,
//         itemBuilder: (context, index) {
//           final item = listResults[index];
//
//           return ListTile(
//             title: Text(item.nome),
//             subtitle: Text(item.parent?.nome ?? ''),
//             onTap: () {
//               AlbunsManager.i.addWallpaperId(item.id);
//             },
//           );
//         },
//       ),
//     );
//   }
// }