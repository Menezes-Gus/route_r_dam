import 'package:flutter/material.dart';

class MenuButtom extends StatefulWidget {
  final String _title;
  final String _description;
  final void Function(BuildContext) _changePage;

  const MenuButtom(this._title, this._description, this._changePage);

  @override
  State<MenuButtom> createState() => _MenuButtomState();
}

class _MenuButtomState extends State<MenuButtom> {
  changePage() {
    widget._changePage(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 0.05 * MediaQuery.of(context).size.height,
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: OutlinedButton(
            child: Text(
              widget._title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20 * MediaQuery.of(context).textScaleFactor),
            ),
            onPressed: changePage,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Text(
            widget._description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 15 * MediaQuery.of(context).textScaleFactor,
            ),
          ),
        ),
        SizedBox(
          height: 0.05 * MediaQuery.of(context).size.height,
        ),
      ],
    );
  }
}
