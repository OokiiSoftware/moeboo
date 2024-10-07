import 'dart:math';
import 'package:flutter/material.dart';

class OkiBool extends ChangeNotifier {
  OkiBool([bool value = false]) {
    _value = value;
  }

  bool _value = false;
  bool get value => _value;
  set value(value) {
    final valorDiferente = _value != value;
    _value = value;
    onUpdate?.call();

    if (valorDiferente) {
      onChanged?.call();
      notifyListeners();
    }
  }

  /// Inverte o valor entre [false e true]
  void invert() {
    _value = !_value;
    onChanged?.call();
    onUpdate?.call();
    notifyListeners();
  }

  /// É chamado sempre que um valor é atribuido
  void Function()? onUpdate;

  /// É chamado somente quando o novo valor é diferente do antigo
  void Function()? onChanged;

  @override
  bool operator ==(Object other) {
    return (other is bool && other == _value) || (other is OkiBool && other._value == _value);
  }

  @override
  int get hashCode => _value.hashCode;

}

class OkiInt extends ChangeNotifier {
  OkiInt([int value = 0]) {
    _value = value;
  }

  late int _value;
  int get value => _value;
  set value(value) {
    final valorDiferente = _value != value;
    _value = value;
    onUpdate?.call();

    if (valorDiferente) {
      onChanged?.call();
      notifyListeners();
    }
  }

  /// É chamado sempre que um valor é atribuido
  void Function()? onUpdate;

  /// É chamado somente quando o novo valor é diferente do antigo
  void Function()? onChanged;
}

class OkiDouble extends ChangeNotifier {
  OkiDouble([double value = 0]) {
    _value = value;
  }

  late double _value;
  double get value => _value;
  set value(value) {
    final valorDiferente = _value != value;
    _value = value;
    onUpdate?.call();

    if (valorDiferente) {
      onChanged?.call();
      notifyListeners();
    }
  }

  /// É chamado sempre que um valor é atribuido
  void Function()? onUpdate;

  /// É chamado somente quando o novo valor é diferente do antigo
  void Function()? onChanged;
}

class OkiString extends ChangeNotifier {
  OkiString([String value = '']) {
    _value = value;
  }

  String _value = '';
  String get value => _value;
  set value(value) {
    final valorDiferente = _value != value;
    _value = value;
    onUpdate?.call(value);

    if (valorDiferente) {
      onChanged?.call(value);
      notifyListeners();
    }
  }

  /// É chamado sempre que um valor é atribuido
  void Function(String)? onUpdate;

  /// É chamado somente quando o novo valor é diferente do antigo
  void Function(String)? onChanged;

  @override
  bool operator ==(Object other) {
    return (other is String && other == _value) || (other is OkiString && other._value == _value);
  }

  @override
  int get hashCode => _value.hashCode;

}


class OkiList<L> extends ChangeNotifier implements List<L> {

  final bool noDuplicate;
  OkiList({this.noDuplicate = false}) {
    _updateLenght();
  }

  final List<L> values = [];

  void _updateLenght() {
    if (isNotEmpty) {
      last = values.last;
      first = values.first;
    }
    length = values.length;
  }

  void _common() {
    _updateLenght();
    notifyListeners();
  }

  @override
  late L first;

  @override
  late L last;

  @override
  late int length;

  @override
  List<L> operator +(List<L> other) {
    final b = values + other;
    _common();
    return b;
  }

  @override
  L operator [](int index) => values[index];

  @override
  void operator []=(int index, value) {
    if (noDuplicate && contains(value)) {
      return;
    }
    values[index] = value;
    _common();
  }

  @override
  void add(value) {
    if (noDuplicate && contains(value)) {
      return;
    }
    values.add(value);
    _common();
  }

  @override
  void addAll(Iterable<L> iterable) {
    values.addAll(iterable);
    _common();
  }

  @override
  void clear() {
    values.clear();
    _common();
  }

  @override
  bool remove(Object? value) {
    final b = values.remove(value);
    _common();
    return b;
  }

