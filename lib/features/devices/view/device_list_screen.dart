import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/device_models.dart';
import '../../../utils/app_palette.dart';
import '../../../utils/routes.dart';
import '../../../widgets/app_custom_text_field.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/list_scroll_more_widget.dart';
import '../view_model/device_list_view_model.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeviceListViewModel(),
      child: const _DeviceListContent(),
    );
  }
}

class _DeviceListContent extends StatelessWidget {
  const _DeviceListContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DeviceListViewModel>();

    return Scaffold(
      backgroundColor: AppPalette.backgroundLight,
      appBar: buildAppBar(
        title: 'Fleet Devices',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppPalette.primaryRose, size: 26),
            onPressed: () async {
              final created = await Navigator.of(context).pushNamed(AppRoutes.addDevice);
              if (created == true) {
                viewModel.refresh();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: CustomTextField(
              hint: 'Search device by name, serial, user...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              onChanged: viewModel.setSearchQuery,
            ),
          ),

          // Device Type Filter Chips
          if (viewModel.deviceTypes.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: const Text('All Types'),
                      selected: viewModel.selectedTypeId == null,
                      onSelected: (_) => viewModel.setFilterType(null),
                      selectedColor: AppPalette.primaryRose.withOpacity(0.2),
                      checkmarkColor: AppPalette.primaryRose,
                    ),
                  ),
                  ...viewModel.deviceTypes.map((type) {
                    final isSelected = viewModel.selectedTypeId == type.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(type.name),
                        selected: isSelected,
                        onSelected: (_) => viewModel.setFilterType(isSelected ? null : type.id),
                        selectedColor: AppPalette.primaryRose.withOpacity(0.2),
                        checkmarkColor: AppPalette.primaryRose,
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // Paginated List
          Expanded(
            child: ListScrollMoreWidget<DeviceModel>(
              items: viewModel.filteredDevices,
              hasMore: viewModel.hasMore,
              isLoadingMore: viewModel.isLoadingMore,
              onRefresh: viewModel.refresh,
              onLoadMore: viewModel.loadMore,
              itemBuilder: (context, device, index) {
                return _buildDeviceCard(context, device, viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, DeviceModel device, DeviceListViewModel vm) {
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
            color: (device.isActive ? AppPalette.callGreen : AppPalette.textSecondaryLight).withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.devices_other_rounded,
            color: device.isActive ? AppPalette.callGreen : AppPalette.textSecondaryLight,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                device.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppPalette.textPrimaryLight,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (device.isActive ? AppPalette.callGreen : Colors.grey).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                device.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: device.isActive ? AppPalette.callGreen : Colors.grey,
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
              'S/N: ${device.serialNumber} • ${device.deviceTypeName ?? "Hardware"}',
              style: const TextStyle(fontSize: 12, color: AppPalette.textSecondaryLight),
            ),
            if (device.assignedUserName != null) ...[
              const SizedBox(height: 2),
              Text(
                'Assigned: ${device.assignedUserName} (${device.groupName ?? "General"})',
                style: const TextStyle(fontSize: 12, color: AppPalette.primaryViolet),
              ),
            ],
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppPalette.textSecondaryLight,
        ),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.deviceDetail,
            arguments: device,
          );
        },
      ),
    );
  }
}
