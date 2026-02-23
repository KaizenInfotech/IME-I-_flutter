# Phase 16: Documents Feature

## Priority: 16
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DocumentListAndDetailController/DocumentListViewControlller.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DocumentListAndDetailController/DocumentsDetailController.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/DocumentListAndDetailController/ShowDocumentViewController.swift

Read WebserviceClass.swift for:
4. addDocument, getDocumentList, updateDocumentIsRead methods

Read Obj-C models:
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/ControllerObjectiveC/ (find TBDocumentistResult, TBAddDocumentResult folders)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/documents/models/document_list_result.dart
2. lib/src/features/documents/models/add_document_result.dart

PROVIDERS:
3. lib/src/features/documents/providers/documents_provider.dart
   - EXACT same logic: document CRUD, background download with progress
   - Download uses ApiClient.downloadFile (http streamed request) matching iOS URLSessionDownloadDelegate pattern
   - State: documents list, selectedDocument, isLoading, isDownloading, downloadProgress, error
   - Methods: fetchDocuments(), addDocument(), updateDocumentIsRead(), downloadDocument()

SCREENS:
4. lib/src/features/documents/screens/documents_list_screen.dart
5. lib/src/features/documents/screens/document_detail_screen.dart
6. lib/src/features/documents/screens/document_viewer_screen.dart - in-app PDF/file viewer (flutter_pdfview)

WIDGETS:
7. lib/src/features/documents/widgets/document_list_tile.dart
8. lib/src/features/documents/widgets/download_progress.dart

STRICT RULES:
- EXACT same API endpoints, parameters, and download pattern as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/DocumentListAndDetailController/` (all 3 files)
- `WebserviceClass.swift` (document methods)
- `ControllerObjectiveC/` (TBDocumentistResult, TBAddDocumentResult)

## Expected Output Files
- `lib/src/features/documents/models/document_list_result.dart`
- `lib/src/features/documents/models/add_document_result.dart`
- `lib/src/features/documents/providers/documents_provider.dart`
- `lib/src/features/documents/screens/documents_list_screen.dart`
- `lib/src/features/documents/screens/document_detail_screen.dart`
- `lib/src/features/documents/screens/document_viewer_screen.dart`
- `lib/src/features/documents/widgets/document_list_tile.dart`
- `lib/src/features/documents/widgets/download_progress.dart`
