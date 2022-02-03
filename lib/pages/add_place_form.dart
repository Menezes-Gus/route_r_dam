import 'package:flutter/material.dart';
import 'package:route_r_dam/components/return.dart';
import 'package:route_r_dam/models/database.dart';
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
  List<String> tags = [];
  final nicknameController = TextEditingController();
  final addressController = TextEditingController();

  Future addPlace(
      String nickname, String address, List<String> categories) async {
    final place = Place(
      nickname: nickname,
      address: address,
      categories: categories,
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

                              // TextFormField(
                              //   decoration: const InputDecoration(
                              //     border: UnderlineInputBorder(),
                              //     labelText: 'Apelido do Local',
                              //   ),
                              // ),
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await addPlace(nicknameController.text,
                          addressController.text, tags);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(context).primaryColor,
                          content:
                              const Text('Localidade cadastrada com sucesso!'),
                        ),
                      );
                      widget._refreshPage();
                      Navigator.pop(context);
                    }
                  },
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
