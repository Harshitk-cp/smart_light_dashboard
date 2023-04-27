class LightListResponse {
  int? statusRefreshInterval;
  String? ip;
  int? port;
  int? id;
  String? model;
  int? fwVer;
  List<String>? support;
  bool? power;
  int? bright;
  int? colorMode;
  int? ct;
  int? rgb;
  int? hue;
  int? sat;
  String? name;

  LightListResponse(
      {this.statusRefreshInterval,
      this.ip,
      this.port,
      this.id,
      this.model,
      this.fwVer,
      this.support,
      this.power,
      this.bright,
      this.colorMode,
      this.ct,
      this.rgb,
      this.hue,
      this.sat,
      this.name});

  LightListResponse.fromJson(Map<String, dynamic> json) {
    statusRefreshInterval = json['status_refresh_interval'];
    ip = json['ip'];
    port = json['port'];
    id = json['id'];
    model = json['model'];
    fwVer = json['fw_ver'];
    support = <String>[];
    for (var method in json['support'] as List<dynamic>) {
      support!.add(method as String);
    }
    power = json['power'];
    bright = json['bright'];
    colorMode = json['color_mode'];
    ct = json['ct'];
    rgb = json['rgb'];
    hue = json['hue'];
    sat = json['sat'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status_refresh_interval'] = statusRefreshInterval;
    data['ip'] = ip;
    data['port'] = port;
    data['id'] = id;
    data['model'] = model;
    data['fw_ver'] = fwVer;
    // data['support'] = support;
    data['power'] = power;
    data['bright'] = bright;
    data['color_mode'] = colorMode;
    data['ct'] = ct;
    data['rgb'] = rgb;
    data['hue'] = hue;
    data['sat'] = sat;
    data['name'] = name;
    return data;
  }
}
