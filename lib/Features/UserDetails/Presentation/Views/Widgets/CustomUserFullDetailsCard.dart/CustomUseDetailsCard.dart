import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Entities/UserRoleBadgeEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Core/widgets/CustomInfoRow.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Helpers/UsersStatusHelper.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomUserDetailsCard extends StatelessWidget {
  const CustomUserDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    UserEntity userEntity = context.watch<UserDetailsCubit>().userEntity;
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
      buildWhen: (previous, current) {
        return current is GetUserDetailsFailure ||
            current is GetUserDetailsLoading ||
            current is GetUserDetailsSuccess;
      },
      builder: (context, state) {
        return CustomCard(
          child: state is GetUserDetailsFailure
              ? Center(child: CustomErrorWidget(errormessage: state.errmessage))
              : Skeletonizer(
                  enabled: state is GetUserDetailsLoading,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "تفاصيل المستخدم",
                        style: AppTextStyles(context).semiBold20,
                      ),
                      const SizedBox(height: 25),
                      CustomInfoRow(
                        label: "الاسم بالكامل",
                        value: "${userEntity.firstName} ${userEntity.lastName}",
                        icon: Icons.person_outline_rounded,
                      ),
                      _buildDivider(),
                      CustomInfoRow(
                        label: "البريد الإلكتروني",
                        value: userEntity.email,
                        icon: Icons.email_outlined,
                      ),
                      _buildDivider(),
                      CustomInfoRow(
                        label: "رقم الهاتف",
                        value: userEntity.phoneNumber,
                        icon: Icons.phone_android_rounded,
                      ),
                      _buildDivider(),
                      CustomInfoRow(
                        label: "العنوان",
                        value: userEntity.address,
                        icon: Icons.location_on_outlined,
                      ),
                      _buildDivider(),
                      CustomInfoRow(
                        label: "الدور (Role)",
                        value: UserRoleBadgeEntity.getUserRoleBadgeEntity(
                          userEntity.role,
                        ).title,
                        icon: Icons.admin_panel_settings_outlined,
                      ),
                      _buildDivider(),

                      CustomInfoRow(
                        label: "الحالة",
                        value: UsersStatusHelper.getUserStatusArabic(
                          userEntity.status,
                        ),
                        icon: Icons.info_outline_rounded,
                      ),
                      _buildDivider(),

                      CustomInfoRow(
                        label: "تاريخ الانضمام",
                        value: DateFormat(
                          'yyyy/MM/dd',
                        ).format(userEntity.joinedDate),
                        icon: Icons.calendar_today_rounded,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.05),
      thickness: 1,
      height: 20,
    );
  }
}
