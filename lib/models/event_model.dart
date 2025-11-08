class EventModel {
  final String id;
  final String name;
  final String date;
  final String startTime;
  final String endTime;
  final String venue;
  final String imageUrl;
  final String status;
  final String statusType; // error, warning, success
  final String category; // active, pending, inactive

  EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.imageUrl,
    required this.status,
    required this.statusType,
    required this.category,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      venue: json['venue'] as String,
      imageUrl: json['imageUrl'] as String,
      status: json['status'] as String,
      statusType: json['statusType'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'venue': venue,
      'imageUrl': imageUrl,
      'status': status,
      'statusType': statusType,
      'category': category,
    };
  }
}
