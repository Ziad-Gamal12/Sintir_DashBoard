part of 'add_subscribers_to_course_cubit.dart';

@immutable
sealed class AddSubscribersToCourseState {}

final class AddSubscribersToCourseInitial extends AddSubscribersToCourseState {}

final class AddSubscribersToCourseLoading extends AddSubscribersToCourseState {}

final class AddSubscribersToCourseSuccess extends AddSubscribersToCourseState {}

final class AddSubscribersToCourseFailure extends AddSubscribersToCourseState {
  final String errmessage;
  AddSubscribersToCourseFailure({required this.errmessage});
}
