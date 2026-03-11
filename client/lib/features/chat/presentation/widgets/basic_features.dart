import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class BasicFeatures extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const BasicFeatures({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
 

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(icon, width: 30, height: 30),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:  GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
              ),
              Text(
                description,
                style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.white38
                    ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        ),
      ],
    );
  }
}
