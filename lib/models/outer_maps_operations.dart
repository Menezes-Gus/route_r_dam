import 'package:map_launcher/map_launcher.dart';
import 'package:route_r_dam/models/place_with_distances.dart';

class OuterMapsOperations {
  final Set<PlaceWithDistances> _placesWithDistances;
  OuterMapsOperations(this._placesWithDistances);

  openMaps() async {
    final availableMaps = await MapLauncher.installedMaps;
    if (availableMaps.isNotEmpty && _placesWithDistances.length > 2) {
      Coords origin = Coords(-23.5689, -46.6380);
      Coords destination = Coords(-23.5689, -46.6380);
      List<Coords> waypoints = [];
      int count = 0;
      for (PlaceWithDistances pwh in _placesWithDistances) {
        count += 1;
        if (count == 1) {
          origin = Coords(pwh.latitude, pwh.longitude);
        } else if (count == _placesWithDistances.length) {
          destination = Coords(pwh.latitude, pwh.longitude);
        }
        waypoints.add(Coords(pwh.latitude, pwh.longitude));
      }
      await availableMaps.first.showDirections(
          destination: destination, origin: origin, waypoints: waypoints);
    } else {
      return;
    }
  }
}
