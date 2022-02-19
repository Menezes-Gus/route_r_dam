import 'package:flutter/material.dart';
import 'package:route_r_dam/models/place.dart';
import 'package:route_r_dam/pages/build_route_page.dart';

class PlaceCard extends StatelessWidget {
  final Place place;

  final Function(dynamic, int)? remove;
  final Function(dynamic, int)? edit;
  final Future<void> Function()? refreshPlaces;
  final bool fromStartingPoint;

  const PlaceCard(this.place, this.edit, this.remove, this.refreshPlaces,
      {this.fromStartingPoint = false});
  const PlaceCard.startingPoint(this.place,
      {this.remove,
      this.edit,
      this.refreshPlaces,
      this.fromStartingPoint = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor, width: 3),
          borderRadius: const BorderRadius.all(Radius.circular(30.0)),
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        right: BorderSide(
                            width: 2,
                            color: Theme.of(context).scaffoldBackgroundColor))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(place.nickname,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor)),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(place.address,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor)),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        ...place.categories.map((e) {
                          return Flexible(
                            child: Container(
                              margin: const EdgeInsets.all(1.0),
                              padding: const EdgeInsets.all(1.0),
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  border: Border.all(
                                      width: 2.0,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12))),
                              child: Text(
                                e.toString() + ' ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.normal,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: fromStartingPoint
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.end,
                crossAxisAlignment: fromStartingPoint
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.end,
                children: [
                  if (fromStartingPoint)
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BuildRoutePage(Place(
                                      id: place.id,
                                      address: place.address,
                                      categories: place.categories,
                                      latitude: place.latitude,
                                      longitude: place.longitude,
                                      nickname: place.nickname,
                                    ))));
                      },
                      icon: Icon(
                        Icons.location_pin,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  if (!fromStartingPoint)
                    IconButton(
                      onPressed: () {
                        edit!(context, place.id!);
                        refreshPlaces!();
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  if (!fromStartingPoint)
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return AlertDialog(
                                title: const Text("ATENÇÃO"),
                                content: const Text(
                                    'Uma vez excluida, não é possível recuperar a localidade. Deseja prosseguir mesmo assim?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Não'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      remove!(context, place.id!);
                                      refreshPlaces!();
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Sim'),
                                  ),
                                ],
                              );
                            });
                      },
                      icon: Icon(
                        Icons.remove_circle,
                        color: Colors.red.shade800,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
