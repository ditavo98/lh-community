import 'package:photo_gallery/photo_gallery.dart';

extension MediumEx on Medium {
  double get ratio {
    final widthValue = width ?? 1;
    final heightValue = height ?? 1;
    return widthValue / heightValue;
  }
}
