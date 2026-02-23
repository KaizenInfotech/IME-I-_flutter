import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_toast.dart';
import '../models/announcement_list_result.dart';
import '../providers/announcements_provider.dart';

/// Port of iOS AddAnnounceController.swift — add/edit announcement form.
/// Blocks: recipient selection, image, title, description, SMS settings,
/// publish date/time, expiry date/time, reminder dates, link.
class AddAnnouncementScreen extends StatefulWidget {
  const AddAnnouncementScreen({
    super.key,
    required this.groupId,
    required this.profileId,
    this.moduleId = '',
    this.isSubGrpAdmin = false,
    this.existingAnnouncement,
  });

  final String groupId;
  final String profileId;
  final String moduleId;
  final bool isSubGrpAdmin;

  /// iOS: when isCalledFrom == "list", this is set for editing
  final AnnounceList? existingAnnouncement;

  @override
  State<AddAnnouncementScreen> createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();

  bool get _isEditMode => widget.existingAnnouncement != null;

  // iOS: varSubGrouporMember — 0=all, 1=subgroups, 2=members
  int _recipientType = 0;
  String _inputIDs = '';

  // iOS: allSMSFlag, nonSmartSMSFlag
  bool _sendSMSAll = false;
  bool _sendSMSNonSmart = false;

  // Dates — iOS: varGetPSD/PST, varGetESD/EST
  DateTime? _publishDate;
  DateTime? _expiryDate;

  // iOS: Reminder dates
  bool _reminderEnabled = false;
  final List<DateTime> _reminderDates = [];

