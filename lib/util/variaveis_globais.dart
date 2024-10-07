import 'dart:io';
import '../oki/import.dart';

bool get isRelease => const bool.fromEnvironment('dart.vm.product');
bool get isDebug => !isRelease;

bool get isPlayStory => pref.getBool(PrefKey.isPlayStore, def: true);
set isPlayStory(bool value) => pref.setBool(PrefKey.isPlayStore, value);

bool get showDebug => pref.getBool(PrefKey.showDebugLogs, def: false);
set showDebug(bool value) => pref.setBool(PrefKey.showDebugLogs, value);

bool get sobrescreverExpiredPosts => pref.getBool(PrefKey.overridePostsExpireds, def: false);
set sobrescreverExpiredPosts(value) => pref.setBool(PrefKey.overridePostsExpireds, value);

bool get useOnlySafeAsCapa => pref.getBool(Childs.useOnlySafeAsCapa, def: true);
set useOnlySafeAsCapa(bool value) => pref.setBool(Childs.useOnlySafeAsCapa, value);

bool get videoIsMute => pref.getBool(Childs.videoIsMute, def: false);
set videoIsMute(bool value) => pref.setBool(Childs.videoIsMute, value);

bool get limparCacheAoFecharApp => pref.getBool(Childs.limparCacheAoFecharApp, def: false);
set limparCacheAoFecharApp(bool value) => pref.setBool(Childs.limparCacheAoFecharApp, value);

// bool get saveImagensReduzidas => pref.getBool(Childs.saveImagensReduzidas, def: false);
// set saveImagensReduzidas(bool value) => pref.setBool(Childs.saveImagensReduzidas, value);

bool get saveTags => pref.getBool(Childs.saveTags, def: false);
set saveTags(bool value) => pref.setBool(Childs.saveTags, value);

bool get criarPreviewsDeQualidade => pref.getBool(Childs.criarPreviewsDeQualidade, def: true);
set criarPreviewsDeQualidade(bool value) => pref.setBool(Childs.criarPreviewsDeQualidade, value);

// String get idiomaAtual => pref.getString(Childs.idiomaAtual, def: 'Português');
// set idiomaAtual(String value) => pref.setString(Childs.idiomaAtual, value);


bool get enableWallpaper => pref.getBool(Childs.enableWallpaper, def: false);
set enableWallpaper(bool value) => pref.setBool(Childs.enableWallpaper, value);

bool get coincidirWallpaperLockscreen => pref.getBool(Childs.coincidirWallpaperLockscreen, def: false);
set coincidirWallpaperLockscreen(bool value) => pref.setBool(Childs.coincidirWallpaperLockscreen, value);

// bool get autoManagerBooru => pref.getBool(Childs.autoManagerBooru, def: false);
// set autoManagerBooru(bool value) => pref.setBool(Childs.autoManagerBooru, value);


int get papelDeParedeLocation => pref.getInt(Childs.papelDeParedeLocation, def: 0);
set papelDeParedeLocation(int value) => pref.setInt(Childs.papelDeParedeLocation, value);

int get wallpaperSource => pref.getInt(Childs.wallpaperSource, def: 0);
set wallpaperSource(int value) => pref.setInt(Childs.wallpaperSource, value);

int get wallpaperRating => pref.getInt(Childs.wallpaperRating, def: 0);
set wallpaperRating(int value) => pref.setInt(Childs.wallpaperRating, value);

int get wallpaperIntervaloType => pref.getInt(Childs.wallpaperIntervaloType, def: 0);
set wallpaperIntervaloType(int value) => pref.setInt(Childs.wallpaperIntervaloType, value);

int get wallpaperIntervalo => pref.getInt(Childs.wallpaperIntervalo, def: 0);
set wallpaperIntervalo(int value) => pref.setInt(Childs.wallpaperIntervalo, value);

int get albunsLatoyt => pref.getInt(PrefKey.albumLayout, def: 0);
set albunsLatoyt(int value) => pref.setInt(PrefKey.albumLayout, value);

int get postsLatoyt => pref.getInt(PrefKey.postsLayout, def: 1);
set postsLatoyt(int value) => pref.setInt(PrefKey.postsLayout, value);

bool get usePage => pref.getBool(PrefKey.paginaLayout, def: false);
set usePage(bool value) => pref.setBool(PrefKey.paginaLayout, value);

int get bloqueioType => pref.getInt(PrefKey.bloqueioType, def: 1);
set bloqueioType(int value) => pref.setInt(PrefKey.bloqueioType, value);

int get postsPorPage => pref.getInt(PrefKey.postsQuant, def: 100);
set postsPorPage(int value) => pref.setInt(PrefKey.postsQuant, value);

// int get postsLimit => pref.getInt(PrefKey.postsLimit, def: 50);
// set postsLimit(int value) => pref.setInt(PrefKey.postsLimit, value);

double get blurBloqueio => pref.getDouble(PrefKey.bloqueioBlur, def: 8.0);
set blurBloqueio(double value) => pref.setDouble(PrefKey.bloqueioBlur, value);

final OkiBool usePostsGroup = OkiBool(pref.getBool(PrefKey.usePostGroupsKey, def: true));
final OkiBool showOnline = OkiBool(pref.getBool(PrefKey.showPosstsOnlineKey, def: true));

bool get isMobile => Platform.isAndroid || Platform.isIOS;
bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;