import 'package:flutter/material.dart';
import 'package:herfay/core/theme/theme_config.dart';
import 'package:herfay/core/widgets/empty_state.dart';
import 'package:herfay/core/widgets/error_widget.dart';
import 'package:herfay/core/widgets/shimmer_card.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'controller/purchase_history_controller.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PurchaseHistoryController(),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: const Text('Purchase History'),
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.textPrimary,
            actions: [
              Consumer<PurchaseHistoryController>(
                builder: (context, controller, _) {
                  if (controller.startDate != null || controller.searchQuery.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear_all),
                      tooltip: 'Clear Filters',
                      onPressed: () => controller.clearAllFilters(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: Consumer<PurchaseHistoryController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return _buildLoadingState();
              }

              if (controller.errorMessage != null) {
                return ErrorStateWidget(
                  message: controller.errorMessage!,
                  onRetry: () => controller.loadPurchases(),
                );
              }

              if (controller.allPurchases.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Purchase History',
                  description: 'You haven\'t made any purchases yet.',
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadPurchases(),
                color: AppTheme.primaryColor,
                child: CustomScrollView(
                  slivers: [
                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        child: Column(
                          children: [
                            // Search Field
                            TextField(
                              onChanged: (value) => controller.searchPurchases(value),
                              decoration: InputDecoration(
                                hintText: 'Search by item name...',
                                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingM,
                                  vertical: AppTheme.spacingS,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingM),

                            // Date Filter
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _selectDateRange(context),
                                    icon: const Icon(Icons.date_range, size: 20),
                                    label: Text(
                                      controller.startDate != null
                                          ? '${DateFormat('dd/MM/yy').format(controller.startDate!)} - ${controller.endDate != null ? DateFormat('dd/MM/yy').format(controller.endDate!) : 'Now'}'
                                          : 'Filter by Date',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryColor,
                                      side: const BorderSide(color: AppTheme.primaryColor),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                if (controller.startDate != null) ...[
                                  const SizedBox(width: AppTheme.spacingS),
                                  IconButton(
                                    onPressed: () => controller.clearDateFilter(),
                                    icon: const Icon(Icons.close, size: 20),
                                    color: AppTheme.errorColor,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Statistics Card
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          boxShadow: AppTheme.shadowMD,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Total Spent',
                              'DT ${NumberFormat('#,##0.00').format(controller.totalSpent)}',
                              Icons.payments_outlined,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            _buildStatItem(
                              'Total Items',
                              '${controller.totalItems}',
                              Icons.shopping_bag_outlined,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            _buildStatItem(
                              'Orders',
                              '${controller.filteredPurchases.length}',
                              Icons.receipt_outlined,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Purchase List
                    if (controller.filteredPurchases.isEmpty)
                      const SliverFillRemaining(
                        child: EmptyStateWidget(
                          icon: Icons.search_off,
                          title: 'No Results Found',
                          description: 'Try adjusting your search or filters.',
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final purchase = controller.filteredPurchases[index];
                              return _buildPurchaseCard(purchase);
                            },
                            childCount: controller.filteredPurchases.length,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: 6,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: AppTheme.spacingM),
        child: ShimmerCard(height: 120),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          value,
          style: AppTheme.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseCard(purchase) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowSM,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    purchase.itemName,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    'x${purchase.quantity}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            const Divider(),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit Price',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      'DT ${purchase.formattedPrice}',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Amount',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      'DT ${purchase.formattedTotal}',
                      style: AppTheme.headingSmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  purchase.formattedDate,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final controller = context.read<PurchaseHistoryController>();
    
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: controller.startDate != null && controller.endDate != null
          ? DateTimeRange(start: controller.startDate!, end: controller.endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setDateRange(picked.start, picked.end);
    }
  }
}
