import 'package:flutter/material.dart';
import 'package:template_app/values/assets.dart';
import 'default_appbar.dart';

class DefaultScaffold extends StatelessWidget  {
  const DefaultScaffold({super.key, this.title, required this.child, this.showTitle, this.additionalWidgets});
  final String? title;
  final List<Widget>? additionalWidgets;
  final Widget child;
  final bool? showTitle;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness; 
    final backgroundAsset = brightness == Brightness.dark ? Asset.blackBackground : Asset.whiteBackground;

    return Scaffold(
      appBar: DefaultAppbar(
        title: title, 
        showTitle: showTitle,
        additionalWidgets: additionalWidgets,
      ),
      body: Stack(
        children: [
          Image(image: Assets.getAsset(backgroundAsset), fit: BoxFit.cover),
          child,
        ],
      ),
    );
  }
}