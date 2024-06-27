class NotificationModel {
  late String title, body, payload, sound;

  NotificationModel({
    required this.title,
    required this.body,
    this.payload = '',
    this.sound = '',
  });

  NotificationModel.fromJson(Map notif) {
    title = notif['title'];
    body = notif['body'];
    payload = notif['payload'];
    sound = notif['sound'];
  }

  Map toJson() {
    final Map notif = {
      'title': title,
      'body': body,
      'payload': payload,
      'sound': sound,
    };
    return notif;
  }
}
