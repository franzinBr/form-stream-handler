library form_stream_handler;

import 'package:rxdart/rxdart.dart';

class Validator {
  final List<Function> _validators = [];

  Validator required(String message) {
    required (value) {
      return (value?.isEmpty ?? true) ? message : null;
    }

    _validators.add(required);

    return this;
  }

  Validator regex(RegExp exp, String message) {

    regex (value) {
      if (exp.hasMatch(value)) return null;
      return message;
    }

    _validators.add(regex);

    return this;
  }

  Validator email(String message) {

    email (value) {
      final exp = RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");
      if (exp.hasMatch(value)) return null;
      return message;
    }

    _validators.add(email);

    return this;
  }

  String? validate(value) {

    for (var validator in _validators) {
      final result = validator(value);

      if (result != null) return result;

    }

    return null;
  }

}

class FormInput<T> {
  late final BehaviorSubject<T> input;
  String? error;
  final Validator? validator;
  final bool validOnChange;

  FormInput(T initialValue, {this.validator, this.validOnChange = false}) {
    input = BehaviorSubject<T>.seeded(initialValue);
  }

  Stream<T> get stream => input.stream;

  void setValue(value) {
    cleanValidation();
    input.sink.add(value);

    if(validOnChange) validate();
  }

  void cleanValidation() {
    error = null;
  }

  void setError(String error) {
    error = error;
    input.sink.addError(error);
  }

  bool hasError() {
    return error != null;
  }

  String? validate() {

    if (validator == null) return null;

    var result = validator!.validate(input.valueOrNull);
    if (result != null) setError(result);

    return result;
  }

}

class FormHandler {
  final Map<String, FormInput> inputs;

  FormHandler(this.inputs);

  FormInput? get(String name) {
    return inputs[name];
  }

  void setValue(String name, dynamic value) {
    get(name)?.setValue(value);
  }

  dynamic getValue(String name) {
    return getInput(name)?.value;
  }

  void setError(String name, String error) {
    return get(name)?.setError(error);
  }

  BehaviorSubject? getInput(String name) {
    return get(name)?.input;
  }

  Stream<T>? getStream<T>(String name) {
    return get(name)?.stream as Stream<T>;
  }

  bool validate() {
    bool isValid = true;
    for(var input in inputs.values) {
      var result = input.validate();
      if (result != null) isValid = false;
    }

    return isValid;
  }

  void dispose() {
    for(var input in inputs.values) {
      input.input.close();
    }
  }
}
