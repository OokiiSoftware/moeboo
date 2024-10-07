import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../booru/import.dart';
import '../model/import.dart';
import '../oki/import.dart';
import 'import.dart';

/// provider > albuns_provider.dart
/// Indica se o usuário está movendo algum album
bool get isUnindoAlbum => albumParaUnir != null;
Album? albumParaUnir;

class AlbunsProvider extends ChangeNotifier {
  static const _log = Log('AlbunsProvider');

  static AlbunsProvider i = AlbunsProvider();
  static const String rootId = 'MoeBoo_547634';
  static const String salvosId = 'SALVOS_96543565';
  static const String analizeId = 'ANALIZE_96543565';
  static const String favoritosId = 'FAVORITOS_96543565';
  static const String _backupKey = '_BACKUP_KEY';

  final Album album = Album(id: rootId, nome: Ressources.appName);
  Album get favoritos {
    if (!album.containsKey(favoritosId)) {
      album[favoritosId] = Album(id: favoritosId, nome: 'Favoritos');
    }
    return album[favoritosId]!;
  }
  Album get salvos {
    if (!album.containsKey(salvosId)) {
      album[salvosId] = Album(id: salvosId, nome: 'Salvos');
    }
    return album[salvosId]!;
  }

  String get backupTimestamp {
    return database.child(_backupKey).get(def: '').value;
  }
  set backupTimestamp(String value) => database.child(_backupKey).set(value);

  Map<String, Album> getAllAlbuns({Album? from, Album? toIgnore}) {
    from??= album;
    Map<String, Album> items = {};
    from.forEach((key, value) {
      if ((toIgnore?.id?? '') != key) {
        items[key] = value;
        items.addAll(getAllAlbuns(from: value, toIgnore: toIgnore));
      }
    });
    return items;
  }

  double getCacheSize([String path = '']) {
    int totalSize = 0;
    var dir = StorageManager.i.getFolder([path]);
    try {
      if (dir.existsSync()) {
        dir.listSync(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
          if (entity is File) {
            totalSize += entity.lengthSync();
          }
        });
      }
    } catch (e) {
      _log.e('getCacheSize', e);
    }

    double bytesToMb(int value) {
      var kb = value / 1024;
      return kb / 1024;
    }
    return bytesToMb(totalSize);
  }

  Future<Map<String, dynamic>> getCacheSizeMap(String path, [bool cache = false]) async {
    int totalSize = 0;
    int totalItems = 0;
    // List<String> paths = [];
    var dir = StorageManager.i.getFolder([path], cache: cache);
    try {
      if (dir.existsSync()) {
        await dir.list(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
          if (entity is File) {
            totalItems++;
            totalSize += entity.lengthSync();
            // paths.add(entity.path);
          }
        });
      }
    } catch (e) {
      _log.e('getCacheSize', e);
    }

    double bytesToMb(int value) {
      var kb = value / 1024;
      return kb / 1024;
    }

    return {
      'size': bytesToMb(totalSize).toStringAsFixed(2),
      'sizeName': StorageManager.i.convertBytesToMb(totalSize),
      'filesCount': totalItems,
      // 'files': paths,
    };
  }

  @Deprecated('Método descontinuado')
  Future<Album> getSavedPosts() async {
    final sav = Album(
      id: salvosId,
      nome: 'SALVOS',
    );
    await album.computPosts(recursive: true);

    sav.addAllPosts(album.getSavedPosts(recursive: true));
    return sav;
  }

  @Deprecated('Método descontinuado')
  Future<Album> getFavoritos() async {
    final fav = Album(
      id: favoritosId,
      nome: 'FAVORITOS',
    );
    await album.computPosts(recursive: true);

    fav.addAllPosts(album.getFavoritos(recursive: true));
    return fav;
  }

  List<Album> find(String query) {
    query = query.toLowerCase();
    return album.findAlbums(query);
  }

  Future<List<Store>> getStories([int? length]) async {
    Random random = Random();
    length ??= random.nextInt(50);

    var booru = BooruProvider.i;

    List<Store> stores = [];

    final albumRoot = album.copy();
    final albuns = albumRoot.getAlbuns(
      addOcultos: AuthManager.auth.isAuthenticated,
    );

    if (albuns.isEmpty) return stores;

    List<Future> futures = [];
    List<int> ids = [];

    for(int i = 0; i < length; i++) {
      int id = random.nextInt(albuns.length);
      if (ids.contains(id)) continue;

      ids.add(id);
      var album = albuns.toList()[id];
      // await album.computPosts();
      futures.add(album.computPosts());
    }

    await Future.wait(futures);

    albuns.removeWhere((album) {
      if (album.lengthPosts == 0) return true;

      // if (!AuthManager.auth.isAuthenticated && album.isOculto) return true;

      album.removePostsWhere((key, value) {
        if (value.isVideo) return true;

        var rating = booru.rating;
        if (!AuthManager.auth.isAuthenticated) {
          rating.removeWhere((b) => b != Rating.safeValue);
        }
        return IBooru.removeWithRating(value, rating);
      });

      if (album.isPostsEmpty) return true;

      return false;
    });

    if (albuns.isEmpty) return stores;

    ids.clear();
    for(int i = 0; i < length; i++) {
      int id = random.nextInt(albuns.length);
      if (ids.contains(id)) continue;

      ids.add(id);

      var album = albuns.toList()[id];
      var postsTemp = album.getSavedPosts();
      List<Post> posts = [];

      if (postsTemp.isEmpty) continue;

      int postsCount = random.nextInt(postsTemp.length >= 10 ? 10 : postsTemp.length);
      for(int i = 0; i < postsCount; i++) {
        final post = postsTemp[random.nextInt(postsTemp.length)];
        postsTemp.remove(post);

        if (post.booruName == Sankaku.name_ && !post.hasAnyFile) continue;

        posts.add(post);
      }

      if (posts.isEmpty) continue;

      stores.add(Store(
        album: album,
        posts: posts,
      ));
    }

    return stores;
  }

  Post? getRandomSavedPost(List<String> rating) {
    final posts = album.getSavedPosts(recursive: true, needExist: true, rating: rating);
    final random = Random();

    if (posts.isEmpty) {
      return null;
    }

    return posts.elementAt(random.nextInt(posts.length));
  }

  Album? getRandomAlbum({bool Function(Album)? ignore}) {
    final list = album.getAlbuns(addOcultos: false);

    final random = Random();

    list.removeWhere(ignore ?? (item) => false);
    // list.removeWhere((item) => !(item.capa?.contains(Ressources.appName) ?? false));
    if (list.isEmpty) {
      return null;
    }

    return list.elementAt(random.nextInt(list.length));
  }

  Future<void> save() async {
    await database.child(Childs.albuns).set(album.mapToSave());
    _log.d('save', 'OK');
  }

  bool load() {
    // Preferences.pref.remove(PreferencesKey.ALBUNS);

    var dataTemp = database.child(Childs.albuns).get();
    if (dataTemp.value == null) {
      return true;
    }

    try {
      _setAlbum(dataTemp.value);
      _log.d('load', 'OK');
    } catch(e) {
      _log.e('load', e);
    }

    return true;
  }

  void _setAlbum(Map<String, dynamic> item) {
    album.set(item..['id'] = rootId, null);
    if (!album.containsKey(favoritosId)) {
      album[favoritosId] = Album(id: favoritosId, nome: 'Favoritos');
    }

    notifyListeners();
  }

}