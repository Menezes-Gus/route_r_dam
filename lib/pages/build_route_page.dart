import 'package:flutter/material.dart';
import 'package:route_r_dam/components/place_card_route_selection.dart';

import 'package:route_r_dam/components/return.dart';
import 'package:route_r_dam/components/text_with_icon.dart';
import 'package:route_r_dam/models/database.dart';
import 'package:route_r_dam/models/distance_calculator.dart';
import 'package:route_r_dam/models/outer_maps_operations.dart';
import 'package:route_r_dam/models/place.dart';
import 'package:route_r_dam/models/place_with_distances.dart';
import 'package:route_r_dam/pages/build_route_page_filter.dart';
import 'dart:math' as math;

import 'package:route_r_dam/pages/filter_cluster.dart';

class BuildRoutePage extends StatefulWidget {
  final Place _startingPlace;
  const BuildRoutePage(this._startingPlace);
  @override
  _BuildRoutePageState createState() => _BuildRoutePageState();
}

class _BuildRoutePageState extends State<BuildRoutePage> {
  bool isLoading = false;
  bool gettingData = true;
  List<Place> places = [];
  Set<PlaceWithDistances> placesWithDistances = {};
  Set<PlaceWithDistances> unfilteredPlacesWithDistances = {};
  Set<PlaceWithDistances> logPlacesWithDistances = {};
  late Set<String> categories = {};
  List<PlaceCardRouteSelection> cards = [];
  String pageTitle = '';
  Set<int> ids = {};
  int routeSchemeSize = 1;
  bool filtered = false;

  @override
  initState() {
    super.initState();

    _refreshPlaces();
    _getPlacesWithDistances();
  }

  List<TextWithIcon> _buildTextsWithIcon() {
    List<TextWithIcon> twi = [];
    for (PlaceWithDistances lpwd in logPlacesWithDistances) {
      twi.add(TextWithIcon(
        placeName: lpwd.nickname,
      ));
    }
    return twi;
  }

  // _filterPlaces(
  //     {List<String>? categoriesList,
  //     bool includeClose = false,
  //     bool includeNextTo = false,
  //     bool includeFar = false}) {
  //   Set<String> categoriesSet = {};
  //   bool includeCategories;
  //   try {
  //     categoriesSet = categoriesList!.toSet();
  //     includeCategories = true;
  //   } catch (e) {
  //     includeCategories = false;
  //   }

  //   bool _filterCategories(Set<String> categories) {
  //     bool test = false;
  //     for (String cs in categoriesSet) {
  //       if (categories.contains(cs)) {
  //         test = true;
  //       }
  //     }
  //     return test;
  //   }

  //   if (includeCategories) {
  //     placesWithDistances = placesWithDistances
  //         .where((element) => _filterCategories(element.categories))
  //         .toSet();
  //   }
  //   if (includeClose) {
  //     placesWithDistances = placesWithDistances.where((element) => element.distances)
  //   }
  // }
  // void _unfilter() {
  //   setState(() {
  //     placesWithDistances = unfilteredPlacesWithDistances;
  //     filtered = false;
  //   });
  // }

  _changeRouteSchemeSize(bool expand) {
    setState(() {
      isLoading = true;
    });
    if (expand) {
      routeSchemeSize = 5;
    } else {
      routeSchemeSize = 1;
    }

    setState(() {
      isLoading = false;
    });
  }

  _initPlacesCards() {
    setState(() {
      isLoading = true;
    });
    logPlacesWithDistances.add(placesWithDistances.last);
    unfilteredPlacesWithDistances.remove(placesWithDistances.last);
    placesWithDistances.remove(placesWithDistances.last);

    ids.add(logPlacesWithDistances.last.id);
    Map<Place, double> mapPlaces = logPlacesWithDistances.last.distances;
    pageTitle = logPlacesWithDistances.last.nickname;
    PlaceCardRouteSelection card;
    for (Place p in mapPlaces.keys) {
      card = PlaceCardRouteSelection(
        addPlaceWithDistancesToRoute: _addPlaceWithDistancesToRoute,
        distance: mapPlaces[p],
        place: p,
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
    PlaceCardRouteSelection card;
    for (Place p in mapPlaces.keys) {
      if (ids.where((element) => element == p.id).isEmpty) {
        card = PlaceCardRouteSelection(
          addPlaceWithDistancesToRoute: _addPlaceWithDistancesToRoute,
          distance: mapPlaces[p],
          place: p,
        );
        cards.add(card);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void _addPlaceWithDistancesToRoute(int id) {
    setState(() {
      isLoading = true;
    });

    logPlacesWithDistances
        .add(placesWithDistances.where((e) => e.id == id).toSet().first);
    unfilteredPlacesWithDistances
        .remove(placesWithDistances.where((e) => e.id == id).toSet().first);
    placesWithDistances
        .remove(placesWithDistances.where((e) => e.id == id).toSet().first);

    ids.add(logPlacesWithDistances.last.id);

    _refreshPlacesCards();

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

    unfilteredPlacesWithDistances.add(logPlacesWithDistances
        .where((e) => e.id == idToReturnTo)
        .toSet()
        .first);

    logPlacesWithDistances.remove(logPlacesWithDistances
        .where((e) => e.id == idToReturnTo)
        .toSet()
        .first);

    ids.remove(idToReturnTo);

    _refreshPlacesCards();
    setState(() {
      isLoading = false;
    });
  }

  _getPlacesWithDistances() async {
    setState(() {
      isLoading = true;
    });
    if (widget._startingPlace.id!.isNegative) {
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
      places.removeWhere(
        (element) => element.id == place.id,
      );
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
      unfilteredPlacesWithDistances.add(placeWithDistances);
      placesWithDistances.add(placeWithDistances);
    }
    _initPlacesCards();
    _changeRouteSchemeSize(true);
    gettingData = false;
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Return(),
                    ],
                  ),
                  Center(
                    child: Text(
                      'Referência: ' + pageTitle,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: logPlacesWithDistances.length <= 1
                            ? null
                            : _returnPlaceWithDistancesToList,
                        icon: const Icon(Icons.backspace_outlined),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 9,
              child: gettingData
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: cards.length,
                      itemBuilder: (ctx, index) {
                        final cd = cards[index];
                        return cd;
                      }),
            ),
            Expanded(
              flex: 1,
              child: gettingData
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0))),
                            backgroundColor: Theme.of(context).primaryColor,
                            shadowColor:
                                Theme.of(context).scaffoldBackgroundColor),
                        onPressed: logPlacesWithDistances.length > 2
                            ? () {
                                OuterMapsOperations(logPlacesWithDistances)
                                    .openMaps();
                              }
                            : null,
                        child: Text(
                          'Concluir (Mapas Externos)',
                          style: TextStyle(
                              color: Theme.of(context).scaffoldBackgroundColor),
                        ),
                      ),
                    ),
            ),
            Expanded(
              flex: 4,
              child: gettingData
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.7),
                          border: Border(
                              top: BorderSide(
                                  width: 2,
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor))),
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Wrap(
                              children: [
                                ..._buildTextsWithIcon(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
