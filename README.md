# form_state
Lightweight reactive form library

## Login Form Sample

```
enum LoginField { IDENTIFIER, PASSWORD }

class LoginBloc {
  final _form = FormGroup();

  LoginBloc(this.authBloc) {
    _form.addControl<String>(
      LoginField.IDENTIFIER.toString(),
      FormControl<String>(
        validators: [requiredField, validEmail],
      ),
    );
    _form.addControl<String>(
      LoginField.PASSWORD.toString(),
      FormControl<String>(validators: [requiredField]),
    );
  }

  FormControl<T> getControl<T>(LoginField field) =>
      _form.getControl<T>(field.toString());

  Stream<bool> get valid => _form.validityStream;

  Future login() {
    final data = _form.value;
    final apiRequest = PasswordLoginApiRequest()
      ..identifier = (data[LoginField.IDENTIFIER.toString()] as String)?.trim()
      ..password = data[LoginField.PASSWORD.toString()] as String;
    return **your_api_client**.login(apiRequest);
  }

  static LoginBloc of(BuildContext context) {
    final LoginBlocProvider provider = context.findAncestorWidgetOfExactType();
    return provider.bloc;
  }

  void dispose() {
    _form.dispose();
  }
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
          obscureText: !_showPassword,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 15),
            suffix: IconButton(
              icon: _showPassword
                  ? Icon(Icons.visibility)
                  : Icon(Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
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
