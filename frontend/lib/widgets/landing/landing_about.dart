import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/seaweed_data.dart';
import '../../models/seaweed_info.dart';

class LandingAbout extends StatelessWidget {
  const LandingAbout({
    super.key,
    required this.desktopBreakpoint,
    required this.mobileBreakpoint,
    required this.maxContentWidth,
  });

  final double desktopBreakpoint;
  final double mobileBreakpoint;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isDesktop = width >= desktopBreakpoint;
        final isMobile = width < mobileBreakpoint;

        final horizontalPadding = isDesktop
            ? 64.0
            : isMobile
                ? 20.0
                : 36.0;

        final verticalPadding = isMobile ? 72.0 : 96.0;

        final guso = _findGuso();

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF071D07),
                Color(0xFF0B2F0B),
                Color(0xFF061806),
              ],
              stops: [
                0.0,
                0.52,
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: IgnorePointer(
                  child: _DecorativeBackground(),
                ),
              ),

              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxContentWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      children: [
                        if (isDesktop)
                          _DesktopLayout(
                            guso: guso,
                          )
                        else
                          _StackedLayout(
                            guso: guso,
                            isMobile: isMobile,
                          ),

                        SizedBox(
                          height: isMobile ? 34 : 44,
                        ),

                        _ResearchStrip(
                          isMobile: isMobile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SeaweedInfo? _findGuso() {
    for (final seaweed in SeaweedData.seaweeds) {
      final searchable =
          '${seaweed.scientificName} '
          '${seaweed.englishName} '
          '${seaweed.filipinoName} '
          '${seaweed.bisayaName}'
              .toLowerCase();

      if (searchable.contains('guso') ||
          searchable.contains('kappaphycus')) {
        return seaweed;
      }
    }

    return null;
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.guso,
  });

  final SeaweedInfo? guso;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 10,
          child: _AboutLeftColumn(
            guso: guso,
          ),
        ),

        const SizedBox(width: 48),

        const Expanded(
          flex: 11,
          child: _FeatureGrid(),
        ),
      ],
    );
  }
}

class _StackedLayout extends StatelessWidget {
  const _StackedLayout({
    required this.guso,
    required this.isMobile,
  });

  final SeaweedInfo? guso;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AboutLeftColumn(
          guso: guso,
        ),

        SizedBox(
          height: isMobile ? 38 : 48,
        ),

        const _FeatureGrid(),
      ],
    );
  }
}

class _AboutLeftColumn extends StatelessWidget {
  const _AboutLeftColumn({
    required this.guso,
  });

  final SeaweedInfo? guso;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AboutBadge(),

        const SizedBox(height: 24),

        const Text(
          'A Smarter Way to\nUnderstand Guso Quality',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 46,
            height: 1.06,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.35,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'gUSo uses image-based analysis to assess the visible '
          'quality of guso, focusing on freshness, image condition, '
          'and observable characteristics.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 17,
            height: 1.65,
          ),
        ),

        const SizedBox(height: 24),

        Container(
          width: 72,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),

        const SizedBox(height: 26),

        _GusoImagePanel(
          guso: guso,
        ),
      ],
    );
  }
}

class _AboutBadge extends StatelessWidget {
  const _AboutBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(
          alpha: 0.82,
        ),
        borderRadius: BorderRadius.circular(
          AppRadius.extraLarge,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.78,
          ),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          SizedBox(width: 8),
          Text(
            'ABOUT GUSO',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.95,
            ),
          ),
        ],
      ),
    );
  }
}

class _GusoImagePanel extends StatelessWidget {
  const _GusoImagePanel({
    required this.guso,
  });

