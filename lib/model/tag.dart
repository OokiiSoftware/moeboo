import '../booru/import.dart';

class Tag {

  late int id;
  late int count;
  late String name;
  late String provider;
  // late String? userId;
  TagType type = TagType.trivia;

  // bool get isUser => name.contains('user:');
  // String get nameUser => name.replaceAll('user:', '');

  Tag({required this.id, required this.name, TagType? type, this.count = 0, this.provider = ''}) {
    if (type != null) this.type = type;
  }

  Tag.fromJson(Map map) {
    id = map['id'];
    name = map['name'];
    provider = map['provider'] ?? '';

    int? countTemp = map['count'];
    countTemp ??= map['post_count'];
    count = countTemp ?? 0;

    var tagTemp = map['type'];
    tagTemp ??= map['category'];
    type = TagType.fromValue(tagTemp);
  }

  static Map<int, Tag> fromJsonList(List map) {
    Map<int, Tag> items = {};
    for (var value in map) {
      var item = Tag.fromJson(value);
      items[item.id] = item;
    }
    return items;
  }

  Map toJson({bool includeAll = true}) => {
    if (includeAll)
      'id': id,
    'name': name,
    'type': type.value,
    if (includeAll)
      'count': count,
    if (includeAll)
      'provider': provider,
  };

  @override
  String toString() {
    return toJson().toString();
  }

  String toName({String remove = ''}) {
    String albumName = name.replaceAll('_', ' ').replaceAll('user:', '').replaceAll(remove.toLowerCase(), '');
    var names = albumName.split(' ');
    for (var name in names) {
      if (name.isNotEmpty) {
        String newName = name[0].toUpperCase();
        newName += name.substring(1);
        albumName = albumName.replaceAll(name, newName);
      }
    }

    return albumName;
  }

  Tag copy() => Tag.fromJson(toJson());
}