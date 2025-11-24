
class Event {
  static const String collectionName = 'events';

  String id;
  final String userId;
  final String image;
  final String description;
  final String title;
  final DateTime date;
  final String time;
  final String eventName;
  final bool isFavorite;
  final String category;
  double? latitude;
  double? longitude;

  Event({
    required this.eventName,
    this.isFavorite = false,
    this.id = '',
    required this.userId,
    required this.image,
    required this.description,
    required this.title,
    required this.date,
    required this.time,
    required this.category,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  /// ✅ Factory constructor لتحويل JSON إلى Object
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      title: json['title'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] ?? 0),
      time: json['time'] ?? '', 
      eventName: json['eventName'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      category: json['category'] ?? '',
      latitude: (json['latitude'] != null) ? json['latitude']: 0.0,
      longitude: (json['longitude'] != null) ? json['longitude'] : 0.0,
    );
  }

  /// ✅ تحويل Object إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'image': image,
      'description': description,
      'title': title,
      'date': date.millisecondsSinceEpoch,
      'time': time,
      'eventName': eventName,
      'isFavorite': isFavorite,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// ✅ دالة copyWith لإنشاء نسخة جديدة مع تعديل قيم محددة
  Event copyWith({
    String? id,
    String? userId,
    String? image,
    String? description,
    String? title,
    DateTime? date,
    String? time,
    String? eventName,
    bool? isFavorite,
    String? category,
    double? latitude,
    double? longitude,
  }) {
    return Event(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      image: image ?? this.image,
      description: description ?? this.description,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      eventName: eventName ?? this.eventName,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}


//  ---------------------------------------------------------------------------------------------------------------

// class Event {
//   static const String collectionName = 'events';
//    String id;
//   final String image;
//   final String description;
//   final String title;
//   final DateTime date;
//   final String time;
//   final String eventName;
//    bool isFavorite;
//   final String category;

//   // final String location;

//   Event({
//     required this.eventName,
//     this.isFavorite = false,
//     this.id = '',
//     required this.image,
//     required this.description,
//     required this.title,
//     required this.date,
//     required this.time,
//     required this.category,
//     // required this.location,
//   });

//   // todo: json => object
//   factory Event.fromJson(Map<String, dynamic> json) {
//     return Event(
//       id: json['id'] ?? '',
//       image: json['image'] ?? '',
//       description: json['description'] ?? '',
//       title: json['title'] ?? '',
//       date: DateTime.fromMillisecondsSinceEpoch(json['date'] ?? 0 ),
//       time: json['time'] ?? '',
//       eventName: json['eventName'] ?? '',
//       isFavorite: json['isFavorite'] ?? false,
//       category: json['category'] ?? '',
//       // location: json['location'] ?? '',
//     );
//   }
//   // todo: object => json 
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'image': image,
//       'description': description,
//       'title': title,
//       'date': date.millisecondsSinceEpoch,
//       'time': time,
//       'eventName': eventName,
//       'isFavorite': isFavorite,
//       'category': category,
//       // 'location': location,
//     };
//   }
// }
