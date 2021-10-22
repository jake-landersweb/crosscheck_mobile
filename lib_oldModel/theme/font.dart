import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';

String? fontFamily() {
  if (kIsWeb) {
    return GoogleFonts.roboto().fontFamily;
  } else {
    if (Platform.isIOS || Platform.isMacOS) {
      // TODO - add SF Pro font to this app
      return 'SF Pro';
    } else {
      return GoogleFonts.roboto().fontFamily;
    }
  }
}
