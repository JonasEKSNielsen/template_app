import 'package:flutter/material.dart';
import 'package:template_app/classes/values/assets.dart';

class DefaultScaffold extends StatelessWidget {
  const DefaultScaffold({
    super.key,
    this.title,
    required this.child,
    this.showTitle,
    this.additionalWidgets,
  });
  final String? title;
  final List<Widget>? additionalWidgets;
  final Widget child;
  final bool? showTitle;

  @override
  Widget build(BuildContext context) {
    const backgroundAsset = Asset.whiteBackground;

    return Scaffold(
      appBar: AppBar(
        title: title != null
            ? Text(title!, style: Theme.of(context).textTheme.headlineMedium)
            : showTitle ?? false
            ? const Image(image: AssetImage('assets/logo.png'), height: 40)
            : null,
        actions: additionalWidgets,
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
