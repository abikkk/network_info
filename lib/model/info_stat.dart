import 'package:network_info/model/network_usage.dart';

class InfoStat {
  late String isp, ip, unit, asn;
  late NetworkUsage networkUsage;

  // late DateTime date;
  // late double upSpeed, downSpeed;

  InfoStat({
    this.isp = 'N/A',
    this.ip = '',
    this.asn = 'N/A',
    this.unit = 'Mbps',
    required this.networkUsage,
    // required this.date,
    // this.upSpeed = 0.0,
    // this.downSpeed = 0.0,
  });

  InfoStat.fromJson(Map json) {
    isp = json['isp'];
    ip = json['ip'];
    asn = json['asn'];
    unit = json['unit'];
    networkUsage = json['networkUsage'];
    // date = json['date'];
    // upSpeed = json['upSpeed'];
    // downSpeed = json['downSpeed'];
  }

  Map toJson() {
    final Map infoStat = {
      'isp': isp,
      'ip': ip,
      'asn': asn,
      'unit': unit,
      'networkUsage': networkUsage
      // 'date': date,
      // 'upSpeed': upSpeed,
      // 'downSpeed': downSpeed
    };
    return infoStat;
  }
}
