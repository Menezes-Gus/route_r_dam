import 'package:flutter/material.dart';
import 'package:route_r_dam/components/menubuttom.dart';
import 'package:route_r_dam/models/place.dart';
import 'package:route_r_dam/pages/build_route_page.dart';

import 'package:route_r_dam/pages/manage_places.dart';
import 'package:route_r_dam/pages/select_starting_point.dart';
import 'package:route_r_dam/pages/test.dart';
import 'package:url_launcher/url_launcher.dart';

import 'automated_route_builder.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  _openManagePlaces(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ManagePlaces()));
  }

  _openAutomatedRouteBuilder(context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AutomatedRouteBuilder()));
  }

  _openSelectStartingPoint(context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SelectStartingPoint()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   title: const Text('Route R Dam'),
      // ),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Tooltip(
                      child: Icon(
                        Icons.help_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: const Duration(seconds: 5),
                      message: '''

Construir Rota: Construa uma rota de viagem utilizando localidades j?? cadastradas. Selecione os locais que deseja visitar e compare as dist??ncias.
            
Rota Autom??tica: Automaticamente constr??i rota otimizada baseada em todos os locais cadastrados no aplicativo.
            
Gerenciar Localidades: Cadastre, altere ou exclua localidades.
''',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                heightFactor: 0.5,
                child: Text(
                  'Route R Dam',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize:
                          (MediaQuery.of(context).textScaleFactor / 5) * 125),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width / 35,
                      0,
                      MediaQuery.of(context).size.width / 35,
                      MediaQuery.of(context).size.height / 35),
                  child: const Image(
                    image: AssetImage('assets/logos/Logo.png'),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                    bottom: BorderSide(
                        color: Theme.of(context).primaryColor, width: 2),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: MenuButtom(
                          'Construir Rota', _openSelectStartingPoint),
                    ),

                    // Expanded(
                    //     flex: 2,
                    //     child: MenuButtom(
                    //         'Rota Autom??tica', _openAutomatedRouteBuilder)),
                    Expanded(
                        flex: 2,
                        child: MenuButtom(
                            'Gerenciar Localidades', _openManagePlaces)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                heightFactor: 5,
                child: TextButton(
                  onPressed: () async {
                    if (!await launch(
                        'https://www.buymeacoffee.com/gustavomenezes')) {
                      throw 'Could not launch';
                    }
                  },
                  child: Text(
                    'Apoie o desenvolvedor',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 60 * MediaQuery.of(context).textScaleFactor / 5,
                      color: Colors.teal.shade300,
                    ),
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
