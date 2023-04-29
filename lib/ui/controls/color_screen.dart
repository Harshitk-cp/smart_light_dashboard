import "package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart";
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                ColorPicker(
                  pickerOrientation: PickerOrientation.inherit,
                  color: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      int rgb =
                          (value.red << 16) | (value.green << 8) | value.blue;

                      _setColor(rgb);
                    });
                  },
                  initialPicker: Picker.paletteValue,
                ),
                Container(
                  width: double.infinity,
                  height: 100,
                  color: Colors.black,
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: 120,
              color: Colors.black,
            )
          ],
        ));
  }

  void _setColor(int rgb) async {
    _apiResponseBrightness =
        await httpService.commands(99458501, 'set_rgb', [rgb, 'smooth', 500]);
    print(_apiResponseBrightness.Data);
  }
}
