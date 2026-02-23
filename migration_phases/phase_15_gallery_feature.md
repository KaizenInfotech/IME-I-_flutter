# Phase 15: Gallery Feature

## Priority: 15
## Depends On: Phase 10

---

## Command Prompt

```
I am migrating an iOS app to Flutter.

Read these iOS source files CAREFULLY:
1. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/GalleryViewController/AddPhotoViewController.swift
2. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/GalleryViewController/AlbumPhotosViewController.swift
3. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/GalleryViewController/CreateAlbumViewController.swift
4. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/GalleryViewController/GalleryOffline/ (ALL files)
5. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/GalleryViewController/PhotosVC/ (ALL files)
6. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/GalleryCategory/GalleryCatyegoryNewViewController.swift
7. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/GalleryCategory/ShowCaseAlbumListViewController.swift
8. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Controllers/GalleryCategory/NewShowCasePhotoDetailsVC.swift
9. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/TouchBase/Classes/Model/Gallery/CreateAlbumModel.swift

Read WebserviceClass.swift for:
10. getAlbumsList, getAlbumPhotoList, addUpdateAlbum, deleteAlbumPhoto, getAlbumDetails, uploadImage methods

Also read:
11. /Users/ios2/Documents/Mani_mac_folder/IMEI-iConnect/folder_details.md (Section 4.6)

Now create in /Users/ios2/Documents/Mani_mac_folder/touchbase_flutter/:

MODELS:
1. lib/src/features/gallery/models/album_list_result.dart
2. lib/src/features/gallery/models/album_detail_result.dart
3. lib/src/features/gallery/models/create_album_model.dart
4. lib/src/features/gallery/models/delete_result.dart

PROVIDERS:
5. lib/src/features/gallery/providers/gallery_provider.dart
   - EXACT same logic: album CRUD, 5-image batch upload, photo delete
   - Upload uses multipart FormData matching iOS pattern
   - State: albums list, selectedAlbum, photos list, isLoading, isUploading, uploadProgress, error
   - Methods: fetchAlbums(), fetchAlbumPhotos(), createAlbum(), uploadPhotos(), deletePhoto()

SCREENS:
6. lib/src/features/gallery/screens/gallery_screen.dart - category-based album grid
7. lib/src/features/gallery/screens/album_photos_screen.dart - photo grid
8. lib/src/features/gallery/screens/add_photo_screen.dart - 5-image batch picker + upload
9. lib/src/features/gallery/screens/create_album_screen.dart - album form
10. lib/src/features/gallery/screens/showcase_albums_screen.dart
11. lib/src/features/gallery/screens/photo_detail_screen.dart - full screen with zoom (photo_view)

WIDGETS:
12. lib/src/features/gallery/widgets/album_grid_item.dart
13. lib/src/features/gallery/widgets/photo_grid_item.dart
14. lib/src/features/gallery/widgets/multi_image_picker.dart - 5-image batch picker

STRICT RULES:
- EXACT same API endpoints, parameters, and 5-image batch upload logic as iOS
- ALL nullable, NO force unwraps
- Provider + Consumer + FutureBuilder
```

---

## iOS Source Files to Read
- `TouchBase/Controllers/GalleryViewController/` (all files and subfolders)
- `TouchBase/Controllers/GalleryCategory/` (all files)
- `TouchBase/Classes/Model/Gallery/CreateAlbumModel.swift`
- `WebserviceClass.swift` (gallery/upload methods)
- `folder_details.md` (Section 4.6)

## Expected Output Files
- `lib/src/features/gallery/models/album_list_result.dart`
- `lib/src/features/gallery/models/album_detail_result.dart`
- `lib/src/features/gallery/models/create_album_model.dart`
- `lib/src/features/gallery/models/delete_result.dart`
- `lib/src/features/gallery/providers/gallery_provider.dart`
- `lib/src/features/gallery/screens/gallery_screen.dart`
- `lib/src/features/gallery/screens/album_photos_screen.dart`
- `lib/src/features/gallery/screens/add_photo_screen.dart`
- `lib/src/features/gallery/screens/create_album_screen.dart`
- `lib/src/features/gallery/screens/showcase_albums_screen.dart`
- `lib/src/features/gallery/screens/photo_detail_screen.dart`
- `lib/src/features/gallery/widgets/album_grid_item.dart`
- `lib/src/features/gallery/widgets/photo_grid_item.dart`
- `lib/src/features/gallery/widgets/multi_image_picker.dart`
