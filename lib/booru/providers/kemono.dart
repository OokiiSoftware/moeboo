import '../import.dart';

/// Kemono. https://kemono.su
class Kemono extends IKemono {
  static const String name_ = 'Kemono';

  Kemono();

  @override
  String get name => name_;

  @override
  String get domain => 'kemono.su';

  @override
  String get home => 'kemono.su';

  @override
  bool get isSafe => false;

}