import 'package:flutter/material.dart';
import '../blocs/tutorial/cubit.dart';
import '../models/tutorial_step.dart';
import 'tutorial_steps.dart';

class TutorialRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final TutorialCubit cubit;

  TutorialRouteObserver(this.cubit);

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _maybeAdvance(route: route, previousRoute: previousRoute, isPop: false);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _maybeAdvance(route: route, previousRoute: previousRoute, isPop: true);
  }

  void _maybeAdvance({
    required Route route,
    required Route? previousRoute,
    required bool isPop,
  }) {
    if (!cubit.state.isActive) return;

    final steps = getTutorialSteps();
    final index = cubit.state.currentStepIndex;
    if (index < 0 || index >= steps.length) return;

    final currentStep = steps[index];
    final newRouteName = isPop ? previousRoute?.settings.name : route.settings.name;

    // Steps that advance on push to a specific route
    final pushAdvances = <String, String>{
      'create_first_template': '/templateEditor',
      'create_second_template': '/templateEditor',
      'create_instance': '/instanceEditor',
      'create_child_instance': '/instanceEditor',
      'create_another_child': '/instanceEditor',
      'navigate_into_instance': '/instanceEditor',
    };

    // Steps that advance on pop to a specific route
    final popAdvances = <String, String>{
      'save_template': '/',
      'navigate_back': '/',
      'confirm_delete_child': '/instanceEditor',
      'confirm_cascade_delete': '/',
    };

    final expectedRoute = isPop ? popAdvances[currentStep.id] : pushAdvances[currentStep.id];

    if (expectedRoute != null && expectedRoute == newRouteName) {
      cubit.nextStep();
    }
  }
}
