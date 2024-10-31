import '../import.dart';

/// AiPorn. https://www.createporn.com/
class AiPorn extends ICreatePorn {
  static const String name_ = 'AiPorn';

  AiPorn();

  @override
  String get name => name_;

  @override
  String get domain => 'api.createporn.com';

  @override
  String get home => 'createporn.com';

}

/// AiHentai. https://www.createhentai.com/
class AiHentai extends ICreatePorn {
  static const String name_ = 'AiHentai';

  AiHentai();

  @override
  String get name => name_;

  @override
  String get domain => 'api.createporn.com';

  @override
  String get home => 'createhentai.com';

}

/// AiAsian. https://www.createaiasian.com/
class AiAsian extends ICreatePorn {
  static const String name_ = 'AiAsian';

  AiAsian();

  @override
  String get name => name_;

  @override
  String get domain => 'createaiasian.com';

  @override
  String get home => 'createaiasian.com';

}

/// AiShemale. https://www.createaishemale.com/
class AiShemale extends ICreatePorn {
  static const String name_ = 'AiShemale';

  AiShemale();

  @override
  String get name => name_;

  @override
  String get domain => 'createaishemale.com';

  @override
  String get home => 'createaishemale.com';

  @override
  bool get isSafe => true;
}

class CreatePornTemplate extends ICreatePorn {
  final String base;
  final String home_;
  final String name_;

  CreatePornTemplate(this.name_, this.base, this.home_) {
    isPersonalizado = true;
  }

  @override
  String get name => name_;

  @override
  String get domain => base;

  @override
  String get home => home_;

}