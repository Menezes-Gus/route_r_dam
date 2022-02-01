import 'package:flutter/material.dart';
import 'package:route_r_dam/components/place_card.dart';
import 'package:route_r_dam/components/return.dart';
import 'package:route_r_dam/models/database.dart';
import 'package:route_r_dam/models/place.dart';
import 'package:route_r_dam/pages/add_place_form.dart';

class ManagePlaces extends StatefulWidget {
  @override
  State<ManagePlaces> createState() => _ManagePlacesState();
}

class _ManagePlacesState extends State<ManagePlaces> {
  late List<Place> places = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshPlaces();
  }

  Future refreshPlaces() async {
    setState(() => isLoading = true);
    this.places = await DbHelper.instance.readAll();
    setState(() => isLoading = false);
  }

  _openAddLocalForm(context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddPlaceForm(refreshPlaces)));
  }

  @override
  Widget build(BuildContext context) {
    final availableHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Padding(
        padding:
            EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Return(),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Gerenciar Localidades'),
                ),
                IconButton(
                  onPressed: () => _openAddLocalForm(context),
                  icon: const Icon(Icons.add),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            Container(
              height: availableHeight * 0.8,
              child: ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (ctx, index) {
                    final pl = places[index];
                    return PlaceCard(pl);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
