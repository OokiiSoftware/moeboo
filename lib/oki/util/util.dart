import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../oki/import.dart';

final Random random = Random();

String randomString({int minLength = 8, int maxLength = 10}) {
  const String chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  if (maxLength < minLength) {
    maxLength = minLength;
  }

  int length = random.nextInt(maxLength);
  if (length < minLength) {
    length = minLength;
  }

  if (length == 0) {
    length++;
  }

  var char = String.fromCharCodes(
    Iterable.generate(
      length, (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
  if (char.isEmpty) {
    return randomString(minLength: minLength, maxLength: length);
  }
  return char;
}

int randomInt([int max = 10]) => random.nextInt(max);

int removeText(String value) {
  value = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (value.length > 10) value = value.substring(0, 10);
  return int.parse(value);
}

double? calculeAspectRatio(int? width, int? height) {
  if (width == null || width == 0) return null;

  if (height == null || height == 0) return null;


  final aspectRatio = width / height;
  if (aspectRatio <= 0) {
    return null;
  }
  return aspectRatio;
}

Preferences get pref => Preferences.pref;


Future<String?> downloadToFile({required File file, required String url, bool override = false}) async {
  if (await file.exists() && !override) return null;

  assert(url.isNotEmpty);

  try {
    final Uri resolved = Uri.parse(url);

    final response = await http.get(resolved);

    if (response.statusCode != HttpStatus.ok) {
      throw ('statusCode: ${response.statusCode}, uri: $resolved');
    }

    final Uint8List bytes = response.bodyBytes;
    if (bytes.lengthInBytes == 0) {
      throw Exception('Image is an empty file: $resolved');
    }

    await file.writeAsBytes(bytes, flush: true);
  } catch(e) {
    return e.toString();
  }

  return null;
}