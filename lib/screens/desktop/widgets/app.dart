import 'package:flutter/material.dart';
import 'package:so_portfolio/core/extensions.dart';

class DesktopApp extends StatelessWidget {
  final String icon;
  final String name;
  final VoidCallback onTap;

  const DesktopApp({
    super.key,
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: SizedBox(
        width: 120,
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Image.asset(icon, fit: BoxFit.cover),
              ),
              SizedBox(height: 5),
              Stack(
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ).withOutline,
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
