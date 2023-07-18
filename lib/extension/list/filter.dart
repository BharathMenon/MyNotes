extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) => map(
      (Listatdifferentpoints) => Listatdifferentpoints.where(where).toList());
}
