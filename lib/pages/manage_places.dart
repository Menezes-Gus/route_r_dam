import 'package:flutter/material.dart';
import 'package:route_r_dam/components/place_card.dart';
import 'package:route_r_dam/components/return.dart';
import 'package:route_r_dam/models/database.dart';
import 'package:route_r_dam/models/filter.dart';
import 'package:route_r_dam/models/place.dart';
import 'package:route_r_dam/pages/add_place_form.dart';
import 'package:route_r_dam/pages/edit_place_form.dart';
import 'package:route_r_dam/pages/filter_cluster.dart';

class ManagePlaces extends StatefulWidget {
  const ManagePlaces({Key? key}) : super(key: key);

  @override
  State<ManagePlaces> createState() => _ManagePlacesState();
}

class _ManagePlacesState extends State<ManagePlaces> {
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

  _openAddPlaceForm(context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddPlaceForm(refreshPlaces)));
  }

  _openFilterCluster(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FilterCluster(categories, _filter)));
  }

  _openEditPlaceForm(context, int id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditPlaceForm(refreshPlaces, id)));
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
                      'Gerenciar Localidades',
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
                        onPressed: () => _openAddPlaceForm(context),
                        icon: const Icon(Icons.add),
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
                    return PlaceCard(pl, _openEditPlaceForm, _removePlace);
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
                  onPressed: () => _openAddPlaceForm(context),
                  child: const Text('Cadastrar Nova Localidade'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
