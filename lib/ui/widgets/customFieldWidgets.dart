import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eschool_saas_staff/data/models/customField.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget builder for custom fields based on their type
class CustomFieldWidgets {
  static Widget buildCustomFieldWidget({
    required BuildContext context,
    required CustomField field,
    required TextEditingController controller,
    required Function(String?) onChanged,
    String? uploadedFilePath,
    VoidCallback? onFileUpload,
  }) {
    final fieldLabel = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                field.name ?? 'Field',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.76),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (field.isRequired == true)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );

    switch (field.type?.toLowerCase()) {
      case 'text':
        return _buildTextField(context, fieldLabel, controller);

      case 'number':
        return _buildNumberField(context, fieldLabel, controller);

      case 'textarea':
        return _buildTextAreaField(context, fieldLabel, controller);

      case 'dropdown':
        return _buildDropdownField(
            context, fieldLabel, field, controller, onChanged);

      case 'radio':
        return _buildRadioField(
            context, fieldLabel, field, controller, onChanged);

      case 'checkbox':
        return _buildCheckboxField(
            context, fieldLabel, field, controller, onChanged);

      case 'file':
        return _buildFileUploadField(
          context,
          fieldLabel,
          field,
          controller,
          uploadedFilePath,
          onFileUpload,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  static Widget _buildTextField(
      BuildContext context,
      Widget label,
      TextEditingController controller,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        CustomTextFieldContainer(
          textEditingController: controller,
          hintTextKey: 'Enter text',
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  static Widget _buildNumberField(
      BuildContext context,
      Widget label,
      TextEditingController controller,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        CustomTextFieldContainer(
          textEditingController: controller,
          hintTextKey: 'Enter number',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  static Widget _buildTextAreaField(
      BuildContext context,
      Widget label,
      TextEditingController controller,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        Container(
          padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter text',
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  static Widget _buildDropdownField(
      BuildContext context,
      Widget label,
      CustomField field,
      TextEditingController controller,
      Function(String?) onChanged,
      ) {
    final options = field.getOptionsAsList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        DropdownButtonFormField<String>(
          value: controller.text.isNotEmpty ? controller.text : null,
          hint: const Text('Select option'),
          items: options
              .map(
                (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(e),
            ),
          )
              .toList(),
          onChanged: (value) {
            controller.text = value ?? '';
            onChanged(value);
          },
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  /// ✅ FIXED RADIO FIELD (NO RadioGroup)
  static Widget _buildRadioField(
      BuildContext context,
      Widget label,
      CustomField field,
      TextEditingController controller,
      Function(String?) onChanged,
      ) {
    final options = field.getOptionsAsList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        ...options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue:
            controller.text.isNotEmpty ? controller.text : null,
            onChanged: (String? value) {
              if (value != null) {
                controller.text = value;
                onChanged(value);
              }
            },
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }).toList(),
        const SizedBox(height: 15),
      ],
    );
  }

  static Widget _buildCheckboxField(
      BuildContext context,
      Widget label,
      CustomField field,
      TextEditingController controller,
      Function(String?) onChanged,
      ) {
    final options = field.getOptionsAsList();
    final selectedValues = controller.text.isNotEmpty
        ? controller.text.split(',').map((e) => e.trim()).toList()
        : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        ...options.map((option) {
          final isChecked = selectedValues.contains(option);
          return CheckboxListTile(
            title: Text(option),
            value: isChecked,
            onChanged: (bool? value) {
              if (value == true) {
                selectedValues.add(option);
              } else {
                selectedValues.remove(option);
              }
              controller.text = selectedValues.join(',');
              onChanged(controller.text);
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
        const SizedBox(height: 15),
      ],
    );
  }

  static Widget _buildFileUploadField(
      BuildContext context,
      Widget label,
      CustomField field,
      TextEditingController controller,
      String? uploadedFilePath,
      VoidCallback? onFileUpload,
      ) {
    final hasFile =
        uploadedFilePath != null && uploadedFilePath.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        GestureDetector(
          onTap: onFileUpload,
          child: Container(
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border:
              Border.all(color: Theme.of(context).colorScheme.tertiary),
            ),
            child: hasFile
                ? Image.file(
              File(uploadedFilePath!),
              fit: BoxFit.cover,
            )
                : Icon(
              Icons.cloud_upload,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
