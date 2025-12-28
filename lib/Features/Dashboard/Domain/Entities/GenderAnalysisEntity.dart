class GenderAnalysisEntity {
  final double malePercentage, femalePercentage;
  final int maleCount, femaleCount;
  GenderAnalysisEntity({
    required this.malePercentage,
    required this.femalePercentage,
    required this.maleCount,
    required this.femaleCount,
  });

  static GenderAnalysisEntity empty() {
    return GenderAnalysisEntity(
      malePercentage: 0.0,
      femalePercentage: 0.0,
      maleCount: 0,
      femaleCount: 0,
    );
  }
}
