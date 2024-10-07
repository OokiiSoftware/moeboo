import '../booru/import.dart';

class Booru {
  String nome = '';
  String baseUrl = '';
  String homeUrl = '';
  bool isSafe = false;
  BooruType booruType = BooruType.moeBooru;

  Booru({
    this.nome = '',
    required this.baseUrl,
    required this.homeUrl,
    this.isSafe = false,
    this.booruType = BooruType.moeBooru,
  });

  Booru.fromJson(Map? map) {
    if (map == null) return;

    nome = map['nome'] ?? '';
    baseUrl = map['urlBase'] ?? '';
    homeUrl = map['homeUrl'] ?? '';
    isSafe = map['isSafe'] ?? false;
    booruType = BooruType.templates[map['booruType'] ?? 0];
  }

  static List<Booru> fromJsonList(Map? map) {
    List<Booru> items = [];
    if (map == null) return items;

    map.forEach((key, value) {
      items.add(Booru.fromJson(value));
    });
    return items;
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'urlBase': baseUrl,
    'homeUrl': homeUrl,
    'isSafe': isSafe,
    'booruType': booruType.index,
  };

  Booru copy() => Booru.fromJson(toJson());

  @override
  String toString() => toJson().toString();

  static Booru get empty => Booru(baseUrl: '', homeUrl: '');
}