import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:route_r_dam/models/place.dart';

class PlaceCardRouteSelection extends StatelessWidget {
  final Place place;
  final double? distance;
  final void Function(int) addPlaceWithDistancesToRoute;
  const PlaceCardRouteSelection(
      {Key? key,
      required this.place,
      required this.distance,
      required this.addPlaceWithDistancesToRoute})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double dist = 0;
    int id = 0;
    if (distance != null) {
      dist = distance!;
    }
    if (place.id != null) {
      id = place.id!;
    }
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.8),
      child: Container(
        width: double.infinity,
        height: 125,
        padding: EdgeInsets.all(2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 3),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        place.nickname,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        place.address,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 3, left: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Distância: ' + dist.toString() + ' m',
                      style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    if (dist <= 2500)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          child: const Text('Perto'),
                          decoration: BoxDecoration(
                              color: Colors.green,
                              border: Border.all(
                                  width: 2.0,
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                    if (dist <= 7000 && dist > 2500)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          child: const Text('Próximo'),
                          decoration: BoxDecoration(
                              color: Colors.yellow,
                              border: Border.all(
                                  width: 2.0,
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                    if (dist > 7000)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          child: const Text('Distante'),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              border: Border.all(
                                  width: 2.0,
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12))),
                        ),
                      ),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: () => addPlaceWithDistancesToRoute(id),
                        icon: Icon(Icons.add_location_alt_rounded,
                            color: Theme.of(context).primaryColor),
                        label: Text(
                          'Adicionar a Rota',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).scaffoldBackgroundColor),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 3),
                child: Column(
                  children: [
                    Flexible(
                        child: FlutterMap(
                      options: MapOptions(
                          center: LatLng(place.latitude, place.longitude),
                          zoom: 9),
                      layers: [
                        TileLayerOptions(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayerOptions(
                          markers: [
                            Marker(
                              width: 20.0,
                              height: 20.0,
                              point: LatLng(place.latitude, place.longitude),
                              builder: (ctx) => Container(
                                child: Icon(
                                  Icons.location_pin,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
