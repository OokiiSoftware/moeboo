import '../import.dart';

/// All The Fallen. https://aibooru.online/
class Aibooru extends IDanbooru {
  static const String name_ = 'Aibooru';

  Aibooru();

  @override
  String get name => name_;

  @override
  String get domain => 'aibooru.online';

  @override
  String get home => 'aibooru.online';

  @override
  bool get isSafe => true;
}

/// All The Fallen. https://booru.allthefallen.moe/
class Atfbooru extends IDanbooru {
  static const String name_ = 'Atfbooru';

  Atfbooru();

  @override
  String get name => name_;

  @override
  String get domain => 'booru.allthefallen.moe';

  @override
  String get home => 'booru.allthefallen.moe';

}

/// Danbooru. https://danbooru.donmai.us/
class Danbooru extends IDanbooru {
  static const String name_ = 'Danbooru';

  Danbooru() : super(options: [BooruOptions.generalRating]);

  @override
  String get name => name_;

  @override
  String get domain => 'danbooru.donmai.us';

  @override
  String get home => 'danbooru.donmai.us';

  @override
  bool get isSafe => true;
}

class DanbooruTemplate extends IDanbooru {
  final String base;
  final String home_;
  final String name_;

  DanbooruTemplate(this.name_, this.base, this.home_) {
    isPersonalizado = true;
  }

  @override
  String get name => name_;

  @override
  String get domain => base;

  @override
  String get home => home_;

}