import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_text_field.dart';
import '../../../core/widgets/common_toast.dart';
import '../providers/ebulletin_provider.dart';

/// Port of iOS AddEBulletineController — create e-bulletin form.
/// iOS: Title, recipient selection (All/SubGroup/Members), URL or PDF,
/// SMS toggle, publish date/time.
class AddEbulletinScreen extends StatefulWidget {
  const AddEbulletinScreen({
    super.key,
    required this.groupId,
    required this.profileId,
    this.moduleId = '',
    this.isSubGrpAdmin = false,
  });

  final String groupId;
  final String profileId;
  final String moduleId;
  final bool isSubGrpAdmin;

  @override
  State<AddEbulletinScreen> createState() => _AddEbulletinScreenState();
}

class _AddEbulletinScreenState extends State<AddEbulletinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();

  /// iOS: ebullTypeStr — "0"=All, "1"=SubGroup, "2"=Members
  String _recipientType = '0';
  DateTime? _publishDate;
  bool _sendSMS = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickPublishDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _publishDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    setState(() {
      _publishDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatDate(DateTime date) {
    // iOS format: "yyyy-MM-dd HH:mm:00"
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}:00';
  }

  String _formatDateDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  /// iOS: verifyUrl — adds https:// if missing
  String _normalizeUrl(String url) {
    if (url.isEmpty) return url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // iOS validations
    final title = _titleController.text.trim();
    final link = _linkController.text.trim();

    if (title.isEmpty) {
      CommonToast.show(context, 'Please enter a title');
      return;
    }

    if (link.isEmpty) {
      CommonToast.show(context, 'Please enter a URL link');
      return;
    }

    if (_publishDate == null) {
      CommonToast.show(context, 'Please select a publish date');
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<EbulletinProvider>();
    final result = await provider.addEbulletin(
      ebulletinType: _recipientType,
      ebulletinTitle: title,
      ebulletinlink: _normalizeUrl(link),
      memID: widget.profileId,
      grpID: widget.groupId,
      publishDate: _formatDate(_publishDate!),
      // iOS: expiry fixed to far future
      expiryDate: '2099-04-05 15:09:00',
      sendSMSAll: _sendSMS ? '1' : '0',
      isSubGrpAdmin: widget.isSubGrpAdmin ? '1' : '0',
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result != null && result.isSuccess) {
      CommonToast.success(context, 'E-Bulletin added successfully');
      Navigator.pop(context);
    } else {
      CommonToast.error(context, result?.message ?? 'Failed to add e-bulletin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: 'Add E-Bulletin',
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation(AppColors.textOnPrimary),
                ),
              ),
            )
          else
            IconButton(
              icon:
                  const Icon(Icons.check, color: AppColors.textOnPrimary),
              onPressed: _save,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipient type (iOS: All/SubGroup/Members radio)
              Text('Recipients', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildRecipientChip('All', '0'),
                  const SizedBox(width: 8),
                  _buildRecipientChip('Sub Groups', '1'),
                  const SizedBox(width: 8),
                  _buildRecipientChip('Members', '2'),
                ],
              ),
              const SizedBox(height: 20),

              // Title
              CommonTextField(
                controller: _titleController,
                label: 'Title *',
                hint: 'Enter e-bulletin title',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Redirect Link / URL
              CommonTextField(
                controller: _linkController,
                label: 'Redirect Link *',
                hint: 'Enter URL (e.g. www.example.com)',
                keyboardType: TextInputType.url,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'URL is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // SMS toggle (iOS: SmsQuestionCell)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Send WhatsApp notification',
                        style: AppTextStyles.body2,
                      ),
                    ),
                    Switch(
                      value: _sendSMS,
                      onChanged: (val) => setState(() => _sendSMS = val),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Publish Date (iOS: ScheduleCell row 2)
              Text('Publish Date & Time *', style: AppTextStyles.label),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickPublishDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        _publishDate != null
                            ? _formatDateDisplay(_publishDate!)
                            : 'Select publish date & time',
                        style: _publishDate != null
                            ? AppTextStyles.body2
                            : AppTextStyles.inputHint,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientChip(String label, String value) {
    final isSelected = _recipientType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _recipientType = value),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.textPrimary,
        fontSize: 13,
      ),
    );
  }
}
