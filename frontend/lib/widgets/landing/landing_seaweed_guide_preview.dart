import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/seaweed_data.dart';
import '../../models/seaweed_info.dart';
import '../../screens/seaweed_guide/seaweed_detail_screen.dart';

class LandingSeaweedGuidePreview extends StatelessWidget {
  const LandingSeaweedGuidePreview({
    super.key,
    required this.desktopBreakpoint,
    required this.mobileBreakpoint,
    required this.maxContentWidth,
    required this.onExploreGuidePressed,
  });

  final double desktopBreakpoint;
  final double mobileBreakpoint;
  final double maxContentWidth;
  final VoidCallback onExploreGuidePressed;

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

        final verticalPadding = isMobile ? 76.0 : 100.0;

        final guso = _findGuso();

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF061806),
                Color(0xFF0B2F0B),
                Color(0xFF051505),
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
                  child: _GuideBackground(),
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
                        const _GuideHeader(),

                        SizedBox(
                          height: isMobile ? 40 : 56,
                        ),

                        if (guso != null)
                          _FeaturedGusoLayout(
                            seaweed: guso,
                            isDesktop: isDesktop,
                            isMobile: isMobile,
                          )
                        else
                          const _FallbackPanel(),

                        SizedBox(
                          height: isMobile ? 32 : 42,
                        ),

                        _GuideActionStrip(
                          onExploreGuidePressed:
                              onExploreGuidePressed,
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

class _GuideHeader extends StatelessWidget {
  const _GuideHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
                alpha: 0.74,
              ),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'GUSO GUIDE',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.95,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Know Your ',
              ),
              TextSpan(
                text: 'Guso',
                style: TextStyle(
                  color: AppColors.primary,
                ),
              ),
              TextSpan(
                text: ' Better',
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 44,
            height: 1.08,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.1,
          ),
        ),

        const SizedBox(height: 18),

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
          ),
          child: const Text(
            'Explore focused information about guso and learn about '
            'the visible characteristics that support image-based '
            'quality assessment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 17,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedGusoLayout extends StatelessWidget {
  const _FeaturedGusoLayout({
    required this.seaweed,
    required this.isDesktop,
    required this.isMobile,
  });

  final SeaweedInfo seaweed;
  final bool isDesktop;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return SizedBox(
        height: 430,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 11,
              child: _GusoImagePanel(
                seaweed: seaweed,
              ),
            ),

            const SizedBox(width: 34),

            Expanded(
              flex: 9,
              child: _GusoInformationPanel(
                seaweed: seaweed,
                fillHeight: true,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: isMobile ? 290 : 360,
          child: _GusoImagePanel(
            seaweed: seaweed,
          ),
        ),

        const SizedBox(height: 24),

        _GusoInformationPanel(
          seaweed: seaweed,
          fillHeight: false,
        ),
      ],
    );
  }
}

class _GusoImagePanel extends StatelessWidget {
  const _GusoImagePanel({
    required this.seaweed,
  });

  final SeaweedInfo seaweed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppRadius.extraLarge,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.76,
          ),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.08,
            ),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppRadius.extraLarge - 1,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              seaweed.imagePath,
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
                    Color(0x08001000),
                    Color(0x33001000),
                    Color(0xD9001000),
                  ],
                  stops: [
                    0.0,
                    0.55,
                    1.0,
                  ],
                ),
              ),
            ),

            Positioned(
              top: 22,
              left: 22,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(
                    alpha: 0.88,
                  ),
                  borderRadius: BorderRadius.circular(
                    50,
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(
                      alpha: 0.72,
                    ),
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
                      'Guso',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withValues(
                    alpha: 0.90,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppRadius.large,
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(
                      alpha: 0.35,
                    ),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.image_search_outlined,
                      color: AppColors.primary,
                      size: 25,
                    ),

                    SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Image-Based Guso Learning',
                            style: TextStyle(
                              color:
                                  AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'Learn what visible characteristics matter when assessing guso quality.',
                            style: TextStyle(
                              color: AppColors
                                  .textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GusoInformationPanel extends StatelessWidget {
  const _GusoInformationPanel({
    required this.seaweed,
    required this.fillHeight,
  });

  final SeaweedInfo seaweed;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: fillHeight ? double.infinity : null,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppRadius.extraLarge,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.48,
          ),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10350C),
            Color(0xFF092507),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.055,
            ),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.verified_outlined,
                color: AppColors.primary,
                size: 21,
              ),

              SizedBox(width: 9),

              Text(
                'FEATURED GUSO',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            seaweed.scientificName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _displayName(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'The Guso Guide provides focused educational information '
            'about the visible characteristics and quality indicators '
            'relevant to image-based assessment.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.65,
            ),
          ),

          const SizedBox(height: 26),

          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _GuideChip(
                icon: Icons.palette_outlined,
                label: 'Color',
              ),
              _GuideChip(
                icon: Icons.texture_outlined,
                label: 'Texture',
              ),
              _GuideChip(
                icon: Icons.eco_outlined,
                label: 'Freshness',
              ),
              _GuideChip(
                icon: Icons.image_outlined,
                label: 'Image Condition',
              ),
            ],
          ),

          if (fillHeight)
            const Spacer()
          else
            const SizedBox(height: 30),

          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) {
                    return SeaweedDetailScreen(
                      seaweed: seaweed,
                    );
                  },
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  AppColors.textPrimary,
              side: BorderSide(
                color: AppColors.primary.withValues(
                  alpha: 0.72,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 16,
              ),
            ),
            icon: const Icon(
              Icons.arrow_forward_rounded,
            ),
            label: const Text(
              'VIEW GUSO DETAILS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayName() {
    if (seaweed.bisayaName.trim().isNotEmpty) {
      return seaweed.bisayaName;
    }

    if (seaweed.filipinoName.trim().isNotEmpty) {
      return seaweed.filipinoName;
    }

    return seaweed.englishName;
  }
}

