import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_text_field.dart';
import '../../../core/widgets/common_toast.dart';
import '../models/album_detail_result.dart';
import '../providers/gallery_provider.dart';

/// Port of iOS AddPhotoViewController (album creation section).
/// Form for creating or editing an album with category, cost, beneficiary fields.
class CreateAlbumScreen extends StatefulWidget {
  const CreateAlbumScreen({
    super.key,
    required this.groupId,
    required this.profileId,
    this.moduleId = '',
    this.existingAlbum,
  });

  final String groupId;
  final String profileId;
  final String moduleId;
  final AlbumDetail? existingAlbum;

  @override
  State<CreateAlbumScreen> createState() => _CreateAlbumScreenState();
}

class _CreateAlbumScreenState extends State<CreateAlbumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _beneficiaryController = TextEditingController();
  final _costController = TextEditingController();
  final _manHoursController = TextEditingController();
  final _rotarianCountController = TextEditingController();
  final _otherCategoryController = TextEditingController();

  String _shareType = 'Public';
  String _categoryId = '';
  String _costType = 'Rupee';
  String _manHoursType = 'Hours';
  String _type = 'Album';
  String _dateOfProject = '';

  bool get _isEditing => widget.existingAlbum != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final album = widget.existingAlbum!;
      _titleController.text = album.albumTitle ?? '';
      _descController.text = album.albumDescription ?? '';
      _beneficiaryController.text = album.beneficiary ?? '';
      _costController.text = album.projectCost ?? '';
      _manHoursController.text = album.workingHour ?? '';
      _rotarianCountController.text = album.numberOfRotarian ?? '';
      _otherCategoryController.text = album.otherCategoryText ?? '';
      _shareType = album.shareType ?? 'Public';
      _categoryId = album.albumCategoryID ?? '';
      _costType = album.costOfProjectType ?? 'Rupee';
      _manHoursType = album.workingHourType ?? 'Hours';
      _type = album.type ?? 'Album';
      _dateOfProject = album.projectDate ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _beneficiaryController.dispose();
    _costController.dispose();
    _manHoursController.dispose();
    _rotarianCountController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<GalleryProvider>();
    final result = await provider.createOrUpdateAlbum(
      albumId: widget.existingAlbum?.albumId ?? '0',
      groupId: widget.groupId,
      type: _type,
      memberIds: '',
      albumTitle: _titleController.text.trim(),
      albumDescription: _descController.text.trim(),
      albumImage: '',
      createdBy: widget.profileId,
      moduleId: widget.moduleId,
      shareType: _shareType,
      categoryId: _categoryId,
      dateOfProject: _dateOfProject,
      costOfProject: _costController.text.trim(),
      beneficiary: _beneficiaryController.text.trim(),
      manHoursSpent: _manHoursController.text.trim(),
      manHoursSpentType: _manHoursType,
      numberOfRotarian: _rotarianCountController.text.trim(),
      otherCategoryText: _otherCategoryController.text.trim(),
      costOfProjectType: _costType,
    );

    if (!mounted) return;

    if (result != null && result.isSuccess) {
      CommonToast.success(
          context, _isEditing ? 'Album updated' : 'Album created');
      Navigator.pop(context);
    } else {
      CommonToast.error(context, 'Failed to save album');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateOfProject =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(
        title: _isEditing ? 'Edit Album' : 'Create Album',
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.textOnPrimary),
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
              // Album Title
              CommonTextField(
                controller: _titleController,
                label: 'Album Title *',
                hint: 'Enter album title',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Album title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              CommonTextField(
                controller: _descController,
                label: 'Description',
                hint: 'Enter album description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Share Type
              Text('Share Type', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildShareChip('Public'),
                  const SizedBox(width: 8),
                  _buildShareChip('Private'),
                ],
              ),
              const SizedBox(height: 16),

              // Date of Project
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: CommonTextField(
                    label: 'Date of Project',
                    hint: _dateOfProject.isEmpty
                        ? 'Select date'
                        : _dateOfProject,
                    suffixIcon: const Icon(Icons.calendar_today, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Beneficiary
              CommonTextField(
                controller: _beneficiaryController,
                label: 'Beneficiary',
                hint: 'Enter beneficiary',
              ),
              const SizedBox(height: 16),

              // Cost of Project
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CommonTextField(
                      controller: _costController,
                      label: 'Cost of Project',
                      hint: 'Enter cost',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _costType,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        border: UnderlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Rupee', child: Text('INR')),
                        DropdownMenuItem(value: 'Dollar', child: Text('USD')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _costType = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Man Hours Spent
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CommonTextField(
                      controller: _manHoursController,
                      label: 'Man Hours Spent',
                      hint: 'Enter hours',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _manHoursType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: UnderlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Hours', child: Text('Hours')),
                        DropdownMenuItem(value: 'Days', child: Text('Days')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _manHoursType = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Number of Rotarians
              CommonTextField(
                controller: _rotarianCountController,
                label: 'Number of Rotarians',
                hint: 'Enter count',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Other Category Text
              CommonTextField(
                controller: _otherCategoryController,
                label: 'Other Category',
                hint: 'Enter category text if applicable',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareChip(String type) {
    final isSelected = _shareType == type;
    return ChoiceChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (_) => setState(() => _shareType = type),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.textPrimary,
        fontSize: 14,
      ),
    );
  }
}
