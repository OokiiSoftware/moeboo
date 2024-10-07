import '../import.dart';

/// SankakuComplex. https://chan.sankakucomplex.com/
class Sankaku extends ISankaku {
  static const String name_ = 'Sankaku';

  Sankaku();

  @override
  String get name => name_;

  @override
  String get domain => 'capi-v2.sankakucomplex.com';

  @override
  String get home => 'chan.sankakucomplex.com';

  @override
  bool get isSafe => true;

}
