import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:herfay/core/theme/theme_config.dart';
import 'package:herfay/core/widgets/stat_card.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
          backgroundColor: AppTheme.backgroundColor,
          body: SliderDrawer(
            isDraggable: false,
            key: _sliderDrawerKey,
            appBar: SliderAppBar(
              config: SliderAppBarConfig(
                title: Text(
                  "Dashboard",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingLarge,
                ),
                drawerIconColor: AppTheme.textPrimary,
              ),
            ),
            sliderOpenSize: 300,
            slider: _buildDrawer(providerContext),
            child: _buildDashboardContent(providerContext),
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data
        //! oo
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.shadowMD,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: const Icon(
                      Icons.coffee_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<HomeController>(
                          builder: (context, value, child) {
                            return Text(
                              'Welcome, ${value.user.name}!',
                              style: AppTheme.headingMedium.copyWith(
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Statistics Cards
            Text('Overview', style: AppTheme.headingMedium),
            const SizedBox(height: AppTheme.spacingM),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppTheme.spacingM,
              crossAxisSpacing: AppTheme.spacingM,
              childAspectRatio: 0.8,
              children: [
                StatCard(
                  title: 'Today\'s Sales',
                  value: 'DT 15,420',
                  icon: Icons.trending_up,
                  color: AppTheme.successColor,
                  subtitle: '+12% from yesterday',
                ),
                StatCard(
                  title: 'Total Purchases',
                  value: '42',
                  icon: Icons.shopping_cart,
                  color: AppTheme.primaryColor,
                  subtitle: 'This week',
                ),
                StatCard(
                  title: 'Active Employers',
                  value: '8',
                  icon: Icons.people,
                  color: AppTheme.secondaryColor,
                  subtitle: 'Currently working',
                ),
                StatCard(
                  title: 'Low Stock Items',
                  value: '5',
                  icon: Icons.warning_rounded,
                  color: AppTheme.warningColor,
                  subtitle: 'Need attention',
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Quick Actions
            Text('Quick Actions', style: AppTheme.headingMedium),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.add_business,
                    label: 'Add Stock',
                    color: AppTheme.primaryColor,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.assessment,
                    label: 'Reports',
                    color: AppTheme.secondaryColor,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.person_add,
                    label: 'Add Employee',
                    color: AppTheme.successColor,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.inventory,
                    label: 'View Stock',
                    color: AppTheme.warningColor,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Sales Chart
            Text('Weekly Sales', style: AppTheme.headingMedium),
            const SizedBox(height: AppTheme.spacingM),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.shadowSM,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[200]!,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: AppTheme.caption,
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                if (value.toInt() >= 0 && value.toInt() < days.length) {
                                  return Text(
                                    days[value.toInt()],
                                    style: AppTheme.caption,
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 3),
                              const FlSpot(1, 4),
                              const FlSpot(2, 3.5),
                              const FlSpot(3, 5),
                              const FlSpot(4, 4.5),
                              const FlSpot(5, 6),
                              const FlSpot(6, 5.5),
                            ],
                            isCurved: true,
                            color: AppTheme.primaryColor,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: AppTheme.primaryColor,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primaryColor.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Recent Activity
            Text('Recent Activity', style: AppTheme.headingMedium),
            const SizedBox(height: AppTheme.spacingM),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.shadowSM,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.shopping_bag,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Employee ${index + 1} made a purchase',
                      style: AppTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      '${index + 1} hour${index > 0 ? 's' : ''} ago',
                      style: AppTheme.caption,
                    ),
                    trailing: Text(
                      'DT ${(index + 1) * 250}',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: AppTheme.shadowSM,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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