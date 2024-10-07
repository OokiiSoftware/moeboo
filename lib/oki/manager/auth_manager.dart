import 'dart:io';
import 'package:flutter/services.dart';
import '../../util/util.dart';
import '../import.dart';

class AuthManager {
  static const _log = Log('AuthManager');

  static const String _authSystemEnabledKey = '_AUTH_IS_SYSTEM_ENABLED_KEY';
  static const String _authPasswordKey = '_AUTH_PASSWORD_KEY';

  static AuthManager auth = AuthManager();

  //region variaveis

  bool _isAuthenticated = false;
  bool _canUseBiometria = false;
  bool _isSystemEnabled = false;
  final _isSupported = false;
  String? _password;

  bool get isAuthenticated => (_isAuthenticated || !isAuthEnabled) || isPlayStory;
  bool get isAuthEnabled => password.isNotEmpty && password.isNotEmpty;
  bool get isSystemEnabled => _isSystemEnabled;
  bool get canUseBiometria => _canUseBiometria;
  bool get isSupported => _isSupported;
  String get password => _password ?? '';

  set password(String value) {
    _password = value;
    pref.setString(_authPasswordKey, value);
  }
  set isSystemEnabled(bool value) {
    _isSystemEnabled = value;
    pref.setBool(_authSystemEnabledKey, value);
  }
  set isAuthenticated(bool value) => _isAuthenticated = value;

  //endregion

  //region metodos

  Future<bool> bioAuth() async {
    try {
      try {
        // bool result = await _auth.authenticate(
        //   localizedReason: 'AniAlbum',
        //   options: AuthenticationOptions(
        //     biometricOnly: canUseBiometria,
        //     stickyAuth: true,
        //   ),
        // );
        // return result;
      } on PlatformException catch (e) {
        _log.e('authenticate > PlatformException', e);
      }
    } catch (e) {
      _log.e('authenticate', e);
    }
    return false;
  }

  void cancelAuthentication() async {
    // await _auth.stopAuthentication();
    isAuthenticated = false;
  }

  Future<void> init() async {
    _isSystemEnabled = pref.getBool(_authSystemEnabledKey);
    _password = pref.getString(_authPasswordKey);
    if (Platform.isAndroid) {
      _canUseBiometria = await _checkBiometrics();
    }
    _log.e('init', 'OK');
  }

  Future<bool> _checkBiometrics() async {
    try {
      // return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      _log.e('checkBiometrics', e);
    }
    return false;
  }

  //endregion

}

