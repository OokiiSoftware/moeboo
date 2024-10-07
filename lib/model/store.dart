import 'import.dart';

class Store {
  Album album;
  List<Post> posts;

  int _storePosition = 0;
  int get storePosition => _storePosition;

  Store({required this.album, required this.posts});

  int get postsLength => posts.length;

  Post postAt(int i) => posts[i];

  Post get current => posts[_storePosition];

  bool _todosVistos = false;
  bool get todosVistos {
    if (_todosVistos) {
      return _todosVistos;
    }

    for(int i = 0; i < postsLength; i++) {
      if (!posts[i].vistoInStore) {
        _storePosition = i;
        return false;
      }
    }
    _storePosition = 0;
    _todosVistos = true;
    return true;
  }

  bool get canNext => _storePosition +1 < postsLength;
  bool get canPrevious => _storePosition > 0;

  void nextPost() {
    if (canNext) {
      _storePosition++;
    }
  }

  void previousPost() {
    if (canPrevious) {
      _storePosition--;
    }
  }

}