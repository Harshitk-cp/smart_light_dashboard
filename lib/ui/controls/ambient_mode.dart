import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_projection_creator/media_projection_creator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../api/api_response.dart';
import '../../api/http_service.dart';

class WhiteScreen extends StatefulWidget {
  const WhiteScreen({super.key});

  @override
  _WhiteScreenState createState() {
    return _WhiteScreenState();
  }
}

class _WhiteScreenState extends State<WhiteScreen> {
  late ApiResponse _apiResponseColour = ApiResponse();
  final HttpService _httpService = HttpService();
  String _createMediaProjectionResult = 'Start Mode';
  late Timer timer;

  bool _isStreaming = false;
  bool _isStreamingAudio = false;

  static const platform =
      MethodChannel('com.example.smart_light_dashboard/get-rgb');

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      Timer(const Duration(milliseconds: 50), () {
        _isStreaming ? getRGBValue() : print("Not Streaming!");
        _isStreamingAudio ? getAudioFormat() : print("Not Capturing Audio!");
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1F2128),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            SizedBox(
              width: 380,
              child: CupertinoButton(
                color: const Color(0xFF6C5DD3),
                onPressed: () {
                  launch('Video');
                },
                child: const Text('Create Video MediaProjection'),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Result: $_createMediaProjectionResult',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 380,
              child: CupertinoButton(
                color: const Color(0xFF6C5DD3),
                onPressed: finish,
                child: const Text('Destroy MediaProjection'),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 380,
              child: CupertinoButton(
                color: const Color(0xFF6C5DD3),
                onPressed: () {
                  launch('Audio');
                },
                child: const Text('Create Audio MediaProjection'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getPermissions() async {
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      print('Permission granted');
    } else if (status == PermissionStatus.denied) {
      print(
          'Permission denied. Show a dialog and again ask for the permission');
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('Take the user to the settings page.');
      await openAppSettings();
    }
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

  Future<void> getAudioFormat() async {
    try {
      final double result = await platform.invokeMethod('getAudioFormat');
      print('Audio format received: $result');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void launch(String media) async {
    int errorCode = await MediaProjectionCreator.createMediaProjection();

    setState(() {
      print('createMediaProjection, result: $errorCode');
      switch (errorCode) {
        case MediaProjectionCreator.ERROR_CODE_SUCCEED:
          _createMediaProjectionResult = 'Succeed';
          setState(() {
            (media == "Video") ? _isStreaming = true : _isStreamingAudio = true;
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
    final int result = await platform.invokeMethod("stopCapture");
    if (result == 0) {
      print("Capturing Stopped by user");
    }
    setState(() {
      _createMediaProjectionResult = 'Start Mode';
      _isStreaming = false;
      _isStreamingAudio = false;
    });
  }

  void sendColour(int rgb) async {
    _apiResponseColour = await _httpService
        .commands(99458501, 'set_rgb', true, [rgb, 'smooth', 200]);
    print(_apiResponseColour.Data);

    if ((_apiResponseColour.Data) != null) {}
  }
}
