import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Step indicator showing progress through onboarding
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps;
    final currentLabel = currentStep < stepLabels.length ? stepLabels[currentStep] : '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          Stack(
            children: [
              // Background
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Progress
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 6,
                width: MediaQuery.of(context).size.width * progress * 0.85,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Step dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;
              return _buildStepDot(
                isCompleted: isCompleted,
                isCurrent: isCurrent,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot({
    required bool isCompleted,
    required bool isCurrent,
  }) {
    return Container(
      width: isCurrent ? 12 : 8,
      height: isCurrent ? 12 : 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? AppColors.primaryGreen
            : isCurrent
                ? AppColors.primaryGreen
                : AppColors.lightGray,
        border: isCurrent
            ? Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3), width: 3)
            : null,
      ),
    );
  }
}

