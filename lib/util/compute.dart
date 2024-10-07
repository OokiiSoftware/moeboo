import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import '../model/import.dart';

//region album

Future<Map<String, Map<String, Post>>> computeOnlinePosts(ComputeParams params) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(params.token);

  Map<String, Map<String, Post>> items = {};
  final file = File(params.path!);

  try {
    if (await file.exists()) {
      Map<String, dynamic> map = jsonDecode(await file.readAsString());

      map.forEach((provider, value) {
        items[provider] = {};
        value.forEach((key, value) {
          items[provider]![key] = Post.fromJson(value);
        });
      });
    }
  } catch(e) {
    if (kDebugMode) {
      print('Album: _computeOnlinePosts: $e\n$params');
    }
  }

  return items;
}

Future<Map<String, Post>> computePosts(ComputeParams params) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(params.token);

  Map<String, Post> items = {};
  final file = File(params.path!);

  try {
    if (await file.exists()) {
      Map<String, dynamic> map = jsonDecode(await file.readAsString());
      map.forEach((key, value) {
        items[key] = Post.fromJson(value);
      });
    }
  } catch(e) {
    if (kDebugMode) {
      print('Album: _computePosts: ${e.toString()}');
    }
  }

  return items;
}

Future<String?> computeSave(ComputeParams params) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(params.token);

  final file = File(params.path!);

  try {
    await file.writeAsString(jsonEncode(params.data));
    return null;
  } catch(e) {
    if (kDebugMode) {
      print('Album: _computeSave: ${e.toString()}');
    }
    return e.toString();
  }
}

//endregion

//region post

Future<ImageFile?> computeCompressPart1(ComputeParams params) async {
  try {
    BackgroundIsolateBinaryMessenger.ensureInitialized(params.token);

    if (!params.sobrescrever!) {
      if (await params.previewSalvoFile!.exists()) {
        return null;
      }
    }

    File? file;
    if (await params.postOriginalFile!.exists()) {
      file = params.postOriginalFile;
    } else if (await params.postSampleFile!.exists()) {
      file = params.postSampleFile;
    }

    if (file == null || !await file.exists()) throw 'post file == null ou não existe';

    return ImageFile(
      rawBytes: await file.readAsBytes(),
      filePath: file.path,
    );

  } catch(e) {
    if (kDebugMode) {
      print('Post: _computeCompress: $e');
    }
    return null;
  }
}

Future<String?> computeCompressPart2(ComputeParams params) async {
  try {
    BackgroundIsolateBinaryMessenger.ensureInitialized(params.token);

    params.previewSalvoFile!.writeAsBytesSync(params.file!.rawBytes);

    return null;
  } catch(e) {
    if (kDebugMode) {
      print('Post: _computeCompress: $e');
    }
    return e.toString();
  }
}

Future<Size?> computeSize(ComputeParams params) async {
  try {
    var decoded = await decodeImageFromList(params.postSampleFile!.readAsBytesSync());
    return Size(decoded.width.toDouble(), decoded.height.toDouble());
  } catch(e) {
    return null;
  }
}

//endregion

//region wallpaper

Future<String?> computeWallpaper(ComputeParams params) async {
  try {
    BackgroundIsolateBinaryMessenger.ensureInitialized(params.token);

    await AsyncWallpaper.setWallpaperFromFile(
      filePath: params.path!,
      wallpaperLocation: params.data,
    );

    return null;
  } catch(e) {
    return e.toString();
  }
}

//endregion

class ComputeParams {
  final String? path;
  final dynamic data;

  late final RootIsolateToken token;

  final bool? sobrescrever;
  final ImageFile? file;
  final File? previewSalvoFile;
  final File? postSampleFile;
  final File? postOriginalFile;

  ComputeParams({
    this.path,
    this.data,
    this.sobrescrever,
    this.file,
    this.previewSalvoFile,
    this.postSampleFile,
    this.postOriginalFile,
  }) {
    token = RootIsolateToken.instance!;
  }

  @override
  String toString() {
    return {
      if (path != null)
        'path': path,
      if (data != null)
        'data': data,
      if (sobrescrever != null)
        'override': sobrescrever,
    }.toString();
  }
}