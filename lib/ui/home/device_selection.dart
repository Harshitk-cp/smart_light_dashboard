import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_light_dashboard/models/lights_list_response.dart';
import 'package:smart_light_dashboard/models/turn_on_off_response.dart';

import '../../api/api_response.dart';
import '../../api/http_service.dart';
import '../../utility/utility.dart';

class DeviceSelectionPage extends StatefulWidget {
  const DeviceSelectionPage({super.key});

  @override
  _DeviceSelectionPageState createState() {
    return _DeviceSelectionPageState();
  }
}

class _DeviceSelectionPageState extends State<DeviceSelectionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Color color = Colors.white;
  final HttpService httpService = HttpService();
  late ApiResponse _apiLightsListResponse = ApiResponse();
  late ApiResponse _apiResponseToggle = ApiResponse();
  bool _toggle = false;

  @override
  void initState() {
    _getLightsList();
    super.initState();
  }

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
            Stack(
              alignment: Alignment.centerRight,
              children: [
                Center(
                  child: Row(
                    children: const [
                      Spacer(),
                      Text("Devices",
                          style: TextStyle(fontSize: 25, color: Colors.white)),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 30,
                        color: Colors.white,
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/controls');
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20, left: 20),
                    child: const Icon(
                      Icons.add_circle,
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
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/controls',
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '${snapshot.data?[index].id}',
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text('${snapshot.data![index].model}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white)),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _toggleFun();
                                  _toggle = !_toggle;
                                });
                              },
                              child: _toggle
                                  ? const Icon(
                                      Icons.tungsten,
                                      color: Colors.white,
                                    )
                                  : const Icon(Icons.tungsten_outlined,
                                      color: Colors.white),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
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

  Future<List<LightListResponse>> _getLightsList() async {
    _apiLightsListResponse = await httpService.getLightsList();
    final List<LightListResponse> lightsListResponse =
        _apiLightsListResponse.Data as List<LightListResponse>;
    return lightsListResponse;
  }

  void _toggleFun() async {
    _apiResponseToggle = await httpService.commands(99458501, 'toggle', []);

    if ((_apiResponseToggle.Data) != null) {
      // Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
