typedef Validator<T> = Future<String> Function(T t);

Future<String> required(dynamic value, {String message}) {
  bool valid = value != null;
  if (valid && value is String) {
    valid = value.isNotEmpty;
  }
  if (!valid) {
    return Future.value(message ?? "Field is required");
  }
  return Future.value();
}

Validator<num> min(num min, {String message}) {
  return (num value) {
    if (value == null || value > min) {
      return Future.value();
    }
    return Future.value("Cannot be less than ${min}");
  };
}

Validator<num> max(num max, {String message}) {
  return (num value) {
    if (value == null || value < max) {
      return Future.value();
    }
    return Future.value("Cannot be greater than ${max}");
  };
}