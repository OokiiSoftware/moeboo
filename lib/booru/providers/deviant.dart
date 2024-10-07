import '../import.dart';

/// DeviantArt. https://deviantart.com/
class DeviantArt extends IDeviantArt {
  static const String name_ = 'DeviantArt';

  DeviantArt();

  @override
  String get name => name_;

  @override
  String get domain => 'deviantart.com';

  @override
  String get home => 'deviantart.com';

  @override
  bool get isSafe => true;

  @override
  int get limitedPosts => 30;

}