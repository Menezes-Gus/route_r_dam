import 'package:flutter/material.dart';

import 'package:route_r_dam/components/return.dart';
import 'package:route_r_dam/models/database.dart';
import 'package:route_r_dam/models/distance_calculator.dart';
import 'package:route_r_dam/models/place.dart';
import 'package:route_r_dam/models/place_with_distances.dart';

class BuildRoutePage extends StatefulWidget {
  final Place _startingPlace;
  const BuildRoutePage(this._startingPlace);
  @override
  _BuildRoutePageState createState() => _BuildRoutePageState();
}

class _BuildRoutePageState extends State<BuildRoutePage> {
  bool isLoading = false;
  List<Place> places = [];
  List<PlaceWithDistances> placesWithDistances = [];
  List<PlaceWithDistances> logPlacesWithDistances = [];
  late Set<String> categories = {};
  List<Card> cards = [];

  @override
  initState() {
    super.initState();
    refreshPlaces();
    getPlacesWithDistances();
  }

  initPlacesCards() {
    setState(() {
      logPlacesWithDistances.add(placesWithDistances.last);
      placesWithDistances.remove(placesWithDistances.last);
      Map<Place, double> mapPlaces = logPlacesWithDistances.last.distances;
      print(mapPlaces);
      Card card;
      for (Place p in mapPlaces.keys) {
        card = Card(
          child: Column(children: [
            Text(
              p.nickname,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Distância: ' + mapPlaces[p].toString() + ' m')
          ]),
        );
        cards.add(card);
      }
    });
  }

  getPlacesWithDistances() async {
    setState(() {
      isLoading = true;
    });
    if (widget._startingPlace.id!.isNegative) {
      print('entrou no if que testa negativo');
      Place place = await RouteCalculator(context).getActualPosition();
      places.add(
        Place(
          id: place.id!,
          nickname: place.nickname,
          address: place.address,
          categories: place.categories,
          longitude: place.longitude,
          latitude: place.latitude,
        ),
      );
    } else {
      print('entrou no if que busca do banco de dados');
      Place place = await DbHelper.instance.read(widget._startingPlace.id!);
      places.add(
        Place(
          id: place.id!,
          nickname: place.nickname,
          address: place.address,
          categories: place.categories,
          longitude: place.longitude,
          latitude: place.latitude,
        ),
      );
      places.remove(place);
      places.add(place);
    }
    for (Place place in places) {
      final PlaceWithDistances placeWithDistances = PlaceWithDistances(
          id: place.id!,
          nickname: place.nickname,
          address: place.address,
          categories: place.categories,
          longitude: place.longitude,
          latitude: place.latitude,
          distances: RouteCalculator(context).getClosest(place, places));
      placesWithDistances.add(placeWithDistances);
      print(placeWithDistances.nickname);
    }
    initPlacesCards();
    setState(() {
      isLoading = false;
    });
  }

  Future refreshPlaces() async {
    setState(() => isLoading = true);
    places = await DbHelper.instance.readAll();
    places.sort(
        (a, b) => a.nickname.toUpperCase().compareTo(b.nickname.toUpperCase()));
    for (Place pl in places) {
      for (String? i in pl.categories) {
        if (i!.isNotEmpty) {
          categories.add(i);
        }
      }
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0, 0),
        child: Column(
          children: [const Return(), ...cards],
        ),
      ),
    );
  }
}
