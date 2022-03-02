import 'package:flutter/material.dart';
import 'package:route_r_dam/models/database.dart';
import 'package:route_r_dam/models/distance_calculator.dart';
import 'package:route_r_dam/models/outer_maps_operations.dart';
import 'package:route_r_dam/models/place.dart';
import 'package:route_r_dam/models/place_with_distances.dart';

class AutomatedRouteBuilder extends StatefulWidget {
  const AutomatedRouteBuilder({Key? key}) : super(key: key);

  @override
  State<AutomatedRouteBuilder> createState() => _AutomatedRouteBuilderState();
}

class _AutomatedRouteBuilderState extends State<AutomatedRouteBuilder> {
  List<Place> places = [];
  Set<PlaceWithDistances> placesWithDistances = {};
  bool gettingData = true;

  @override
  initState() {
    super.initState();

    _getPlaces();

    setState(() {
      gettingData = false;
    });

    _openMaps();
  }

  Future _getPlaces() async {
    places = await DbHelper.instance.readAll();
    places.sort(
        (a, b) => a.nickname.toUpperCase().compareTo(b.nickname.toUpperCase()));

    _getPlacesWithDistances();
  }

  _getPlacesWithDistances() async {
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
    }
  }

  _openMaps() {
    if (placesWithDistances.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.grey,
          content: Text('Número Insuficiente de Localidades Cadastradas'),
        ),
      );
    } else {
      OuterMapsOperations(placesWithDistances).openMaps();
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
