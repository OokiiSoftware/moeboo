import 'package:flutter/material.dart';
import '../../fragments/import.dart';
import '../provider/import.dart';
import '../model/import.dart';
import '../oki/import.dart';
import '../res/import.dart';

class AnalizePage extends StatefulWidget {
  final PostG group;
  final Album album;
  const AnalizePage({required this.album, required this.group, super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<AnalizePage> {

  Album get album => widget.album;
  final List<PostG> posts = [];

  final OkiInt _selecting = OkiInt();

  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    for (var post in widget.group.posts) {
      posts.add(PostG(
        id: post.id,
        album: album,
        posts: [post],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: _onWillPopScope,
      canPop: _canPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Análize do grupo'),
          actions: [
            OkiStatefulBuilder(
              dispose: (setState) => _selecting.onChanged = null,
              builder: (context, setState, state) {
                _selecting.onChanged = setState;
                return IconButton(
                  tooltip: 'Add / Remover',
                  icon: const Icon(Icons.bookmark),
                  onPressed: _selecting.value > 0 ? _onRemoveClick : null,
                );
              },
            ),
          ],
        ),
        body: PostsFragment(
          posts: posts,
          builder: (item) {
            return PostTile(
              key: Key('${item.hashCode}'),
              post: item,
              showMarker: true,
              onTap: _onPostClick,
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _onWillPopScope(false),
          child: const Text('OK'),
        ),
      ),
    );
  }

  void _onWillPopScope(bool value) async {
    PostG? post1;
    PostG? post2;

    for (var post in posts) {
      post.isSelected = false;

      if (post.isAnalizing) {
        post1 ??= PostG(id: post.id, album: album);

        post1.addAll(post.posts);
        post.isAnalizing = false;

      } else {
        post2 ??= PostG(id: post.id, album: album);
        post2.addAll(post.posts);
      }
    }

    album.removeGroup(widget.group.id);
    album.addAllPosts(post1?.posts);
    album.addAllPosts(post2?.posts);

    if (post1 != null && post2 != null) {
      Navigator.pop(context, true);
      AlbunsProvider.i.save();
      return;
    }
    _canPop = true;
    setState(() {});
  }

  void _onPostClick(PostG post) {
    post.isSelected = !post.isSelected;

    if (post.isSelected) {
      _selecting.value++;
    } else {
      _selecting.value--;
    }
  }

  void _onRemoveClick() {
    for (var post in posts) {
      if (post.isSelected) {
        post.isAnalizing = !post.isAnalizing;
        post.isSelected = false;
      }
    }
    _selecting.value = 0;
  }

}