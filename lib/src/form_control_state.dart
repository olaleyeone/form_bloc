import 'form_member_state.dart';

class FormControlState<T> implements FormMemberState<T> {
  final T value;
  final List<String> errors;
  final bool visited;

  FormControlState({
    this.value,
    this.errors,
    this.visited = false,
  });

  String get error => (errors?.isNotEmpty ?? false) ? errors.first : null;
}
