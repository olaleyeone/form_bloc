class FormControlState<T> {
  final T value;
  final String error;
  final bool visited;

  FormControlState({
    this.value,
    this.error,
    this.visited = false,
  });
}
