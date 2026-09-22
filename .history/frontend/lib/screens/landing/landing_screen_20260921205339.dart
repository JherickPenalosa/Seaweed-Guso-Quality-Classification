import 'package:flutter/material.dart';

import '../../app/theme.dart';

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
              _LandingHeader(
                desktopBreakpoint: _desktopBreakpoint,
                mobileBreakpoint: _mobileBreakpoint,
                maxContentWidth: _maxContentWidth,
              ),
              _HeroSection(
                desktopBreakpoint: _desktopBreakpoint,
                mobileBreakpoint: _mobileBreakpoint,
                maxContentWidth: _maxContentWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingHeader extends StatelessWidget {
  const _LandingHeader({
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

        final isMobile = width < mobileBreakpoint;
        final isDesktop = width >= desktopBreakpoint;

        final horizontalPadding = isDesktop
            ? 64.0
            : isMobile
                ? 20.0
                : 36.0;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 22,
              ),
              child: Row(
                children: [
                  const _GusoLogo(),

                  const Spacer(),

                  if (!isMobile) ...[
                    _NavigationButton(
                      label: 'Home',
                      onPressed: () {},
                    ),
                    _NavigationButton(
                      label: 'About',
                      onPressed: () {},
                    ),
                    _NavigationButton(
                      label: 'How It Works',
                      onPressed: () {},
                    ),
                    _NavigationButton(
                      label: 'Seaweed Guide',
                      onPressed: () {},
                    ),
                    const SizedBox(width: 24),
                  ],

                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20 : 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppRadius.medium,
                        ),
                      ),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (isMobile) ...[
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      tooltip: 'Menu',
                      color: AppColors.surface,
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: AppColors.textPrimary,
                        size: 28,
                      ),
                      onSelected: (_) {},
                      itemBuilder: (context) {
                        return const [
                          PopupMenuItem(
                            value: 'home',
                            child: Text('Home'),
                          ),
                          PopupMenuItem(
                            value: 'about',
                            child: Text('About'),
                          ),
                          PopupMenuItem(
                            value: 'workflow',
                            child: Text('How It Works'),
                          ),
                          PopupMenuItem(
                            value: 'guide',
                            child: Text('Seaweed Guide'),
                          ),
                        ];
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GusoLogo extends StatelessWidget {
  const _GusoLogo();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'g',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -2,
            ),
          ),
          TextSpan(
            text: 'US',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -2,
            ),
          ),
          TextSpan(
            text: 'o',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -2,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
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

        final verticalPadding = isMobile ? 54.0 : 82.0;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                isMobile ? 70 : 110,
              ),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          flex: 11,
                          child: _HeroContent(),
                        ),
                        const SizedBox(width: 70),
                        Expanded(
                          flex: 9,
                          child: _HeroVisual(
                            compact: false,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _HeroContent(),
                        SizedBox(
                          height: isMobile ? 48 : 64,
                        ),
                        _HeroVisual(
                          compact: isMobile,
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        double headlineSize;

        if (availableWidth >= 650) {
          headlineSize = 64;
        } else if (availableWidth >= 450) {
          headlineSize = 50;
        } else {
          headlineSize = 40;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(
                  AppRadius.extraLarge,
                ),
                border: Border.all(
                  color: AppColors.borderPrimary.withValues(
                    alpha: 0.45,
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
                    'AI-POWERED SEAWEED ANALYSIS',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Know Your Guso.\n',
                  ),
                  TextSpan(
                    text: 'Understand Its Quality.',
                    style: const TextStyle(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: headlineSize,
                height: 1.04,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.8,
              ),
            ),

            const SizedBox(height: 26),

            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 650,
              ),
              child: const Text(
                'Upload an image of Guso and receive structured insights '
                'about its quality, freshness, image condition, and '
                'observable characteristics.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  height: 1.65,
                ),
              ),
            ),

            const SizedBox(height: 36),

            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                  ),
                  label: const Text(
                    'GET STARTED',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.menu_book_outlined,
                  ),
                  label: const Text(
                    'EXPLORE SEAWEED GUIDE',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 34),

            const Wrap(
              spacing: 28,
              runSpacing: 16,
              children: [
                _HeroMiniFeature(
                  icon: Icons.photo_camera_outlined,
                  label: 'Image-based analysis',
                ),
                _HeroMiniFeature(
                  icon: Icons.spa_outlined,
                  label: 'Quality & freshness',
                ),
                _HeroMiniFeature(
                  icon: Icons.science_outlined,
                  label: 'Research-oriented',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _HeroMiniFeature extends StatelessWidget {
  const _HeroMiniFeature({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 19,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual({
    required this.compact,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cardHeight = compact ? 390.0 : 500.0;

    return Container(
      constraints: BoxConstraints(
        minHeight: cardHeight,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.extraLarge,
        ),
        border: Border.all(
          color: AppColors.borderPrimary,
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: compact ? 30 : 42,
            right: compact ? 24 : 38,
            child: Container(
              width: compact ? 78 : 100,
              height: compact ? 78 : 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(
                  alpha: 0.08,
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(
                    alpha: 0.24,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: compact ? 40 : 54,
            left: compact ? 20 : 34,
            child: Container(
              width: compact ? 60 : 82,
              height: compact ? 60 : 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(
                  alpha: 0.07,
                ),
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: EdgeInsets.all(
                compact ? 24 : 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: compact ? 112 : 145,
                    height: compact ? 112 : 145,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(
                        AppRadius.extraLarge,
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.spa_outlined,
                      size: compact ? 62 : 82,
                      color: AppColors.primary,
                    ),
                  ),

                  SizedBox(
                    height: compact ? 28 : 38,
                  ),

                  const Text(
                    'Guso Quality Preview',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'A preview of the structured information '
                    'the classification system can present.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(
                    height: compact ? 24 : 32,
                  ),

                  const _PreviewResultRow(
                    label: 'Quality',
                    value: 'Class A',
                  ),

                  const SizedBox(height: 12),

                  const _PreviewResultRow(
                    label: 'Freshness',
                    value: 'Fresh',
                  ),

                  const SizedBox(height: 12),

                  const _PreviewResultRow(
                    label: 'Image Quality',
                    value: 'Clear',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewResultRow extends StatelessWidget {
  const _PreviewResultRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(
          AppRadius.medium,
        ),
        border: Border.all(
          color: AppColors.disabled,
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}