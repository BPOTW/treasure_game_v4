import 'package:flutter/material.dart';

class FillProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color fillColor;
  final Color borderColor;

  const FillProgressBar({
    super.key,
    required this.progress,
    this.height = 20.0,
    this.fillColor = Colors.red,
    this.borderColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth * progress.clamp(0.0, 1.0);
        return Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 3),
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Stack(
            children: [
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
