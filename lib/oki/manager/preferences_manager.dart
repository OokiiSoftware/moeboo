import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/logs.dart';

class Preferences {

  static const _log = Log('Preferences');
  static Preferences pref = Preferences();

  SharedPreferences? _instance;

  int getInt(String key, {int def = 0}) => _instance?.getInt(key) ?? def;
  bool getBool(String key, {bool def = false}) => _instance?.getBool(key) ?? def;
  String getString(String key, {String def = ''}) => _instance?.getString(key) ?? def;
  double getDouble(String key, {double def = 0.0}) => _instance?.getDouble(key) ?? def;
  List getList(String key, {List<String> def = const <String>[]}) => _instance?.getStringList(key) ?? def;
  dynamic getObj(String key, {dynamic def}) {
    var temp = getString(key);
    if (temp.isEmpty) {
      return def;
    }
    return jsonDecode(temp);
  }

  Future<void> setInt(String key, int value) async => await _instance?.setInt(key, value);
  Future<void> setBool(String key, bool value) async => await _instance?.setBool(key, value);
  Future<void> setDouble(String key, double value) async => await _instance?.setDouble(key, value);
  Future<void> setString(String key, String? value) async => await _instance?.setString(key, value?? '');
  Future<void> setList(String key, List<String> value) async => await _instance?.setStringList(key, value);
  Future<void> setObj(String key, dynamic value) async => await setString(key, json.encode(value));

  Future<void> remove(String key) async => await _instance?.remove(key);

  bool containsKey(String key) => _instance?.containsKey(key) ?? false;

  Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
    _log.d('init', 'OK');
  }
}

class PrefKey {
  static const String isPlayStore = "isPlayStory";
  static const String showDebugLogs = "SHOW_DEBUG";
  static const String albumLayout = "ALBUNS_LAYOUT";
  static const String bloqueioBlur = "BLOQUEIO_BLUR";
  static const String postsLayout = "POSTS_LAYOUT";
  static const String paginaLayout = "PAGINA_LAYOUT2";
  static const String bloqueioType = "BLOQUEIO_TYPE";
  static const String postsQuant = "POSTS_QUANT";
  static const String postsLimit = "POSTS_LIMIT";
  static const String usePostGroupsKey = "_USE_GROUP_POSTS_KEY";
  static const String showPosstsOnlineKey = "_SHOW_POSTS_ONLINE_KEY";
  static const String createDirectorys = "CREATE_DIECTORYS_2";
  static const String avidoBooruLinksExpire = "AVISO_BORU_LINK_EXPIRE2";
  static const String avidoBooruCapaExpire = "AVISO_BORU_CAPA_EXPIRE";
  static const String overridePostsExpireds = "OVERRIDE_EXPIRABLE_BOORU";
  static const String wallpaperPath = "wallpaper";
  static const String providersEnableds = "providersEnableds";

  static const String collectionAlbumSearch = "collectionAlbumSearch3";
  static const String albumGroup = "albumGroup4";
  static const String albumOnline = "albumOnline4";
  static const String postClick = "postClick";
  static const String unirPosts = "unirPosts_3";
  static const String atualizarPost = "atualizarPost_3";
  static const String setCapaPost = "setCapaPost_3";

  static const String postPageSlide = "postPageSlide";
  static const String postPageTags = "postPageTags";
  static const String postPageFav = "postPageFav";
  static const String postPageSave = "postPageSave";
  static const String postPageLike = "postPageLike";
  static const String postPageQualit = "postPageQualit";

}
