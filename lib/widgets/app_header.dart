import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final VoidCallback? onProfileTap;
  final bool showProfile;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions,
    this.onProfileTap,
    this.showProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> appBarActions = [];
    
    if (actions != null) {
      appBarActions.addAll(actions!);
    }
    
    if (showProfile && onProfileTap != null) {
      appBarActions.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    return AppBar(
      title: Text(title),
      centerTitle: true,
      automaticallyImplyLeading: showBack,
      actions: appBarActions.isEmpty ? null : appBarActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
