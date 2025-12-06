import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:herfay/core/theme/theme_config.dart';
import 'package:herfay/core/widgets/stat_card.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/widgets/showDialog.dart';
import '../controller/home_controller.dart';
import '../../services/report_export_service.dart';

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
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        // Show error message if any
        if (controller.errorMessage != null && !controller.isLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    controller.errorMessage!,
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  ElevatedButton(
                    onPressed: () => controller.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show loading indicator
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
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
                          color: Colors.white.withValues(alpha: 0.2),
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
                            Text(
                              'Welcome, ${controller.user.name}!',
                              style: AppTheme.headingMedium.copyWith(
                                color: Colors.white,
                              ),
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
                  childAspectRatio: 0.4,
                  children: [
                    StatCard(
                      title: 'Total Revenue',
                      value: 'DT ${controller.totalRevenue.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet,
                      color: AppTheme.successColor,
                      subtitle: 'All time',
                    ),
                    StatCard(
                      title: 'Total Purchases',
                      value: controller.totalNumberPurchase.toString(),
                      icon: Icons.shopping_bag,
                      color: AppTheme.primaryColor,
                      subtitle: 'Completed',
                    ),
                    StatCard(
                      title: 'Today\'s Revenue',
                      value: 'DT ${controller.totalRevenueToday.toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                      color: AppTheme.successColor,
                      subtitle: DateFormat('MMM d').format(DateTime.now()),
                    ),
                    StatCard(
                      title: 'Today\'s Purchases',
                      value: controller.totalNumberPurchaseToday.toString(),
                      icon: Icons.shopping_cart,
                      color: AppTheme.primaryColor,
                      subtitle: 'Transactions',
                    ),
                    StatCard(
                      title: 'Low Stock Alert',
                      value: controller.numberOfItemLowStock.toString(),
                      icon: Icons.warning_rounded,
                      color: AppTheme.warningColor,
                      subtitle: controller.numberOfItemLowStock > 0 ? 'Need restock' : 'All good',
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
                        onTap: () {
                          // Navigate to add stock screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Add Stock feature coming soon')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.assessment,
                        label: 'Reports',
                        color: AppTheme.secondaryColor,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reports feature coming soon')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.picture_as_pdf,
                        label: 'Export PDF',
                        color: Colors.red.shade600,
                        onTap: () async {
                          final filePath = await controller.exportReportPDF(context);
                          if (filePath != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Report saved: $filePath'),
                                action: SnackBarAction(
                                  label: 'Open',
                                  onPressed: () {
                                    ReportExportService.openFile(filePath);
                                  },
                                ),
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to export PDF'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: _buildQuickAction(
                        icon: Icons.table_chart,
                        label: 'Export CSV',
                        color: Colors.green.shade600,
                        onTap: () async {
                          final filePath = await controller.exportReportCSV(context);
                          if (filePath != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Report saved: $filePath'),
                                action: SnackBarAction(
                                  label: 'Open',
                                  onPressed: () {
                                    ReportExportService.openFile(filePath);
                                  },
                                ),
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to export CSV'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Sales Chart
                Text('Weekly Sales', style: AppTheme.headingMedium),
                const SizedBox(height: AppTheme.spacingM),
                _buildWeeklySalesChart(controller),

                const SizedBox(height: AppTheme.spacingL),

                // Recent Activity
                Text('Recent Activity', style: AppTheme.headingMedium),
                const SizedBox(height: AppTheme.spacingM),
                _buildRecentActivity(controller),

                const SizedBox(height: AppTheme.spacingXL),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklySalesChart(HomeController controller) {
    final salesData = controller.weeklySalesData;
    final maxValue = salesData.fold<double>(0, (max, val) => val > max ? val : max);
    final totalSales = salesData.fold<double>(0, (sum, val) => sum + val);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowSM,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Last 7 Days', style: AppTheme.bodySmall),
              Text(
                'Total: DT ${totalSales.toStringAsFixed(2)}',
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
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
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'DT${value.toInt()}',
                          style: AppTheme.caption,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
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
                minY: 0,
                maxY: maxValue > 0 ? maxValue * 1.2 : 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      7,
                      (index) => FlSpot(index.toDouble(), salesData[index]),
                    ),
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
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(HomeController controller) {
    if (controller.recentPurchases.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: AppTheme.shadowSM,
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'No recent activity',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowSM,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.recentPurchases.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final purchase = controller.recentPurchases[index];
          final userName = purchase['users']?['name'] ?? 'Unknown';
          final itemName = purchase['items']?['item_name'] ?? 'Unknown Item';
final totalAmount = (purchase['total_amount'] as num?)?.toDouble() ?? 0.0;
          final purchaseDate = purchase['purchase_date'] != null
              ? DateTime.parse(purchase['purchase_date'])
              : DateTime.now();
          final timeAgo = _getTimeAgo(purchaseDate);

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: const Icon(
                Icons.shopping_bag,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            title: Text(
              '$userName purchased $itemName',
              style: AppTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              timeAgo,
              style: AppTheme.caption,
            ),
            trailing: Text(
              'DT ${totalAmount.toStringAsFixed(2)}',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.successColor,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Helper function to calculate time ago
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
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
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
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
                    color: Colors.black.withValues(alpha: 0.3),
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
                    color: Colors.white.withValues(alpha: 0.8),
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
