import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_projection_creator/media_projection_creator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../api/api_response.dart';
import '../../api/http_service.dart';

class AudioModePage extends StatefulWidget {
  const AudioModePage({super.key});

  @override
  _AudioModePageState createState() {
    return _AudioModePageState();
  }
}

class _AudioModePageState extends State<AudioModePage> {
  late ApiResponse _apiResponseColour = ApiResponse();
  late ApiResponse _apiResponseToggle = ApiResponse();
  final HttpService _httpService = HttpService();
  late Timer timer;
  bool _isStreaming = false;
  final String _deviceName = "Yeelight LightStrip Plus";
  bool _togglePower = true;

  final List<int> colors = [0xff0000, 0x00ff00, 0x0000ff, 0xffaa00, 0xff00aa];
  int color_index = 0;

  static const platform =
      MethodChannel('com.example.smart_light_dashboard/get-rgb');

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      Timer(const Duration(milliseconds: 50), () {
        if (_isStreaming) {
          _getAudioOutput();
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF1F2128),
        body: Column(
          children: [
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 20, left: 20),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(_deviceName,
                      style: const TextStyle(
                          fontSize: 20, color: Color(0xFFf9f9f9))),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        final res = _togglePowerFun();
                        (res == "Fail")
                            ? print("failed")
                            : _togglePower = !_togglePower;
                      });
                    },
                    child: _togglePower
                        ? _togglePowerWidget(
                            const Color(0xFF6C5DD3), const Color(0xFF8374EE))
                        : _togglePowerWidget(
                            const Color(0xFF2F323B), const Color(0xFF3A3E49)),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFF262930),
              thickness: 2,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Expanded(
                          flex: 6,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.black,
                                gradient: RadialGradient(radius: 2.5, colors: [
                                  Color(0xFF1F2128),
                                  Color(0xFF6C5DD3)
                                ])),
                            child: const Align(
                              alignment: Alignment.bottomCenter,
                              child: Icon(
                                Icons.bar_chart,
                                color: Color(0xFF6C5DD3),
                                size: 0,
                              ),
                            ),
                          )),
                      Expanded(
                          flex: 7,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Color(0xFF6C5DD3), width: 5)),
                                  color: Color(0xFF262930),
                                ),
                                child: const SizedBox(
                                  height: 400,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isStreaming
                                        ? _stopStreaming()
                                        : _startStreaming();
                                  });
                                },
                                child: _toggleModeWidget(),
                              )
                            ],
                          )),
                    ],
                  ),
                  Positioned(
                      top: 240,
                      child: Container(
                        height: 200,
                        padding: const EdgeInsets.all(65),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(radius: 0.4, colors: [
                            const Color(0xFF6C5DD3),
                            Color(0xFF2F323B)
                          ]),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15.0,
                                spreadRadius: 0,
                                offset: const Offset(0, 4))
                          ],
                          border: Border.all(
                              color: const Color(0xFF8374EE), width: 3),
                          color: const Color(0xFF6C5DD3),
                        ),
                        child: Image.asset(
                          'assets/video_mode/audio_icon.png',
                          color: const Color(0xFF8374EE),
                        ),
                      ))
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF242731),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.color_lens_outlined),
              label: 'Color',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.videocam),
              label: 'Ambient Mode',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: 'Music Mode',
            ),
          ],
          currentIndex: 2,
          unselectedItemColor: const Color(0xFF3A3E49),
          selectedItemColor: const Color(0xFF8374EE),
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _toggleModeWidget() {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15.0,
              spreadRadius: 0,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: const Color(0xFF8374EE), width: 3),
        color: const Color(0xFF6C5DD3),
      ),
      child: Icon(
        _isStreaming ? Icons.square_rounded : Icons.play_arrow_rounded,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _togglePowerWidget(Color color, borderColor) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15.0,
              spreadRadius: 0,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: borderColor, width: 3),
        color: color,
        borderRadius: BorderRadius.circular(40),
      ),
      child: const Icon(
        Icons.power_settings_new,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      switch (index) {
        case 0:
          {
            Navigator.pop(context);
            break;
          }

        case 1:
          {
            Navigator.popAndPushNamed(context, '/videoModePage');
            break;
          }
        case 2:
          {
            break;
          }
      }
    });
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

  Future<void> _getAudioOutput() async {
    try {
      final double result = await platform.invokeMethod('getAudioOutput');
      if (result > 0.0) {
        color_index = (color_index + 1) % colors.length;
        int color = colors[color_index];
        sendColour(color);
      }
      print('Audio format received: $result');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void _startStreaming() async {
    int errorCode = await MediaProjectionCreator.createMediaProjection();

    setState(() {
      switch (errorCode) {
        case MediaProjectionCreator.ERROR_CODE_SUCCEED:
          setState(() {
            _isStreaming = true;
          });
          break;
        case MediaProjectionCreator.ERROR_CODE_FAILED_USER_CANCELED:
          print('Failed: User Canceled Hello');
          break;
        case MediaProjectionCreator.ERROR_CODE_FAILED_SYSTEM_VERSION_TOO_LOW:
          print('Failed: System API level need to higher than 21');
          break;
      }
    });
  }

  void _stopStreaming() async {
    await MediaProjectionCreator.destroyMediaProjection();
    final int result = await platform.invokeMethod("stopCapture");
    if (result == 0) {
      print("Capturing Stopped by user");
    }
    setState(() {
      _isStreaming = false;
    });
  }

  void sendColour(int rgb) async {
    _apiResponseColour = await _httpService
        .commands(99458501, 'set_rgb', true, [rgb, 'smooth', 200]);
    // print(_apiResponseColour.Data);

    // if ((_apiResponseColour.Data) != null) {}
  }

  Future<String> _togglePowerFun() async {
    _apiResponseToggle =
        await _httpService.commands(99458501, 'toggle', false, []);

    if ((_apiResponseToggle.Data) != null) {
      // Navigator.of(context, rootNavigator: true).pop();
      return _apiResponseToggle.Data.toString();
    } else {
      return "Fail";
    }
  }
}
