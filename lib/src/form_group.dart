import 'dart:async';

import 'package:form_state/form_state.dart';

import 'form_group_state.dart';

import 'form_member.dart';

class FormGroup implements FormMember<Map<String, dynamic>> {
  Map<String, dynamic> _value;
  StreamController<FormGroupState> _stream;
  Map<String, FormMember<dynamic>> _members;
  Map<String, List<StreamSubscription<FormMemberState<dynamic>>>> _listeners;

  StreamController<bool> _validity;
  bool _valid = true;

  FormGroup({Map<String, FormMember<dynamic>> members}) {
    _stream = StreamController.broadcast();
    _validity = StreamController.broadcast();
    _value = Map<String, dynamic>();
    _members = Map<String, FormMember<dynamic>>();
    _listeners =
        Map<String, List<StreamSubscription<FormMemberState<dynamic>>>>();
    if (members != null) {
      this._members.addAll(members);
    }

    refreshState();
  }

  bool get valid => _valid;

  Stream<bool> get validityStream => _validity.stream;

  Map<String, dynamic> get value => _value;

  Stream<FormGroupState> get stateStream => _stream.stream;

  FormGroupState get state => FormGroupState(
        value: _value,
        errors: _members.values
            .map((e) => e.state)
            .where((element) => element != null && element.errors != null)
            .map((e) => e.errors)
            .fold(
          [],
          (value, element) {
            value.addAll(element);
            return value;
          },
        ),
      );

  add<T>(String name, FormMember<T> control,
      {List<FormMember<dynamic>> dependsOn}) {
    List<StreamSubscription<FormMemberState<T>>> listeners = [];
    _members[name] = control;
    _listeners[name] = listeners;

    if (dependsOn != null) {
      listeners.addAll(dependsOn.map(
          (element) => element.stateStream.listen((event) => refreshState())));
    }

    listeners.add(control.stateStream.listen((event) {
      _value[name] = event?.value;
      refreshState();
    }));

    _value[name] = control.state?.value;
    refreshState();
  }

  @override
  Future<FormGroupState> refreshState() {
    _valid = _isValid();
    _validity.sink.add(_valid);
    FormGroupState _state = state;
    _stream.sink.add(_state);
    return Future.value(_state);
  }

  bool _isValid() {
    for (var entry in _members.entries) {
      if (entry.value.state == null ||
          (entry.value.state.errors?.isNotEmpty ?? false)) {
        return false;
      }
    }
    return true;
  }

  FormMember<T> get<T>(String name) => _members[name] as FormMember<T>;

  void remove(String name) {
    _members.remove(name);
    final listeners = _listeners.remove(name);
    if (listeners != null) {
      listeners.forEach((element) => element.cancel());
    }
    refreshState();
  }

  void dispose() {
    _validity.close();
    _stream.close();
    _listeners.values
        .forEach((val) => val.forEach((element) => element.cancel()));
    _listeners.clear();
  }
}
