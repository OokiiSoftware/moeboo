import '../import.dart';

/// Sex. https://sex.com/
class Sex extends ISex {
  static const String name_ = 'Sex';

  Sex();

  @override
  String get name => name_;

  @override
  String get domain => 'sex.com';

  @override
  String get home => 'sex.com';

  @override
  bool get isSafe => false;

  @override
  int get limitedPosts => 24;

  @override
  Map<String, String>? get headers => {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Encoding': 'gzip, deflate, br',
    'Content-Type': 'application/json',
    'X-Correlation-Id': 'WEB-APP.jO4x1',
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36',
    'Origin': 'https://sex.com',
    'Referer': 'https://sex.com/',
  };
}
