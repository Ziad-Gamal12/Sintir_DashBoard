import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/SubscriberEntity.dart';
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSubscribersCubit/CourseSubscribersCubit.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/IconInfoRow.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/SubscriberActionSection.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/SubscriberAvatar.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/SubscriberDetails.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/SubscriberGenderBadge.dart';

class SubscriberPremiumCard extends StatelessWidget {
  final SubscriberEntity subscriber;
  final VoidCallback onDelete;
  final VoidCallback onNavigate;

  const SubscriberPremiumCard({
    super.key,
    required this.subscriber,
    required this.onDelete,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = AppTextStyles(context);
    return BlocListener<CourseSubscribersCubit, CourseSubscribersState>(
      listener: (context, state) {
        if (state is DeleteSubscriberFailure) {
          CustomSnackBar.show(
            context,
            message: state.errMessage,
            type: SnackType.error,
          );
        } else if (state is DeleteSubscriberSuccess &&
            state.subscriberId == subscriber.id) {
          CustomSnackBar.show(
            context,
            message: "تم حذف المستخدم بنجاح",
            type: SnackType.success,
          );
          context.read<CourseSubscribersCubit>().subscribers.removeWhere(
            (element) => element.id == subscriber.id,
          );
        }
      },
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(
            bottom: BorderSide(color: theme.dividerColor.withOpacity(0.05)),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 950) {
              return _buildDesktop(context, styles);
            }
            return _buildCompact(context);
          },
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context, AppTextStyles styles) {
    final isMale =
        subscriber.gender.toLowerCase().contains('m') ||
        subscriber.gender.contains('ذكر');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SubscriberAvatar(imageUrl: subscriber.imageUrl),
        const SizedBox(width: 20),
        Expanded(flex: 4, child: SubscriberDetails(subscriber: subscriber)),
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconInfoRow(
                icon: Icons.phone_android_rounded,
                text: subscriber.phone,
              ),
              const SizedBox(height: 8),
              IconInfoRow(
                icon: Icons.location_on_outlined,
                text: subscriber.address,
              ),
            ],
          ),
        ),

        // 3. Gender & Reference ID
        Expanded(
          flex: 3,
          child: Row(
            children: [
              SubscriberGenderBadge(isMale: isMale, gender: subscriber.gender),
              const SizedBox(width: 12),
              Text(
                "#${subscriber.id.substring(0, 5)}",
                style: styles.regular11.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 40, indent: 25, endIndent: 25),

        SubscriberActionSection(
          joinedDate: subscriber.joinedDate ?? DateTime.now(),
          onDelete: onDelete,
          onNaviagte: onNavigate,
          subscriberId: subscriber.id,
        ),
      ],
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Row(
      children: [
        SubscriberAvatar(imageUrl: subscriber.imageUrl),
        const SizedBox(width: 12),
        Expanded(child: SubscriberDetails(subscriber: subscriber)),
        SubscriberActionSection(
          joinedDate: subscriber.joinedDate ?? DateTime.now(),
          onDelete: onDelete,
          onNaviagte: onNavigate,
          subscriberId: subscriber.id,
        ),
      ],
    );
  }
}
