
class Event {
  static const String collectionName = 'events';

  String id;
  final String userId;
  final String image;
  final String description;
  final String title;
  final DateTime date;
  final String time;
  final bool isFavorite;
  final String category;
  double? latitude;
  double? longitude;
  final String? city;
  final String? country;  

  Event({
    this.id = '',
    required this.userId,
    required this.image,
    required this.description,
    required this.title,
    required this.date,
    required this.time,
    this.isFavorite = false,
    required this.category,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
  });

  /// ✅ Factory constructor لتحويل JSON إلى Object
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['date']) 
          : DateTime.now(),
      time: json['time'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      category: json['category'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      city: json['city'],
      country: json['country'],
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
      'isFavorite': isFavorite,
      'category': category,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
    };
  }

  /// ✅ دالة copyWith
  Event copyWith({
    String? id,
    String? userId,
    String? image,
    String? description,
    String? title,
    DateTime? date,
    String? time,
    bool? isFavorite,
    String? category,
    double? latitude,
    double? longitude,
    String? city,
    String? country,
  }) {
    return Event(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      image: image ?? this.image,
      description: description ?? this.description,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }
}
//  ---------------------------------------------------------------------------------------------------------------
