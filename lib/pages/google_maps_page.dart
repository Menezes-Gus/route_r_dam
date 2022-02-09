import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:route_r_dam/components/return.dart';

class GoogleMapsPage extends StatefulWidget {
  const GoogleMapsPage({Key? key}) : super(key: key);

  @override
  State<GoogleMapsPage> createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  String erro = '';
  LatLng _center = LatLng(0, 0);
  final MapController _mapController = MapController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  getPosicao() async {
    setState(() {
      isLoading = true;
    });
    try {
      Position posicao = await _posicaoAtual();
      setState(() {
        _center = LatLng(posicao.latitude, posicao.longitude);
        _mapController.move(LatLng(posicao.latitude, posicao.longitude), 13.0);
      });
    } catch (e) {
      erro = e.toString();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<Position> _posicaoAtual() async {
    LocationPermission permissao;
    bool ativado = await Geolocator.isLocationServiceEnabled();
    if (!ativado) {
      return Future.error('Por favor, habilite a localização no smartphone');
    }
    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        return Future.error('Você recisa autorizar o acesso à localização');
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      return Future.error('Você precisa autorizar o acesso à localização');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    getPosicao();
    return Scaffold(
      body: Padding(
        padding:
            EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0, 0),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Return(),
                ],
              ),
            ),
            Expanded(
              flex: 14,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  onTap: (tapPosition, point) {
                    setState(() {
                      _center = point;
                    });
                  },
                  center: _center,
                  zoom: 15,
                ),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                      attributionBuilder: (_) {
                        return const Text("© OpenStreetMap contributors");
                      }),
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        width: 60.0,
                        height: 60.0,
                        point: _center,
                        builder: (ctx) => const Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
