import 'package:flutter/material.dart';
import 'package:smart_light_dashboard/ui/controls/color_screen.dart';
import 'package:smart_light_dashboard/ui/controls/white_screen.dart';

import '../../api/api_response.dart';
import '../../api/http_service.dart';

class DeviceControlPage extends StatefulWidget {
  const DeviceControlPage({super.key});

  @override
  _DeviceControlPageState createState() {
    return _DeviceControlPageState();
  }
}

class _DeviceControlPageState extends State<DeviceControlPage> {
  late ApiResponse _apiResponseBrightness = ApiResponse();
  final HttpService httpService = HttpService();
  late Color color = Colors.white;
  final String _deviceName = "Yeelight LightStrip Plus";
  final PageController _controller = PageController();
  List<bool> _toggleControls = [true, false];
  int _curr = 0;
  int _sliderVal = 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black38,
        body: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
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
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
                const Spacer(),
                InkWell(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.only(right: 20, left: 20),
                    child: const Icon(
                      Icons.graphic_eq_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _toggleControls[0] = true;
                          _toggleControls[1] = false;
                          _controller.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _toggleControls[0]
                              ? Colors.green.shade400
                              : Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                            child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text("White",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        )),
                      ),
                    )),
                Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _toggleControls[0] = false;
                          _toggleControls[1] = true;
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: _toggleControls[1]
                              ? Colors.green.shade400
                              : Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                            child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Colour",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )),
                      ),
                    )),
              ]),
            ),
            Expanded(
              child: PageView(
                allowImplicitScrolling: true,
                scrollDirection: Axis.horizontal,
                controller: _controller,
                onPageChanged: (num) {
                  setState(() {
                    _toggleControls.fillRange(0, _toggleControls.length, false);
                    _curr = num;
                    _toggleControls[num] = true;
                  });
                },
                children: const [
                  Center(
                    child: WhiteScreen(),
                  ),
                  Center(
                    child: ColorScreen(),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade900),
              child: Slider(
                value: _sliderVal.toDouble(),
                activeColor: Colors.green.shade400,
                inactiveColor: Colors.green.shade800,
                max: 100,
                min: 1,
                onChangeEnd: (double value) {
                  setState(() {
                    _setBrightness(value.toInt());
                  });
                },
                onChanged: (double value) {
                  setState(() {
                    _sliderVal = value.round();
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _setBrightness(int brightness) async {
    _apiResponseBrightness = await httpService
        .commands(99458501, 'set_bright', [brightness, 'smooth', 500]);
    print(_apiResponseBrightness.Data);

    if ((_apiResponseBrightness.Data) != null) {
      // Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
