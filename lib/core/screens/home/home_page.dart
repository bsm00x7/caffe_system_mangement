import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:provider/provider.dart';

import '../../utils/widgets/showDialog.dart';
import '../controller/home_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
  GlobalKey<SliderDrawerState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => HomeController(),
      builder: (providerContext, child) {
        return Scaffold(
          body: SliderDrawer(
            isDraggable: false,
            key: _sliderDrawerKey,
            appBar: SliderAppBar(
              config: SliderAppBarConfig(
                title: const Text(
                  "Home",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                drawerIconColor: Colors.black,
              ),
            ),
            sliderOpenSize: 300,
            slider: _buildDrawer(providerContext),
            child: Container(color: Colors.amber),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade800],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Profile Section
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 60, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<HomeController>(
              builder: (context, value, child) {
                return Text(
                  value.user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 5),
            Consumer<HomeController>(
              builder: (context, value, child) {
                return Text(
                  value.user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white38, thickness: 1),
            const SizedBox(height: 10),
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _buildDrawerItem(
                    icon: Icons.home_rounded,
                    title: "Home",
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_rounded,
                    title: "Profile",
                    onTap: () {
                      // Navigate to profile
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_rounded,
                    title: "Settings",
                    onTap: () {
                      // Navigate to settings
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.contact_phone_rounded,
                    title: "Contact",
                    onTap: () {
                      // Navigate to contact
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_rounded,
                    title: "About",
                    onTap: () {
                      // Navigate to about
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white38, thickness: 1),
            // Logout Button
            _buildDrawerItem(
              icon: Icons.logout_rounded,
              title: "Logout",
              iconColor: Colors.redAccent,
              textColor: Colors.white,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return ShowdialogWidget(
                      message: 'Are you sure you want to logout?',
                      onPressed: () {
                        context.read<HomeController>().logout(context);
                      },
                      title: 'logout',
                      textAction: 'logout',
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.white, size: 26),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.white,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: Colors.white.withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }
}