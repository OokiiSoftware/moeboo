import 'package:flutter/material.dart';

class OkiMap<K, V> extends ChangeNotifier implements Map<K, V> {

  final Map<K, V> _items = {};

  //region overrides

  @override
  V? remove(Object? key) {
    _items.remove(key);
    notifyListeners();
    return null;
  }

  @override
  V? operator [](Object? key) => _items[key];

  @override
  void operator []=(K key, V value) {
    _items[key] = value;
    notifyListeners();
  }

  @override
  void addAll(Map<K, V> other) {
    _items.addAll(other);
    notifyListeners();
  }

  /// Adiciona os valores sem chamar Listener
  void addAllNoListener(Map<K, V> other) {
    _items.addAll(other);
  }

  @override
  void clear() {
    _items.clear();
    notifyListeners();
  }

  @override
  bool get isEmpty => _items.isEmpty;

  @override
  bool get isNotEmpty => _items.isNotEmpty;

  @override
  Iterable<K> get keys => _items.keys;

  @override
  Iterable<MapEntry<K, V>> get entries => _items.entries;

  @override
  int get length => _items.length;

  @override
  void removeWhere(bool Function(K key, V value) test) {
    _items.removeWhere(test);
    notifyListeners();
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) => _items.addEntries(newEntries);

  @override
  Map<RK, RV> cast<RK, RV>() => _items.cast();

  @override
  bool containsKey(Object? key) => _items.containsKey(key);

  @override
  bool containsValue(Object? value) => _items.containsValue(value);

  @override
  void forEach(void Function(K key, V value) action) => _items.forEach(action);

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) => _items.map(convert);

  @override
  V putIfAbsent(K key, V Function() ifAbsent) => _items.putIfAbsent(key, ifAbsent);

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) => _items.update(key, update);

  @override
  void updateAll(V Function(K key, V value) update) => _items.updateAll(update);

  @override
  Iterable<V> get values => _items.values;

  //endregion
}
