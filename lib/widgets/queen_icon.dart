import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The coloured queen that stands for "profiles": gold crown, red jewels,
/// light grey base. Shown on the profile screen and as the menu's way back
/// to it.
class QueenIcon extends StatelessWidget {
  const QueenIcon({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/ui/queen.svg',
      width: size,
      height: size,
      semanticsLabel: 'queen',
    );
  }
}
