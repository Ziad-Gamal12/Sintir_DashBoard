import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/Entities/CustomDrawerEntity.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/widgets/AppVersionLabel.dart';
import 'package:sintir_dashboard/Core/widgets/CustomUserListTile.dart';
import 'package:sintir_dashboard/Core/widgets/Drawer/CustomDrawerItem.dart';
import 'package:sintir_dashboard/Core/widgets/LogOutDialog.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomDrawerBody extends StatefulWidget {
  const CustomDrawerBody({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  final int currentIndex;
  final Function(int index) onItemTapped;

  @override
  State<CustomDrawerBody> createState() => _CustomDrawerBodyState();
}

class _CustomDrawerBodyState extends State<CustomDrawerBody> {
  late UserEntity userEntity;
  final List<CustomDrawerEntity> drawerItems =
      CustomDrawerEntity.getDrawerItems();

  @override
  void initState() {
    super.initState();
    userEntity = getUserData();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    final Color subtleDivider = theme.dividerColor.withOpacity(0.05);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(left: BorderSide(color: subtleDivider, width: 1.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              CustomUserListTile(userEntity: userEntity),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: drawerItems.length,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final bool isSelected = widget.currentIndex == index;
                    return InkWell(
                      onTap: () => widget.onItemTapped(index),
                      borderRadius: BorderRadius.circular(12),
                      splashColor: KMainColor.withOpacity(0.05),
                      child: Stack(
                        children: [
                          CustomDrawerItem(
                            drawerItem: drawerItems[index],
                            isSelected: isSelected,
                          ),
                          if (isSelected)
                            Positioned(
                              right: 0,
                              top: 12,
                              bottom: 12,
                              child: Container(
                                width: 3,
                                decoration: BoxDecoration(
                                  color: KMainColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Divider using the custom subtle color
              Divider(color: subtleDivider, height: 40, thickness: 1),

              _buildLogoutButton(subtleDivider),

              const SizedBox(height: 20),
              Center(child: AppVersionLabel(version: currentVersion)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () {
          showDialog(context: context, builder: (context) => LogoutDialog());
        },
        borderRadius: BorderRadius.circular(12),
        child: CustomDrawerItem(
          isSelected: false,
          drawerItem: CustomDrawerEntity(
            icon: FontAwesomeIcons.rightFromBracket,
            title: "تسجيل الخروج",
          ),
          overrideColor: Colors.red,
        ),
      ),
    );
  }
}
