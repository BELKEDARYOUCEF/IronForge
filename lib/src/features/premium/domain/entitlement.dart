enum PremiumFeature {
  unlimitedWorkoutExercises,
  advancedAnalytics,
  cloudSync,
  aiInsights,
  exportData,
  customThemes,
}

class Entitlement {
  const Entitlement({required this.isPremium});

  final bool isPremium;

  bool canUse(PremiumFeature feature) {
    return isPremium;
  }
}

