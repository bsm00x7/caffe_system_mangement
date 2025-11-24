import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:herfay/core/theme/theme_config.dart';
import 'package:herfay/core/widgets/empty_state.dart';
import 'package:herfay/core/widgets/error_widget.dart';
import 'package:herfay/core/widgets/shimmer_card.dart';
import 'package:herfay/model/item_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/db/auth.dart';
import 'controller/employer_controller.dart';

class EmployerScreen extends StatelessWidget {
  const EmployerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => EmployerController(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                'Welcome Back!',
                style: AppTheme.bodySmall,
              ),
              Text(
                Auth.currentUser()!.userMetadata!['name'] ?? 'Employee',
                style: AppTheme.headingMedium,
              ),
            ],
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => Auth.signOut(),
            icon: const Icon(Icons.logout_outlined, color: AppTheme.errorColor),
          ),
          actions: [
            Consumer<EmployerController>(
              builder: (context, controller, _) {
                return controller.hasItemsInCart
                    ? Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Stack(
                          children: [
                            IconButton(
                              onPressed: () => _showCartSummary(context),
                              icon: const Icon(Icons.shopping_cart),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.errorColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${controller.totalItems}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),

        // -------------------- BODY --------------------
        body: Consumer<EmployerController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return _buildLoadingState();
            }

            if (controller.errorMessage != null) {
              return ErrorStateWidget(
                message: controller.errorMessage!,
                onRetry: () => controller.loadItem(),
              );
            }

            if (controller.items.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.inventory_2_outlined,
                title: 'No Items Available',
                description: 'There are no items in the store right now.',
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.loadItem(),
              color: AppTheme.primaryColor,
              child: CustomScrollView(
                slivers: [
                  // Header Info
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(AppTheme.spacingM),
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        boxShadow: AppTheme.shadowMD,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white),
                          const SizedBox(width: AppTheme.spacingM),
                          Expanded(
                            child: Text(
                              'Select items and quantities, then checkout',
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Product Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppTheme.spacingM,
                        mainAxisSpacing: AppTheme.spacingM,
                        childAspectRatio: 0.65,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ItemModel item = controller.items[index];
                          final quantity = controller.itemCount[index];
                          final isOutOfStock = item.stock <= 0;
                          final isLowStock = item.stock < 10;

                          return _buildProductCard(
                            context,
                            item,
                            quantity,
                            index,
                            isOutOfStock,
                            isLowStock,
                          );
                        },
                        childCount: controller.items.length,
                      ),
                    ),
                  ),

                  // Bottom spacing for FAB
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            );
          },
        ),

        // Floating Action Button for Cart
        floatingActionButton: Consumer<EmployerController>(
          builder: (context, controller, _) {
            if (!controller.hasItemsInCart) return const SizedBox.shrink();

            return FloatingActionButton.extended(
              onPressed: () => _showCartSummary(context),
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.shopping_cart_checkout),
              label: Text(
                'Checkout (PKR ${NumberFormat('#,##0.00').format(controller.totalAmount)})',
                style: AppTheme.button.copyWith(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
          childAspectRatio: 0.65,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ShimmerGridItem(),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ItemModel item,
    int quantity,
    int index,
    bool isOutOfStock,
    bool isLowStock,
  ) {
    final controller = context.read<EmployerController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusL),
                    topRight: Radius.circular(AppTheme.radiusL),
                  ),
                  child: item.image != null
                      ? CachedNetworkImage(
                          imageUrl: item.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.coffee,
                              size: 60,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.coffee,
                            size: 60,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                ),
                // Stock Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? AppTheme.errorColor
                          : isLowStock
                              ? AppTheme.warningColor
                              : AppTheme.successColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      isOutOfStock
                          ? 'Out'
                          : isLowStock
                              ? 'Low'
                              : '${item.stock}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.item_name,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    'PKR ${NumberFormat('#,##0.00').format(item.price)}',
                    style: AppTheme.headingSmall.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),

                  // Quantity Selector
                  if (!isOutOfStock)
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => controller.decrementItem(index),
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppTheme.primaryColor,
                            iconSize: 24,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingS,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: quantity > 0
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppTheme.radiusS),
                            ),
                            child: Text(
                              '$quantity',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: quantity > 0
                                    ? Colors.white
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.incrementItem(index),
                            icon: const Icon(Icons.add_circle),
                            color: AppTheme.primaryColor,
                            iconSize: 24,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      child: Text(
                        'Out of Stock',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
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

  void _showCartSummary(BuildContext context) {
    final controller = context.read<EmployerController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
      ),
      builder: (context) {
        return Consumer<EmployerController>(
          builder: (context, controller, _) {
            final cartItems = <Map<String, dynamic>>[];
            for (int i = 0; i < controller.items.length; i++) {
              if (controller.itemCount[i] > 0) {
                cartItems.add({
                  'item': controller.items[i],
                  'quantity': controller.itemCount[i],
                });
              }
            }

            return Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  // Title
                  Text('Cart Summary', style: AppTheme.headingLarge),
                  const SizedBox(height: AppTheme.spacingL),

                  // Cart Items
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: cartItems.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final cartItem = cartItems[index];
                        final item = cartItem['item'] as ItemModel;
                        final quantity = cartItem['quantity'] as int;
                        final subtotal = item.price * quantity;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.item_name, style: AppTheme.bodyLarge),
                          subtitle: Text(
                            'PKR ${NumberFormat('#,##0.00').format(item.price)} x $quantity',
                            style: AppTheme.bodySmall,
                          ),
                          trailing: Text(
                            'PKR ${NumberFormat('#,##0.00').format(subtotal)}',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(thickness: 2),
                  const SizedBox(height: AppTheme.spacingM),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTheme.headingMedium),
                      Text(
                        'PKR ${NumberFormat('#,##0.00').format(controller.totalAmount)}',
                        style: AppTheme.headingLarge.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingL),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            controller.clearCart();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Clear Cart'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            final success = await controller.submitCart();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Order submitted successfully!'
                                        : 'Failed to submit order',
                                  ),
                                  backgroundColor:
                                      success ? AppTheme.successColor : AppTheme.errorColor,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Submit Order'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
