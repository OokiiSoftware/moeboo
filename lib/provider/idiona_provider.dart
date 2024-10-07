import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../res/import.dart';

class IdiomaProvider extends ChangeNotifier {

  factory IdiomaProvider() => IdiomaProvider.i;
  static IdiomaProvider i = IdiomaProvider._();
  IdiomaProvider._();

  late ILanguage iStrings = LanguagePT();

  bool _loaded = false;

  final Map<String, ILanguage> values = {
    LanguageEN.name: LanguageEN(),
    LanguagePT.name: LanguagePT(),
  };

  void setIdioma(ILanguage value) {
    iStrings = value;
    notifyListeners();
  }

  void setIdiomaFromString(String value) {
    setIdioma(values[value]!);
  }

  void load() {
    if (_loaded) return;

    final String locale = Platform.localeName;

    switch(locale) {
      case LanguagePT.locale:
        setIdiomaFromString(LanguagePT.name);
        break;
      default:
        setIdiomaFromString(LanguageEN.name);
    }

    _loaded = true;
  }
}

ILanguage idiomaWatch(BuildContext context) => context.watch<IdiomaProvider>().iStrings;
ILanguage get idioma => IdiomaProvider.i.iStrings;