import 'dart:io';
import 'package:flutter/services.dart';

Future<void> loadTestFonts() async {
  for (final entry in {
    'SmartSchoolTest': 'DejaVuSans.ttf',
    'MaterialIcons': 'MaterialIcons-Regular.otf',
  }.entries) {
    final bytes = await File(
      '../../packages/school_data/test/fonts/${entry.value}',
    ).readAsBytes();
    await (FontLoader(
      entry.key,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}
