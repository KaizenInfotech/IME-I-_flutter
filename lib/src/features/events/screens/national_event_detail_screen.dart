import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_loader.dart';
import '../../../core/widgets/common_toast.dart';
import '../providers/events_provider.dart';

/// Port of iOS NationalEventDetailViewController.swift.
/// Shows national/district event details: title, date, description,
/// venue, photo, and registration link.
/// Can be loaded from passed data or fetched via API (when isFrom == "notify").
class NationalEventDetailScreen extends StatefulWidget {
  const NationalEventDetailScreen({
    super.key,
    this.eventId,
    this.groupId,
    this.profileId,
    this.titleName,
    this.dateOfEvent,
    this.description,
    this.eventVenue,
    this.photoUrl,
    this.regLink,
    this.isFrom,
  });

  final String? eventId;
  final String? groupId;
  final String? profileId;
  final String? titleName;
  final String? dateOfEvent;
  final String? description;
  final String? eventVenue;
  final String? photoUrl;
  final String? regLink;
  final String? isFrom;

  @override
  State<NationalEventDetailScreen> createState() =>
      _NationalEventDetailScreenState();
}

class _NationalEventDetailScreenState extends State<NationalEventDetailScreen> {
  // Local state for data passed directly
  String? _title;
  String? _date;
  String? _description;
  String? _venue;
  String? _photo;
  String? _link;

  @override
  void initState() {
    super.initState();

    // iOS: if isFrom == "notify", fetch from API; otherwise use passed data
    if (widget.isFrom == 'notify' &&
        widget.eventId != null &&
        widget.eventId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchEventDetail());
    } else {
      _title = widget.titleName;
      _date = widget.dateOfEvent;
      _description = widget.description;
      _venue = widget.eventVenue;
      _photo = widget.photoUrl;
      _link = widget.regLink;
    }
  }

  /// iOS: getEventsDetail → POST Event/GetEventDetails
  Future<void> _fetchEventDetail() async {
    final provider = context.read<EventsProvider>();
    CommonLoader.show(context);

    final success = await provider.fetchEventDetail(
      groupProfileID: widget.profileId ?? '',
      eventID: widget.eventId ?? '',
      grpId: widget.groupId ?? '',
    );

    if (!mounted) return;
    CommonLoader.dismiss(context);

    if (success) {
      final event = provider.selectedEvent;
      if (event != null) {
        setState(() {
          _title = event.eventTitle;
          _date = event.eventDateTime;
          _description = event.eventDesc;
          _venue = event.venue;
          _photo = event.eventImg;
          _link = event.link;
        });
      }
    } else if (provider.error != null) {
      CommonToast.error(context, provider.error!);
    }
  }

  void _openLink() async {
    if (_link == null || _link!.isEmpty) return;
    String url = _link!.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
        title: const Text(
          'Upcoming Event Details',
          style: TextStyle(
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
            // iOS: TitleofEvent
            if (_title != null && _title!.isNotEmpty)
              Text(
                _title!,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            const SizedBox(height: 8),

            // iOS: eventDate
            if (_date != null && _date!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    _date!,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // iOS: DescriptionEvent (numberOfLines = 3 in iOS, unlimited here)
            if (_description != null && _description!.isNotEmpty)
              Text(
                _description!,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 12),

            // iOS: evenueDetail
            if (_venue != null && _venue!.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on,
                      size: 18, color: AppColors.systemRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _venue!,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // iOS: linkName button
            if (_link != null && _link!.isNotEmpty)
              GestureDetector(
                onTap: _openLink,
                child: Row(
                  children: [
                    const Icon(Icons.link,
                        size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _link!,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          color: AppColors.primaryBlue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // iOS: ImageEvent — only shown if photo URL exists
            if (_photo != null && _photo!.isNotEmpty) ...[
              const Text(
                'Photo',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _photo!.replaceAll(' ', '%20'),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 200,
                    color: AppColors.backgroundGray,
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          color: AppColors.textSecondary, size: 48),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
