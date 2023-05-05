import "package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart";
import 'package:flutter/material.dart';

import '../../../api/api_response.dart';
import '../../../api/http_service.dart';

class WhiteScreen extends StatefulWidget {
  const WhiteScreen({super.key});

  @override
  _WhiteScreenState createState() {
    return _WhiteScreenState();
  }
}

class _WhiteScreenState extends State<WhiteScreen> {
  late ApiResponse _apiResponseBrightness = ApiResponse();
  final HttpService httpService = HttpService();
  double posx = 100.0;
  double posy = 100.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(
              height: 120,
            ),
            Listener(
              onPointerMove: (event) {
                setState(() {
                  if (event.localPosition.dy < 220 &&
                      event.localPosition.dy > -8) {
                    posx = event.localPosition.dx;
                    posy = event.localPosition.dy;
                    if (event.localPosition.dx > 0 &&
                        event.localPosition.dx < 150) {
                      int rgb = (223 << 16 | 243 << 8) | (250 << 0);
                      _setColor(rgb);
                    } else if (event.localPosition.dx > 150 &&
                        event.localPosition.dx < 300) {
                      int rgb = (255 << 16 | 255 << 8) | (255 << 0);

                      _setColor(rgb);
                    } else {
                      int rgb = (127 << 16 | 193 << 8) | (241 << 0);

                      _setColor(rgb);
                    }
                  }
                });
              },
              child: Stack(
                children: [
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Color(0xFFF9D480),
                          Color(0xFFFFFFFF),
                          Color(0xFF7FC1F1),
                        ]),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  Positioned(
                      left: posx,
                      top: posy,
                      child: const Icon(
                        Icons.circle_outlined,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 2,
                          )
                        ],
                        color: Colors.white,
                      ))
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 200,
              color: const Color(0xFF1F2128),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                primary: false,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 40,
                mainAxisSpacing: 40,
                crossAxisCount: 4,
                children: [
                  _swatchesWidget(const Color(0xFFFFFFF4)),
                  _swatchesWidget(const Color(0xFFFEFFDA)),
                  _swatchesWidget(const Color(0xFFFEFFC4)),
                  _swatchesWidget(const Color(0xFFFDFFAE)),
                  _swatchesWidget(const Color(0xFFF0F9FF)),
                  _swatchesWidget(const Color(0xFFCEE9FC)),
                  _swatchesWidget(const Color(0xFFA5D7FC)),
                  _swatchesWidget(const Color(0xFF7FC1F1)),
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
