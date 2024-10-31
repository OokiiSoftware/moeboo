import '../import.dart';

/// Gelbooru. https://gelbooru.com
class GelBooru extends IGelBooru {
  static const String name_ = 'Gelbooru';

  GelBooru() : super(options: [BooruOptions.generalRating, ]);

  @override
  String get name => name_;

  @override
  String get domain => 'gelbooru.com';

  @override
  String get home => 'gelbooru.com';

  @override
  bool get isSafe => true;

}

/// Hypnohub. https://hypnohub.net
class Hypnohub extends IGelBooru {
  static const String name_ = 'Hypnohub';

  Hypnohub() : super(options: [BooruOptions.tagApiXml]);

  @override
  String get name => name_;

  @override
  String get domain => 'hypnohub.net';

  @override
  String get home => 'hypnohub.net';

  @override
  bool get isSafe => true;
}

/// Realbooru. https://realbooru.com
class Real extends IGelBooru {
  static const String name_ = 'Real';

  Real() : super(options: [BooruOptions.tagApiXml, ], type: BooruType.gelbooru);

  @override
  String get name => name_;

  @override
  String get domain => 'realbooru.com';

  @override
  String get home => 'realbooru.com';

  @override
  bool get isSafe => false;

  @override
  Map<String, String>? get headers => {
    'Accept-Encoding': 'gzip, deflate, br',
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36',
    'Origin': 'https://realbooru.com',
    'Referer': 'https://realbooru.com/',
  };
}

/// Rule34. https://rule34.xxx
class Rule34 extends IGelBooru {
  static const String name_ = 'Rule';

  Rule34() : super(options: [BooruOptions.tagApiXml, ]);

  @override
  String get name => name_;

  @override
  String get domain => 'api.rule34.xxx';

  @override
  String get home => 'rule34.xxx';

  @override
  bool get isSafe => true;
}

/// Safebooru. https://safebooru.org
class Safebooru extends IGelBooru2 {
  static const String name_ = 'Safe';

  Safebooru() : super(options: []);

  @override
  String get name => name_;

  @override
  String get domain => 'safebooru.org';

  @override
  String get home => 'safebooru.org';

  @override
  bool get isSafe => true;
}

/// XBooru. https://xbooru.com
class XBooru extends IGelBooru {
  static const String name_ = 'XBooru';

  XBooru() : super(options: [BooruOptions.tagApiXml, ]);

  @override
  String get name => name_;

  @override
  String get domain => 'xbooru.com';

  @override
  String get home => 'xbooru.com';

}

class GelbooruTemplate extends IGelBooru {
  final String base;
  final String home_;
  final String name_;

  GelbooruTemplate(this.name_, this.base, this.home_) {
    isPersonalizado = true;
  }

  @override
  String get name => name_;

  @override
  String get domain => base;

  @override
  String get home => home_;

}

class GelbooruTemplate2 extends IGelBooru2 {
  final String base;
  final String home_;
  final String name_;

  GelbooruTemplate2(this.name_, this.base, this.home_, {required super.options}) {
    isPersonalizado = true;
  }

  @override
  String get name => name_;

  @override
  String get domain => base;

  @override
  String get home => home_;

}