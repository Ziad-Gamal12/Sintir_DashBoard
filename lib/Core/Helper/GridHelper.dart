class GridHelper {
  static int getCrossAxisCount(double maxWidth) {
    if (maxWidth >= 1024) return 5;
    if (maxWidth >= 900) return 4;
    if (maxWidth >= 600) return 3;
    return 2;
  }

  static double getAspectRatio({required double maxWidth}) {
    final crossAxisCount = getCrossAxisCount(maxWidth);
    final freeSpaceCount = crossAxisCount - 1;
    const spacing = 10.0;

    final freeSpaceWidth = spacing * freeSpaceCount;
    final availableWidth = maxWidth - freeSpaceWidth;
    final itemWidth = availableWidth / crossAxisCount;
    final itemHeight = itemWidth / 0.75;

    return itemWidth / itemHeight;
  }
}
