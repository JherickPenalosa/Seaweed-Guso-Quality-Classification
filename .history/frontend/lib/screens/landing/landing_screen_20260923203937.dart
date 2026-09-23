import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../screens/seaweed_guide/seaweed_guide_screen.dart';

import '../../widgets/landing/landing_about.dart';
import '../../widgets/landing/landing_footer.dart';
import '../../widgets/landing/landing_hero.dart';
import '../../widgets/landing/landing_how_it_works.dart';
import '../../widgets/landing/landing_navbar.dart';
import '../../widgets/landing/landing_seaweed_guide_preview.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  static const double _desktopBreakpoint = 1200;
  static const double _mobileBreakpoint = 768;
  static const double _maxContentWidth = 1440;
  static const double _navbarHeight = 92;

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _seaweedGuideKey = GlobalKey();

  bool _showLogin = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(
                  top: _navbarHeight,
                ),
                child: Column(
                  children: [
                    KeyedSubtree(
                      key: _homeKey,
                      child: LandingHero(
                        desktopBreakpoint: _desktopBreakpoint,
                        mobileBreakpoint: _mobileBreakpoint,
                        maxContentWidth: _maxContentWidth,

                        onGetStartedPressed: () {
                          _openLoginPanel();
                        },

                        onExploreGuidePressed: () {
                          _openSeaweedGuide();
                        },

                        showLogin: _showLogin,

                        onLoginSubmitted: (
                          identifier,
                          password,
                        ) {
                          _handleLoginSubmission(
                            identifier,
                            password,
                          );
                        },

                        onLoginBackPressed: () {
                          _closeLoginPanel();
                        },
                      ),
                    ),

                    KeyedSubtree(
                      key: _aboutKey,
                      child: const LandingAbout(
                        desktopBreakpoint: _desktopBreakpoint,
                        mobileBreakpoint: _mobileBreakpoint,
                        maxContentWidth: _maxContentWidth,
                      ),
                    ),

                    KeyedSubtree(
                      key: _howItWorksKey,
                      child: const LandingHowItWorks(
                        desktopBreakpoint: _desktopBreakpoint,
                        mobileBreakpoint: _mobileBreakpoint,
                        maxContentWidth: _maxContentWidth,
                      ),
                    ),

                    KeyedSubtree(
                      key: _seaweedGuideKey,
                      child: LandingSeaweedGuidePreview(
                        desktopBreakpoint: _desktopBreakpoint,
                        mobileBreakpoint: _mobileBreakpoint,
                        maxContentWidth: _maxContentWidth,
                        onExploreGuidePressed: () {
                          _openSeaweedGuide();
                        },
                      ),
                    ),

                    LandingFooter(
                      desktopBreakpoint: _desktopBreakpoint,
                      mobileBreakpoint: _mobileBreakpoint,
                      maxContentWidth: _maxContentWidth,

                      onHomePressed: () {
                        _returnToHome();
                      },

                      onAboutPressed: () {
                        _scrollToSection(_aboutKey);
                      },

                      onHowItWorksPressed: () {
                        _scrollToSection(_howItWorksKey);
                      },

                      onSeaweedGuidePressed: () {
                        _scrollToSection(_seaweedGuideKey);
                      },

                      onGetStartedPressed: () {
                        _openLoginPanel();
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

                  onHomePressed: () {
                    _returnToHome();
                  },

                  onAboutPressed: () {
                    _scrollToSection(_aboutKey);
                  },

                  onHowItWorksPressed: () {
                    _scrollToSection(_howItWorksKey);
                  },

                  onSeaweedGuidePressed: () {
                    _scrollToSection(_seaweedGuideKey);
                  },

                  onLoginPressed: () {
                    _openLoginPanel();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLoginPanel() {
    if (!_showLogin) {
      setState(() {
        _showLogin = true;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _scrollToSection(_homeKey);
    });
  }

  void _closeLoginPanel() {
    if (!_showLogin) {
      return;
    }

    setState(() {
      _showLogin = false;
    });
  }

  void _returnToHome() {
    if (_showLogin) {
      setState(() {
        _showLogin = false;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _scrollToSection(_homeKey);
    });
  }

  void _handleLoginSubmission(
    String identifier,
    String password,
  ) {
    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email or contact number and password.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Login authentication will be connected in the next step.',
        ),
      ),
    );
  }

  Future<void> _scrollToSection(GlobalKey key) async {
    final sectionContext = key.currentContext;

    if (sectionContext == null ||
        !_scrollController.hasClients) {
      return;
    }

    final renderObject =
        sectionContext.findRenderObject();

    if (renderObject is! RenderBox) {
      return;
    }

    final sectionPosition =
        renderObject.localToGlobal(Offset.zero).dy;

    final targetOffset =
        _scrollController.offset +
        sectionPosition -
        _navbarHeight -
        12;

    final safeOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    await _scrollController.animateTo(
      safeOffset,
      duration: const Duration(
        milliseconds: 550,
      ),
      curve: Curves.easeInOutCubic,
    );
  }

  void _openSeaweedGuide() {
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