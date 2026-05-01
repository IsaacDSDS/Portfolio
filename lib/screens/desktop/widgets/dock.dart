import 'dart:math';

import 'package:flutter/material.dart';
import 'package:so_portfolio/core/constants.dart';
import 'package:so_portfolio/widgets/SeparatedRow.dart';

class Dock extends StatelessWidget {
  const Dock({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        height: bottomBarHeight,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(10),

        child: SeparatedRow(
          separatorBuilder: (context, index) => SizedBox(width: 5),
          children: [
            Container(
              width: bottomBarHeight - 20,
              height: bottomBarHeight - 20,
              decoration: BoxDecoration(
                color:
                    Colors.primaries[Random().nextInt(Colors.primaries.length)],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
