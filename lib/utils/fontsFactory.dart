import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle googleFont(
    {double? fontsize,
    FontWeight? fontweight,
    FontStyle? fontStyle,
    Color? colour}) {
  return GoogleFonts.lato(
    color: colour ?? Colors.black,
    fontSize: fontsize ?? 16,
    fontWeight: fontweight ?? FontWeight.normal,
    fontStyle: fontStyle ?? FontStyle.normal,
  );
}
