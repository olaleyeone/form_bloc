# form_state
Lightweight reactive form library

## Login Form Sample

```
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
```

## Login Form Inputs
```
Widget _buildEmailInput(FormControl<String> control) {
    return StreamBuilder<FormControlState<String>>(
      stream: control.stateStream,
      builder: (context, snapshot) => Focus(
        child: TextField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'everyone@flutter.app',
            labelText: 'Email Address',
            errorText:
                (snapshot.data?.visited ?? false) ? snapshot.data.error : null,
          ),
          onChanged: control.setValue,
        ),
        onFocusChange: control.setInFocus,
      ),
    );
  }

  Widget _buildPasswordInput(FormControl<String> control) {
    return StreamBuilder<FormControlState<String>>(
      stream: control.stateStream,
      builder: (context, snapshot) => Focus(
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            errorText:
                (snapshot.data?.visited ?? false) ? snapshot.data.error : null,
          ),
          onChanged: control.setValue,
        ),
        onFocusChange: control.setInFocus,
      ),
    );
  }

  Widget _buildSubmitButton(LoginBloc bloc) {
    return StreamBuilder<bool>(
      stream: bloc.valid,
      builder: (context, snapshot) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          child: Text(
            'Login',
          ),
          onPressed:
              (snapshot.data ?? false) ? () => _login(context, bloc) : null,
        ),
      ),
    );
  }
```

Use ```TextFormField``` for inputs that have initial data

```
TextFormField(
          initialValue: control.value,
          ...
          )
```
