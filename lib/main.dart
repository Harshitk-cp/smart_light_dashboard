import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_light_dashboard/ui/controls/audio_mode.dart';
import 'package:smart_light_dashboard/ui/controls/device_control/device_control.dart';
import 'package:smart_light_dashboard/ui/controls/video_mode.dart';

import 'ui/home/device_selection.dart';

void main() {
  runApp(MyApp());
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF1F2128), // navigation bar color
    statusBarColor: Color(0xFF1F2128), // status bar color
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Light Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: getMaterialColor(),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (context) => const DeviceSelectionPage(),
        '/controls': (context) => const DeviceControlPage(),
        '/videoModePage': (context) => const VideoModePage(),
        '/audioModePage': (context) => const AudioModePage()
      },
    );
  }

  MaterialColor getMaterialColor() {
    int colorValue = 0xFF144c83;
    Color color = Color(colorValue);
    Map<int, Color> shades = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]
        .asMap()
        .map((key, value) =>
            MapEntry(value, color.withOpacity(1 - (1 - (key + 1) / 10))));

    return MaterialColor(colorValue, shades);
  }
}
