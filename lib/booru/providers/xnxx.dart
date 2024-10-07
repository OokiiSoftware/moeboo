import '../import.dart';

/// Xnxx. https://xnxx.com
class Xnxx extends IXnxx {
  static const String name_ = 'Xnxx';

  Xnxx();

  @override
  String get name => name_;

  @override
  String get domain => 'xnxx.com';

  @override
  String get home => 'xnxx.com';

  @override
  bool get isSafe => false;

  @override
  int get limitedPosts => 36;

}