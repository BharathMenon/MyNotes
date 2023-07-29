import 'package:flutter/material.dart';
import 'package:mynotes/utilities/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetemailsentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content:
        'We have now sent you a link to reset you password. Please check your email for more information.',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
