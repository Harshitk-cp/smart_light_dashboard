import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_light_dashboard/models/lights_list_response.dart';
import '../../api/api_response.dart';
import '../../api/http_service.dart';

class DeviceSelectionPage extends StatefulWidget {
  const DeviceSelectionPage({super.key});

  @override
  _DeviceSelectionPageState createState() {
    return _DeviceSelectionPageState();
  }
}

class _DeviceSelectionPageState extends State<DeviceSelectionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final HttpService _httpService = HttpService();
  late ApiResponse _apiResponseToggle = ApiResponse();
  late ApiResponse _apiResponseState = ApiResponse();
  late ApiResponse _apiLightsListResponse = ApiResponse();
  late bool _toggle = false;
  int n = 0;

  @override
  void initState() {
    _getLightsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF1F2128),
        body: Column(
          children: [
            Container(
              height: 60,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Center(
                    child: Row(
                      children: const [
                        Spacer(),
                        Text("Devices",
                            style: TextStyle(
                                fontSize: 24, color: Color(0xFFf9f9f9))),
                        Spacer(),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _getLightsList();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 30, left: 20),
                      child: const Icon(
                        Icons.refresh_rounded,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFF262930),
              thickness: 2,
            ),
            lightsListView(_getLightsList())
          ],
        ),
      ),
    );
  }

  Widget lightsListView(Future<List<LightListResponse>> list) {
    return Center(
      child: FutureBuilder<List<LightListResponse>>(
        future: list,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return StatefulBuilder(builder: (context, setStateItem) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    margin: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
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
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/controls',
                        );
                      },
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Image.asset(
                              'assets/device_selection/led_strip_icon.png',
                              height: 60,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${snapshot.data?[index].name ?? "Yeelight LED Strip"}',
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                  snapshot.data![index].colorMode == 1
                                      ? "Color Mode"
                                      : "Color Temperature Mode",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF60636E),
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                          const Spacer(),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  _toggleFun();
                                  _toggle = !_toggle;
                                });
                              },
                              child: _toggle
                                  ? toggleWidget(const Color(0xFF6C5DD3),
                                      const Color(0xFF8374EE))
                                  : toggleWidget(const Color(0xFF2F323B),
                                      const Color(0xFF3A3E49)))
                        ],
                      ),
                    ),
                  );
                  ;
                });
              },
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Widget toggleWidget(Color color, borderColor) {
    return Container(
      padding: const EdgeInsets.all(10),
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
        size: 25,
        color: Colors.white,
      ),
    );
  }

  Future<List<LightListResponse>> _getLightsList() async {
    _apiLightsListResponse = await _httpService.getLightsList();
    final List<LightListResponse> lightsListResponse =
        _apiLightsListResponse.Data as List<LightListResponse>;

    setState(() {
      if (n == 0) {
        _getLightState();
      }
      n++;
    });
    return lightsListResponse;
  }

  void _toggleFun() async {
    _apiResponseToggle =
        await _httpService.commands(99458501, 'toggle', false, []);

    if ((_apiResponseToggle.Data) != null) {
      // Navigator.of(context, rootNavigator: true).pop();
      final response = jsonEncode(_apiResponseToggle.Data);
      print(response.substring(11, 18));
    } else {
      print("couldn't toggle");
      ;
    }
  }

  void _getLightState() async {
    print("API CALLED");
    _apiResponseState =
        await _httpService.commands(99458501, 'get_prop', false, ["power"]);
    if ((_apiResponseState.Data) != null) {
      final response = jsonEncode(_apiResponseState.Data);
      if (response.substring(29, 31) == "on") {
        setState(() {
          _toggle = true;
        });
      } else {
        _toggle = false;
      }
      print(_apiResponseState.Data.toString());
    } else {
      print("Not available");
    }
  }
}
