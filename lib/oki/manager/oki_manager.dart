import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../provider/idiona_provider.dart';
import '../import.dart';

class OkiManager {
  static const _log = Log('OkiManager');

  static OkiManager i = OkiManager();

  late Size deviceSize;
  late PackageInfo packageInfo;

  String get appVersion => packageInfo.version;

  Future<void> init() async {
    OkiString erro = OkiString();
    erro.onChanged = (value) {
      throw(value);
    };

    Future<String?> execute({FutureOr<dynamic> Function()? future, String? tag}) async {
      try {
        await future?.call();
        return null;
      } catch(e) {
        _log.e('load', tag, e);
        erro.value = e.toString();
        return e.toString();
      }
    }

    packageInfo = await PackageInfo.fromPlatform();

    // String buildNumber = packageInfo.buildNumber;

     await execute(
      tag: 'Preferences',
      future: Preferences.pref.init,
    );
     await execute(
      tag: 'Storage',
      future: StorageManager.i.init,
    );
     await execute(
      tag: 'Database',
      future: database.load,
    );
     await execute(
      tag: 'AuthManager',
      future: AuthManager.auth.init,
    );
     await execute(
      tag: 'ThemeManager',
      future: ThemeManager.i.load,
    );

    _log.d('init', 'OK');
  }

  Future<void> openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch(e) {
      if (kDebugMode) {
        Log.snack(e.toString(), isError: true);
      } else {
        Log.snack(idioma.openLink, isError: true);
      }
      _log.e('openUrl', e, url);
    }
  }

  Future<bool> share(String path, {String? text, void Function(dynamic)? onError}) async {
    try {
      await Share.shareXFiles([XFile(path)], subject: Ressources.appName, text: text);
      return true;
    } catch(e) {
      onError?.call(e);
      _log.e('share', e);
      return false;
    }
  }

}