class _GuideChip extends StatelessWidget {
  const _GuideChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(
          alpha: 0.75,
        ),
        borderRadius: BorderRadius.circular(
          50,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 16,
          ),

          const SizedBox(width: 7),

          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideActionStrip extends StatelessWidget {
  const _GuideActionStrip({
    required this.onExploreGuidePressed,
    required this.isMobile,
  });

  final VoidCallback onExploreGuidePressed;
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
            alpha: 0.60,
          ),
        ),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF0B2608),
            Color(0xFF143D0F),
            Color(0xFF092107),
          ],
        ),
      ),
      child: isMobile
          ? Column(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.primary,
                  size: 34,
                ),

                const SizedBox(height: 14),

                const Text(
                  'Explore focused information about Guso.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 18),

                _ExploreButton(
                  onPressed:
                      onExploreGuidePressed,
                ),
              ],
            )
          : Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.primary,
                  size: 38,
                ),

                const SizedBox(width: 22),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continue Exploring Guso',
                        style: TextStyle(
                          color:
                              AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Open the complete guide for focused guso information and educational details.',
                        style: TextStyle(
                          color: AppColors
                              .textSecondary,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                _ExploreButton(
                  onPressed:
                      onExploreGuidePressed,
                ),
              ],
            ),
    );
  }
}

class _ExploreButton extends StatelessWidget {
  const _ExploreButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ButtonStyle(
        elevation:
            const WidgetStatePropertyAll(0),

        backgroundColor:
            WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(
              WidgetState.hovered,
            )) {
              return Colors.white;
            }

            return AppColors.primary;
          },
        ),

        foregroundColor:
            const WidgetStatePropertyAll(
          Colors.black,
        ),

        padding:
            const WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),

        shape:
            WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.medium,
            ),
          ),
        ),
      ),
      icon: const Icon(
        Icons.arrow_forward_rounded,
      ),
      label: const Text(
        'EXPLORE SEAWEED GUIDE',
        style: TextStyle(
          fontWeight: FontWeight.bold,
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
            Color(0xFF164515),
            Color(0xFF092608),
            Color(0xFF041304),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          color: AppColors.primary.withValues(
            alpha: 0.24,
          ),
          size: 140,
        ),
      ),
    );
  }
}

class _FallbackPanel extends StatelessWidget {
  const _FallbackPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 300,
      ),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppRadius.extraLarge,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.50,
          ),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10350C),
            Color(0xFF092507),
          ],
        ),
      ),
      child: const Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_outlined,
            color: AppColors.primary,
            size: 50,
          ),

          SizedBox(height: 18),

          Text(
            'Guso Guide',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 10),

          Text(
            'Focused Guso information will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideBackground extends StatelessWidget {
  const _GuideBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: -240,
          top: -160,
          child: Container(
            width: 540,
            height: 540,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(
                alpha: 0.032,
              ),
            ),
          ),
        ),

        Positioned(
          right: -280,
          bottom: -300,
          child: Container(
            width: 700,
            height: 700,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(
                alpha: 0.045,
              ),
            ),
          ),
        ),

        Positioned(
          right: 40,
          top: 80,
          child: Transform.rotate(
            angle: 0.32,
            child: Icon(
              Icons.eco_rounded,
              size: 240,
              color: AppColors.primary.withValues(
                alpha: 0.025,
              ),
            ),
          ),
        ),

        Positioned(
          left: 80,
          bottom: -40,
          child: Transform.rotate(
            angle: -0.45,
            child: Icon(
              Icons.eco_rounded,
              size: 220,
              color: AppColors.primary.withValues(
                alpha: 0.032,
              ),
            ),
          ),
        ),
      ],
    );
  }
}