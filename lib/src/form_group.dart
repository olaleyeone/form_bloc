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

  /// Get the current validity of the form
  bool get valid => _valid;

  /// Get a stream to listen to changes in the validity of the form
  Stream<bool> get validityStream => _validity.stream;

  /// Get the current value of the form
  Map<String, dynamic> get value => _value;

  /// Get a stream to listen to changes in the state of the form
  @override
  Stream<FormGroupState> get stateStream => _stream.stream;

  /// Get the current state of the form
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

  /// Add form member.
  /// Optionally provide other members whose value can affect validity of this member.
  add<T>(
    String name,
    FormMember<T> member, {
    List<FormMember<dynamic>> dependsOn,
    bool closeOnRemove = true,
  }) {
    if (closeOnRemove == true) {
      _disposables.add(member);
    }
    List<StreamSubscription<FormMemberState<T>>> listeners = [];
    _members[name] = member;
    _listeners[name] = listeners;

    if (dependsOn != null) {
      listeners.addAll(dependsOn.map((element) =>
          element.stateStream.listen((event) => member.refreshState())));
    }

    listeners.add(member.stateStream.listen((event) {
      // print('$name: ${event?.value}');
      _value[name] = event?.value;
      refreshState();
    }));

    _value[name] = member.state?.value;
    refreshState();
  }

  /// Remove a form member by name
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

  /// Force form to compute state by visiting its members
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

  /// Retrieve a form member by name
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
