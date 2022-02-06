import 'package:flutter/material.dart';
import 'package:route_r_dam/models/filter.dart';

class ToggleButtonHM extends StatefulWidget {
  final String _text;
  final void Function(String) _addFilterValue;
  final void Function(String) _removeFilterValue;
  const ToggleButtonHM(
      this._text, this._addFilterValue, this._removeFilterValue);

  @override
  _ToggleButtonHMState createState() => _ToggleButtonHMState();
}

class _ToggleButtonHMState extends State<ToggleButtonHM> {
  bool state = true;
  Set<Filter> filters = {};
  Set<String> filterValues = {};
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: state
            ? Theme.of(context).scaffoldBackgroundColor
            : Theme.of(context).primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
      ),
      onPressed: () {
        setState(() {
          state = !state;
          if (!state) {
            widget._addFilterValue(widget._text);
          } else {
            widget._removeFilterValue(widget._text);
          }
        });
      },
      child: Text(
        widget._text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: state
              ? Theme.of(context).primaryColor
              : Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }
}


//teal.accent.shade100