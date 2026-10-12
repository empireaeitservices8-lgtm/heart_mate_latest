import 'package:flutter/material.dart';
import '../../../models/device_models.dart';
import '../../../services/device_api_service.dart';
import '../../../utils/app_palette.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/custom_app_bar.dart';

class DeviceDetailScreen extends StatefulWidget {
  final DeviceModel device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  final _service = DeviceApiService();
  bool _isDeleting = false;

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Device?'),
        content: Text('Are you sure you want to unbind and remove "${widget.device.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppPalette.callRed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isDeleting = true);
              await _service.removeDevice(widget.device.id);
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTransferKeyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transfer Device Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign license access for ${widget.device.name} to another operator:'),
            const SizedBox(height: 14),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Target User ID or Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppPalette.primaryRose),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Key transferred successfully!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Transfer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.device;

    return Scaffold(
      backgroundColor: AppPalette.backgroundLight,
      appBar: buildAppBar(title: d.name),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppPalette.surfaceCardLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (d.isActive ? AppPalette.callGreen : Colors.grey).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.devices_rounded,
                        color: d.isActive ? AppPalette.callGreen : Colors.grey,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      d.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'S/N: ${d.serialNumber}',
                      style: const TextStyle(color: AppPalette.textSecondaryLight, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (d.isActive ? AppPalette.callGreen : Colors.grey).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        d.status.toUpperCase(),
                        style: TextStyle(
                          color: d.isActive ? AppPalette.callGreen : Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Specs List
              const Text(
                'Configuration & Assignment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              _buildSpecTile('Category', d.deviceTypeName ?? 'Gateway Device'),
              _buildSpecTile('Hardware Model', d.model.isNotEmpty ? d.model : 'Standard Hardware'),
              _buildSpecTile('Assigned User', d.assignedUserName ?? 'Unassigned'),
              _buildSpecTile('Group Assignment', d.groupName ?? 'General Fleet'),
              _buildSpecTile('Registration Date', d.createdAt.isNotEmpty ? d.createdAt : 'Active'),
              const SizedBox(height: 30),

              // Actions
              AppButton(
                label: 'Transfer Access Key',
                icon: Icons.vpn_key_rounded,
                onPressed: _showTransferKeyDialog,
              ),
              const SizedBox(height: 14),

              AppButton(
                label: 'Remove from Fleet',
                type: AppButtonType.outlined,
                icon: Icons.delete_outline_rounded,
                isLoading: _isDeleting,
                onPressed: _confirmDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.surfaceCardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppPalette.textSecondaryLight, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
