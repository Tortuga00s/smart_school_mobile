// ignore: deprecated_member_use
import 'package:flutter/material.dart';

/// Wait until the dismissal animation unmounts the dialog before its caller
/// disposes controllers. DialogRoute's result alone completes before unmount.
Future<T?> settledDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) async {
  final route = DialogRoute<T>(context: context, builder: builder);
  final result = await Navigator.of(
    context,
    rootNavigator: true,
  ).push<T>(route);
  await route.completed;
  return result;
}
