import 'package:flutter/material.dart';
import 'package:route_r_dam/models/place.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  const PlaceCard(this.place);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
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
              ...place.categories.map((e) => Text(e.toString() + ' ')).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
