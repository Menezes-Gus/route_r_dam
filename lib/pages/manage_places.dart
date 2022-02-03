import 'package:flutter/material.dart';
import 'package:route_r_dam/components/place_card.dart';
import 'package:route_r_dam/components/return.dart';
import 'package:route_r_dam/models/database.dart';
import 'package:route_r_dam/models/place.dart';
import 'package:route_r_dam/pages/add_place_form.dart';

class ManagePlaces extends StatefulWidget {
  const ManagePlaces({Key? key}) : super(key: key);

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
    this.places.sort(
        (a, b) => a.nickname.toUpperCase().compareTo(b.nickname.toUpperCase()));
    setState(() => isLoading = false);
  }

  _openAddLocalForm(context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddPlaceForm(refreshPlaces)));
  }

  _removeLocal(context, id) async {
    setState(() => isLoading = true);
    await DbHelper.instance.delete(id);
    this.places = await DbHelper.instance.readAll();
    this.places.sort(
        (a, b) => a.nickname.toUpperCase().compareTo(b.nickname.toUpperCase()));
    setState(() => isLoading = false);
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
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Return(),
                  const Center(
                    child: Text('Gerenciar Localidades'),
                  ),
                  IconButton(
                    onPressed: () => _openAddLocalForm(context),
                    icon: const Icon(Icons.add),
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 13,
              child: ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: places.length,
                  itemBuilder: (ctx, index) {
                    final pl = places[index];
                    return PlaceCard(pl);
                  }),
            ),
            Expanded(
              flex: 1,
              child: SizedBox(
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
                  onPressed: () => _openAddLocalForm(context),
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
