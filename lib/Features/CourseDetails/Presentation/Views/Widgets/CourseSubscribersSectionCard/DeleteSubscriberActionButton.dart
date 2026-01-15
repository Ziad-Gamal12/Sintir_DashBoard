import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Managers/CourseSubscribersCubit/CourseSubscribersCubit.dart';

class DeleteSubscriberActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String subscriberId;

  const DeleteSubscriberActionButton({
    super.key,
    required this.subscriberId,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CourseSubscribersCubit, CourseSubscribersState, bool>(
      selector: (state) {
        return state is DeleteSubscriberLoading &&
            state.subscriberId == subscriberId;
      },
      builder: (context, isLoading) {
        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(color: Colors.red),
          );
        }
        return IconButton(
          onPressed: onPressed,
          tooltip: "حذف",
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
          style: IconButton.styleFrom(
            backgroundColor: Colors.redAccent.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: Colors.redAccent,
          ),
        );
      },
    );
  }
}
