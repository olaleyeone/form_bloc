import 'form_member_state.dart';

class FormGroupState implements FormMemberState<Map<String, dynamic>> {
  final Map<String, dynamic> value;
  final List<String> errors;

  FormGroupState({this.value, this.errors});

  String get error => (errors?.isNotEmpty ?? false) ? errors[0] : null;
}
