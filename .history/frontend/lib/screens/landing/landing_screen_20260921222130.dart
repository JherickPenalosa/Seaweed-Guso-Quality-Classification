import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../screens/seaweed_guide/seaweed_guide_screen.dart';
import '../../widgets/landing/landing_about.dart';
import '../../widgets/landing/landing_hero.dart';
import '../../widgets/landing/landing_how_it_works.dart';
import '../../widgets/landing/landing_navbar.dart';
import '../../widgets/landing/landing_seaweed_guide_preview.dart';

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
                onSeaweedGuidePressed: () {
                  _openSeaweedGuide(context);
                },
                onLoginPressed: () {},
              ),

              LandingHero(
                desktopBreakpoint: _desktopBreakpoint,
                mobileBreakpoint: _mobileBreakpoint,
                maxContentWidth: _maxContentWidth,
                onGetStartedPressed: () {},
                onExploreGuidePressed: () {
                  _openSeaweedGuide(context);
                },
              ),

              LandingAbout(
                desktopBreakpoint: _desktopBreakpoint,
                mobileBreakpoint: _mobileBreakpoint,
                maxContentWidth: _maxContentWidth,
              ),

              LandingHowItWorks(
                desktopBreakpoint: _desktopBreakpoint,
                mobileBreakpoint: _mobileBreakpoint,
                maxContentWidth: _maxContentWidth,
              ),

              LandingSeaweedGuidePreview(
                desktopBreakpoint: _desktopBreakpoint,
                mobileBreakpoint: _mobileBreakpoint,
                maxContentWidth: _maxContentWidth,
                onExploreGuidePressed: () {
                  _openSeaweedGuide(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSeaweedGuide(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: SeaweedGuideScreen(),
            ),
          );
        },
      ),
    );
  }
}