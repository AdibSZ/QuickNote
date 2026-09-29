import 'package:flutter/material.dart';

/// Pixel-perfect vector render of the QuickNote App Emblem from Stitch.
class AppEmblem extends StatelessWidget {
  final double size;

  const AppEmblem({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C22),
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.44,
          height: size * 0.5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(size * 0.07),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 0.7,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: size * 0.07, vertical: size * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 1.2,
                width: size * 0.22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Container(
                height: 1.0,
                width: size * 0.28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 1.0,
                    width: size * 0.16,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Container(
                    width: size * 0.07,
                    height: size * 0.07,
                    decoration: const BoxDecoration(
                      color: Color(0xFFAAC7FF),
                      shape: BoxShape.circle,
                    ),
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
