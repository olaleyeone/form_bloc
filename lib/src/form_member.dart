import 'form_member_state.dart';

abstract class FormMember<T> {
  FormMemberState<T> get state;

  Stream<FormMemberState<T>> get stateStream;
}
