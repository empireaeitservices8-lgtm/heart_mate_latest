import 'package:flutter/material.dart';
import '../../../utils/app_palette.dart';
import '../../../widgets/app_button_widget.dart';
import '../../../widgets/app_custom_text_field.dart';

class CreateDeviceGroupDialog extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final bool isEdit;

  const CreateDeviceGroupDialog({
    super.key,
    this.initialName,
    this.initialDescription,
    this.isEdit = false,
  });

  @override
  State<CreateDeviceGroupDialog> createState() => _CreateDeviceGroupDialogState();
}

class _CreateDeviceGroupDialogState extends State<CreateDeviceGroupDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppPalette.surfaceCardLight,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isEdit ? 'Rename Device Group' : 'New Device Group',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Group Name',
              hint: 'e.g. North Gate Access Points',
              controller: _nameController,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Description (Optional)',
              hint: 'e.g. Primary surveillance cluster',
              controller: _descController,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: widget.isEdit ? 'Save' : 'Create',
                    height: 46,
                    onPressed: () {
                      final name = _nameController.text.trim();
                      final desc = _descController.text.trim();
                      if (name.isNotEmpty) {
                        Navigator.of(context).pop({'name': name, 'description': desc});
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
