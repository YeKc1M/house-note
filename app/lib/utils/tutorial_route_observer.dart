import 'package:flutter/material.dart';
import '../blocs/tutorial/cubit.dart';
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

    final index = cubit.state.currentStepIndex;
    if (index < 0 || index >= tutorialSteps.length) return;

    final currentStep = tutorialSteps[index];
    final newRouteName = isPop ? previousRoute?.settings.name : route.settings.name;

    final expectedRoute = isPop ? currentStep.expectedRoute : currentStep.expectedRoute;

    if (expectedRoute != null && expectedRoute == newRouteName) {
      cubit.nextStep();
      return;
    }

    if (!isPop && route is DialogRoute && currentStep.advanceOnDialog) {
      cubit.nextStep();
    }
  }
}
