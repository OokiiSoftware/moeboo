// import 'package:flutter/material.dart';
// import '../oki/util/logs.dart';
// import '../fragments/import.dart';
// import '../model/import.dart';
//
// class ReorderPage extends StatefulWidget {
//   final Album album;
//   const ReorderPage({required this.album, super.key});
//
//   @override
//   State<StatefulWidget> createState() => _State();
// }
// class _State extends State<ReorderPage> {
//   static const _log = Log('ReorderPage');
//
//   late List<PostG> posts;
//   Album get album => widget.album;
//
//   final ScrollController _controllerReorder = ScrollController();
//
//   @override
//   void dispose() {
//     super.dispose();
//     _controllerReorder.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     posts = album.getGroup(false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reordenando'),
//       ),
//       body: PostsFragmentReorder(
//         posts: posts,
//         onReorder: _onPostReorder,
//         controller: _controllerReorder,
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         label: const Text('Salvar'),
//         onPressed: _onSaveReorderClick,
//       ),
//     );
//   }
//
//   void _onPostReorder(int a, int b) {
//     final postA = posts[a];
//
//     if (a > b) {
//       for (int i = a; i > b; i--) {
//         final temp = posts[i];
//         posts[i] = posts[i-1];
//         posts[i-1] = temp;
//       }
//     } else {
//       for (int i = a; i < b; i++) {
//         final temp = posts[i];
//         posts[i] = posts[i+1];
//         posts[i+1] = temp;
//       }
//     }
//
//     posts[b] = postA;
//     _setState();
//   }
//
//   void _onSaveReorderClick() {
//     Navigator.pop(context, posts);
//     return;
//     final items = <Post>[];
//     for (var value in posts) {
//       items.addAll(value.posts);
//     }
//
//     try {
//       album.setOrdenadedList(items);
//     } catch(e) {
//       _log.e('onSaveReorderClick', e);
//       Log.snack(e.toString(), isError: true);
//     }
//   }
//
//   void _setState() {
//     if (mounted) {
//       setState(() {});
//     }
//   }
// }