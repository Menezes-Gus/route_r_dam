import 'package:flutter/material.dart';
import 'package:route_r_dam/models/place.dart';

class PlaceCard extends StatelessWidget {
  final Place place;

  final Function(dynamic, int) _remove;
  final Function(dynamic, int) _edit;

  const PlaceCard(this.place, this._edit, this._remove);

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
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      _edit(context, place.id!);
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
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
                                    _remove(context, place.id!);
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
