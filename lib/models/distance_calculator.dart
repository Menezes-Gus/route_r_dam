import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:route_r_dam/models/place.dart';

class RouteCalculator {
  BuildContext context;
  RouteCalculator(this.context);
  Map<Place, Map<Place, double>> placesMap = {};
  String erro = '';

  Map<Place, double> getClosest(Place a, List<Place> b) {
    const Distance distance = Distance();
    Map<Place, double> distanceMap = {};
    for (Place c in b) {
      if (!(a == c)) {
        double meter = distance(
            LatLng(a.latitude, a.longitude), LatLng(c.latitude, c.longitude));
        distanceMap[c] = meter;
      }
    }
    Map<Place, double> sortedDistanceMap = SplayTreeMap<Place, double>.from(
        distanceMap,
        (key1, key2) => distanceMap[key1]!.compareTo(distanceMap[key2]!));
    return sortedDistanceMap;
  }

  Future<Place> getActualPosition() async {
    LatLng latLng = await getPosicao();
    Place place = Place(
        id: -1,
        address: 'Local Atual',
        categories: [],
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        nickname: 'Local Atual');

    return place;
  }

  Future<LatLng> getPosicao() async {
    try {
      Position posicao = await _posicaoAtual();
      return LatLng(posicao.latitude, posicao.longitude);
    } catch (e) {
      Navigator.pop(context);
    }
    return LatLng(0.0, 0.0);
  }

  Future<Position> _posicaoAtual() async {
    LocationPermission permissao;
    bool ativado = await Geolocator.isLocationServiceEnabled();
    if (!ativado) {
      Navigator.pop(context);
    }
    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        Navigator.pop(context);
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      Navigator.pop(context);
    }

    return await Geolocator.getCurrentPosition();
  }
}
