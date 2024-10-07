import 'dart:io';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Color get mainColor => ThemeManager.i.mainColor;

Color get tintColor => ThemeManager.i.tintColor;
// Color get textColor => ThemeManager.i.textColor;
Color get disabledTextColor => ThemeManager.i.disabledTextColor;
Color get backgroundColor => ThemeManager.i.background;
Color get shadowColor => ThemeManager.i.shadow;

class ThemeManager {
  static ThemeManager i = ThemeManager();

  Color get mainColor => Colors.white;// const Color.fromRGBO(46, 46, 46, 1);
  Color get tintColor => Colors.deepOrange;

  // Color get textColor => Colors.white;
  Color get disabledTextColor => Colors.black26;

  Color get background => Colors.white;// const Color.fromRGBO(46, 46, 46, 1);
  Color get shadow => Colors.white12;

  ThemeData themeData() {
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // primaryColor: color,
      // dividerColor: color,
      // indicatorColor: color,
      // highlightColor: color,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // textTheme: const TextTheme(
      //   displayLarge: textStyle,
      //   displayMedium: textStyle,
      //   displaySmall: textStyle,
      //   headlineLarge: textStyle,
      //   headlineMedium: textStyle,
      //   headlineSmall: textStyle,
      //   titleLarge: textStyle,
      //   titleMedium: textStyle,
      //   titleSmall: textStyle,
      //   bodyLarge: textStyle,
      //   bodyMedium: textStyle,
      //   bodySmall: textStyle,
      //   labelMedium: textStyle,
      //   labelSmall: textStyle,
      //   labelLarge: textStyle,
      // ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.white,
        actionTextColor: Colors.black,
        shape: shape,
        contentTextStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      appBarTheme: const AppBarTheme(
        // color: color,
        shape: shape,
        centerTitle: true,
        // foregroundColor: textColor,
        // titleTextStyle: TextStyle(
        //   color: textColor,
        //   fontSize: 18,
        //   fontWeight: FontWeight.w100,
        // ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      ),
      // colorScheme: ColorScheme.fromSwatch(
      //   brightness: Brightness.light,
      // ).copyWith(secondary: color),
      // floatingActionButtonTheme: FloatingActionButtonThemeData(
      //   foregroundColor: textColor,
      // ),
      // progressIndicatorTheme: ProgressIndicatorThemeData(
      //   color: tintColor,
      // ),
      sliderTheme: SliderThemeData(
        activeTickMarkColor: tintColor,
        activeTrackColor: tintColor,
        inactiveTrackColor: tintColor.withOpacity(0.6),
        thumbColor: tintColor,
      ),
      // iconTheme: IconThemeData(
      //   color: textColor,
      // ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((
            Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return Colors.amber;
          }
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((
            Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return Colors.amber;
          }
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return Colors.amber;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((
            Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return null;
          }
          if (states.contains(MaterialState.selected)) {
            return Colors.amberAccent;
          }
          return null;
        }),
      ),
      // bottomAppBarTheme: BottomAppBarTheme(color: color),
      // dividerTheme: const DividerThemeData(
      //   color: Colors.white30,
      // )
    );
  }

  Future<void> setFullScreen(bool value) async {
    if (value) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
  }

  void _setSettings() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_TRANSLUCENT_NAVIGATION);
    }
  }

  void load() {
    _setSettings();
  }
}
