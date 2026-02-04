import 'package:flutter/material.dart';

class DefaultAppbar extends StatelessWidget implements PreferredSizeWidget{
  const DefaultAppbar({super.key, this.title, this.showTitle, this.additionalWidgets});
  final String? title;
  final List<Widget>? additionalWidgets;
  final bool? showTitle;

  @override
  Widget build(BuildContext context) => AppBar(
      title: title != null ? Text(
        title!,
        style: Theme.of(context).textTheme.headlineMedium,
      ) : showTitle ?? false ? const Image(image: AssetImage('assets/logo.png'), height: 40) :
      null,
      actions: additionalWidgets,
  );
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}