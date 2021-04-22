typedef Validator<T> = Future<String> Function(T t);

Validator<T> mergeValidators<T>(List<Validator<T>> validators) {
  return (T value) async {
    for (var entry in validators) {
      String error = await entry(value);
      if (error != null) {
        return Future.value(error);
      }
    }
    return Future.value();
  };
}
