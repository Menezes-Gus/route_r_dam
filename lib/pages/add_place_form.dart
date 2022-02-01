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
            const Return(),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
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
                    SizedBox(
                      height: 0.03 * MediaQuery.of(context).size.height,
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
                    SizedBox(
                      height: 0.03 * MediaQuery.of(context).size.height,
                    ),
                    TextFieldTags(
                      textSeparators: const [' ', ','],
                      initialTags: const [],
                      validator: (tag) {
                        if (tag.isEmpty) {
                          return 'Insira pelo menos 1 categoria';
                        }

                        return null;
                      },
                      textFieldStyler: TextFieldStyler(
                          helperText: 'Insira ao menos 1 Categoria',
                          hintText: 'Categorias',
                          textFieldBorder: const OutlineInputBorder()),
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
                    SizedBox(
                      height: 0.03 * MediaQuery.of(context).size.height,
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_formKey.currentState!.validate() && tags.isNotEmpty) {
            await addPlace(
                nicknameController.text, addressController.text, tags);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).primaryColor,
                content: const Text('Localidade cadastrada com sucesso!'),
              ),
            );
            widget._refreshPage();
            Navigator.pop(context);
          }
        },
        label: const Text('Cadastrar Localidade'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
