import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Logos {
  static Widget google({double size = 18}) =>
      SvgPicture.asset('assets/google.svg', width: size, height: size);

  static Widget instagram({double size = 18}) =>
      SvgPicture.asset('assets/instagram.svg', width: size, height: size);

  static Widget tiktok({double size = 18}) =>
      SvgPicture.asset('assets/tiktok.svg', width: size, height: size);

  static Widget youtube({double size = 18}) =>
      SvgPicture.asset('assets/youtube.svg', width: size, height: size);

}
