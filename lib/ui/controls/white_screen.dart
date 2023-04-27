import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_projection_creator/media_projection_creator.dart';
import 'package:permission_handler/permission_handler.dart';

class WhiteScreen extends StatefulWidget {
  const WhiteScreen({super.key});

  @override
  _WhiteScreenState createState() {
    return _WhiteScreenState();
  }
}

class _WhiteScreenState extends State<WhiteScreen> {
  // create some values
  Color pickerColor = const Color(0xff443a49);
  Color currentColor = const Color(0xff443a49);
  late Color myColor = Colors.white;
  String createMediaProjectionResult = 'Unknown';

  bool _isConnected = false;

  int rgbValue = 0;
  static const platform =
      MethodChannel('com.example.smart_light_dashboard/get-rgb');

  Future<void> getRGBValue() async {
    int value = 0;
    try {
      final int result = await platform.invokeMethod("getRGBValue");
      value = result;
      print("RGB: $value");
    } on PlatformException catch (e) {
      print(e.message);
    }

    setState(() {
      rgbValue = value;
    });
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void launch() async {
    int errorCode = await MediaProjectionCreator.createMediaProjection();

    setState(() {
      print('createMediaProjection, result: $errorCode');
      switch (errorCode) {
        case MediaProjectionCreator.ERROR_CODE_SUCCEED:
          createMediaProjectionResult = 'Succeed';
          print("hi");
          setState(() {
            _isConnected = true;
          });
          break;
        case MediaProjectionCreator.ERROR_CODE_FAILED_USER_CANCELED:
          createMediaProjectionResult = 'Failed: User Canceled Hello';
          print("hello");
          break;
        case MediaProjectionCreator.ERROR_CODE_FAILED_SYSTEM_VERSION_TOO_LOW:
          createMediaProjectionResult =
              'Failed: System API level need to higher than 21';
          print("haha");
          break;
      }
    });
  }

  void finish() async {
    await MediaProjectionCreator.destroyMediaProjection();
    setState(() {
      createMediaProjectionResult = 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            CupertinoButton.filled(
              child: const Text('Create MediaProjection'),
              onPressed: launch,
            ),
            const SizedBox(height: 10),
            Text(
              'Result: $createMediaProjectionResult',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 50),
            CupertinoButton.filled(
              child: const Text('Destroy MediaProjection'),
              onPressed: finish,
            ),
            const SizedBox(height: 50),
            CupertinoButton.filled(
              child: const Text('Get RGB'),
              onPressed: () {
                getRGBValue();
              },
            ),

            // _isConnected
            //     ? StreamBuilder(
            //         stream: eventChannel.receiveBroadcastStream(),
            //         builder: (context, snapshot) {
            //           if (!snapshot.hasData) {
            //             return const CircularProgressIndicator();
            //           }
            //           //? Working for single frames
            //           return Image.memory(
            //             Uint8List.fromList(
            //               base64Decode(
            //                 (snapshot.data.toString()),
            //               ),
            //             ),
            //             gaplessPlayback: true,
            //             excludeFromSemantics: true,
            //           );
            //         },
            //       )
            //     : const Text(
            //         "Initiate Connection",
            //         style: TextStyle(color: Colors.white),
            //       )
          ],
        ),
      ),
    );
  }
}
