import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:herfay/core/theme/theme_config.dart';
import 'package:herfay/core/widgets/empty_state.dart';
import 'package:herfay/core/widgets/shimmer_card.dart';
import 'package:herfay/core/utils/widgets/text_form_field.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controller/screen_user_controller.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScreenUserController(),
      builder: (providerContext, child) {
        return Consumer<ScreenUserController>(
          builder: (context, controller, child) {
            return Column(
              children: [
                const SizedBox(height: AppTheme.spacingM),

                // Enhanced Header with Stats
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    boxShadow: AppTheme.shadowMD,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Users Management',
                                  style: AppTheme.headingLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacingXS),
                                Text(
                                  '${controller.users.length} ${controller.users.length == 1 ? 'user' : 'users'} registered',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: const Icon(
                              Icons.people_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatChip(
                              icon: Icons.admin_panel_settings,
                              label: 'Admins',
                              value: controller.users.where((u) => u.isAdmin == true).length.toString(),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingS),
                          Expanded(
                            child: _buildStatChip(
                              icon: Icons.work_outline,
                              label: 'Employers',
                              value: controller.users.where((u) => u.isAdmin == false).length.toString(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                  child: TextField(
                    onChanged: (value) => controller.searchUsers(value),
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.primaryColor,
                      ),
                      suffixIcon: controller.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => controller.searchUsers(''),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'All',
                        isSelected: controller.selectedFilter == UserFilter.all,
                        onTap: () => controller.setFilter(UserFilter.all),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      _buildFilterChip(
                        label: 'Admins',
                        isSelected: controller.selectedFilter == UserFilter.admins,
                        onTap: () => controller.setFilter(UserFilter.admins),
                        icon: Icons.admin_panel_settings,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      _buildFilterChip(
                        label: 'Employers',
                        isSelected: controller.selectedFilter == UserFilter.employers,
                        onTap: () => controller.setFilter(UserFilter.employers),
                        icon: Icons.work_outline,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Error Message
                if (controller.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingS,
                    ),
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: Border.all(color: AppTheme.errorColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: Text(
                            controller.errorMessage!,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          color: AppTheme.errorColor,
                          onPressed: () => controller.clearError(),
                        ),
                      ],
                    ),
                  ),

                // User List
                Expanded(
                  child: controller.isLoading
                      ? _buildLoadingState()
                      : controller.filteredUsers.isEmpty
                          ? EmptyStateWidget(
                              icon: controller.searchQuery.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.people_outline,
                              title: controller.searchQuery.isNotEmpty
                                  ? 'No users found'
                                  : 'No users yet',
                              description: controller.searchQuery.isNotEmpty
                                  ? 'Try a different search term'
                                  : 'Add your first user to get started',
                              actionText: controller.searchQuery.isEmpty ? 'Add User' : null,
                              onAction: controller.searchQuery.isEmpty
                                  ? () => _showUserDialog(context, controller)
                                  : null,
                            )
                          : RefreshIndicator(
                              onRefresh: () => controller.loadUsers(),
                              color: AppTheme.primaryColor,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingM,
                                ),
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: AppTheme.spacingM),
                                itemCount: controller.filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = controller.filteredUsers[index];
                                  return _buildUserCard(context, controller, user, index);
                                },
                              ),
                            ),
                ),

                const SizedBox(height: AppTheme.spacingM),

                // Add Button
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: controller.isLoading
                          ? null
                          : () => _showUserDialog(context, controller),
                      icon: const Icon(Icons.person_add_rounded),
                      label: Text(
                        'Add New User',
                        style: AppTheme.button.copyWith(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: AppTheme.spacingS),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTheme.headingSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: AppTheme.caption.copyWith(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacingXS),
            ],
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingM),
      itemCount: 5,
      itemBuilder: (context, index) => const ShimmerListItem(),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    ScreenUserController controller,
    dynamic user,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowSM,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTheme.spacingM),
        leading: user.profileImageUrl != null
            ? CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(user.profileImageUrl!),
              )
            : CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  user.name[0].toUpperCase(),
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (user.isAdmin == true)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 12,
                      color: AppTheme.warningColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Admin',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacingXS),
            Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingXS),
                Expanded(
                  child: Text(
                    user.email,
                    style: AppTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (user.createdAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(width: AppTheme.spacingXS),
                  Text(
                    'Joined ${DateFormat('MMM d, yyyy').format(user.createdAt!)}',
                    style: AppTheme.caption,
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppTheme.primaryColor,
              onPressed: () {
                final actualIndex = controller.users.indexOf(user);
                _showUserDialog(
                  context,
                  controller,
                  isEdit: true,
                  index: actualIndex,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppTheme.errorColor,
              onPressed: () {
                final actualIndex = controller.users.indexOf(user);
                _showDeleteConfirmation(context, controller, actualIndex);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDialog(
    BuildContext context,
    ScreenUserController controller, {
    bool isEdit = false,
    int? index,
  }) {
    final formKey = GlobalKey<FormState>();

    if (isEdit && index != null) {
      controller.loadUserForEdit(index);
    } else {
      controller.clearFields();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXL),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppTheme.spacingM),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Title
              Text(
                isEdit ? 'Edit User' : 'Add New User',
                style: AppTheme.headingLarge,
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormFieldWidget(
                          labelText: 'Full Name',
                          hintText: 'Enter full name',
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: AppTheme.primaryColor,
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter name';
                            }
                            if (value.length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            return null;
                          },
                          controller: controller.name,
                        ),
                        const SizedBox(height: AppTheme.spacingL),

                        TextFormFieldWidget(
                          labelText: 'Email Address',
                          hintText: 'Enter email address',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppTheme.primaryColor,
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            }
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          controller: controller.email,
                        ),
                        const SizedBox(height: AppTheme.spacingL),

                        if (!isEdit)
                          TextFormFieldWidget(
                            labelText: 'Password',
                            hintText: 'Enter password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppTheme.primaryColor,
                            ),
                            obscureText: true,
                            validator: (String? value) {
                              if (!isEdit && (value == null || value.isEmpty)) {
                                return 'Please enter password';
                              }
                              if (!isEdit && value!.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            controller: controller.password,
                          ),

                        const SizedBox(height: AppTheme.spacingXL),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : () => Navigator.pop(modalContext),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : () async {
                                        if (formKey.currentState!.validate()) {
                                          bool success;
                                          if (isEdit && index != null) {
                                            success = await controller.updateUser(index);
                                          } else {
                                            success = await controller.addUser();
                                          }

                                          if (success && modalContext.mounted) {
                                            Navigator.pop(modalContext);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  isEdit
                                                      ? 'User updated successfully!'
                                                      : 'User added successfully!',
                                                ),
                                                backgroundColor: AppTheme.successColor,
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                child: controller.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(isEdit ? 'Update' : 'Add User'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingL),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ScreenUserController controller,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: AppTheme.errorColor),
              const SizedBox(width: AppTheme.spacingS),
              const Text('Delete User'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this user? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                bool success = await controller.deleteUser(index);
                Navigator.pop(dialogContext);

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User deleted successfully!'),
                      backgroundColor: AppTheme.errorColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}