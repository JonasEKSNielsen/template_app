import 'package:flutter/material.dart';

abstract class Constants {

  ///
  /// GENERAL colors
  ///
  //region Colors

  static const Color transparent = Colors.transparent;

  static const Gradient buttonDefault = LinearGradient(
    colors: <Color>[transparent, transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient buttonPressed = LinearGradient(
    colors: <Color>[
      Color(0x20FFFFFF),
      Color(0x20FFFFFF)
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );


  //endregion
}
