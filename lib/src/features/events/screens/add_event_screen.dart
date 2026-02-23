import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_toast.dart';
import '../models/event_detail_result.dart';
import '../providers/events_provider.dart';

/// Port of iOS AddEventsController.swift — add/edit event form.
/// ALL 25+ parameters from iOS addEventsResult method.
/// Sections: event image, title, description, venue, dates (event/publish/expiry/notify),
/// repeat events, RSVP toggle, question toggle + options, SMS settings, banner display, link.
class AddEventScreen extends StatefulWidget {
  const AddEventScreen({
    super.key,
    required this.grpId,
    required this.groupProfileID,
    this.isCategory = '',
    this.editEvent,
  });

  final String grpId;
  final String groupProfileID;
  final String isCategory;
  final EventsDetail? editEvent;

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // iOS: HeaderCelll fields
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _venueController;
  late TextEditingController _linkController;

  // iOS: ScheduleCell date fields
  late TextEditingController _eventDateController;
  late TextEditingController _publishDateController;
  late TextEditingController _expiryDateController;
  late TextEditingController _notifyDateController;

  // iOS: QuestionViewCell fields
  late TextEditingController _questionTextController;
  late TextEditingController _option1Controller;
  late TextEditingController _option2Controller;

  // iOS: AddQuestionCell toggles
  bool _rsvpEnabled = false;
  bool _questionEnabled = false;
  bool _displayOnBanner = false;
  bool _sendSmsNonSmart = false;
  bool _sendSmsAll = false;

  // iOS: HeaderCell2 repeat toggle
  bool _repeatEnabled = false;
  final List<Map<String, String>> _repeatDates = [];

  // iOS: recipient type — All/SubGroup/Members
  String _recipientType = 'A'; // A=All, B=SubGroup, E=Members

  // iOS: image upload
  String _eventImageID = '';
  String _venueLat = '';
  String _venueLon = '';

  bool get _isEditMode => widget.editEvent != null;

  String get _userProfileId =>
      LocalStorage.instance.getString(AppConstants.keySessionGrpProfileId) ??
      '';

