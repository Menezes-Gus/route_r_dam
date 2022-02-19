import 'package:flutter/material.dart';
import 'dart:math' as math;

class TextWithIcon extends StatelessWidget {
  final String placeName;

  const TextWithIcon({
    Key? key,
    required this.placeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Transform.rotate(
            angle: 180 * math.pi / 180,
            child: Icon(
              Icons.alt_route_rounded,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            placeName,
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Theme.of(context).primaryColor,
            ),
          ),

          const Spacer(
            flex: 1,
          ),
          // IconButton(onPressed: onPressed, icon: icon)
        ],
      ),
    );
  }
}
