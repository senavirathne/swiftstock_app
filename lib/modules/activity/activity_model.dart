// modules/activity/activity_model.dart

class Activity {
  int? id;
  String description;
  DateTime dateTime;

  Activity({this.id, required this.description, required this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      description: map['description'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}
