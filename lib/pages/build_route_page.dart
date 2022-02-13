import 'package:flutter/material.dart';

import 'package:route_r_dam/components/return.dart';
import 'package:route_r_dam/models/database.dart';
import 'package:route_r_dam/models/distance_calculator.dart';
import 'package:route_r_dam/models/outer_maps_operations.dart';
import 'package:route_r_dam/models/place.dart';
import 'package:route_r_dam/models/place_with_distances.dart';
import 'dart:math' as math;

class BuildRoutePage extends StatefulWidget {
  final Place _startingPlace;
  const BuildRoutePage(this._startingPlace);
  @override
  _BuildRoutePageState createState() => _BuildRoutePageState();
}

class _BuildRoutePageState extends State<BuildRoutePage> {
  bool isLoading = false;
  List<Place> places = [];
  Set<PlaceWithDistances> placesWithDistances = {};
  Set<PlaceWithDistances> logPlacesWithDistances = {};
  late Set<String> categories = {};
  List<Card> cards = [];
  String pageTitle = '';
  Set<int> ids = {};

  @override
  initState() {
    super.initState();
    _refreshPlaces();
    _getPlacesWithDistances();
  }

  _initPlacesCards() {
    setState(() {
      isLoading = true;
    });
    logPlacesWithDistances.add(placesWithDistances.last);
    placesWithDistances.remove(placesWithDistances.last);
    ids.add(logPlacesWithDistances.last.id);
    Map<Place, double> mapPlaces = logPlacesWithDistances.last.distances;
    print(mapPlaces);
    pageTitle = logPlacesWithDistances.last.nickname;
    Card card;
    for (Place p in mapPlaces.keys) {
      card = Card(
        child: Column(children: [
          Text(
            p.nickname,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Distância: ' + mapPlaces[p].toString() + ' m'),
          ElevatedButton(
              onPressed: () => _addPlaceWithDistancesToRoute(p.id!),
              child: const Text('Adicionar a Rota'))
        ]),
      );
      cards.add(card);
    }
    setState(() {
      isLoading = false;
    });
  }

  _refreshPlacesCards() {
    setState(() {
      isLoading = true;
    });
    cards = [];
    Map<Place, double> mapPlaces = logPlacesWithDistances.last.distances;

    pageTitle = logPlacesWithDistances.last.nickname;
    Card card;
    for (Place p in mapPlaces.keys) {
      if (ids.where((element) => element == p.id).isEmpty) {
        card = Card(
          child: Column(children: [
            Text(
              p.nickname,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Distância: ' + mapPlaces[p].toString() + ' m'),
            ElevatedButton(
              onPressed: () => _addPlaceWithDistancesToRoute(p.id!),
              child: const Text('Adicionar a Rota'),
            )
          ]),
        );
        cards.add(card);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  _addPlaceWithDistancesToRoute(int id) {
    setState(() {
      isLoading = true;
    });

    logPlacesWithDistances
        .add(placesWithDistances.where((e) => e.id == id).toSet().first);
    placesWithDistances
        .remove(placesWithDistances.where((e) => e.id == id).toSet().first);

    ids.add(logPlacesWithDistances.last.id);

    _refreshPlacesCards();
    print(logPlacesWithDistances);
    setState(() {
      isLoading = false;
    });
  }

  _returnPlaceWithDistancesToList([int? id]) {
    setState(() {
      isLoading = true;
    });
    int idToReturnTo;
    if (id == null) {
      idToReturnTo = logPlacesWithDistances.last.id;
    } else {
      idToReturnTo = id;
    }

    placesWithDistances.add(logPlacesWithDistances
        .where((e) => e.id == idToReturnTo)
        .toSet()
        .first);

    logPlacesWithDistances.remove(logPlacesWithDistances
        .where((e) => e.id == idToReturnTo)
        .toSet()
        .first);

    ids.remove(idToReturnTo);

    _refreshPlacesCards();
    print(logPlacesWithDistances);
    setState(() {
      isLoading = false;
    });
  }

  _getPlacesWithDistances() async {
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
    _initPlacesCards();
    setState(() {
      isLoading = false;
    });
  }

  Future _refreshPlaces() async {
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
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Return(),
                  Center(
                    child: Text(
                      pageTitle,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                  IconButton(
                    onPressed: logPlacesWithDistances.length <= 1
                        ? null
                        : _returnPlaceWithDistancesToList,
                    icon: const Icon(Icons.backspace_outlined),
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 9,
              child: ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: cards.length,
                  itemBuilder: (ctx, index) {
                    final cd = cards[index];
                    return cd;
                  }),
            ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        border: Border(
                            top: BorderSide(
                                width: 2,
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor))),
                    width: double.infinity,
                    child: Column(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            OuterMapsOperations(logPlacesWithDistances)
                                .openMaps();
                          },
                          child: const Text('Concluir (Mapas Externos)'),
                        ),
                        Transform.rotate(
                          angle: 90 * math.pi / 180,
                          child: Icon(
                            Icons.alt_route_sharp,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        )
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
