import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:template_app/objects/flavor_item.dart';


enum FlavorEnum {
  white,
  black,
  none,
}



class FlavorHelper {
  String? test;

  // Gets flavor
  static Flavor getFlavor() {
    const String givenFlavorString = appFlavor ?? '';

    final int index = FlavorEnum.values.indexWhere((e) => e.toString() == 'FlavorEnum.$givenFlavorString');
    
    FlavorEnum flavorEnum;
    if (index != -1) {
      flavorEnum = FlavorEnum.values[index];
    } else {
      flavorEnum = FlavorEnum.none;
    }

    final Flavor flavor = Flavor();
    
     switch(flavorEnum) {
       case FlavorEnum.white:
         flavor.appName = 'White';
         flavor.serverUrl = 'https://www.white.dk';
         flavor.testServerUrl = 'https://www.testwhite.dk';
         flavor.icon = FlavorAssets.getAsset(FlavorAsset.whiteIcon);
         return flavor;

       case FlavorEnum.black:
         flavor.appName = 'Black';
         flavor.serverUrl = 'https://www.black.dk';
         flavor.testServerUrl = 'https://www.testblack.dk';
         flavor.icon = FlavorAssets.getAsset(FlavorAsset.blackIcon);
         return flavor;

       case FlavorEnum.none:
         return flavor;
     }
  }
}

enum FlavorAsset {
  whiteIcon,
  blackIcon,
}

abstract class FlavorAssets {
  static AssetImage getAsset(FlavorAsset asset) {
    switch (asset) {
      case FlavorAsset.whiteIcon:
        return const AssetImage('assets/black_icon.png');
      case FlavorAsset.blackIcon:
        return const AssetImage('assets/white_icon.png');
    }
  }
}