  final SeaweedInfo? guso;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppRadius.large,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.78,
          ),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.08,
            ),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppRadius.large - 1,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/landing/guso_about_banner.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const _FallbackImage();
              },
            ),

            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x11001000),
                    Color(0x44001000),
                    Color(0xCC001000),
                  ],
                  stops: [
                    0.0,
                    0.58,
                    1.0,
                  ],
                ),
              ),
            ),

            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(
                    alpha: 0.86,
                  ),
                  borderRadius: BorderRadius.circular(
                    50,
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(
                      alpha: 0.50,
                    ),
                    width: 1.3,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Guso (Seaweed)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Positioned(
              left: 22,
              right: 22,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focused on Guso',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Image-based insights centered on visible quality, '
                    'freshness, and observable characteristics.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  const _FallbackImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF154A14),
            Color(0xFF0A2509),
            Color(0xFF041304),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          size: 140,
          color: AppColors.primary.withValues(
            alpha: 0.22,
          ),
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow =
            constraints.maxWidth < 520;

        if (narrow) {
          return const Column(
            children: [
              _FeatureCard(
                icon: Icons.image_search_outlined,
                title: 'Image-Based Analysis',
                description:
                    'Uses a guso image as the basis for structured quality assessment.',
              ),
              SizedBox(height: 18),
              _FeatureCard(
                icon: Icons.eco_outlined,
                title: 'Quality & Freshness',
                description:
                    'Highlights key visible indicators related to guso quality and freshness.',
              ),
              SizedBox(height: 18),
              _FeatureCard(
                icon: Icons.visibility_outlined,
                title: 'Observable Quality',
                description:
                    'Reviews traits such as color, texture, image condition, and visible features.',
              ),
              SizedBox(height: 18),
              _FeatureCard(
                icon: Icons.menu_book_outlined,
                title: 'Seaweed Guide',
                description:
                    'Provides focused image-based information for learning more about guso.',
              ),
            ],
          );
        }

        return const Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _FeatureCard(
                    icon:
                        Icons.image_search_outlined,
                    title:
                        'Image-Based Analysis',
                    description:
                        'Uses a guso image as the basis for structured quality assessment.',
                  ),
                  SizedBox(height: 22),
                  _FeatureCard(
                    icon:
                        Icons.visibility_outlined,
                    title:
                        'Observable Quality',
                    description:
                        'Reviews traits such as color, texture, image condition, and visible features.',
                  ),
                ],
              ),
            ),

            SizedBox(width: 22),

            Expanded(
              child: Column(
                children: [
                  _FeatureCard(
                    icon:
                        Icons.eco_outlined,
                    title:
                        'Quality & Freshness',
                    description:
                        'Highlights key visible indicators related to guso quality and freshness.',
                  ),
                  SizedBox(height: 22),
                  _FeatureCard(
                    icon:
                        Icons.menu_book_outlined,
                    title:
                        'Seaweed Guide',
                    description:
                        'Provides focused image-based information for learning more about guso.',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  State<_FeatureCard> createState() =>
      _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(
          minHeight: 250,
        ),
        padding: const EdgeInsets.all(28),
        transform: Matrix4.translationValues(
          0,
          _hovered ? -4 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AppRadius.large,
          ),
          border: Border.all(
            color: _hovered
                ? AppColors.primary.withValues(
                    alpha: 0.9,
                  )
                : AppColors.textMuted.withValues(
                    alpha: 0.48,
                  ),
            width: _hovered ? 1.4 : 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _hovered
                ? const [
                    Color(0xFF123A0F),
                    Color(0xFF0A2508),
                  ]
                : const [
                    Color(0xFF0D2B09),
                    Color(0xFF082006),
                  ],
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: 0.09,
                    ),
                    blurRadius: 26,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -28,
              bottom: -32,
              child: Icon(
                Icons.eco_rounded,
                size: 150,
                color: AppColors.primary.withValues(
                  alpha: 0.035,
                ),
              ),
            ),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.medium,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: AppColors.primary,
                    size: 29,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    height: 1.22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  widget.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResearchStrip extends StatelessWidget {
  const _ResearchStrip({
    required this.isMobile,
  });

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 30,
        vertical: isMobile ? 22 : 24,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppRadius.large,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.62,
          ),
        ),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF0B2608),
            Color(0xFF123B0F),
            Color(0xFF092107),
          ],
        ),
      ),
      child: isMobile
          ? const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.science_outlined,
                  color: AppColors.primary,
                  size: 38,
                ),
                SizedBox(height: 16),
                _ResearchCopy(),
              ],
            )
          : const Row(
              children: [
                Icon(
                  Icons.science_outlined,
                  color: AppColors.primary,
                  size: 40,
                ),

                SizedBox(width: 26),

                SizedBox(
                  height: 52,
                  child: VerticalDivider(
                    color: AppColors.disabled,
                  ),
                ),

                SizedBox(width: 26),

                Expanded(
                  child: _ResearchCopy(),
                ),
              ],
            ),
    );
  }
}

class _ResearchCopy extends StatelessWidget {
  const _ResearchCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Built for research and learning.',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        SizedBox(height: 6),

        Text(
          'A clean, research-oriented platform for guso quality '
          'assessment and exploration through image analysis.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _DecorativeBackground extends StatelessWidget {
  const _DecorativeBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: -220,
          top: 100,
          child: Container(
            width: 520,
            height: 520,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(
                alpha: 0.035,
              ),
            ),
          ),
        ),

        Positioned(
          right: -260,
          bottom: -260,
          child: Container(
            width: 660,
            height: 660,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(
                alpha: 0.05,
              ),
            ),
          ),
        ),

        Positioned(
          right: 80,
          top: 40,
          child: Transform.rotate(
            angle: -0.35,
            child: Container(
              width: 360,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  999,
                ),
                color: AppColors.primary.withValues(
                  alpha: 0.025,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}