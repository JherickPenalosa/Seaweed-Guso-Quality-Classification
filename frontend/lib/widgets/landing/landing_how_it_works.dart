import 'package:flutter/material.dart';

import '../../app/theme.dart';

class LandingHowItWorks extends StatelessWidget {
  const LandingHowItWorks({
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

        final verticalPadding = isMobile ? 76.0 : 100.0;

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF061A06), Color(0xFF0B300B), Color(0xFF051505)],
              stops: [0.0, 0.50, 1.0],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: IgnorePointer(child: _HowItWorksBackground()),
              ),

              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      children: [
                        const _SectionHeader(),

                        SizedBox(height: isMobile ? 42 : 58),

                        _ProcessLayout(
                          isDesktop: isDesktop,
                          isMobile: isMobile,
                        ),

                        SizedBox(height: isMobile ? 34 : 46),

                        _WorkflowStrip(isMobile: isMobile),
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
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.75),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_tree_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'HOW IT WORKS',
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
              TextSpan(text: 'From Image to Clear '),
              TextSpan(
                text: 'Guso',
                style: TextStyle(color: AppColors.primary),
              ),
              TextSpan(text: ' Quality Insights'),
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
          constraints: const BoxConstraints(maxWidth: 860),
          child: const Text(
            'gUSo keeps the classification process simple. Upload a clear '
            'guso image, let the system analyze its visible characteristics, '
            'and review the structured result.',
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

class _ProcessLayout extends StatelessWidget {
  const _ProcessLayout({required this.isDesktop, required this.isMobile});

  final bool isDesktop;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final steps = [
      const _ProcessStep(
        number: '01',
        icon: Icons.upload_file_outlined,
        title: 'Upload',
        description:
            'Choose a clear image of the guso sample you want to assess.',
      ),
      const _ProcessStep(
        number: '02',
        icon: Icons.image_search_outlined,
        title: 'Analyze',
        description: 'The system processes visible image characteristics for classification.',
      ),
      const _ProcessStep(
        number: '03',
        icon: Icons.bar_chart_rounded,
        title: 'View Results',
        description: 'Review quality, freshness, confidence, image condition, and visible traits.',
      ),
      const _ProcessStep(
        number: '04',
        icon: Icons.bookmark_border_rounded,
        title: 'Save or Continue',
        description: 'Save the result for later review or upload another image for assessment.',
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          for (int index = 0; index < steps.length; index++) ...[
            steps[index],
            if (index < steps.length - 1) ...[
              const SizedBox(height: 14),
              const _VerticalConnector(),
              const SizedBox(height: 14),
            ],
          ],
        ],
      );
    }

    if (!isDesktop) {
      return Wrap(
        spacing: 22,
        runSpacing: 22,
        children: [
          for (final step in steps)
            SizedBox(width: 330, height: 320, child: step),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: SizedBox(height: 328, child: steps[0])),

        const _HorizontalConnector(),

        Expanded(child: SizedBox(height: 328, child: steps[1])),

        const _HorizontalConnector(),

        Expanded(child: SizedBox(height: 328, child: steps[2])),

        const _HorizontalConnector(),

        Expanded(child: SizedBox(height: 328, child: steps[3])),
      ],
    );
  }
}

class _ProcessStep extends StatefulWidget {
  const _ProcessStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String number;
  final IconData icon;
  final String title;
  final String description;

  @override
  State<_ProcessStep> createState() => _ProcessStepState();
}

class _ProcessStepState extends State<_ProcessStep> {
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
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        transform: Matrix4.translationValues(0, _hovered ? -5 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.95)
                : AppColors.primary.withValues(alpha: 0.48),
            width: _hovered ? 1.5 : 1.1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _hovered
                ? const [Color(0xFF16480F), Color(0xFF0B2C08)]
                : const [Color(0xFF10350C), Color(0xFF092507)],
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.11),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ]
              : const [],
        ),
        child: Stack(
          children: [
            Positioned(
              left: -36,
              bottom: -48,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.025),
                ),
              ),
            ),

            Positioned(
              right: -18,
              bottom: -24,
              child: Icon(
                Icons.eco_rounded,
                size: 145,
                color: AppColors.primary.withValues(alpha: 0.045),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      widget.number,
                      style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.76),
                        fontSize: 31,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
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

class _HorizontalConnector extends StatelessWidget {
  const _HorizontalConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.18),
                    AppColors.primary.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),

          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF061806),
              border: Border.all(color: AppColors.primary, width: 1.6),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 21,
            ),
          ),

          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.85),
                    AppColors.primary.withValues(alpha: 0.18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalConnector extends StatelessWidget {
  const _VerticalConnector();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 1.4,
          height: 20,
          color: AppColors.primary.withValues(alpha: 0.55),
        ),

        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF061806),
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
            size: 21,
          ),
        ),

        Container(
          width: 1.4,
          height: 20,
          color: AppColors.primary.withValues(alpha: 0.55),
        ),
      ],
    );
  }
}

class _WorkflowStrip extends StatelessWidget {
  const _WorkflowStrip({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 940),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 30,
        vertical: isMobile ? 20 : 22,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.68)),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF0A2408), Color(0xFF153F10), Color(0xFF0A2208)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
          ),
        ],
      ),
      child: isMobile
          ? const Column(
              children: [
                Icon(
                  Icons.science_outlined,
                  color: AppColors.primary,
                  size: 34,
                ),
                SizedBox(height: 12),
                Text(
                  'A simple, research-oriented workflow for guso quality assessment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.science_outlined,
                  color: AppColors.primary,
                  size: 35,
                ),

                SizedBox(width: 22),

                SizedBox(
                  height: 40,
                  child: VerticalDivider(color: AppColors.disabled),
                ),

                SizedBox(width: 22),

                Flexible(
                  child: Text(
                    'A simple, research-oriented workflow for guso quality assessment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _HowItWorksBackground extends StatelessWidget {
  const _HowItWorksBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -220,
          left: -120,
          child: Container(
            width: 560,
            height: 420,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.07),
                width: 1.2,
              ),
            ),
          ),
        ),

        Positioned(
          top: -150,
          left: -40,
          child: Transform.rotate(
            angle: -0.20,
            child: Container(
              width: 660,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.045),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          right: -240,
          top: 130,
          child: Container(
            width: 520,
            height: 520,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.032),
            ),
          ),
        ),

        Positioned(
          left: -70,
          bottom: -70,
          child: Transform.rotate(
            angle: -0.55,
            child: Icon(
              Icons.eco_rounded,
              size: 250,
              color: AppColors.primary.withValues(alpha: 0.055),
            ),
          ),
        ),

        Positioned(
          right: -50,
          bottom: -90,
          child: Transform.rotate(
            angle: 0.55,
            child: Icon(
              Icons.eco_rounded,
              size: 280,
              color: AppColors.primary.withValues(alpha: 0.050),
            ),
          ),
        ),
      ],
    );
  }
}
