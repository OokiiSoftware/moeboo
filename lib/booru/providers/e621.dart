import '../import.dart';

class E621Template extends IE621 {
  final String base;
  final String home_;
  final String name_;

  E621Template(this.name_, this.base, this.home_) {
    isPersonalizado = true;
  }

  @override
  String get name => name_;

  @override
  String get domain => base;

  @override
  String get home => home_;

}