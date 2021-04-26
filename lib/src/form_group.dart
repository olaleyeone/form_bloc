import 'dart:async';

import 'form_group_state.dart';
import 'form_member_state.dart';

import 'form_member.dart';

class FormGroup implements FormMember<Map<String, dynamic>> {
  Map<String, dynamic> _value;
  StreamController<FormGroupState> _stream;
  Map<String, FormMember<dynamic>> _members;

  StreamController<bool> _validity;
  bool _valid = true;

  FormGroup({Map<String, FormMember<dynamic>> members}) {
    _stream = StreamController.broadcast();
    _validity = StreamController.broadcast();
    _value = Map<String, dynamic>();
    this._members = Map<String, FormMember<dynamic>>();
    if (members != null) {
      this._members.addAll(members);
    }

    _refreshAndBroadcast();
  }

  bool get valid => _valid;

  Stream<bool> get validityStream => _validity.stream;

  Map<String, dynamic> get value => _value;

  Stream<FormGroupState> get stateStream => _stream.stream;

  FormMemberState<Map<String, dynamic>> get state => FormGroupState(
      value: _value,
      errors: _members.values
          .map((e) => e.state)
          .where((element) => element != null && element.errors != null)
          .map((e) => e.errors)
          .fold([], (value, element) {
        value.addAll(element);
        return value;
      }));

  addControl<T>(String name, FormMember<T> control) {
    _members[name] = control;
    control.stateStream.listen((event) {
      _value[name] = event?.value;

      _refreshAndBroadcast();
    });

    _refreshAndBroadcast();
  }

  void _refreshAndBroadcast() {
    _valid = _isValid();
    _validity.sink.add(_valid);
    _stream.sink.add(state);
  }

  bool _isValid() {
    for (var val in _members.values) {
      if (val.state == null || (val.state.errors?.isNotEmpty ?? false)) {
        return false;
      }
    }
    return true;
  }

  FormMember<T> get<T>(String name) => _members[name] as FormMember<T>;

  void dispose() {
    _validity.close();
    _stream.close();
  }
}
