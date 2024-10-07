// import 'dart:math';
// import '../../auxiliar/import.dart';
// import '../../booru/import.dart';
// import '../../manager/import.dart';
// import '../../model/import.dart';
// import '../import.dart';

/*class BackgroundManager {
  static const _tag = 'BackgroundManager';
  static BackgroundManager i = BackgroundManager();

  final workmanager = Workmanager();

  bool _iniciado = false;

  void habilitarWallpaper({Map<String, dynamic>? inputData, Duration? frequency}) async {
    if (isMobile) {
      await init();
      await workmanager.registerPeriodicTask(
        "1",
        "wallpaper",
        frequency: frequency ?? const Duration(days: 1),
        inputData: inputData ?? {'a': 'a'},
      );
    } else {

    }
    Log.d(_tag, 'habilitarWallpaper', 'OK', 'frequency', frequency);
  }

  void habilitarTeste({Map<String, dynamic>? inputData}) async {
    await init();
    await workmanager.registerOneOffTask(
      "2",
      "wallpaper teste",
      inputData: inputData ?? {'a' : 'a'},
    );
    Log.d(_tag, 'habilitarTeste', 'OK');
  }

  void cancelAll() {
    workmanager.cancelAll();
  }

  Future<void> init() async {
    if (!_iniciado && isMobile) {
      await BackgroundManager.i.workmanager.initialize(
        callbackDispatche,
        isInDebugMode: !isRelease,
      );
      _iniciado = true;
    }
  }

}*/


void callbackDispatche() async {
  // final album = AlbunsManager.i.getRandomAlbum(
  //   // ignore: (album) => album.isPostsEmpty,
  // );
  // await album?.computPosts();
  //
  // final List<dynamic> posts = [];
  // posts.add(album?.getRandomPost(Rating.safe)?.anyFile);
  // posts.add(album?.getRandomPost(Rating.safe)?.anyFile);
  //
  // Log.d('BackgroundManager', 'callbackDispatcher', 'album', album?.nome);
  // Log.d('BackgroundManager', 'callbackDispatcher', 'items', posts);
  //
  // return;

  /*BackgroundManager.i.workmanager.executeTask((task, inputData) async {
    try {
      Log.d('BackgroundManager', 'callbackDispatcher', task);
      final booru = Konachan();
      final List<dynamic> posts = [];

      int location = inputData!['location'] ?? 0;
      int source = inputData['source'] ?? 0;
      List<String> rating = inputData['rating'] ?? <String>[];
      bool both = inputData['both'] ?? false;

      location++;

      if (source == 2) {
        source = Random().nextInt(2);
      }

      if (source == 0) {
        await Preferences.pref.init();
        await StorageManager.i.init();
        await Database.i.load();

        AlbunsManager.i.load();

        final ab = AlbunsManager.i.wallpapers();

        Album? album;
        if (ab.isEmpty) {
          album = AlbunsManager.i.getRandomAlbum(
            ignore: (album) => album.isPostsEmpty,
          );
        } else {
          album = ab[Random().nextInt(ab.length)];
        }

        await album?.computPosts();
        posts.add(album?.getRandomPost(rating)?.anyFile);
        posts.add(album?.getRandomPost(rating)?.anyFile);
        Log.d('BackgroundManager', 'callbackDispatcher', 'album', album?.nome, album?.lengthPosts);
      } else if (source == 1) {
        final temp = await booru.getLastPosts(
          query: AlbumQuery(
            postsLimit: 2,
            rating: rating,
            tags: ['realistic'],
          ),
        );
        posts.add(temp[0]?.sampleUrl);
        posts.add(temp[1]?.sampleUrl);
      }

      posts.removeWhere((e) => e == null);

      Log.d('BackgroundManager', 'callbackDispatcher', 'items', posts);

      if (posts.isEmpty) {
        return false;
      }

      if (both) {
        WallpaperManage.i.set(posts[0], locationId: location);
      } else {
        if (location != 3) {
          WallpaperManage.i.set(posts[0], locationId: location);
        } else {
          WallpaperManage.i.set(posts[0], locationId: 1);
          WallpaperManage.i.set(posts[1], locationId: 2);
        }
      }

      Log.d('BackgroundManager', 'callbackDispatcher', 'Set wallpaper', 'OK');
    } catch(e) {
      Log.e('BackgroundManager', 'callbackDispatcher', e);
      return false;
    }

    return true;
  });*/
}
