import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

import '../../api/api_response.dart';
import '../../api/http_service.dart';

class ColorScreen extends StatefulWidget {
  const ColorScreen({super.key});

  @override
  _ColorScreenState createState() {
    return _ColorScreenState();
  }
}

class _ColorScreenState extends State<ColorScreen> {
  late ApiResponse _apiResponseBrightness = ApiResponse();
  final HttpService httpService = HttpService();
  late Color myColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: ColorPicker(
        color: myColor,
        enableShadesSelection: false,
        onColorChanged: (Color color) {
          setState(() {
            myColor = color;

            int rgb = (myColor.red << 16) | (myColor.green << 8) | myColor.blue;

            _setColor(rgb);
          });
        },
        pickersEnabled: const <ColorPickerType, bool>{
          ColorPickerType.both: false,
          ColorPickerType.accent: false,
          ColorPickerType.primary: false,
          ColorPickerType.custom: true,
          ColorPickerType.wheel: true,
        },
      ),
    );
  }

  void _setColor(int rgb) async {
    int val = rgb;
    _apiResponseBrightness =
        await httpService.commands(99458501, 'set_rgb', [val, 'smooth', 500]);
    print(_apiResponseBrightness.Data);

    if ((_apiResponseBrightness.Data) != null) {
      // Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