  // Image
  String _imageId = '';

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _populateEditData();
    }
  }

  void _populateEditData() {
    final ann = widget.existingAnnouncement!;
    _titleController.text = ann.announTitle ?? '';
    _descriptionController.text = ann.announceDEsc ?? '';
    _linkController.text = ann.link ?? '';
    _imageId = ann.announImg ?? '';

    // iOS: type "0"=All, "1"=SubGroups, "2"=Members
    _recipientType = int.tryParse(ann.type ?? '0') ?? 0;
    _inputIDs = ann.profileIds ?? '';

    _sendSMSAll = ann.sendSMSAll == '1';
    _sendSMSNonSmart = ann.sendSMSNonSmartPh == '1';

    // Parse publish date
    if (ann.publishDate != null && ann.publishDate!.isNotEmpty) {
      _publishDate = DateTime.tryParse(ann.publishDate!);
    }
    // Parse expiry date
    if (ann.expiryDate != null && ann.expiryDate!.isNotEmpty) {
      _expiryDate = DateTime.tryParse(ann.expiryDate!);
    }

    // Parse reminder dates
    if (ann.repeatDateTime != null && ann.repeatDateTime!.isNotEmpty) {
      _reminderEnabled = true;
      final parts = ann.repeatDateTime!.split(',');
      for (final part in parts) {
        final dt = DateTime.tryParse(part.trim());
        if (dt != null) _reminderDates.add(dt);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  /// iOS: validation before save
  bool _validate() {
    if (_titleController.text.trim().isEmpty) {
      CommonToast.error(context, 'Please enter announcement title');
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) {
      CommonToast.error(context, 'Please enter announcement description');
      return false;
    }
    if (_publishDate == null) {
      CommonToast.error(context, 'Please select publish date');
      return false;
    }
    if (_expiryDate == null) {
      CommonToast.error(context, 'Please select expiry date');
      return false;
    }
    if (_expiryDate!.isBefore(_publishDate!)) {
      CommonToast.error(
          context, 'Expiry date must be after publish date');
      return false;
    }
    // iOS: reminder dates must be between publish and expiry
    for (final dt in _reminderDates) {
      if (dt.isBefore(_publishDate!) || dt.isAfter(_expiryDate!)) {
        CommonToast.error(
            context, 'Reminder dates must be between publish and expiry dates');
        return false;
      }
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) return;

    setState(() => _isSaving = true);

    // Format dates — iOS: "yyyy-MM-dd HH:mm"
    final publishStr = _formatDateTime(_publishDate!);
    final expiryStr = _formatDateTime(_expiryDate!);

    // Format reminder dates — iOS: CSV "yyyy-MM-dd HH:mm:00"
    final reminderStr = _reminderDates
        .map((dt) =>
            '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}:00')
        .join(',');

    final provider = context.read<AnnouncementsProvider>();
    final result = await provider.addAnnouncement(
      announID: _isEditMode
          ? (widget.existingAnnouncement!.announID ?? '0')
          : '0',
      annType: _recipientType.toString(),
      announTitle: _titleController.text.trim(),
      announceDEsc: _descriptionController.text.trim(),
      memID: widget.profileId,
      grpID: widget.groupId,
      inputIDs: _inputIDs,
      announImg: _imageId,
      publishDate: publishStr,
      expiryDate: expiryStr,
      sendSMSNonSmartPh: _sendSMSNonSmart ? '1' : '0',
      sendSMSAll: _sendSMSAll ? '1' : '0',
      moduleId: widget.moduleId,
      announcementRepeatDates: reminderStr,
      reglink: _linkController.text.trim(),
      isSubGrpAdmin: widget.isSubGrpAdmin ? '1' : '0',
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result != null && result.isSuccess) {
      CommonToast.success(
        context,
        _isEditMode
            ? 'Announcement updated successfully'
            : 'Announcement added successfully',
      );
      Navigator.pop(context);
    } else {
      CommonToast.error(
        context,
        result?.message ?? 'Failed to save announcement',
      );
    }
  }

  String _formatDateTime(DateTime dt) =>
      '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}';

  String _pad(int n) => n.toString().padLeft(2, '0');

  Future<void> _selectDate({
    required DateTime? current,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: current != null
          ? TimeOfDay.fromDateTime(current)
          : TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    onSelected(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  void _addReminderDate() {
    _selectDate(
      current: null,
      onSelected: (dt) {
        setState(() {
          _reminderDates.add(dt);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        title: Text(
          _isEditMode ? 'Edit Announcement' : 'Add Announcement',
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Block 1: Recipient type — iOS: All/SubGroup/Members radio buttons
            _buildSectionHeader('Send To'),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRadioChip(0, 'All'),
                const SizedBox(width: 8),
                _buildRadioChip(1, 'Sub Groups'),
                const SizedBox(width: 8),
                _buildRadioChip(2, 'Members'),
              ],
            ),
            const SizedBox(height: 20),

            // Block 3: Title — iOS: textfieldTitle
            _buildSectionHeader('Title'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
              ),
              decoration: _inputDecoration('Enter title'),
            ),
            const SizedBox(height: 20),

            // Block 4: Description — iOS: textViewDescription (max 2000 chars)
            _buildSectionHeader('Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 2000,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
              ),
              decoration: _inputDecoration('Enter description'),
            ),
            const SizedBox(height: 12),

            // Link — iOS: textfieldLink
            _buildSectionHeader('Link (Optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _linkController,
              keyboardType: TextInputType.url,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
              ),
              decoration: _inputDecoration('Enter link URL'),
            ),
            const SizedBox(height: 20),

            // Block 5: SMS settings — iOS: checkboxes
            _buildSectionHeader('Send SMS To'),
            const SizedBox(height: 8),
            _buildCheckbox(
              'All Members',
              _sendSMSAll,
              (val) => setState(() => _sendSMSAll = val ?? false),
            ),
            _buildCheckbox(
              'Non-Smartphone Users',
              _sendSMSNonSmart,
              (val) => setState(() => _sendSMSNonSmart = val ?? false),
            ),
            const SizedBox(height: 20),

            // Block 6: Publish Date — iOS: buttonSelectPublishDate/Time
            _buildSectionHeader('Publish Date & Time'),
            const SizedBox(height: 8),
            _buildDateButton(
              _publishDate,
              'Select Publish Date & Time',
              () => _selectDate(
                current: _publishDate,
                onSelected: (dt) => setState(() => _publishDate = dt),
              ),
            ),
            const SizedBox(height: 20),

            // Block 7: Expiry Date — iOS: buttonSelectExpireDate/Time
            _buildSectionHeader('Expiry Date & Time'),
            const SizedBox(height: 8),
            _buildDateButton(
              _expiryDate,
              'Select Expiry Date & Time',
              () => _selectDate(
                current: _expiryDate,
                onSelected: (dt) => setState(() => _expiryDate = dt),
              ),
            ),
            const SizedBox(height: 20),

            // Block 8: Reminders — iOS: switch + table of dates
            Row(
              children: [
                _buildSectionHeader('Reminder'),
                const Spacer(),
                Switch(
                  value: _reminderEnabled,
                  onChanged: (val) =>
                      setState(() => _reminderEnabled = val),
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withAlpha(128),
                ),
              ],
            ),
            if (_reminderEnabled) ...[
              const SizedBox(height: 8),
              ..._reminderDates.asMap().entries.map((entry) {
                final index = entry.key;
                final dt = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.alarm,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatDisplayDate(dt),
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Color(0xFFFF4C4D), size: 20),
                        onPressed: () {
                          setState(() => _reminderDates.removeAt(index));
                        },
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addReminderDate,
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Add Reminder',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Action buttons — iOS: buttonAdd / buttonCancel
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnPrimary,
                            ),
                          )
                        : Text(
                            _isEditMode ? 'Update' : 'Add',
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildRadioChip(int value, String label) {
    final isSelected = _recipientType == value;
    return GestureDetector(
      onTap: () => setState(() => _recipientType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 14,
        color: AppColors.grayMedium,
      ),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateButton(DateTime? date, String placeholder, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(
              date != null ? _formatDisplayDate(date) : placeholder,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                color: date != null ? AppColors.textPrimary : AppColors.grayMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDisplayDate(DateTime dt) =>
      '${_pad(dt.day)}/${_pad(dt.month)}/${dt.year} ${_pad(dt.hour)}:${_pad(dt.minute)}';
}
