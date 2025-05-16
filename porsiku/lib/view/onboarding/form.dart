import 'package:flutter/material.dart';
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
import 'steps/step_reminder.dart';
import 'steps/step_ready.dart';
import '../../components/primary_button.dart';
import '../../components/back_button.dart';
import '../../components/progressbar.dart';

class OnboardingFormPage extends StatefulWidget {
  const OnboardingFormPage({super.key});

  @override
  State<OnboardingFormPage> createState() => _OnboardingFormPageState();
}

class _OnboardingFormPageState extends State<OnboardingFormPage> {
  int step = 0;
  String? goal;
  String? gender;
  int age = 23;
  int height = 170;
  int weight = 60;
  int targetWeight = 65;
  String pace = '0.02kg/week';
  String? activityLevel;
  List<String> reminders = ['breakfast', 'lunch', 'dinner'];

  void nextStep() {
    if (step < 10) {
      setState(() => step++);
    }
  }

  void prevStep() {
    if (step > 0) {
      setState(() => step--);
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
      'reminders': reminders,
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
        return StepReminder(
          selectedMeals: reminders,
          onMealTap: (meal) {
            setState(() {
              if (reminders.contains(meal)) {
                reminders.remove(meal);
              } else {
                reminders.add(meal);
              }
            });
          },
        );
      case 10:
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
      case 9:
        return reminders.isNotEmpty;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (step > 0) ...[
                    BackButtonCustom(onPressed: prevStep),
                    const SizedBox(width: 16),
                  ],
                  Expanded(child: ProgressBarOnboarding(step: step)),
                ],
              ),
            ),
            Expanded(child: getStepWidget()),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: step == 10 ? "Let's Get Started" : 'Next',
                  isActive: step == 10 ? true : _isStepValid(),
                  onPressed:
                      step == 10
                          ? submitOnboardingData
                          : (_isStepValid() ? nextStep : null),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
