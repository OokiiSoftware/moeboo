
extension RegExpExtension on RegExp {
  List<String> allMatchesWithSep(String input, [int start = 0]) {
    var result = <String>[];
    for (var match in allMatches(input, start)) {
      result.add(input.substring(start, match.start));
      result.add(match[0] ?? '');
      start = match.end;
    }
    result.add(input.substring(start));
    return result;
  }
}

extension StringExtension on String {
  List<String> splitWithDelim(RegExp pattern) => pattern.allMatchesWithSep(this);

  int removeText() {
    var aStr = replaceAll(RegExp(r'[^0-9]'),'');
    if (aStr.length > 10) aStr = aStr.substring(0, 10);

    return int.parse(aStr);
  }

  bool get isNumeric => int.tryParse(this) != null;

  int get asInt {
    return int.parse(this);
  }
  double get asDouble {
    return double.parse(this);
  }
}