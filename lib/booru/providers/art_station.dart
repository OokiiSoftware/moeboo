import '../import.dart';

/// DeviantArt. https://artstation.com/
class ArtStation extends IArtStation {
  static const String name_ = 'ArtStation';

  ArtStation();

  @override
  String get name => name_;

  @override
  String get domain => 'artstation.com';

  @override
  String get home => 'artstation.com';

  @override
  bool get isSafe => true;

  @override
  int get limitedPosts => 50;
}