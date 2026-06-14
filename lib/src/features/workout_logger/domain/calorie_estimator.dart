/// MET-based calorie estimator for resistance training.
/// Returns null if [bodyWeightKg] is not positive.
int? estimateKcal({
  required double bodyWeightKg,
  required Duration duration,
}) {
  if (bodyWeightKg <= 0) return null;
  return (5.0 * bodyWeightKg * duration.inMinutes / 60).round();
}
