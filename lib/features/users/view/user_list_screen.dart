import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_models.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/routes.dart';
import '../../../widgets/app_custom_text_field.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/list_scroll_more_widget.dart';
import '../view_model/user_view_model.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserViewModel(),
      child: const _UserListContent(),
    );
  }
}

class _UserListContent extends StatelessWidget {
  const _UserListContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.backgroundLight,
      appBar: buildAppBar(
        title: 'User Access Control',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppPalette.primaryRose, size: 24),
            onPressed: () async {
              final added = await Navigator.of(context).pushNamed(AppRoutes.addUser);
              if (added == true) {
                viewModel.refresh();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: CustomTextField(
              hint: 'Search by name, email, or phone...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              onChanged: viewModel.setSearchQuery,
            ),
          ),
          Expanded(
            child: ListScrollMoreWidget<UserModel>(
              items: viewModel.filteredUsers,
              hasMore: viewModel.hasMore,
              isLoadingMore: viewModel.isLoadingMore,
              onRefresh: viewModel.refresh,
              onLoadMore: viewModel.loadMore,
              itemBuilder: (context, user, index) {
                return _buildUserTile(context, user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppPalette.surfaceCardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppPalette.primaryRose.withOpacity(0.12),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: AppPalette.primaryRose,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppPalette.callIndigo.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.role,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.callIndigo,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(fontSize: 12, color: AppPalette.textSecondaryLight),
            ),
            const SizedBox(height: 2),
            Text(
              '${user.devicesCount} devices • ${user.groupsCount} groups',
              style: const TextStyle(fontSize: 12, color: AppPalette.primaryViolet),
            ),
          ],
        ),
      ),
    );
  }
}
