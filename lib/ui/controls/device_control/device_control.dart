import 'package:flutter/material.dart';
import 'package:smart_light_dashboard/ui/controls/device_control/color_screen.dart';
import 'package:smart_light_dashboard/ui/controls/ambient_mode.dart';

import '../../../api/api_response.dart';
import '../../../api/http_service.dart';

class DeviceControlPage extends StatefulWidget {
  const DeviceControlPage({super.key});

  @override
  _DeviceControlPageState createState() {
    return _DeviceControlPageState();
  }
}

class _DeviceControlPageState extends State<DeviceControlPage> {
  late ApiResponse _apiResponseBrightness = ApiResponse();
  final HttpService _httpService = HttpService();
  late ApiResponse _apiResponseToggle = ApiResponse();
  late Color color = Colors.white;
  final String _deviceName = "Yeelight LightStrip Plus";
  final PageController _controller = PageController();
  List<bool> _toggleControls = [true, false];
  int _curr = 0;
  int _sliderVal = 1;
  int _selectedIndex = 0;
  bool _toggle = true;

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
                        final res = _toggleFun();
                        (res == "Fail") ? print("failed") : _toggle = !_toggle;
                      });
                    },
                    child: _toggle
                        ? toggleWidget(
                            const Color(0xFF6C5DD3), const Color(0xFF8374EE))
                        : toggleWidget(
                            const Color(0xFF2F323B), const Color(0xFF3A3E49)),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFF262930),
              thickness: 2,
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF2F323B),
                borderRadius: BorderRadius.circular(12),
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
                              ? const Color(0xFF6C5DD3)
                              : const Color(0xFF2F323B),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            _toggleControls[0]
                                ? BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 15.0,
                                    spreadRadius: 1,
                                  )
                                : const BoxShadow(),
                          ],
                        ),
                        child: const Center(
                            child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text("Color",
                              style: TextStyle(color: Colors.white)),
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
                                ? const Color(0xFF6C5DD3)
                                : const Color(0xFF2F323B),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              _toggleControls[1]
                                  ? BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 15.0,
                                      spreadRadius: 1,
                                    )
                                  : const BoxShadow(),
                            ]),
                        child: const Center(
                            child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "White",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        )),
                      ),
                    )),
              ]),
            ),
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                allowImplicitScrolling: false,
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
                    child: ColorScreen(),
                  ),
                  Center(
                    child: AmbientMode(),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15.0,
                      spreadRadius: 0,
                      offset: const Offset(0, 4))
                ],
                color: const Color(0xFF242731),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Slider(
                value: _sliderVal.toDouble(),
                activeColor: const Color(0xAA8374EE),
                inactiveColor: const Color(0x604d5261),
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
          currentIndex: 0,
          unselectedItemColor: const Color(0xFF3A3E49),
          selectedItemColor: const Color(0xFF8374EE),
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Future<String> _toggleFun() async {
    _apiResponseToggle =
        await _httpService.commands(99458501, 'toggle', false, []);

    if ((_apiResponseToggle.Data) != null) {
      // Navigator.of(context, rootNavigator: true).pop();
      return _apiResponseToggle.Data.toString();
    } else {
      return "Fail";
    }
  }

  Widget toggleWidget(Color color, borderColor) {
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
            break;
          }
        case 1:
          {
            Navigator.pushNamed(context, '/videoModePage');
            break;
          }
        case 2:
          {
            Navigator.popAndPushNamed(context, '/audioModePage');
            break;
          }
      }
    });
  }

  void _setBrightness(int brightness) async {
    _apiResponseBrightness = await _httpService
        .commands(99458501, 'set_bright', true, [brightness, 'smooth', 500]);
    print(_apiResponseBrightness.Data);

    if ((_apiResponseBrightness.Data) != null) {
      // Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
