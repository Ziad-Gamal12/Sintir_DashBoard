// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';

class CustomVideoControllerBetter {
  BetterPlayerController? betterPlayerController;
  bool isInitialized = false;

  Future<void> initializeVideo({
    required String? videoUrl,
    required File? file,
    required VoidCallback? onUpdate,
    ValueChanged<Duration>? onDurationChanged,
    required BuildContext context,
  }) async {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    try {
      if (videoUrl == null && file == null) {
        throw Exception("الفيديو غير موجود");
      }

      BetterPlayerDataSource dataSource;
      if (file != null) {
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          file.path,
        );
      } else {
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          videoUrl!,
        );
      }

      BetterPlayerConfiguration betterPlayerConfiguration =
          BetterPlayerConfiguration(
            autoPlay: true,
            looping: false,
            allowedScreenSleep: false,
            fit: BoxFit.contain,
            aspectRatio: 16 / 9,
            controlsConfiguration: BetterPlayerControlsConfiguration(
              enablePlaybackSpeed: true,
              enableSkips: true,
              enableFullscreen: true,
              enableMute: true,
              // Theme-aware colors
              controlBarColor: theme.colorScheme.surface.withOpacity(0.8),
              textColor: theme.textTheme.bodyLarge?.color ?? Colors.white,
              progressBarPlayedColor: theme.colorScheme.primary,
              progressBarHandleColor: theme.colorScheme.primary,
              progressBarBufferedColor:
                  theme.textTheme.bodyMedium?.color?.withOpacity(0.5) ??
                  Colors.white70,
              progressBarBackgroundColor: theme.dividerColor,
              liveTextColor: isDarkMode
                  ? Colors.red.shade400
                  : Colors.redAccent,
              loadingColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface.withOpacity(0.5),
              overflowModalColor: theme.cardColor,
              overflowModalTextColor:
                  theme.textTheme.bodyLarge?.color ?? Colors.white,
              overflowMenuIconsColor: theme.colorScheme.primary,
            ),
            errorBuilder: (context, errorMessage) {
              final theme = Theme.of(context);
              CustomSnackBar.show(
                context,
                message: "$errorMessage",
                type: SnackType.error,
              );
              return Center(
                child: Text(
                  errorMessage ?? "فشل تشغيل الفيديو",
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                  ),
                ),
              );
            },
          );

      betterPlayerController = BetterPlayerController(
        betterPlayerConfiguration,
      );

      await betterPlayerController!.setupDataSource(dataSource);

      if (onDurationChanged != null) {
        final duration =
            betterPlayerController!.videoPlayerController?.value.duration;
        if (duration != null) onDurationChanged(duration);
      }

      isInitialized = true;
      onUpdate?.call();
    } catch (e) {
      CustomSnackBar.show(
        context,
        message: "الفيديو غير مدعوم",
        type: SnackType.error,
      );
      isInitialized = false;
      onUpdate?.call();
      debugPrint("⚠️ CustomVideoControllerBetter Error: $e");
    }
  }

  void dispose() {
    betterPlayerController?.dispose();
    betterPlayerController = null;
    isInitialized = false;
  }
}
