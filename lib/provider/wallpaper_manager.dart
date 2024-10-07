import 'dart:ffi';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:win32/win32.dart';
import '../model/import.dart';
import '../util/util.dart';
import '../oki/import.dart';
// ignore: depend_on_referenced_packages
import 'package:ffi/ffi.dart';
import 'import.dart';

class WallpaperProvider {
  static const _log = Log('WallpaperManager');

  final List<String> _albumWallpapersId = [];

  static WallpaperProvider i = WallpaperProvider();

  DesktopWallpaper? _wallpaperWindows;

  /// [locationId] Wallpaper (1); LockScreem (2); Wallpaper e LockScreem (3)
  Future<String?> setFile(File file, {int locationId = 1}) async {
    try {
      await _set(file, locationId);
      _log.d('setFile', 'OK');
      return null;
    } catch(e) {
      _log.e('setFile', e, 'file', file.path);
      return 'Falha ao aplicar papel de parede';
    }
  }

  /// [locationId] Wallpaper (1); LockScreem (2); Wallpaper e LockScreem (3)
  Future<String?> setUrl(String url, {int locationId = 1}) async {
    try {
      var response = await http.get(Uri.parse(url));
      File file = File(pref.getString(PrefKey.wallpaperPath));
      file = await file.writeAsBytes(response.bodyBytes);

      await _set(file, locationId);
      _log.d('setUrl', 'OK');
      return null;
    } catch(e) {
      _log.e('setUrl', e, url);
      return 'Falha ao aplicar papel de parede';
    }
  }

  /// [locationId] Wallpaper (1); LockScreem (2); Wallpaper e LockScreem (3)
  Future<void> set(dynamic data, {int locationId = 1}) async {
    File? file;
    if (data is String) {
      var response = await http.get(Uri.parse(data));
      file = File(pref.getString(PrefKey.wallpaperPath));
      file = await file.writeAsBytes(response.bodyBytes);
    } else if (data is File) {
      file = data;
    }

    _log.d('set', 'file', file?.path);
    await _set(file, locationId);
    _log.e('set', 'OK');
  }

  void setWindowSlide(List<dynamic> data, int tick) {
    Pointer<COMObject> items = Pointer<COMObject>.fromAddress(0);

    _wallpaperWindows?.setSlideshow(items);
    _wallpaperWindows?.setSlideshowOptions(DESKTOP_SLIDESHOW_OPTIONS.DSO_SHUFFLEIMAGES, tick);
  }

  Future<void> _set(File? file, int location) async {
    if (isDesktop) {
      // print(_wallpaperWindows.Get(Pointer.fromAddress(0)));
      var d = file?.path.toNativeUtf16();
      if (d != null) {
        _wallpaperWindows?.setWallpaper(Pointer.fromAddress(0), d);
      }
    } else if (isMobile) {
      if (file == null || !file.existsSync()) {
        throw 'set: file não existe';
      }

      await computeWallpaper(ComputeParams(
        path: file.path,
        data: location,
      ));
      // await AsyncWallpaper.setWallpaperFromFile(
      //   filePath: file.path,
      //   wallpaperLocation: location,
      // );

      // if (location == 3) {
      //   _wallpaper?.setwallpaperfromFile(file, 1);
      //   _wallpaper?.setwallpaperfromFile(file, 2);
      // } else {
      //   _wallpaper?.setwallpaperfromFile(file, location);
      // }
    }
  }



  List<Album> wallpapers() {
    List<Album> items = [];
    for (var albumId in _albumWallpapersId) {
      final item = AlbunsProvider.i.album.findAlbum(albumId);

      if (item != null) {
        items.add(item);
      }
    }
    return items;
  }

  void saveWallpapers([List<Album>? values]) {
    if (values != null) {
      _albumWallpapersId.clear();
      for (var album in values) {
        _albumWallpapersId.add(album.id);
      }
    }

    database.child(Childs.albunsWallpaper).set(_albumWallpapersId);
    _log.d('saveWallpapers', 'OK');
  }

  void addWallpaperId(String id) {
    if (!_albumWallpapersId.contains(id)) {
      _albumWallpapersId.add(id);
      saveWallpapers();
    }
  }

  void load() {
    if (isDesktop) {
      _wallpaperWindows = DesktopWallpaper.createInstance();
    }

    List ids = database.child(Childs.albunsWallpaper).get(def: <String>[]).value;
    for (var id in ids) {
      _albumWallpapersId.add(id);
    }
  }
}