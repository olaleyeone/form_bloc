abstract class FormMemberState<T> {
  /// get the value of a form member in a particular state
  T get value;

  /// get first error message of form member or null if the member is valid
  String get error;

  /// get all error messages of form member
  List<String> get errors;
}
