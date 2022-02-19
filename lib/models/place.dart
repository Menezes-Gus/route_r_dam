// final String tablePlaces = 'places';

// class PlaceFields {
//   static final String id = '_id';
//   static final String nickname = 'nickname';
//   static final String address = 'address';
//   static final String categories = 'categories';
// }

class Place {
  final int? id;
  final String nickname;
  final String address;
  final Set<String> categories;
  final double latitude;
  final double longitude;

  Place(
      {this.id,
      required this.nickname,
      required this.address,
      required this.categories,
      required this.longitude,
      required this.latitude});

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'nickname': nickname,
      'address': address,
      'categories': categories.join("/"),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static Place fromMap(Map<String, Object?> map) {
    String categoriesString = map['categories'] as String;
    List<String> categories = categoriesString.split("/");
    return Place(
      id: map['_id'] as int?,
      nickname: map['nickname'] as String,
      address: map['address'] as String,
      categories: categories.toSet(),
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }

  Place copy({
    int? id,
    String? nickname,
    String? address,
    Set<String>? categories,
    double? latitude,
    double? longitude,
  }) =>
      Place(
        id: id ?? this.id,
        nickname: nickname ?? this.nickname,
        address: address ?? this.address,
        categories: categories ?? this.categories,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );
}
