import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AnalyzingOverlay extends StatelessWidget {
  final Widget child;
  final bool isAnalyzing;

  const AnalyzingOverlay({
    super.key,
    required this.child,
    required this.isAnalyzing,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,

        if (isAnalyzing)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(
                  AppRadius.large - 2,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        color: AppColors.primary,
                      ),
                    ),

                    SizedBox(height: 24),

                    Text(
                      'ANALYZING...',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Processing the uploaded image',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}