import 'package:flutter/material.dart';
import 'package:route_r_dam/components/menubuttom.dart';
import 'package:route_r_dam/pages/manage_places.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  _openManagePlaces(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ManagePlaces()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   title: const Text('Route R Dam'),
      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MenuButtom(
              'Construir Rota',
              'Construa uma rota de viagem utilizando localidades já cadastradas. Selecione os locais que deseja visitar e compare as distâncias.',
              _openManagePlaces),
          MenuButtom(
              'Rota Automática',
              'Automaticamente constrói rota otimizada baseada em todos os locais cadastrados no aplicativo.',
              _openManagePlaces),
          MenuButtom('Gerenciar Localidades',
              'Cadastre, altere ou exclua localidades.', _openManagePlaces),
        ],
      ),
    );
  }
}
