import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/device_group_models.dart';
import '../../../utils/app_palette.dart';
import '../../../widgets/app_progress_widget.dart';
import '../../../widgets/custom_app_bar.dart';
import '../view_model/device_group_view_model.dart';
import 'create_device_group_dialog.dart';

class DeviceGroupListScreen extends StatelessWidget {
  const DeviceGroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeviceGroupViewModel(),
      child: const _GroupListContent(),
    );
  }
}

class _GroupListContent extends StatelessWidget {
  const _GroupListContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DeviceGroupViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.backgroundLight,
      appBar: buildAppBar(
        title: 'Device Groups',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppPalette.primaryRose, size: 26),
            onPressed: () => _openCreateDialog(context, viewModel),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppPalette.primaryRose,
        onRefresh: viewModel.loadGroups,
        child: viewModel.isLoading && viewModel.groups.isEmpty
            ? const Center(child: AppProgressWidget())
            : viewModel.groups.isEmpty
                ? const Center(child: Text('No device groups found', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.groups.length,
                    itemBuilder: (context, index) {
                      final group = viewModel.groups[index];
                      return _buildGroupCard(context, group, viewModel);
                    },
                  ),
      ),
    );
  }

  void _openCreateDialog(BuildContext context, DeviceGroupViewModel vm) async {
    final res = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => const CreateDeviceGroupDialog(),
    );

    if (res != null && res['name'] != null) {
      await vm.createGroup(res['name']!, res['description'] ?? '');
    }
  }

  void _openRenameDialog(BuildContext context, DeviceGroupModel group, DeviceGroupViewModel vm) async {
    final res = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => CreateDeviceGroupDialog(
        initialName: group.name,
        initialDescription: group.description,
        isEdit: true,
      ),
    );

    if (res != null && res['name'] != null) {
      await vm.renameGroup(group.id, res['name']!);
    }
  }

  Widget _buildGroupCard(BuildContext context, DeviceGroupModel group, DeviceGroupViewModel vm) {
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
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppPalette.primaryRose.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.folder_shared_rounded,
            color: AppPalette.primaryRose,
            size: 24,
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                group.description,
                style: const TextStyle(fontSize: 12, color: AppPalette.textSecondaryLight),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '${group.deviceCount} devices assigned',
              style: const TextStyle(fontSize: 12, color: AppPalette.callIndigo, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: AppPalette.textSecondaryLight),
          onSelected: (action) {
            if (action == 'rename') {
              _openRenameDialog(context, group, vm);
            } else if (action == 'delete') {
              vm.deleteGroup(group.id);
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'rename', child: Text('Rename')),
            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}
