import 'package:flutter/material.dart';
import '../../../models/device_models.dart';
import '../../../services/device_api_service.dart';
import '../../../utils/app_palette.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/app_custom_text_field.dart';
import '../../../widgets/custom_app_bar.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _nameController = TextEditingController();
  final _serialController = TextEditingController();
  final _service = DeviceApiService();

  int _selectedTypeId = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final serial = _serialController.text.trim();

    if (name.isEmpty || serial.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await _service.addDevice(
      AddDeviceRequest(
        name: name,
        serialNumber: serial,
        deviceTypeId: _selectedTypeId,
      ),
    );
    setState(() => _isLoading = false);

    if (res.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device added successfully!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.backgroundLight,
      appBar: buildAppBar(title: 'Register Device'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Hardware Device Specs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Register a device node or sensor into the enterprise pool',
                style: TextStyle(fontSize: 13, color: AppPalette.textSecondaryLight),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                label: 'Device Friendly Name',
                hint: 'e.g. North Gate Access Sensor',
                controller: _nameController,
                prefixIcon: const Icon(Icons.drive_file_rename_outline_rounded, size: 20),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Serial Number / IMEI',
                hint: 'e.g. SN-88234-AX',
                controller: _serialController,
                prefixIcon: const Icon(Icons.qr_code_rounded, size: 20),
              ),
              const SizedBox(height: 16),

              const Text(
                'Device Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppPalette.backgroundLightAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedTypeId,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Gateway Hub')),
                      DropdownMenuItem(value: 2, child: Text('Security Camera')),
                      DropdownMenuItem(value: 3, child: Text('Access Terminal')),
                      DropdownMenuItem(value: 4, child: Text('Mobile / Tablet')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTypeId = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 36),

              AppButton(
                label: 'Save & Provision Device',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
