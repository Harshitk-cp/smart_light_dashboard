import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

import '../models/lights_list_response.dart';
import '../models/turn_on_off_response.dart';
import '../utility/constants.dart';
import 'api_error.dart';
import 'api_response.dart';

class HttpService {
  final String baseUrl = ApiConstants.BASE_URL;

  final headers = {
    'Content-Type': 'application/json',
    'Charset': 'utf-8',
    "Connection": "Keep-Alive",
  };

  Future<ApiResponse> turnOnOff() async {
    ApiResponse apiResponse = ApiResponse();
    try {
      Response res = await get(Uri.parse("$baseUrl/switch"), headers: headers);

      switch (res.statusCode) {
        case 200:
          apiResponse.Data = TurnOnOffResponse.fromJson(json.decode(res.body));
          break;
        case 400:
          apiResponse.ApiError = ApiError.fromJson(json.decode(res.body));
          break;
        default:
          apiResponse.ApiError = ApiError.fromJson(json.decode(res.body));
          break;
      }
    } on SocketException {
      apiResponse.ApiError = ApiError(error: "Server error. Please retry");
    }

    return apiResponse;
  }

  Future<ApiResponse> getLightsList() async {
    ApiResponse apiResponse = ApiResponse();

    try {
      Response res = await get(Uri.parse("$baseUrl/lights"), headers: headers);
      List<dynamic> rawLights = <dynamic>[];
      List<LightListResponse> lights = <LightListResponse>[];
      switch (res.statusCode) {
        case 200:
          rawLights = json.decode(res.body);
          for (var rawLight in rawLights) {
            LightListResponse light = LightListResponse.fromJson(rawLight);
            lights.add(light);
          }
          apiResponse.Data = lights;
          break;
        case 400:
          apiResponse.ApiError = ApiError.fromJson(json.decode(res.body));
          break;
        default:
          apiResponse.ApiError = ApiError.fromJson(json.decode(res.body));
          break;
      }
    } on SocketException {
      apiResponse.ApiError = ApiError(error: "Server error. Please retry");
    }

    return apiResponse;
  }

  Future<ApiResponse> commands(
      int id, String method, List<dynamic> params) async {
    ApiResponse apiResponse = ApiResponse();

    try {
      Response res = await post(Uri.parse("$baseUrl/command"),
          body: jsonEncode(
              {'id': id, 'method': method, 'bypass': true, 'params': params}),
          headers: headers);

      switch (res.statusCode) {
        case 200:
          apiResponse.Data = json.decode(res.body);

          break;
        case 400:
          apiResponse.ApiError = ApiError.fromJson(json.decode(res.body));
          break;
        default:
          apiResponse.ApiError = ApiError.fromJson(json.decode(res.body));
          break;
      }
    } on SocketException {
      apiResponse.ApiError = ApiError(error: "Server error. Please retry");
    }

    return apiResponse;
  }
}
