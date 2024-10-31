import 'package:flutter/material.dart';
import '../util/util.dart';
import '../booru/import.dart';
import '../model/import.dart';
import '../oki/import.dart';

String get currentBooru => BooruProvider.i.booru.name;

class BooruProvider extends ChangeNotifier {
  static const _log = Log('BooruMananger');

  static BooruProvider i = BooruProvider();

  ABooru booru = Konachan();

  /// Tags black List
  final OkiList<String> blackList = OkiList();

  final OkiList<String> _rating = OkiList(noDuplicate: true);
  OkiList<String> get rating {
    if (isPlayStory) {
      return OkiList(noDuplicate: true)..add(Rating.safeValue);
    }

    return _rating;
  }

  void addBooru(Booru value) {
    dynamic aBooru = createBooru(value);

    _add(aBooru);
    database.child(Childs.boorus).child(value.nome).set(value.toJson());
    setBooru(aBooru);

    notifyListeners();
  }

  void _add(ABooru value) {
    Boorus.values[value.name] = value;
    notifyListeners();
  }

  void removeBooru(Booru value) {
    Boorus.values.remove(value.nome);
    database.child(Childs.boorus).child(value.nome).remove();
    setBooru(Yandere());
    notifyListeners();
  }

  void setBooru(ABooru value) {
    booru = value;
    _saveBooru(value.name);
    notifyListeners();
  }
  void setBooruFromName(String value) {
    var temp = Boorus.get(value);
    if (temp != null) {
      booru = temp;
      _saveBooru(value);
    }
    notifyListeners();
  }

  void _ratingListener() {
    database.child(Childs.rating).set(rating);
  }

  void _saveBooru(String value) {
    database.child(Childs.booru).set(value);
  }

  void _blackListChanged() {
    database.child(Childs.blackList).set(blackList);
  }

  Future<int> findTagsInfo(List<String>? tags) async {
    if (tags == null) {
      return -1;
    }
    return await booru.findPostsCount(tags);
  }

  ABooru? createBooru(Booru value) {
    switch(value.booruType) {
      case BooruType.danbooru:
        return DanbooruTemplate(
          value.nome,
          value.baseUrl,
          value.homeUrl,
        );
      case BooruType.gelbooru:
        return GelbooruTemplate(
          value.nome,
          value.baseUrl,
          value.homeUrl,
        );
      case BooruType.gelbooru2:
        return GelbooruTemplate2(
          value.nome,
          value.baseUrl,
          value.homeUrl,
          options: [],
        );
      case BooruType.moeBooru:
        return MoebooruTemplate(
          value.nome,
          value.baseUrl,
          value.homeUrl,
        );
      case BooruType.e621:
        return E621Template(
          value.nome,
          value.baseUrl,
          value.homeUrl,
        );
      case BooruType.createPorn:
        return CreatePornTemplate(
          value.nome,
          value.baseUrl,
          value.homeUrl,
        );
    }
    return null;
  }

  void load() {
    List<Booru> boorus = Booru.fromJsonList(database.child(Childs.boorus).get().value);
    for (var item in boorus) {
      _add(createBooru(item)!);
    }

    booru = Boorus.get(database.child(Childs.booru).get(def: Yandere.name_).value) ?? Yandere();

    for (var item in (database.child(Childs.rating).get(def: ['safe']).value as List<dynamic>)) {
      rating.add(item);
    }

    Map providersEnableds = database.child(Childs.booruOpt).get(def: <String, bool>{}).value;
    providersEnableds.forEach((key, value) {
      Boorus.optEnabled[key] = value;
    });

    rating.addListener(_ratingListener);
    blackList.addListener(_blackListChanged);

    notifyListeners();
    _log.d('load', 'OK');
  }
}

class Boorus {
  static List<ABooru> get list {
    List<ABooru> items = [...values.values];
    optionals.forEach((key, value) {
      if (optEnabled.containsKey(key) && optEnabled[key]!) {
        items.add(value);
      }
    });
    return items..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Provedores padrão
  static Map<String, ABooru> values = {
    Danbooru.name_: Danbooru(),
    GelBooru.name_: GelBooru(),
    Konachan.name_: Konachan(),
    Safebooru.name_: Safebooru(),
    Sankaku.name_: Sankaku(),
    Yandere.name_: Yandere(),
  };
  static Map<String, ABooru> get allValues => {...values, ..._optionals};

  static Map<String, ABooru> get optionals => {..._optionals}..removeWhere((key, value) {
    if (isPlayStory) {
      return !value.isSafe;
    }
    return false;
  });


  /// Provedores opicionais
  static final Map<String, ABooru> _optionals = {
    Aibooru.name_: Aibooru(),
    ArtStation.name_: ArtStation(),
    Atfbooru.name_: Atfbooru(),
    DeviantArt.name_: DeviantArt(),
    Behoimi.name_: Behoimi(),
    Bleach.name_: Bleach(),
    EHentai.name_: EHentai(),
    Hypnohub.name_: Hypnohub(),
    Kemono.name_: Kemono(),
    // Lolibooru.name_: Lolibooru(),
    Rule34.name_: Rule34(),
    Sakugabooru.name_: Sakugabooru(),
    XBooru.name_: XBooru(),

    Coomer.name_: Coomer(),
    // AiPorn.name_: AiPorn(),
    // AiHentai.name_: AiHentai(),
    // AiAsian.name_: AiAsian(),
    // AiShemale.name_: AiShemale(),
    Fapello.name_: Fapello(),
    Real.name_: Real(),
    IdolComplex.name_: IdolComplex(),
    Sex.name_: Sex(),
    Xnxx.name_: Xnxx(),
  };

  /// Provedores opicionais habilitados
  static Map<String, bool> optEnabled  = {};

  static ABooru? get(String? booruBase) {
    return {...values, ..._optionals}[booruBase];
  }

  static void save() {
    database.child(Childs.booruOpt).set(optEnabled);
  }
}

/**
 * Como add novos provedores
 * Vá para a pasta [booru]
 * Add o provider.dart em [templates] e [providers]
 * Adicione na lista [Boorus.values] ou [Boorus.optionals] acima
* */