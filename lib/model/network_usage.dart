import 'dart:convert';

class NetworkUsage {
  late int dateKey;
  late double wifiDownload, wifiUpload, cellularDownload, cellularUpload;

  NetworkUsage({
    required this.dateKey,
    required this.wifiDownload,
    required this.wifiUpload,
  });

  NetworkUsage.fromJson(Map netUsage) {
    dateKey = netUsage['day'];
    wifiDownload = netUsage['wifiDownload'];
    wifiUpload = netUsage['wifiUpload'];
    cellularDownload = netUsage['cellularDownload'];
    cellularUpload = netUsage['cellularUpload'];
  }

  Map toJson() {
    final Map netUsage = {
      'day': dateKey,
      'wifiDownload': wifiDownload,
      'wifiUpload': wifiUpload,
      'cellularDownload': cellularDownload,
      'cellularUpload': cellularUpload,
    };
    return netUsage;
  }

  static Map<String, dynamic> toMap(NetworkUsage model) => <String, dynamic>{
        'day': model.dateKey,
        'download': model.wifiDownload,
        'upload': model.wifiUpload,
        'cellularDownload': model.cellularDownload,
        'cellularUpload': model.cellularUpload,
      };

  static String serialize(NetworkUsage model) =>
      json.encode(NetworkUsage.toMap(model));

  static NetworkUsage deserialize(String json) =>
      NetworkUsage.fromJson(jsonDecode(json));
}
