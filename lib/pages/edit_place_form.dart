import 'package:flutter/material.dart';
import 'package:route_r_dam/components/return.dart';
import 'package:route_r_dam/models/database.dart';
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
  late List<String> tags;
  final nicknameController = TextEditingController();
  final addressController = TextEditingController();
  bool isLoading = false;
  late Place place;

  @override
  void initState() {
    super.initState();
    getPlace();
  }

  Future getPlace() async {
    setState(() => isLoading = true);
    place = await DbHelper.instance.read(widget.id);
    nicknameController.text = place.nickname;
    addressController.text = place.address;
    tags = place.categories;
    setState(() => isLoading = false);
  }

  Future editPlace(
      {required String nickname,
      required String address,
      required List<String> categories,
      double latitude = 0.0,
      double longitude = 0.0}) async {
    final place = Place(
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
              flex: 12,
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
                                controller: addressController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Endereço Completo',
                                ),
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
                          child: TextFieldTags(
                            key: _formKey,
                            textSeparators: const [' ', ','],
                            initialTags: tags.first.isNotEmpty ? tags : [],
                            validator: (tag) {
                              if (tag.isEmpty) {
                                return 'Insira pelo menos 1 categoria';
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
                                )),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          textStyle: TextStyle(
                              fontSize: 32 *
                                  MediaQuery.of(context).textScaleFactor /
                                  2),
                          primary: Theme.of(context).scaffoldBackgroundColor,
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0))),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await editPlace(
                                nickname: nicknameController.text,
                                address: addressController.text,
                                categories: tags);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Theme.of(context).primaryColor,
                                content: const Text(
                                    'Localidade cadastrada com sucesso!'),
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
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          textStyle: TextStyle(
                              fontSize: 32 *
                                  MediaQuery.of(context).textScaleFactor /
                                  2),
                          primary: Theme.of(context).primaryColor,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0))),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancelar',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
