import 'package:client/core/theme/app_theme.dart' show AppTheme;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    TextTheme textTheme = AppTheme.darkTheme.textTheme;

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
                style: TextStyle(
                  fontSize: textTheme.headlineMedium?.fontSize ?? 20,
                  fontWeight:
                      textTheme.headlineMedium?.fontWeight ?? FontWeight.bold,
                  color: textTheme.headlineMedium?.color ?? Colors.white,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: textTheme.bodySmall?.fontSize ?? 20,
                  fontWeight:
                      textTheme.bodySmall?.fontWeight ?? FontWeight.bold,
                  color: textTheme.bodySmall?.color ?? Colors.white,
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
