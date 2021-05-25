import 'dart:async';

import 'package:form_state/form_state.dart';

import 'form_group_state.dart';

import 'form_member.dart';

class FormGroup implements FormMember<Map<String, dynamic>> {
  Map<String, dynamic> _value = Map();
  StreamController<FormGroupState> _stream = StreamController.broadcast();
  Map<String, FormMember<dynamic>> _members = Map();
  Map<String, List<StreamSubscription<FormMemberState<dynamic>>>> _listeners =
      Map();
  Set<FormMember<dynamic>> _disposables = Set();
  StreamController<bool> _validity = StreamController.broadcast();
  bool _valid = true;

  FormGroup({Map<String, FormMember<dynamic>> members}) {
    if (members != null) {
      this._members.addAll(members);
      this._disposables.addAll(members.values);
    }

    refreshState();
  }

  bool get valid => _valid;

  Stream<bool> get validityStream => _validity.stream;

  Map<String, dynamic> get value => _value;

  @override
  Stream<FormGroupState> get stateStream => _stream.stream;

  @override
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

  add<T>(
    String name,
    FormMember<T> control, {
    List<FormMember<dynamic>> dependsOn,
    bool disposeOnRemove = true,
  }) {
    if (disposeOnRemove == true) {
      _disposables.add(control);
    }
    List<StreamSubscription<FormMemberState<T>>> listeners = [];
    _members[name] = control;
    _listeners[name] = listeners;

    if (dependsOn != null) {
      listeners.addAll(dependsOn.map((element) =>
          element.stateStream.listen((event) => control.refreshState())));
    }

    listeners.add(control.stateStream.listen((event) {
      // print('$name: ${event?.value}');
      _value[name] = event?.value;
      refreshState();
    }));

    _value[name] = control.state?.value;
    refreshState();
  }

  void remove(String name) {
    final member = _members.remove(name);
    if (_disposables.remove(member)) {
      member.close();
    }
    final listeners = _listeners.remove(name);
    if (listeners != null) {
      listeners.forEach((element) => element.cancel());
    }
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

  @override
  void close() {
    _validity.close();
    _stream.close();
    _listeners.values
        .forEach((val) => val.forEach((element) => element.cancel()));
    _listeners.clear();
    _disposables.forEach((element) => element.close());
    _disposables.clear();
  }
}
