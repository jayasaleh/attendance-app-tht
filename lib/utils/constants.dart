// lib/utils/constants.dart

import 'package:flutter/material.dart';

// Colors
const kPrimaryColor = Colors.indigo;
const kSuccessColor = Colors.green;
const kErrorColor = Colors.red;
const kMutedColor = Colors.grey;

// Spacing
const double kDefaultPadding = 16.0;
const SizedBox kGap = SizedBox(height: kDefaultPadding);
const SizedBox kGapSmall = SizedBox(height: kDefaultPadding / 2);
const SizedBox kGapTiny = SizedBox(height: kDefaultPadding / 4);

// Border Radius
final BorderRadius kBorderRadius = BorderRadius.circular(8.0);

// Text Styles
const TextStyle kTitleStyle = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.bold,
);
const TextStyle kHeadingStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
);
