import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/support_chat_cubit/support_chat_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomPickAndUploadMessageImage extends StatelessWidget {
  const CustomPickAndUploadMessageImage({
    super.key,
    required this.supportChatMessageImage,
  });

  final String supportChatMessageImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SupportChatCubit, SupportChatState>(
      buildWhen: (previous, current) =>
          current is PickAndUploadMessageImageSuccess ||
          current is PickAndUploadMessageImageFailure ||
          current is PickAndUploadMessageImageLoading,
      builder: (context, state) {
        String displayUrl = supportChatMessageImage;

        if (state is PickAndUploadMessageImageSuccess &&
            state.imageUrl.isNotEmpty) {
          displayUrl = state.imageUrl;
        }

        return AspectRatio(
          aspectRatio: 4 / 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildMainContent(context, state, displayUrl, theme),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    SupportChatState state,
    String url,
    ThemeData theme,
  ) {
    bool isLoading = state is PickAndUploadMessageImageLoading;

    if (url.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          InkWell(
            onTap: () => context.read<SupportChatCubit>().pickAndUplaodImage(),
            child: CustomCachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
          ),
          if (isLoading) _buildLoadingOverlay(),
          _buildEditBadge(theme),
        ],
      );
    }

    return Skeletonizer(
      enabled: isLoading,
      child: InkWell(
        onTap: () => context.read<SupportChatCubit>().pickAndUplaodImage(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: theme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
    );
  }

  Widget _buildEditBadge(ThemeData theme) {
    return Positioned(
      right: 8,
      top: 8,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.edit, size: 16, color: Colors.white),
      ),
    );
  }
}
