class InfoStat {
  late String isp, ip, unit, asn;
  late DateTime date;
  late double upSpeed, downSpeed;

  InfoStat(
      {this.isp = 'N/A',
      this.ip = '',
      this.asn = 'N/A',
      required this.date,
      this.unit = 'Mbps',
      this.upSpeed = 0.0,
      this.downSpeed = 0.0});

  InfoStat.fromJson(Map json) {
    isp = json['isp'];
    ip = json['ip'];
    asn = json['asn'];
    unit = json['unit'];
    date = json['date'];
    upSpeed = json['upSpeed'];
    downSpeed = json['downSpeed'];
  }

  Map toJson() {
    final Map infoStat = {
      'isp': isp,
      'ip': ip,
      'asn': asn,
      'unit': unit,
      'date': date,
      'upSpeed': upSpeed,
      'downSpeed': downSpeed
    };
    return infoStat;
  }
}
