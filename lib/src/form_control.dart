import 'dart:async';

import 'form_member.dart';

import 'merge_validators.dart';
import 'form_control_state.dart';

import '../validator.dart';

class FormControl<T> implements FormMember<T> {
  Validator<T> _validator;
  FormControlState<T> _state;
  T _value;
  StreamController<FormControlState<T>> _stream;

  FormControl({
    T value,
    List<Validator<T>> validators,
  }) {
    _value = value;
    _stream = StreamController<FormControlState<T>>.broadcast();

    if (validators?.isNotEmpty ?? false) {
      _validator = mergeValidators(validators);
      _validator(value).then(
        (error) {
          _state = FormControlState(
            value: value,
            errors: error == null ? [] : [error],
          );
          _stream.sink.add(_state);
        },
      );
    } else {
      _state = FormControlState(value: value);
      _stream.sink.add(_state);
    }
  }

  /// Set a new value
  Future<FormControlState<T>> setValue(T value) {
    _value = value;
    return refreshState();
  }

  /// Set when control is in focus
  setInFocus(bool focus) {
    if (focus) {
      return;
    }
    _markAsVisited();
  }

  _markAsVisited() {
    _state = FormControlState(
      value: _state.value,
      visited: true,
      errors: _state.errors,
    );
    _stream.sink.add(_state);
  }

  T get value => _value;

  @override
  close() {
    _stream.close();
  }

  /// Get the current state of the form member
  @override
  FormControlState<T> get state => _state;

  /// Get a stream to listen to changes in the state of the form member
  @override
  Stream<FormControlState<T>> get stateStream => _stream.stream;

  /// Force form member to compute state by visiting its members
  @override
  Future<FormControlState<T>> refreshState() {
    FormControlState<T> state = _state;
    if (_validator != null) {
      _stream.sink.add(null);
      return _validator(value).then(
        (error) {
          if (_state != state) {
            return refreshState();
          }
          _state = FormControlState(
            value: value,
            visited: state.visited,
            errors: error == null ? [] : [error],
          );
          _stream.sink.add(_state);
          return _state;
        },
      );
    } else {
      _state = FormControlState(
        value: value,
        visited: state.visited,
      );
      _stream.sink.add(_state);
    }
    return Future.value(_state);
  }
}
