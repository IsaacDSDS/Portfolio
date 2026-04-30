import 'package:flutter/material.dart';

abstract class StatefulWithTag extends StatefulWidget {
  final String tag;

  const StatefulWithTag({super.key, required this.tag});
}
