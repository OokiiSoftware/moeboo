import '../import.dart';

/// Fapello. https://fapello.com
class Fapello extends IFapello {
  static const String name_ = 'Fapello';

  Fapello();

  @override
  String get name => name_;

  @override
  String get domain => 'fapello.com';

  @override
  String get home => 'fapello.com';

  @override
  bool get isSafe => false;

  @override
  int get limitedPosts => 10;

}