import 'package:flutter/material.dart';
import '../authentication/signup.dart'; // Pastikan path ini benar

// Import semua step onboarding
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

  void goToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SignupPage(
              age: age,
              gender: gender ?? '',
              height: height,
              weight: weight,
              goal: goal ?? '',
              targetWeight: targetWeight,
              pace: pace,
              activityLevel: activityLevel ?? '',
              reminders: reminders,
            ),
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
        return StepReady(onGetStarted: goToSignup);
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan progress bar dan tombol kembali
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: prevStep,
                  ),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: (step + 1) / 11),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.black12,
                          color: Colors.black87,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Widget step yang sedang aktif
            Expanded(child: getStepWidget()),
            // Tombol Next
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child:
                    step == 10
                        ? const SizedBox.shrink()
                        : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: nextStep,
                          child: const Text(
                            'Next',
                            style: TextStyle(fontSize: 16),
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
