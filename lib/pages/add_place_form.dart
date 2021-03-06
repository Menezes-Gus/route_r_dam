import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:route_r_dam/components/return.dart';
import 'package:route_r_dam/models/database.dart';
import 'package:route_r_dam/models/debouncer.dart';
import 'package:route_r_dam/models/place.dart';
import 'package:textfield_tags/textfield_tags.dart';

class AddPlaceForm extends StatefulWidget {
  final Future<dynamic> Function() _refreshPage;
  const AddPlaceForm(this._refreshPage);

  @override
  State<AddPlaceForm> createState() => _AddPlaceFormState();
}

class _AddPlaceFormState extends State<AddPlaceForm> {
  final _formKey = GlobalKey<FormState>();
  Set<String> tags = {};
  final nicknameController = TextEditingController();
  final addressController = TextEditingController();

  String erro = '';
  LatLng _center = LatLng(0, 0);
  final MapController _mapController = MapController();
  bool isLoading = false;
  bool gotCoords = false;

  final _debouncer = Debouncer(milliseconds: 2000);

  @override
  initState() {
    super.initState();
    getPosicao();
  }

  _getLatLngFromTextField(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      Location location = locations.first;

      if (!location.latitude.isNaN && !location.longitude.isNaN) {
        setState(() {
          _center = LatLng(location.latitude, location.longitude);
          _mapController.move(
              LatLng(_center.latitude, _center.longitude), 13.0);
          gotCoords = true;
        });
        await Future.delayed(const Duration(seconds: 1));
        List<Placemark> placemarks = await placemarkFromCoordinates(
            location.latitude, location.longitude);
        Placemark placemark = placemarks.first;
        setState(() {
          addressController.text = placemark.street! +
              ', ' +
              placemark.name! +
              ', ' +
              placemark.subLocality! +
              ', ' +
              placemark.locality! +
              ', ' +
              placemark.administrativeArea! +
              ', ' +
              placemark.postalCode! +
              ', ' +
              placemark.country!;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  _getAddressLineFromLatLng(LatLng ltlg) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(ltlg.latitude, ltlg.longitude);

    Placemark placemark = placemarks.first;
    if (placemark.name!.isNotEmpty) {
      setState(() {
        _center = ltlg;
        _mapController.move(LatLng(_center.latitude, _center.longitude), 13.0);
        gotCoords = true;
        try {
          addressController.text = placemark.street! +
              ', ' +
              placemark.name! +
              ', ' +
              placemark.subLocality! +
              ', ' +
              placemark.locality! +
              ', ' +
              placemark.administrativeArea! +
              ', ' +
              placemark.postalCode! +
              ', ' +
              placemark.country!;
        } catch (e) {
          erro = e.toString();
        }
      });
    }
  }

  getPosicao() async {
    try {
      Position posicao = await _posicaoAtual();
      setState(() {
        _center = LatLng(posicao.latitude, posicao.longitude);
        _mapController.move(LatLng(posicao.latitude, posicao.longitude), 13.0);
      });
    } catch (e) {
      erro = e.toString();
    }
    setState(() {});
  }

  Future<Position> _posicaoAtual() async {
    LocationPermission permissao;
    bool ativado = await Geolocator.isLocationServiceEnabled();
    if (!ativado) {
      widget._refreshPage();
      Navigator.pop(context);
    }
    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        widget._refreshPage();
        Navigator.pop(context);
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      widget._refreshPage();
      Navigator.pop(context);
    }

    return await Geolocator.getCurrentPosition();
  }

  Future addPlace(String nickname, String address, List<String> categories,
      double latitude, double longitude) async {
    final place = Place(
      nickname: nickname,
      address: address,
      categories: categories.toSet(),
      latitude: latitude,
      longitude: longitude,
    );

    await DbHelper.instance.create(place);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children: const [
                  Return(),
                ],
              ),
            ),
            Expanded(
              flex: 13,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Colors.grey, width: 2)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextFormField(
                                textCapitalization: TextCapitalization.words,
                                maxLength: 20,
                                controller: nicknameController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Apelido do Local',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Insira um nome v??lido';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                textCapitalization: TextCapitalization.words,
                                controller: addressController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Endere??o Completo',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    gotCoords = false;
                                  });
                                  _debouncer.run(() {
                                    _getLatLngFromTextField(value);
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Insira um endere??o v??lido';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Colors.grey, width: 2)),
                          width: double.infinity,
                          height: 300,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              onTap: (tapPosition, point) {
                                setState(() {
                                  gotCoords = false;
                                });
                                _getAddressLineFromLatLng(point);
                              },
                              center: _center,
                              zoom: 13,
                            ),
                            layers: [
                              TileLayerOptions(
                                  urlTemplate:
                                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                  subdomains: ['a', 'b', 'c'],
                                  attributionBuilder: (_) {
                                    return const Text(
                                        "?? OpenStreetMap contributors");
                                  }),
                              MarkerLayerOptions(
                                markers: [
                                  Marker(
                                    width: 60.0,
                                    height: 60.0,
                                    point: _center,
                                    builder: (ctx) => Icon(
                                      Icons.location_on,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Colors.grey, width: 2)),
                          child: TextFieldTags(
                            key: _formKey,
                            textSeparators: const [' ', ','],
                            initialTags: const [],
                            validator: (tag) {
                              if (tag.isEmpty) {
                                return '';
                              }

                              return null;
                            },
                            textFieldStyler: TextFieldStyler(
                              helperText:
                                  'Aperte espa??o para separar as categorias',
                              hintText: 'Categorias ex: parque, restaurante',
                              textFieldBorder: const UnderlineInputBorder(),
                            ),
                            onDelete: (String tag) {
                              tags.remove(tag);
                            },
                            onTag: (String tag) {
                              tags.add(tag);
                            },
                            tagsStyler: TagsStyler(
                              tagCancelIcon: const Icon(
                                Icons.cancel,
                                size: 18.0,
                                color: Colors.white,
                              ),
                              tagPadding: const EdgeInsets.all(6.0),
                              tagDecoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
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
                  onPressed: gotCoords
                      ? () async {
                          if (_formKey.currentState!.validate() && gotCoords) {
                            await addPlace(
                                nicknameController.text,
                                addressController.text,
                                tags.toSet().toList(),
                                _center.latitude,
                                _center.longitude);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.grey,
                                content:
                                    Text('Localidade cadastrada com sucesso!'),
                              ),
                            );
                            widget._refreshPage();
                            Navigator.pop(context);
                          }
                        }
                      : null,
                  child: const Text(
                    'Cadastrar Localidade',
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
