import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smart_light_dashboard/api/api_response.dart';
import 'package:smart_light_dashboard/api/http_service.dart';
import 'package:smart_light_dashboard/models/lights_list_response.dart';
import 'package:smart_light_dashboard/models/turn_on_off_response.dart';
import 'package:smart_light_dashboard/ui/home/device_selection.dart';

class MockHttpService extends Mock implements HttpService {}

void main() {}