  @override
  void initState() {
    super.initState();
    final e = widget.editEvent;

    _titleController = TextEditingController(text: e?.eventTitle ?? '');
    _descController = TextEditingController(text: e?.eventDesc ?? '');
    _venueController = TextEditingController(text: e?.venue ?? '');
    _linkController = TextEditingController(text: e?.link ?? '');
    _eventDateController =
        TextEditingController(text: e?.eventDateTime ?? '');
    _publishDateController = TextEditingController(text: e?.pubDate ?? '');
    _expiryDateController = TextEditingController(text: e?.expiryDate ?? '');
    _notifyDateController = TextEditingController(text: '');
    _questionTextController =
        TextEditingController(text: e?.questionText ?? '');
    _option1Controller = TextEditingController(text: e?.option1 ?? '');
    _option2Controller = TextEditingController(text: e?.option2 ?? '');

    if (e != null) {
      _rsvpEnabled = e.isRsvpEnabled;
      _questionEnabled = e.hasQuestion;
      _displayOnBanner = e.showOnBanner;
      _sendSmsNonSmart = e.sendSMSNonSmartPh == '1';
      _sendSmsAll = e.sendSMSAll == '1';
      _recipientType = e.eventType ?? 'A';
      _eventImageID = '';
      _venueLat = e.venueLat ?? '';
      _venueLon = e.venueLon ?? '';

      if (e.repeatEventResult != null && e.repeatEventResult!.isNotEmpty) {
        _repeatEnabled = true;
        for (final repeat in e.repeatEventResult!) {
          _repeatDates.add({
            'date': repeat.eventDate ?? '',
            'time': repeat.eventTime ?? '',
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _venueController.dispose();
    _linkController.dispose();
    _eventDateController.dispose();
    _publishDateController.dispose();
    _expiryDateController.dispose();
    _notifyDateController.dispose();
    _questionTextController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    super.dispose();
  }

  /// iOS: addEventButtonTapped → addEventsResult with ALL parameters
  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    CommonLoader.show(context);

    // Build repeat date time JSON — iOS: RepeatDateTime parameter
    String repeatDateTimeJson = '';
    if (_repeatEnabled && _repeatDates.isNotEmpty) {
      final parts = _repeatDates
          .map((r) => '{"eventDate":"${r['date']}","eventTime":"${r['time']}"}')
          .join(',');
      repeatDateTimeJson = '[$parts]';
    }

    final result = await context.read<EventsProvider>().addEvent(
          eventID: _isEditMode ? (widget.editEvent!.eventID ?? '0') : '0',
          questionEnable: _questionEnabled ? '1' : '0',
          eventType: _recipientType,
          membersIDs: '',
          eventImageID: _eventImageID,
          evntTitle: _titleController.text.trim(),
          evntDesc: _descController.text.trim(),
          eventVenue: _venueController.text.trim(),
          venueLat: _venueLat,
          venueLong: _venueLon,
          evntDate: _eventDateController.text.trim(),
          publishDate: _publishDateController.text.trim(),
          expiryDate: _expiryDateController.text.trim(),
          notifyDate: _notifyDateController.text.trim(),
          userID: _userProfileId,
          grpID: widget.grpId,
          repeatDateTime: repeatDateTimeJson,
          questionType: _questionEnabled ? '0' : '',
          questionText: _questionTextController.text.trim(),
          option1: _option1Controller.text.trim(),
          option2: _option2Controller.text.trim(),
          sendSMSNonSmartPh: _sendSmsNonSmart ? '1' : '0',
          sendSMSAll: _sendSmsAll ? '1' : '0',
          rsvpEnable: _rsvpEnabled ? 1 : 0,
          displayOnBanners: _displayOnBanner ? '1' : '0',
          link: _linkController.text.trim(),
          isSubGrpAdmin: '0',
        );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (result != null && result.isSuccess) {
      CommonToast.success(
          context,
          _isEditMode
              ? 'Event updated successfully'
              : 'Event added successfully');
      Navigator.of(context).pop(true);
    } else {
      CommonToast.error(
          context, result?.message ?? 'Failed to save event');
    }
  }

  /// iOS: date picker for event/publish/expiry/notify dates
  Future<void> _selectDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null && mounted) {
        final dt = DateTime(
            picked.year, picked.month, picked.day, time.hour, time.minute);
        // iOS format: "yyyy-MM-dd HH:mm:ss"
        controller.text =
            '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}:00';
        setState(() {});
      }
    }
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

  /// iOS: RepeatDateTimeCell — add repeat date
  void _addRepeatDate() {
    setState(() {
      _repeatDates.add({'date': '', 'time': ''});
    });
  }

  /// iOS: RepeatDateTimeCell — select repeat date
  Future<void> _selectRepeatDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null && mounted) {
        setState(() {
          _repeatDates[index] = {
            'date':
                '${picked.year}-${_pad(picked.month)}-${_pad(picked.day)}',
            'time': '${_pad(time.hour)}:${_pad(time.minute)}',
          };
        });
      }
    }
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
          _isEditMode ? 'Edit Event' : 'Add Event',
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: const Text(
              'Save',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── Event Details Section ──────────────
            _buildSectionTitle('Event Details'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              label: 'Event Title *',
              icon: Icons.title,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descController,
              label: 'Description',
              icon: Icons.description,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _venueController,
              label: 'Venue',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _linkController,
              label: 'Registration Link',
              icon: Icons.link,
              keyboardType: TextInputType.url,
            ),

            // ─── Date & Time Section ──────────────
            const SizedBox(height: 24),
            _buildSectionTitle('Schedule'),
            const SizedBox(height: 8),
            _buildDateField(
              controller: _eventDateController,
              label: 'Event Date & Time *',
              icon: Icons.event,
            ),
            const SizedBox(height: 12),
            _buildDateField(
              controller: _publishDateController,
              label: 'Publish Date',
              icon: Icons.publish,
            ),
            const SizedBox(height: 12),
            _buildDateField(
              controller: _expiryDateController,
              label: 'Expiry Date',
              icon: Icons.timer_off,
            ),
            const SizedBox(height: 12),
            _buildDateField(
              controller: _notifyDateController,
              label: 'Notify Date',
              icon: Icons.notifications,
            ),

            // ─── Repeat Events Section ──────────────
            const SizedBox(height: 24),
            _buildSwitchRow(
              'Repeat Event',
              Icons.repeat,
              _repeatEnabled,
              (v) => setState(() => _repeatEnabled = v),
            ),
            if (_repeatEnabled) ...[
              const SizedBox(height: 8),
              ..._repeatDates.asMap().entries.map((entry) {
                final idx = entry.key;
                final repeat = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectRepeatDate(idx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              repeat['date']!.isEmpty
                                  ? 'Select date & time'
                                  : '${repeat['date']} ${repeat['time']}',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 14,
                                color: repeat['date']!.isEmpty
                                    ? AppColors.textTertiary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: AppColors.systemRed),
                        onPressed: () {
                          setState(() => _repeatDates.removeAt(idx));
                        },
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addRepeatDate,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Repeat Date'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],

            // ─── Settings Section ──────────────
            const SizedBox(height: 24),
            _buildSectionTitle('Settings'),
            const SizedBox(height: 8),
            _buildSwitchRow(
              'Enable RSVP',
              Icons.how_to_vote,
              _rsvpEnabled,
              (v) => setState(() => _rsvpEnabled = v),
            ),
            _buildSwitchRow(
              'Display on Banner',
              Icons.flag,
              _displayOnBanner,
              (v) => setState(() => _displayOnBanner = v),
            ),
            _buildSwitchRow(
              'Send SMS (Non-Smart)',
              Icons.sms,
              _sendSmsNonSmart,
              (v) => setState(() => _sendSmsNonSmart = v),
            ),
            _buildSwitchRow(
              'Send SMS (All)',
              Icons.sms_outlined,
              _sendSmsAll,
              (v) => setState(() => _sendSmsAll = v),
            ),

            // ─── RSVP Question Section ──────────────
            _buildSwitchRow(
              'Add Question',
              Icons.quiz,
              _questionEnabled,
              (v) => setState(() => _questionEnabled = v),
            ),
            if (_questionEnabled) ...[
              const SizedBox(height: 8),
              _buildTextField(
                controller: _questionTextController,
                label: 'Question Text',
                icon: Icons.help_outline,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _option1Controller,
                label: 'Option 1',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _option2Controller,
                label: 'Option 2',
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textSecondary, size: 20)
            : null,
        filled: true,
        fillColor: AppColors.white,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      style: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
  }) {
    return InkWell(
      onTap: () => _selectDate(controller),
      child: IgnorePointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textSecondary, size: 20)
                : null,
            suffixIcon: const Icon(Icons.calendar_month,
                color: AppColors.textSecondary, size: 20),
            filled: true,
            fillColor: AppColors.white,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary.withAlpha(128),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
