import 'package:flutter/material.dart';
import 'package:route_r_dam/models/place.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  const PlaceCard(this.place);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Apelido: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(place.nickname)
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Endereço: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(place.address)
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Categorias: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...place.categories
                        .map((e) => Text(e.toString() + ' '))
                        .toList(),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Center(child: Icon(Icons.edit)),
                    Center(
                      child: Icon(
                        Icons.remove_circle,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
