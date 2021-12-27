import 'package:flutter/material.dart';

import 'package:therapist_buddy/variables.dart';

class SmallProgressIndicator extends StatelessWidget {
  const SmallProgressIndicator({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: primaryColor,
    );
  }
}
