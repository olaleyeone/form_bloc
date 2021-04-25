import 'dart:async';

import './form_control.dart';
import './form_state.dart';

export './form_state.dart';
export './form_control.dart';
export './form_control_state.dart';

class FormBloc {
  FormState _state;
  Map<String, FormControl<dynamic>> _controls;
  StreamController<bool> _validity;
  bool _valid = false;

  FormBloc({FormState state}) {
    _state = state ?? FormState();
    this._controls = Map<String, FormControl<dynamic>>();
    _validity = StreamController.broadcast();
  }

  bool get valid => _valid;

  Stream<bool> get validityStream => _validity.stream;

  Map<String, dynamic> get value => _state.data;

  addControl<T>(String name, FormControl<T> control) {
    _controls[name] = control;
    control.stateStream.listen((event) {
      _state.setField(name, event?.value);
      _valid = _isValid();
      _validity.sink.add(_valid);
    });

    _validity.sink.add(_isValid());
  }

  bool _isValid() {
    for (var val in _controls.values) {
      if (val.state == null || val.state.error != null) {
        return false;
      }
    }
    return true;
  }

  FormControl<T> getControl<T>(String name) =>
      _controls[name] as FormControl<T>;

  void dispose() {
    _validity.close();
  }
}
