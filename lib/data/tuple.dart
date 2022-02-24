class Tuple<K, V> {
  late K _val1;
  late V _val2;

  Tuple(this._val1, this._val2);

  K v1() => _val1;

  V v2() => _val2;

  void set1(K v) {
    _val1 = v;
  }

  void set2(V v) {
    _val2 = v;
  }
}
