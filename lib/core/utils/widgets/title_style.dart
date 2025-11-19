import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleStyleWidget extends StatelessWidget {
  final String? title;
  final double? fontSize;
  final double? letterSpacing;
  final FontWeight? fontWeight;
  final Color? color;

  const TitleStyleWidget({
    super.key,
    this.title,
    this.fontSize = 18,
    this.letterSpacing  =0,
    this.fontWeight,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title!,
      style: GoogleFonts.montserrat(
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
        color: color ?? CupertinoColors.label.resolveFrom(context),
      ),
    );
  }
}