  @override
  L removeAt(int index) {
    final b = values.removeAt(index);
    _common();
    return b;
  }

  @override
  L removeLast() {
    final b = values.removeLast();
    _common();
    return b;
  }

  @override
  void removeRange(int start, int end) {
    values.removeRange(start, end);
    _common();
  }

  @override
  void removeWhere(bool Function(L) test) {
    values.removeWhere(test);
    _common();
  }

  @override
  bool any(bool Function(L) test) => values.any(test);

  @override
  Map<int, L> asMap() => values.asMap();

  @override
  List<R> cast<R>() => values.cast();


  @override
  bool contains(Object? element) => values.contains(element);

  @override
  L elementAt(int index) => values.elementAt(index);

  @override
  bool every(bool Function(L) test) => values.every(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(L) f) => values.expand(f);

  @override
  void fillRange(int start, int end, [fillValue]) => values.fillRange(start, end, fillValue);

  @override
  L firstWhere(bool Function(L) test, {L Function()? orElse}) => values.firstWhere(test, orElse: orElse);

  @override
  T fold<T>(T initialValue, T Function(T previousValue, L) combine) => values.fold(initialValue, combine);

  @override
  Iterable<L> followedBy(Iterable<L> other) => values.followedBy(other);

  @override
  void forEach(void Function(L) f) => values.forEach(f);

  @override
  Iterable<L> getRange(int start, int end) => values.getRange(start, end);

  @override
  int indexOf(element, [int start = 0]) => values.indexOf(element, start);

  @override
  int indexWhere(bool Function(L) test, [int start = 0]) => values.indexWhere(test, start);

  @override
  void insert(int index, element) => values.insert(index, element);

  @override
  void insertAll(int index, Iterable<L> iterable) => values.insertAll(index, iterable);

  @override
  bool get isEmpty => values.isEmpty;

  @override
  bool get isNotEmpty => values.isNotEmpty;

  @override
  Iterator<L> get iterator => values.iterator;

  @override
  String join([String separator = ""]) => values.join(separator);

  @override
  int lastIndexOf(element, [int? start]) => values.lastIndexOf(element, start);

  @override
  int lastIndexWhere(bool Function(L) test, [int? start]) => values.lastIndexWhere(test, start);

  @override
  L lastWhere(bool Function(L) test, {L Function()? orElse}) => values.lastWhere(test, orElse: orElse);

  @override
  Iterable<T> map<T>(T Function(L) f) => values.map(f);

  @override
  L reduce(L Function(L, L) combine) => values.reduce(combine);

  @override
  void replaceRange(int start, int end, Iterable<L> replacements) => values.replaceRange(start, end, replacements);

  @override
  void retainWhere(bool Function(L) test) => values.retainWhere(test);

  @override
  Iterable<L> get reversed => values.reversed;

  @override
  void setAll(int index, Iterable<L> iterable) => values.setAll(index, iterable);

  @override
  void setRange(int start, int end, Iterable<L> iterable, [int skipCount = 0]) => values.setRange(start, end, iterable);

  @override
  void shuffle([Random? random]) => values.shuffle(random);

  @override
  get single => values.single;

  @override
  L singleWhere(bool Function(L) test, {L Function()? orElse}) => values.singleWhere(test, orElse: orElse);

  @override
  Iterable<L> skip(int count) => values.skip(count);

  @override
  Iterable<L> skipWhile(bool Function(L) test) => values.skipWhile(test);

  @override
  void sort([int Function(L, L)? compare]) => values.sort(compare);

  @override
  List<L> sublist(int start, [int? end]) => values.sublist(start, end);

  @override
  Iterable<L> take(int count) => values.take(count);

  @override
  Iterable<L> takeWhile(bool Function(L) test) => values.takeWhile(test);

  @override
  List<L> toList({bool growable = true}) => values.toList(growable: growable);

  @override
  Set<L> toSet() => values.toSet();

  @override
  Iterable<L> where(bool Function(L) test) => values.where(test);

  @override
  Iterable<T> whereType<T>() => values.whereType();

}
