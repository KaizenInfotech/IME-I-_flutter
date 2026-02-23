import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/web_links_provider.dart';
import '../widgets/web_link_tile.dart';
import 'web_link_detail_screen.dart';

/// Port of iOS WebLinkListViewController — list of web links.
class WebLinksScreen extends StatefulWidget {
  const WebLinksScreen({
    super.key,
    required this.groupId,
    this.moduleName = 'Web Links',
  });

  final String groupId;
  final String moduleName;

  @override
  State<WebLinksScreen> createState() => _WebLinksScreenState();
}

class _WebLinksScreenState extends State<WebLinksScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WebLinksProvider>().fetchWebLinks(groupId: widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: widget.moduleName),
      body: Consumer<WebLinksProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = provider.webLinks;
          if (list.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.link_off,
              message: provider.error ?? 'No web links available',
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                provider.fetchWebLinks(groupId: widget.groupId),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, index) {
                final item = list[index];
                return WebLinkTile(
                  item: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WebLinkDetailScreen(
                          item: item,
                          moduleName: widget.moduleName,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
