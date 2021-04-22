class FormState {
  Map<String, dynamic> _data;

  FormState() {
    this._data = Map<String, dynamic>();
  }

  setField(String name, dynamic value) {
    _data[name] = value;
  }

  Map<String, dynamic> get data => _data;
}
