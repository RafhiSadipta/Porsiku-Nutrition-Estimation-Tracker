import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:porsiku/view/authentication/signup.dart';
import 'steps/step_intro.dart';
import 'steps/step_gender.dart';
import 'steps/step_age.dart';
import 'steps/step_height.dart';
import 'steps/step_weight.dart';
import 'steps/step_goal.dart';
import 'steps/step_weight_goal.dart';
import 'steps/step_goal_pace.dart';
import 'steps/step_activity_level.dart';
import 'steps/step_ready.dart';
import '../../components/button.dart';
import '../../constants/constants.dart';

class OnboardingFormPage extends StatefulWidget {
  const OnboardingFormPage({super.key});

  @override
  State<OnboardingFormPage> createState() => _OnboardingFormPageState();
}

class _OnboardingFormPageState extends State<OnboardingFormPage>
    with TickerProviderStateMixin {
  int step = 0;
  String? goal;
  String? gender;
  int age = 23;
  int height = 170;
  int weight = 60;
  int targetWeight = 65;
  String pace = '0.02kg/week';
  String? activityLevel;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void nextStep() {
    if (step < 9) {
      HapticFeedback.lightImpact();
      _slideController.reverse().then((_) {
        setState(() => step++);
        _slideController.forward();
      });
    }
  }

  void prevStep() {
    if (step > 0) {
      HapticFeedback.lightImpact();
      _slideController.reverse().then((_) {
        setState(() => step--);
        _slideController.forward();
      });
    }
  }

  /// Saat submit onboarding selesai, arahkan ke SignupPage dengan data dikirim
  void submitOnboardingData() {
    final Map<String, dynamic> onboardingData = {
      'goal': goal,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'pace': pace,
      'activityLevel': activityLevel,
    };

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SignupPage(onboardingData: onboardingData),
      ),
    );
  }

  Widget getStepWidget() {
    switch (step) {
      case 0:
        return const StepIntro();
      case 1:
        return StepGoal(
          selectedGoal: goal,
          onGoalSelected: (g) => setState(() => goal = g),
        );
      case 2:
        return StepGender(
          selectedGender: gender,
          onGenderSelected: (g) => setState(() => gender = g),
        );
      case 3:
        return StepAge(
          selectedAge: age,
          onAgeChanged: (i) => setState(() => age = 10 + i),
        );
      case 4:
        return StepHeight(
          selectedHeight: height,
          onHeightChanged: (i) => setState(() => height = 100 + i),
        );
      case 5:
        return StepWeight(
          selectedWeight: weight,
          onWeightChanged: (i) => setState(() => weight = 30 + i),
        );
      case 6:
        return StepWeightGoal(
          currentWeight: weight,
          targetWeight: targetWeight,
          onTargetWeightChanged: (i) => setState(() => targetWeight = 30 + i),
        );
      case 7:
        return StepGoalPace(
          selectedPace: pace,
          onPaceChanged: (p) => setState(() => pace = p),
        );
      case 8:
        return StepActivityLevel(
          selectedLevel: activityLevel,
          onLevelSelected: (l) => setState(() => activityLevel = l),
        );
      case 9:
        return StepReady(onGetStarted: submitOnboardingData);
      default:
        return const SizedBox();
    }
  }

  bool _isStepValid() {
    switch (step) {
      case 1:
        return goal != null;
      case 2:
        return gender != null;
      case 3:
        return age > 0;
      case 4:
        return height > 0;
      case 5:
        return weight > 0;
      case 6:
        return targetWeight > 0;
      case 7:
        return pace.isNotEmpty;
      case 8:
        return activityLevel != null;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header with Progress
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (step > 0) ...[
                        _EnhancedBackButton(onPressed: prevStep),
                        SizedBox(width: AppSpacing.md),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Langkah ${step + 1} dari 10',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            _EnhancedProgressBar(step: step, totalSteps: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content with Animation
            Expanded(
              child: AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: getStepWidget(),
                    ),
                  );
                },
              ),
            ),

            // Enhanced Bottom Action
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  child: Button(
                    text: step == 9 ? "Mulai Perjalanan" : 'Lanjutkan',
                    variant: ButtonVariant.primary,
                    isActive: step == 9 ? true : _isStepValid(),
                    onPressed:
                        step == 9
                            ? submitOnboardingData
                            : (_isStepValid() ? nextStep : null),
                    icon:
                        step == 9
                            ? Icon(
                              Icons.rocket_launch_rounded,
                              size: 18,
                              color: AppColors.white,
                            )
                            : Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: AppColors.white,
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Components for Premium UI/UX
class _EnhancedBackButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const _EnhancedBackButton({required this.onPressed});

  @override
  State<_EnhancedBackButton> createState() => _EnhancedBackButtonState();
}

class _EnhancedBackButtonState extends State<_EnhancedBackButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.lightGrey.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onPressed?.call();
                },
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EnhancedProgressBar extends StatelessWidget {
  final int step;
  final int totalSteps;

  const _EnhancedProgressBar({required this.step, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getStepTitle(step),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${((step + 1) / totalSteps * 100).round()}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: (step + 1) / totalSteps),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                color: AppColors.lightGrey.withOpacity(0.3),
              ),
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * value,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Selamat Datang';
      case 1:
        return 'Tujuan Anda';
      case 2:
        return 'Jenis Kelamin';
      case 3:
        return 'Usia';
      case 4:
        return 'Tinggi Badan';
      case 5:
        return 'Berat Badan';
      case 6:
        return 'Target Berat';
      case 7:
        return 'Kecepatan Target';
      case 8:
        return 'Aktivitas Harian';
      case 9:
        return 'Siap Dimulai';
      default:
        return 'Langkah ${step + 1}';
    }
  }
}
