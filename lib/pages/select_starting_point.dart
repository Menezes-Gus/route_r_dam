import 'dart:ffi';
import 'package:route_r_dam/models/filter.dart';
import 'package:route_r_dam/pages/filter_cluster.dart';
import 'package:flutter/material.dart';
import 'package:route_r_dam/components/place_card.dart';
import 'package:route_r_dam/components/return.dart';
import 'package:route_r_dam/models/database.dart';
import 'package:route_r_dam/models/place.dart';
import 'package:route_r_dam/pages/build_route_page.dart';

class SelectStartingPoint extends StatefulWidget {
  const SelectStartingPoint();

  @override
  State<SelectStartingPoint> createState() => _SelectStartingPointState();
}

class _SelectStartingPointState extends State<SelectStartingPoint> {
  late List<Place> places = [];
  late List<Place> filteredPlaces = [];
  late Set<String> categories = {};
  final Map<String, bool> categoriesFilterMapped = {};
  Set<Filter> filters = {};

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshPlaces();
  }

  Future refreshPlaces() async {
    setState(() => isLoading = true);
    places = await DbHelper.instance.readAll();
    places.sort(
        (a, b) => a.nickname.toUpperCase().compareTo(b.nickname.toUpperCase()));
    filteredPlaces = places;
    for (Place pl in places) {
      for (String? i in pl.categories) {
        if (i!.isNotEmpty) {
          categories.add(i);
        }
      }
    }

    setState(() => isLoading = false);
  }

  _openFilterCluster(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                FilterCluster(categories, doFilter: _filter)));
  }

  _openBuildRoutePage(context, Place place) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => BuildRoutePage(place)));
  }

  _removePlace(context, int id) async {
    setState(() => isLoading = true);
    await DbHelper.instance.delete(id);
    places = await DbHelper.instance.readAll();
    places.sort(
        (a, b) => a.nickname.toUpperCase().compareTo(b.nickname.toUpperCase()));
    setState(() => isLoading = false);
  }

  Future<void> _filter(List<Filter> filters) async {
    setState(() => isLoading = true);
    filteredPlaces = await DbHelper.instance.readFiltered(filters);
    filteredPlaces.sort(
        (a, b) => a.nickname.toUpperCase().compareTo(b.nickname.toUpperCase()));
    setState(() => isLoading = false);
  }

  _refreshCategoriesSet() {
    categories = categories.where((e) => e.isNotEmpty || e != "").toSet();
  }

  @override
  Widget build(BuildContext context) {
    final availableHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    categories = categories.where((e) => e.isNotEmpty || e != "").toSet();

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
                    children: [
                      const Return(),
                      IconButton(
                        onPressed: places.length == filteredPlaces.length
                            ? null
                            : refreshPlaces,
                        icon: const Icon(Icons.refresh),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      'Iniciar Rota a partir de...',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _openFilterCluster(context),
                        icon: const Icon(Icons.filter_alt_outlined),
                        color: Theme.of(context).primaryColor,
                      ),
                      IconButton(
                        onPressed: () => _openBuildRoutePage(
                            context,
                            Place(
                                address: 'Local Atual',
                                categories: {},
                                latitude: 0,
                                longitude: 0,
                                nickname: 'Local Atual',
                                id: -1)),
                        icon: const Icon(Icons.location_pin),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 13,
              child: ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: filteredPlaces.length,
                  itemBuilder: (ctx, index) {
                    final pl = filteredPlaces[index];
                    for (String i in pl.categories) {
                      categories.add(i);
                    }
                    return PlaceCard.startingPoint(
                      pl,
                    );
                  }),
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            width: 2,
                            color: Theme.of(context).scaffoldBackgroundColor))),
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    textStyle: TextStyle(
                        fontSize:
                            32 * MediaQuery.of(context).textScaleFactor / 2),
                    primary: Theme.of(context).scaffoldBackgroundColor,
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0))),
                  ),
                  onPressed: () => _openBuildRoutePage(
                    context,
                    Place(
                        address: 'Local Atual',
                        categories: {},
                        latitude: 0,
                        longitude: 0,
                        nickname: 'Local Atual',
                        id: -1),
                  ),
                  child: const Text('Usar Local Atual'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
