import 'package:eschool_saas_staff/data/models/staffAttendance.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';

class StaffAttendanceConfirmationBottomSheet extends StatefulWidget {
  final List<StaffAttendanceRecord> attendanceRecords;
  final bool sendNotificationToAbsent;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const StaffAttendanceConfirmationBottomSheet({
    super.key,
    required this.attendanceRecords,
    required this.sendNotificationToAbsent,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<StaffAttendanceConfirmationBottomSheet> createState() =>
      _StaffAttendanceConfirmationBottomSheetState();
}

class _StaffAttendanceConfirmationBottomSheetState
    extends State<StaffAttendanceConfirmationBottomSheet> {
  int getTotalPresent() {
    return widget.attendanceRecords
        .where((record) =>
            record.currentStatus == StaffAttendanceStatus.present ||
            record.currentStatus == StaffAttendanceStatus.firstHalfPresent ||
            record.currentStatus == StaffAttendanceStatus.secondHalfPresent)
        .length;
  }

  int getTotalAbsent() {
    return widget.attendanceRecords
        .where((record) =>
            record.currentStatus == StaffAttendanceStatus.absentWithReason ||
            record.currentStatus == StaffAttendanceStatus.absentWithoutReason)
        .length;
  }

  // Leave count is no longer relevant - staff can be selected regardless of leave
  int getTotalOnLeave() {
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final totalPresent = getTotalPresent();
    final totalAbsent = getTotalAbsent();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          const CustomTextContainer(
            textKey: confirmAttendanceSubmissionKey,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          const CustomTextContainer(
            textKey: areYouSureToSubmitAttendanceKey,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.tertiary,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  context,
                  Icons.check_circle,
                  presentKey,
                  totalPresent.toString(),
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(
                  context,
                  Icons.cancel,
                  absentKey,
                  totalAbsent.toString(),
                  const Color(0xFFF44336),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomTextContainer(
                      textKey: totalKey,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    CustomTextContainer(
                      textKey: widget.attendanceRecords.length.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Notification checkbox info
          if (widget.sendNotificationToAbsent) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: CustomTextContainer(
                      textKey: sendNotificationToAbsentStaffKey,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: CustomRoundedButton(
                  height: 48,
                  widthPercentage: 1.0,
                  backgroundColor: Colors.grey[300]!,
                  buttonTitle: cancelKey,
                  titleColor: Colors.black87,
                  showBorder: false,
                  onTap: widget.onCancel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomRoundedButton(
                  height: 48,
                  widthPercentage: 1.0,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  buttonTitle: confirmKey,
                  showBorder: false,
                  onTap: widget.onConfirm,
                ),
              ),
            ],
          ),

          // Add bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    IconData icon,
    String labelKey,
    String count,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            CustomTextContainer(
              textKey: labelKey,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomTextContainer(
            textKey: count,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
