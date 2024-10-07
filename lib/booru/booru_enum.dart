enum BooruOptions {
  none,
  expireLinks,
  generalRating,
  http,
  tagApiXml,
}

class BooruType {
  static const String artValue = 'ArtStation';
  static const String danValue = 'Danbooru';
  static const String devValue = 'Deviant';
  static const String gelValue = 'Gelbooru';
  static const String gelValue2 = 'Gelbooru 2';
  static const String henValue = 'EHEntai';
  static const String moeValue = 'MoeBooru';
  static const String sanValue = 'Sankaku';
  static const String kemValue = 'Kemono';

  static const String cooValue = 'Coomer';
  static const String fapValue = 'Fapello';
  static const String xnxValue = 'Xnxx';
  static const String sexValue = 'Sex';

  static const BooruType artStation = BooruType(artValue);
  static const BooruType danbooru = BooruType(danValue);
  static const BooruType deviant = BooruType(devValue);
  static const BooruType ehentai = BooruType(henValue);
  static const BooruType gelbooru = BooruType(gelValue);
  static const BooruType gelbooru2 = BooruType(gelValue2);
  static const BooruType moeBooru = BooruType(moeValue);
  static const BooruType sankaku = BooruType(sanValue);
  static const BooruType kemono = BooruType(kemValue);

  static const BooruType coomer = BooruType(cooValue);
  static const BooruType fapello = BooruType(fapValue);
  static const BooruType xnxx = BooruType(xnxValue);
  static const BooruType sex = BooruType(sexValue);

  const BooruType(this.value);

  final String value;

  /// Somente os que podem criar novos boorus
  static const List<String> templateValues = [
    danValue,
    gelValue,
    gelValue2,
    moeValue,
  ];

  /// Somente os que podem criar novos boorus
  static const List<BooruType> templates = [
    danbooru,
    gelbooru,
    gelbooru2,
    moeBooru,
  ];

  static BooruType fromName(String value) {
    switch(value) {
      case artValue:
        return BooruType.artStation;
      case danValue:
        return BooruType.danbooru;
      case devValue:
        return BooruType.deviant;
      case henValue:
        return BooruType.ehentai;
      case gelValue:
        return BooruType.gelbooru;
      case gelValue2:
        return BooruType.gelbooru2;
      case sanValue:
        return BooruType.sankaku;
      case kemValue:
        return BooruType.kemono;
      default:
        return BooruType.moeBooru;
    }
  }

  bool get isArt => value == artValue;
  bool get isDan => value == danValue;
  bool get isDev => value == devValue;
  bool get isHen => value == henValue;
  bool get isGeo => value == gelValue;
  bool get isGeo2 => value == gelValue2;
  bool get isMoe => value == moeValue;
  bool get isSan => value == sanValue;
  bool get isKem => value == kemValue;

  bool get isCoo => value == cooValue;
  bool get isSex => value == sexValue;
  bool get isFap => value == fapValue;
  bool get isXnx => value == xnxValue;

  int get index {
    if (isDan) return 0;
    if (isGeo) return 1;
    if (isGeo2) return 2;
    if (isMoe) return 3;

    return -1;
  }

  @override
  String toString() => 'BooruType.$value';
}

class TagType {
  static const int triviaValue = 0;
  static const int artistValue = 1;
  static const int metadataValue = 2;
  static const int copyrightValue = 3;
  static const int characterValue = 4;

  static TagType get trivia => TagType(triviaValue);
  static TagType get artist => TagType(artistValue);
  static TagType get metadata => TagType(metadataValue);
  static TagType get copyright => TagType(copyrightValue);
  static TagType get character => TagType(characterValue);

  TagType(this.value);

  final int value;

  String get name {
    switch(value) {
      case triviaValue:
        return 'general';
      case artistValue:
        return 'artist';
      case metadataValue:
        return 'metadata';
      case copyrightValue:
        return 'copyright';
      case characterValue:
        return 'character';
      default:
        return 'trivia';
    }
  }

  static TagType fromValue(dynamic value) {
    if (value is int) {
      switch (value) {
        case triviaValue:
          return trivia;
        case artistValue:
          return artist;
        case metadataValue:
          return metadata;
        case copyrightValue:
          return copyright;
        case characterValue:
          return character;
        default:
          return trivia;
      }
    }

    if (value is String) {
      switch (value) {
        case 'tag':
        case '0':
          return trivia;
        case 'artist':
        case '1':
          return artist;
        case 'metadata':
        case '2':
          return metadata;
        case 'copyright':
        case '3':
          return copyright;
        case 'character':
        case '4':
          return character;
        default:
          return trivia;
      }
    }
    return trivia;
  }

  @override
  String toString() {
    return '$value: $name';
  }
}

class BooruOpt {
  final List<BooruOptions> _options = [];

  BooruOpt([List<BooruOptions>? options]) {
    if (options != null) {
      _options.addAll(options);
    }
  }

  bool contains(BooruOptions options) => _options.contains(options);

  void add(BooruOptions flag) {
    _options.add(flag);
  }
  void addAll(List<BooruOptions> flags) {
    _options.addAll(flags);
  }
  void remove(BooruOptions flag) {
    _options.remove(flag);
  }

  @override
  String toString() {
    return _options.toString();
  }
}

/// Represents a level of explicit content of the post.
/// https://danbooru.donmai.us/wiki_pages/howto%3Arate
class Rating {
  static const String generalValue = 'general';
  static const String safeValue = 'safe';
  static const String questionableValue = 'questionable';
  static const String explicitValue = 'explicit';

  /// Indicates that post cannot be considered either questionable or explicit.
  /// Note that safe does not mean safe for work and may still include "sexy" content.
  static const Rating safe = Rating(safeValue);

  /// Indicates that post may contain some non-explicit nudity or sexual content, but isn't quite pornographic.
  static const Rating questionable = Rating(questionableValue);

  /// Indicates that post contains explicit sex, gratuitously exposed genitals, or it is otherwise pornographic.
  static const Rating explicit = Rating(explicitValue);

  const Rating(this.value);

  static Rating fromString(String value) {
    if (value[0] == 'q') {
      return Rating.questionable;
    }

    if (value[0] == 'e') {
      return Rating.explicit;
    }

    return Rating.safe;
  }

  static Rating fromInt(int value) {
    switch(value) {
      case 0:
        return Rating.safe;
      case 1:
        return Rating.questionable;
      case 2:
        return Rating.explicit;
    }

    return Rating.safe;
  }

  /// [value] = false (safe) else (explicit)
  static Rating fromBool(bool value) {
    if (value) {
      return Rating.explicit;
    }
    return Rating.safe;
  }

  static List<String> get values => [
    safe.value,
    questionable.value,
    explicit.value,
  ];

  final String value;

  String get valueTag {
    if (value[0] == 't') {
      return '';
    }

    return value[0];
  }

  bool get isSafe => value == safe.value || value == generalValue;
  bool get isQuestionable => value == questionable.value;
  bool get isExplicit => value == explicit.value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Rating && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;

}
