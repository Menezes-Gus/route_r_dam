import 'package:flutter/material.dart';

class Return extends StatelessWidget {
  const Return({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.keyboard_return,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
