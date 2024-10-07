export 'compute.dart';
export 'player_mobile.dart';
export 'variaveis_globais.dart';
export 'video_controller.dart';

import 'package:moeboo/model/import.dart';

import '../oki/manager/preferences_manager.dart';
import '../oki/util/util.dart';

class Tutorial {

  static bool get collectionAlbumSearch => pref.getBool(PrefKey.collectionAlbumSearch);
  static set collectionAlbumSearch(bool value) => pref.setBool(PrefKey.collectionAlbumSearch, value);

  static bool get unirPosts => pref.getBool(PrefKey.unirPosts);
  static set unirPosts(bool value) => pref.setBool(PrefKey.unirPosts, value);

  static bool get atualizarPost => pref.getBool(PrefKey.atualizarPost);
  static set atualizarPost(bool value) => pref.setBool(PrefKey.atualizarPost, value);

  static bool get setCapaPost => pref.getBool(PrefKey.setCapaPost);
  static set setCapaPost(bool value) => pref.setBool(PrefKey.setCapaPost, value);

  static bool get albumGroup => pref.getBool(PrefKey.albumGroup);
  static set albumGroup(bool value) => pref.setBool(PrefKey.albumGroup, value);

  static bool get albumOnline => pref.getBool(PrefKey.albumOnline);
  static set albumOnline(bool value) => pref.setBool(PrefKey.albumOnline, value);

  static bool get postClick => pref.getBool(PrefKey.postClick);
  static set postClick(bool value) => pref.setBool(PrefKey.postClick, value);


  static bool get postPageSlide => pref.getBool(PrefKey.postPageSlide);
  static set postPageSlide(bool value) => pref.setBool(PrefKey.postPageSlide, value);

  static bool get postPageTags => pref.getBool(PrefKey.postPageTags);
  static set postPageTags(bool value) => pref.setBool(PrefKey.postPageTags, value);

  static bool get postPageFav => pref.getBool(PrefKey.postPageFav);
  static set postPageFav(bool value) => pref.setBool(PrefKey.postPageFav, value);

  static bool get postPageSave => pref.getBool(PrefKey.postPageSave);
  static set postPageSave(bool value) => pref.setBool(PrefKey.postPageSave, value);

  static bool get postPageLike => pref.getBool(PrefKey.postPageLike);
  static set postPageLike(bool value) => pref.setBool(PrefKey.postPageLike, value);

  static bool get postPageQualit => pref.getBool(PrefKey.postPageQualit);
  static set postPageQualit(bool value) => pref.setBool(PrefKey.postPageQualit, value);


  static bool get avisoLinkExpireMostrado => pref.getBool(PrefKey.avidoBooruLinksExpire);
  static set avisoLinkExpireMostrado(bool value) => pref.setBool(PrefKey.avidoBooruLinksExpire, value);

}

class LinkConsert {
  static String tryConsert(Post post) {
    var source = post.source ?? '';

    if (source.isNotEmpty) {
      if (post.booru.isKemono) {
        return source.substring(0, source.length-1);
      }

      if (source.contains('i.pximg.net')) {
        var sp = source.split('/');
        var fName = sp[sp.length-1];
        sp = fName.split('_');
        fName = sp[0];
        return 'https://www.pixiv.net/en/artworks/$fName';
      }

      return source;
    } else {
      dynamic id = post.id;
      if (post.booru.isDeviant) {
        id = [...post.tags, post.id.toString()];
      } else if (post.booru.isEHentai) {
        id = post.source;
      }

      return post.booru.postUri(id).toString();
    }
  }
}