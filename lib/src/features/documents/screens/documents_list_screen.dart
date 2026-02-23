import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_toast.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/document_list_result.dart';
import '../providers/documents_provider.dart';
import '../widgets/document_list_tile.dart';
import '../widgets/download_progress.dart';
import 'document_detail_screen.dart';

/// Port of iOS DocumentListViewControlller — document list with search & type filter.
/// iOS: Published/All/Scheduled/Expired filter, search, download, delete.
class DocumentsListScreen extends StatefulWidget {
  const DocumentsListScreen({
    super.key,
    this.groupId,
    this.profileId,
    this.isAdmin = false,
    this.moduleId = '',
  });

  final String? groupId;
  final String? profileId;
  final bool isAdmin;
  final String moduleId;

  @override
  State<DocumentsListScreen> createState() => _DocumentsListScreenState();
}

class _DocumentsListScreenState extends State<DocumentsListScreen> {
  final _searchController = TextEditingController();
  String _groupId = '';
  String _profileId = '';

  /// iOS: annType — "0"=All, "1"=Published, "2"=Scheduled, "3"=Expired
  String _docType = '1';
  final List<String> _typeLabels = ['Published', 'All', 'Scheduled', 'Expired'];
  final List<String> _typeValues = ['1', '0', '2', '3'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final localStorage = LocalStorage.instance;
    _profileId = widget.profileId ?? localStorage.authProfileId ?? '';
    _groupId = widget.groupId ?? localStorage.authGroupId ?? '';
    _fetchDocuments();
  }

  void _fetchDocuments() {
    context.read<DocumentsProvider>().fetchDocuments(
          groupId: _groupId,
          memberProfileId: _profileId,
          type: _docType,
          isAdmin: widget.isAdmin ? '1' : '0',
          searchText: _searchController.text.trim(),
        );
  }

  void _onSearch(String query) {
    _fetchDocuments();
  }

  Future<void> _onDeleteDocument(DocumentItem doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${doc.docTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.systemRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<DocumentsProvider>().deleteDocument(
          docId: doc.docID ?? '',
          profileId: _profileId,
        );

    if (!mounted) return;
    if (success) {
      CommonToast.success(context, 'Document deleted');
    } else {
      CommonToast.error(context, 'Failed to delete document');
    }
  }

  void _onDocumentTap(DocumentItem doc) {
    // Mark as read
    context.read<DocumentsProvider>().updateDocumentIsRead(
          docId: doc.docID ?? '',
          memberProfileId: _profileId,
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentDetailScreen(
          document: doc,
          profileId: _profileId,
          isAdmin: widget.isAdmin,
        ),
      ),
    ).then((_) => _fetchDocuments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CommonAppBar(title: 'Documents'),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search documents...',
                      hintStyle: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        color: AppColors.grayMedium,
                      ),
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.grayMedium),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppColors.grayMedium),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.backgroundGray,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Type filter (admin only, like iOS picker)
                if (widget.isAdmin) ...[
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list,
                        color: AppColors.primary),
                    onSelected: (val) {
                      setState(() => _docType = val);
                      _fetchDocuments();
                    },
                    itemBuilder: (_) => List.generate(
                      _typeLabels.length,
                      (i) => PopupMenuItem(
                        value: _typeValues[i],
                        child: Row(
                          children: [
                            if (_docType == _typeValues[i])
                              const Icon(Icons.check,
                                  color: AppColors.primary, size: 18)
                            else
                              const SizedBox(width: 18),
                            const SizedBox(width: 8),
                            Text(_typeLabels[i]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // Document list
          Expanded(
            child: Consumer<DocumentsProvider>(
              builder: (context, provider, _) {
                return Stack(
                  children: [
                    _buildList(provider),
                    if (provider.isDownloading)
                      DownloadProgressWidget(
                        progress: provider.downloadProgress,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(DocumentsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        message: provider.error!,
        onRetry: _fetchDocuments,
        retryLabel: 'Retry',
      );
    }

    if (provider.documents.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.folder_open,
        message: 'No documents found',
        onRetry: _fetchDocuments,
        retryLabel: 'Refresh',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _fetchDocuments(),
      child: ListView.builder(
        itemCount: provider.documents.length,
        itemBuilder: (_, index) {
          final doc = provider.documents[index];
          return DocumentListTile(
            document: doc,
            isAdmin: widget.isAdmin,
            onTap: () => _onDocumentTap(doc),
            onDownload: () => _onDocumentTap(doc),
            onDelete: () => _onDeleteDocument(doc),
          );
        },
      ),
    );
  }
}
