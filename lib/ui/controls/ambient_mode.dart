import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_projection_creator/media_projection_creator.dart';
import '../../api/api_response.dart';
import '../../api/http_service.dart';

class AmbientMode extends StatefulWidget {
  const AmbientMode({super.key});

  @override
  _AmbientModeState createState() {
    return _AmbientModeState();
  }
}

class _AmbientModeState extends State<AmbientMode> {
  late ApiResponse _apiResponseColour = ApiResponse();
  final HttpService _httpService = HttpService();
  String _createMediaProjectionResult = 'Start Mode';
  late Timer timer;

  bool _isStreaming = false;

  static const platform =
      MethodChannel('com.example.smart_light_dashboard/get-rgb');

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 500), (Timer timer) {
      Timer(const Duration(milliseconds: 50), () {
        _isStreaming ? getRGBValue() : print("Not Streaming!");
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            CupertinoButton.filled(
              onPressed: launch,
              child: const Text('Create MediaProjection'),
            ),
            const SizedBox(height: 10),
            Text(
              'Result: $_createMediaProjectionResult',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 50),
            CupertinoButton.filled(
              onPressed: finish,
              child: const Text('Destroy MediaProjection'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getRGBValue() async {
    try {
      final int result = await platform.invokeMethod("getRGBValue");
      int r = (result & 0xff0000) >> 16;
      int g = (result & 0x00ff00) >> 8;
      int b = (result & 0x0000ff) >> 0;
      print("rgba($r, $g, $b)");
      _isStreaming
          ? sendColour(result & 0xffffff)
          : print("Streaming not started!");
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void launch() async {
    int errorCode = await MediaProjectionCreator.createMediaProjection();

    setState(() {
      print('createMediaProjection, result: $errorCode');
      switch (errorCode) {
        case MediaProjectionCreator.ERROR_CODE_SUCCEED:
          _createMediaProjectionResult = 'Succeed';
          setState(() {
            _isStreaming = true;
          });
          break;
        case MediaProjectionCreator.ERROR_CODE_FAILED_USER_CANCELED:
          _createMediaProjectionResult = 'Failed: User Canceled Hello';
          break;
        case MediaProjectionCreator.ERROR_CODE_FAILED_SYSTEM_VERSION_TOO_LOW:
          _createMediaProjectionResult =
              'Failed: System API level need to higher than 21';
          break;
      }
    });
  }

  void finish() async {
    await MediaProjectionCreator.destroyMediaProjection();
    setState(() {
      _createMediaProjectionResult = 'Start Mode';
      _isStreaming = false;
    });
  }

  void sendColour(int rgb) async {
    _apiResponseColour =
        await _httpService.commands(99458501, 'set_rgb', [rgb, 'smooth', 200]);
    print(_apiResponseColour.Data);

    if ((_apiResponseColour.Data) != null) {}
  }
}
