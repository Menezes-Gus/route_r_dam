import 'package:flutter/material.dart';

class MenuButtom extends StatefulWidget {
  final String _title;
  final void Function(BuildContext) _changePage;

  const MenuButtom(this._title, this._changePage);

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)))),
              child: Text(
                widget._title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20 * MediaQuery.of(context).textScaleFactor),
              ),
              onPressed: changePage,
            ),
          ),
        ),
      ],
    );
  }
}
