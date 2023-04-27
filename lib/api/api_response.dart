// ignore_for_file: non_constant_identifier_names, unnecessary_getters_setters

class ApiResponse {
  // _data will hold any response converted into
  // its own object. For example user.
  late Object _data;
  // _apiError will hold the error object
  late Object _apiError;

  Object get Data => _data;
  set Data(Object data) => _data = data;

  Object get ApiError => _apiError;
  set ApiError(Object error) => _apiError = error;
}
