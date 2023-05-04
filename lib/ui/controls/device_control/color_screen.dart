import "package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart";
import 'package:flutter/material.dart';

import '../../../api/api_response.dart';
import '../../../api/http_service.dart';

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
                Container(
                  margin: EdgeInsets.only(bottom: 100),
                  child: ColorPicker(
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
                ),
                Container(
                  width: double.infinity,
                  height: 100,
                  color: const Color(0xFF1F2128),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              height: 200,
              color: const Color(0xFF1F2128),
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                primary: false,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 40,
                mainAxisSpacing: 40,
                crossAxisCount: 4,
                children: [
                  _swatchesWidget(Color(0xFFF17CBB)),
                  _swatchesWidget(Color(0xFF6C5DD3)),
                  _swatchesWidget(Color(0xFF3542B4)),
                  _swatchesWidget(Color(0xFF499EDB)),
                  _swatchesWidget(Color(0xFFFCAFD8)),
                  _swatchesWidget(Color(0xFFA094F1)),
                  _swatchesWidget(Color(0xFF6E79DA)),
                  _swatchesWidget(Color(0xFF7FC1F1)),
                ],
              ),
            )
          ],
        ));
  }

  Widget _swatchesWidget(Color color) {
    return GestureDetector(
      onTap: () {
        int rgb = (color.red << 16) | (color.green << 8) | color.blue;

        _setColor(rgb);
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color,
        ),
      ),
    );
  }

  void _setColor(int rgb) async {
    _apiResponseBrightness = await httpService
        .commands(99458501, 'set_rgb', true, [rgb, 'smooth', 500]);
    print(_apiResponseBrightness.Data);
  }
}
