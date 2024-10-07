import '../import.dart';

/// Kemono. https://coomer.su
class Coomer extends ICoomer {
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