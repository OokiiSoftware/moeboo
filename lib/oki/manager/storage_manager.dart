import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../import.dart';

class StorageManager {

  static const _log = Log('StorageManager');
  static StorageManager i = StorageManager();

  late String localPath;
  late String cachePath;

  Future<void> init() async {
    await _loadLocalPath();
    // await createFolder(Directorys.postsCompressed, cache: true);
    await createFolder(Directorys.previews, cache: true);
    await createFolder(Directorys.posts, cache: true);
    await createFolder(Directorys.search, cache: true);

    await createFolder(Directorys.previews);
    await createFolder(Directorys.posts);
    await createFolder(Directorys.search);

    await createFolder(Directorys.backup);
    pref.setString(PrefKey.wallpaperPath, '${file(PrefKey.wallpaperPath).path}.jpg');
    _log.e('init', 'OK');
  }

  Future<void> _loadLocalPath() async {
    if (Platform.isAndroid) {
      final directory = await getTemporaryDirectory();
      cachePath = '${directory.path}$deviceDivider${Directorys.appFolder}';

      final directory2 = await getApplicationSupportDirectory();
      localPath = '${directory2.path}$deviceDivider${Directorys.appFolder}';
    } else {
      final directory = await getApplicationDocumentsDirectory();
      localPath = '${directory.path}${deviceDivider}OkiSoft$deviceDivider${Directorys.appFolder}';

      cachePath = '$localPath${deviceDivider}cache';
    }
  }

  Future<Map<String, dynamic>> loadTest() async {
    Map<String, dynamic> map = {};

    int position = 0;
    try {
      try {
        var temp = await getTemporaryDirectory();
        map['temp'] = temp.path;
      } catch(e) {
        map['temp'] = e.toString();
      }
      position++;
      try {
        var suport = await getApplicationSupportDirectory();
        map['suport'] = suport.path;
      } catch(e) {
        map['suport'] = e.toString();
      }
      position++;
      try {
        var library = await getLibraryDirectory();
        map['library'] = library.path;
      } catch(e) {
        map['library'] = e.toString();
      }
      position++;
      try {
        var docs = await getApplicationDocumentsDirectory();
        map['docs'] = docs.path;
      } catch(e) {
        map['docs'] = e.toString();
      }
      position++;
      try {
        // var external = await getExternalStorageDirectory();
        // externalPath = external!.path.replaceAll('Android/data/com.ookiisoftware.booru/files', 'booru');
        // map['external'] = externalPath;
      } catch(e) {
        map['external'] = e.toString();
      }
      position++;
      try {
        var download = await getDownloadsDirectory();
        map['download'] = download?.path;
      } catch(e) {
        map['download'] = e.toString();
      }
      position++;
      try {
        var cache = await getExternalCacheDirectories();
        map['cache'] = cache?.asMap().toString();
      } catch(e) {
        map['cache'] = e.toString();
      }
      position++;
      try {
        var externals = await getExternalStorageDirectories();
        map['externals'] = externals?.asMap().toString();
      } catch(e) {
        map['externals'] = e.toString();
      }
      position++;
    } catch(e) {
      map['ERROR'] = e.toString();
    }

    map['position'] = position.toString();
    return map;
  }

  String makePath(List<String> path) {
    return '$localPath$deviceDivider${path.join(deviceDivider)}';
  }

  Future<String?> createFolder(String name, {bool external = false, bool cache = false}) async {
    var temp = Directory('${getPath(external, cache)}$deviceDivider$name');
    if (!await temp.exists()) {
      await temp.create(recursive: true);
    }
    return null;
  }

  Future deleteFolder(String name, {bool cache = false}) async {
    var temp = Directory('${getPath(false, cache)}$deviceDivider$name');
    if (temp.existsSync()) {
      await temp.delete(recursive: true);
    }
  }

  Directory getFolder(List<String> path, {bool external = false, bool cache = false}) {
    return Directory('${getPath(external, cache)}$deviceDivider${path.join(deviceDivider)}');
  }

  /// /storage/emulated/0/Pictures/AniAlbum
  Directory appFolder() {
    return Directory('${getPath(true, false)}}');
  }

  /// Storage root => /storage/emulated/0
  Directory getRoot() {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0');
    }

    return Directory('C:/');
  }

  Future<bool> delete(String fileName, [String? path]) async {
    if (!fileExist(fileName, path)) {
      return false;
    }
    await file(fileName, path: path).delete();
    return true;
  }

  Future<bool> resetAppFolfer() async {
    try {
      await getFolder([]).delete(recursive: true);
      await getFolder([], cache: true).delete(recursive: true);
      await init();
      return true;
    } catch(e) {
      _log.e('resetAppFolfer', e);
      return false;
    }
  }

  bool fileExist(String fileName, [String? path]) => file(fileName, path: path).existsSync();

  File file(String fileName, {String? path, bool external = false, bool cache = false}) {
    if (path == null || path.isEmpty) {
      return File('${getPath(external, cache)}$deviceDivider$fileName');
    }
    return File('${getPath(external, cache)}$deviceDivider$path$deviceDivider$fileName');
  }

  String getPath(bool external, bool cache) {
    if (cache) {
      return cachePath;
    }
    return localPath;
  }

  String convertBytesToMb(int value) {
    var kb = value / 1024;
    if (kb < 1024) {
      return '${kb.toInt()} Kb';
    }

    var mb = kb / 1024;

    if (mb < 1000) {
      return '${mb.toStringAsFixed(2)} Mb';
    }

    var gb = mb / 1024;

    return '${gb.toStringAsFixed(2)} Gb';
  }

}

class Directorys {
  static const String appFolder = 'MoeBoo';

  static const String posts = 'posts';
  static const String previews = 'previews';
  // static const String postsCompressed = 'posts_compressed';
  // static const String previewsCompressed = 'previews_compressed';

  static const String search = 'search';
  static const String backup = 'backups';
}

String get deviceDivider => Platform.isWindows ? '\\': '/';
