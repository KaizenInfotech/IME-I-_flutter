import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/monthly_report_provider.dart';
import 'monthly_pdf_view_screen.dart';

/// Port of iOS MontlyPDFListViewControllerViewController.
/// Displays list of downloaded PDF/document files from app Documents directory.
class MonthlyPdfListScreen extends StatefulWidget {
  const MonthlyPdfListScreen({
    super.key,
    this.moduleName = 'Downloaded Document list',
  });

  final String moduleName;

  @override
  State<MonthlyPdfListScreen> createState() => _MonthlyPdfListScreenState();
}

class _MonthlyPdfListScreenState extends State<MonthlyPdfListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MonthlyReportProvider>().fetchDownloadedDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: widget.moduleName),
      body: Consumer<MonthlyReportProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = provider.reports;
          if (list.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.description,
              message: 'No downloaded documents',
            );
          }

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, index) {
              final file = list[index];
              final fileName = file.path.split('/').last;

              return Container(
                color: AppColors.white,
                margin: const EdgeInsets.only(bottom: 1),
                child: ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf,
                    color: AppColors.systemRed,
                    size: 28,
                  ),
                  title: Text(
                    fileName,
                    style: AppTextStyles.body2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MonthlyPdfViewScreen(
                          urlStr: file.path,
                          isLocalFile: true,
                          moduleName: 'Downloaded Document',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
