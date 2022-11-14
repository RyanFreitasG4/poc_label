import 'package:flutter/material.dart';

mixin CustomDialogMixin {
  Future<void> showCustomDialog({
    required BuildContext context,
    required String title,
    required String content,
    required List<Widget> actions,
  }) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions,
      ),
    );
  }
}
