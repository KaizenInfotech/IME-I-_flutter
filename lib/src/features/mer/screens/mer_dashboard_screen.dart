import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/mer_provider.dart';

/// Port of iOS MERDashViewController / iMelengaViewController.
/// Shared screen — constructor takes type ("1"=MER, "2"=iMelange) and title.
class MerDashboardScreen extends StatefulWidget {
  const MerDashboardScreen({
    super.key,
    required this.type,
    required this.title,
  });

  /// "1" for MER(I), "2" for iMelange.
  final String type;
  final String title;

  @override
  State<MerDashboardScreen> createState() => _MerDashboardScreenState();
}

class _MerDashboardScreenState extends State<MerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<MerProvider>();
    await provider.fetchYears(type: widget.type);
    if (!mounted) return;
    // Fetch list for the first year
    if (provider.selectedYear.isNotEmpty) {
      provider.fetchMerList(
        financeYear: provider.selectedYear,
        transType: widget.type,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: widget.title),
      body: Consumer<MerProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Year dropdown filter
              if (provider.years.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.white,
                  child: Row(
                    children: [
                      Text(
                        'Year: ',
                        style: AppTextStyles.body2
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        child: DropdownButton<String>(
                          value: provider.selectedYear.isNotEmpty
                              ? provider.selectedYear
                              : null,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: provider.years.map((year) {
                            return DropdownMenuItem<String>(
                              value: year.financeYear ?? '',
                              child: Text(
                                year.financeYear ?? '',
                                style: AppTextStyles.body2,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              provider.setSelectedYear(value);
                              provider.fetchMerList(
                                financeYear: value,
                                transType: widget.type,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 1),
              // List
              Expanded(child: _buildList(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(MerProvider provider) {
    if (provider.isLoading || provider.isLoadingYears) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.merItems.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.library_books,
        message: provider.error ?? 'No records found',
        onRetry: _loadData,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.merItems.length,
      itemBuilder: (_, index) {
        final item = provider.merItems[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              item.title ?? '',
              style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: item.publishDate != null
                ? Text(
                    item.publishDate!,
                    style: AppTextStyles.caption,
                  )
                : null,
            trailing: const Icon(
              Icons.open_in_new,
              size: 18,
              color: AppColors.primary,
            ),
            onTap: () => _openDocument(item.displayUrl),
          ),
        );
      },
    );
  }

  /// iOS: MERWebViewController — opens doc in web view.
  /// Using url_launcher for simplicity.
  Future<void> _openDocument(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
