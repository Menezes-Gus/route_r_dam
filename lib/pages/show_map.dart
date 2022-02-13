import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

class ShowMap extends StatelessWidget {
  const ShowMap({Key? key}) : super(key: key);
  maps() async {
    final availableMaps = await MapLauncher.installedMaps;
    print(availableMaps);

    // await availableMaps.first.showMarker(
    //   coords: Coords(37.759392, -122.5107336),
    //   title: "Ocean Beach",
    // );
    Coords origin = Coords(-23.5489, -46.6378);
    Coords destination = Coords(-23.5589, -46.6400);
    List<Coords> waypoints = [];
    waypoints.add(Coords(-23.5689, -46.6380));
    waypoints.add(Coords(-23.5789, -46.6488));
    waypoints.add(Coords(-23.5889, -46.6348));
    waypoints.add(Coords(-23.5989, -46.6318));
    await availableMaps.first.showDirections(
        destination: destination, origin: origin, waypoints: waypoints);
  }

  @override
  Widget build(BuildContext context) {
    maps();
    return Container();
  }
}
