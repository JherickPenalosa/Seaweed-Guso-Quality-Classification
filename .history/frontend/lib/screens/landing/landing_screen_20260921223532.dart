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

  static const double _navbarHeight = 92;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: _navbarHeight,
                ),
                child: Column(
                  children: [
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

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.disabled.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),
                ),
                child: LandingNavbar(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSeaweedGuide(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      28,
                      20,
                      28,
                      0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(routeContext).pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                        ),
                        label: const Text(
                          'Back to Landing Page',
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: SeaweedGuideScreen(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}