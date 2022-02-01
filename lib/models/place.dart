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
  final List<String> categories;

  Place({
    this.id,
    required this.nickname,
    required this.address,
    required this.categories,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'nickname': nickname,
      'address': address,
      'categories': categories.join("/"),
    };
  }

  static Place fromMap(Map<String, Object?> map) {
    String categoriesString = map['categories'] as String;
    List<String> categories = categoriesString.split("/");
    return Place(
      id: map['_id'] as int?,
      nickname: map['nickname'] as String,
      address: map['address'] as String,
      categories: categories,
    );
  }

  Place copy({
    int? id,
    String? nickname,
    String? address,
    List<String>? categories,
  }) =>
      Place(
          id: id ?? this.id,
          nickname: nickname ?? this.nickname,
          address: address ?? this.address,
          categories: categories ?? this.categories);
}
