import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/landing/landing_hero.dart';
import '../../widgets/landing/landing_navbar.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const double _desktopBreakpoint = 1200;
  static const double _mobileBreakpoint = 768;
  static const double _maxContentWidth = 1440;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              LandingNavbar(
                desktopBreakpoint: _desktopBreakpoint,
                mobileBreakpoint: _mobileBreakpoint,
                maxContentWidth: _maxContentWidth,
                onHomePressed: () {},
                onAboutPressed: () {},
                onHowItWorksPressed: () {},
                onSeaweedGuidePressed: () {},
                onLoginPressed: () {},
              ),
              LandingHero(
                desktopBreakpoint: _desktopBreakpoint,
                mobileBreakpoint: _mobileBreakpoint,
                maxContentWidth: _maxContentWidth,
                onGetStartedPressed: () {},
                onExploreGuidePressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}