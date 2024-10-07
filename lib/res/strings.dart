import 'package:flutter/cupertino.dart';

import '../provider/import.dart';
import 'import.dart';

class Ressources {
  static const String appName = 'MoeBoo';
  static const String appPackage = 'com.okisoft.moeboo';
}

class Assets {
  static const String icLauncher = 'assets/icons/ic_launcher.png';
  // static const String icLauncherAdaptive = 'assets/icons/ic_launcher_adaptive.png';
}

class Erros {
  // static const String openLink = 'Erro ao abrir este link';
}

class Childs {
  static const String boorus = 'boorus';
  static const String booru = 'booru';
  static const String auth = 'auth';
  static const String booruOpt = 'booruOpt';
  static const String blackList = 'blackList';
  static const String albunsWallpaper = 'albunsWallpaper';
  static const String rating = 'ratting';
  static const String theme = 'theme';
  static const String useOnlySafeAsCapa = 'useOnlyCapaSafe';
  static const String videoIsMute = 'isVideoMuted';
  static const String saveImagensReduzidas = 'saveImagesReduzidas';
  static const String saveTags = 'saveTags';
  static const String limparCacheAoFecharApp = 'LIMPAR_CACHE_AO_FECHAR_APP';
  static const String criarPreviewsDeQualidade = 'CIAR_PREVIEWS_QUALIDADE';
  static const String idiomaAtual = 'idiomaAtual';
  static const String enableWallpaper = 'ENABLE_WALLPAPER';
  static const String wallpaperSource = 'WALLPAPER_SOURCE';
  static const String wallpaperRating = 'WALLPAPER_RATING';
  static const String wallpaperIntervaloType = 'WALLPAPER_INTERVALO_TYPE';
  static const String papelDeParedeLocation = 'PAPEL_DE_PAREDE_LOCATION';
  static const String wallpaperIntervalo = 'ENABLE_LOCKSCREEN';
  static const String coincidirWallpaperLockscreen = 'COINCIDIR_WALLPAPER_LOCKSCREEN';
  static const String autoManagerBooru = 'autoManagerBooru';
  static const String albuns = "ALBUNS";
}

Map<String, String> _menuSubtitle(BuildContext context) {
  ILanguage ui = idioma;

  return {
    ui.novoAlbum: ui.subAlbum,
    ui.unirPosts: ui.unirPostsSemelhantes,
    ui.tagsCount: ui.verificarNumeroPosts,
    ui.editarAlbum: ui.alterarNomeETags,
    ui.excluirAlbum: ui.excluirEsteAlbum,
    ui.resetCapa: ui.usarCapaPadrao,
    ui.autoUpdateCapa: ui.semprePostRecente,
    ui.useAlbumAsCapa: ui.usarComoCapaColecao,
    ui.info: ui.dadosDesteAlbum,
    ui.goToPage: ui.paginaBuscaNaWeb,
    ui.maturidade: BooruProvider.i.rating.join(', '),
    for (var booru in Boorus.allValues.values)
      booru.name: ui.provedor,
  };
}

String menuSubtitle(BuildContext context, String value) {
  String data = _menuSubtitle(context)[value] ?? '';

  return data;
}