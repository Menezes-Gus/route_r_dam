import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:route_r_dam/components/return.dart';
import 'package:route_r_dam/models/database.dart';
import 'package:route_r_dam/models/debouncer.dart';
import 'package:route_r_dam/models/place.dart';
import 'package:textfield_tags/textfield_tags.dart';

class EditPlaceForm extends StatefulWidget {
  final id;
  final Future<dynamic> Function() _refreshPage;
  const EditPlaceForm(this._refreshPage, this.id);

  @override
  State<EditPlaceForm> createState() => _EditPlaceFormState();
}

class _EditPlaceFormState extends State<EditPlaceForm> {
  final _formKey = GlobalKey<FormState>();
  Set<String> tags = {};
  final nicknameController = TextEditingController();
  final addressController = TextEditingController();
  bool isLoading = false;
  bool gotCoords = false;

  String erro = '';
  LatLng _center = LatLng(0, 0);
  final MapController _mapController = MapController();

  final _debouncer = Debouncer(milliseconds: 2000);

  late Place place;

  @override
  void initState() {
    super.initState();
    getPlace();
  }

  Set<String> _transformSetIntoSetWithoutNullValues(Set set) {
    Set<String> setWithoutNull = {};
    for (String s in set) {
      if (s.isNotEmpty && s != null && s != '' && s != ' ') {
        setWithoutNull.add(s);
      }
    }
    return setWithoutNull;
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
    List<Placemark> placemarks;
    try {
      placemarks =
          await placemarkFromCoordinates(ltlg.latitude, ltlg.longitude);
    } catch (e) {
      print('Localização Inválida, redirecionando para o local atual...');
      getPosicao();
      return;
    }

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

  Future getPlace() async {
    setState(() => isLoading = true);
    place = await DbHelper.instance.read(widget.id);
    nicknameController.text = place.nickname;
    addressController.text = place.address;
    tags = place.categories;
    _center = LatLng(place.latitude, place.longitude);
    _mapController.move(LatLng(_center.latitude, _center.longitude), 13.0);
    setState(() => isLoading = false);
  }

  Future editPlace(
      {required int id,
      required String nickname,
      required String address,
      required Set<String> categories,
      required double latitude,
      required double longitude}) async {
    final place = Place(
      id: id,
      nickname: nickname,
      address: address,
      categories: categories,
      latitude: latitude,
      longitude: longitude,
    );

    await DbHelper.instance.update(place);
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
                                  border: OutlineInputBorder(),
                                  labelText: 'Apelido do Local',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Insira um nome válido';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                textCapitalization: TextCapitalization.words,
                                controller: addressController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Endereço Completo',
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
                                    return 'Insira um endereço válido';
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
                                        "© OpenStreetMap contributors");
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
                            initialTags: tags.isNotEmpty
                                ? (tags.first.isNotEmpty ? tags.toList() : [])
                                : [],
                            validator: (tag) {
                              if (tag.isEmpty) {
                                return '';
                              }

                              return null;
                            },
                            textFieldStyler: TextFieldStyler(
                              helperText:
                                  'Aperte espaço para separar as categorias',
                              hintText: 'Categorias ex: parque, restaurante',
                              textFieldBorder: const UnderlineInputBorder(),
                            ),
                            onDelete: (String tag) {
                              setState(() {
                                gotCoords = false;
                              });

                              tags.remove(tag);
                              setState(() {
                                gotCoords = true;
                              });
                            },
                            onTag: (String tag) {
                              setState(() {
                                gotCoords = false;
                              });

                              tags.add(tag);
                              setState(() {
                                gotCoords = true;
                              });
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && gotCoords) {
                      await editPlace(
                          id: widget.id,
                          nickname: nicknameController.text,
                          address: addressController.text,
                          categories:
                              _transformSetIntoSetWithoutNullValues(tags),
                          latitude: _center.latitude,
                          longitude: _center.longitude);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.grey,
                          content: Text('Localidade alterada com sucesso!'),
                        ),
                      );
                      widget._refreshPage();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Confirmar Alteração',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
