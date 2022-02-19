import 'package:route_r_dam/models/place.dart';

class PlaceWithDistances {
  final int id;
  final String nickname;
  final String address;
  final Set<String> categories;
  final double latitude;
  final double longitude;
  final Map<Place, double> distances;

  PlaceWithDistances(
      {required this.id,
      required this.nickname,
      required this.address,
      required this.categories,
      required this.longitude,
      required this.latitude,
      required this.distances});
}
