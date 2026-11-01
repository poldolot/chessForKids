import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/constants.dart';
import '../../data/models.dart';

/// A teacher or profile avatar: picture [index] (1-based) of [theme].
class AvatarImage extends StatelessWidget {
  const AvatarImage(this.theme, this.index, {super.key, this.size = 64});

  final TeacherTheme theme;
  final int index;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      avatarAsset(theme, index),
      width: size,
      height: size,
      semanticsLabel: '${theme.name} $index',
    );
  }
}
