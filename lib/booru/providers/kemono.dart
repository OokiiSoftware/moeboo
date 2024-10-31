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

}

/// Kemono. https://coomer.su
class Coomer extends IKemono {
  static const String name_ = 'Coomer';

  Coomer();

  @override
  String get name => name_;

  @override
  String get domain => 'coomer.su';

  @override
  String get home => 'coomer.su';

  @override
  bool get isSafe => false;

}