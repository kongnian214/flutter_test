import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../shell/festival_showcase_page.dart';

class AuroraShowcaseApp extends StatelessWidget {
  const AuroraShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '圣诞氛围实验室',
      theme: AppTheme.dark(),
      home: const FestivalShowcasePage(),
    );
  }
}
