import 'package:form_state/form_state.dart';
import 'package:form_state/validator.dart' as validator;

enum LoginField { IDENTIFIER, PASSWORD }

class LoginBloc {
  final _form = FormGroup();

  LoginBloc() {
    _form.add<String>(
      LoginField.IDENTIFIER.toString(),
      FormControl<String>(
        validators: [validator.required],
      ),
    );
    _form.add<String>(
      LoginField.PASSWORD.toString(),
      FormControl<String>(
        validators: [validator.required],
      ),
    );
  }

  FormControl<T> getControl<T>(LoginField field) =>
      _form.get<T>(field.toString());

  Stream<bool> get valid => _form.validityStream;

  Future login() async {
    final data = _form.value;
    //TODO: make API call and return response;
    return data;
  }

  void dispose() {
    _form.close();
  }
}

main() async {
  final bloc = LoginBloc();
  print(bloc._form.valid); // false
  await bloc.getControl(LoginField.IDENTIFIER).setValue('Form');
  await bloc.getControl(LoginField.PASSWORD).setValue('Reactive');
  await Future.microtask(() async {
    print(bloc._form.valid); // true
    print(await bloc.login());
    bloc.dispose();
  });
}
