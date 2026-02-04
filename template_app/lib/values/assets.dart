import 'package:flutter/material.dart';

enum Asset {
  whiteBackground,
  blackBackground,
  logIn,
  whiteIcon,
  blackIcon,
}

abstract class Assets {
  static AssetImage getAsset(Asset asset) {
    switch (asset) {
      case Asset.whiteBackground:
        return const AssetImage('assets/backgrounds/image_background_white.png');
      case Asset.blackBackground:
        return const AssetImage('assets/backgrounds/image_background_black.png');
      case Asset.logIn:
        return const AssetImage('assets/icons/lock_icon.png');
      case Asset.whiteIcon:
        return const AssetImage('assets/black_icon.png');
      case Asset.blackIcon:
        return const AssetImage('assets/white_icon.png');

    }
  }
}
