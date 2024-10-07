import '../import.dart';

/// EHentai. https://e-hentai.org/
class EHentai extends IEHentai {
  static const String name_ = 'EHentai';

  EHentai();

  @override
  String get name => name_;

  @override
  String get domain => 'e-hentai.org';

  @override
  String get home => 'e-hentai.org';

}