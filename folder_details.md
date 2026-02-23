# IMEI-iConnect: iOS to Flutter Migration - Folder Structure Mapping

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Original iOS Project Structure](#2-original-ios-project-structure)
3. [Flutter Feature-First Directory Layout](#3-flutter-feature-first-directory-layout)
4. [Feature-by-Feature Mapping](#4-feature-by-feature-mapping)
5. [Shared / Core Layer Mapping](#5-shared--core-layer-mapping)
6. [State Management Strategy (Provider)](#6-state-management-strategy-provider)
7. [Swift ViewController to Flutter Widget Mapping Table](#7-swift-viewcontroller-to-flutter-widget-mapping-table)
8. [Navigation Mapping](#8-navigation-mapping)
9. [Third-Party Dependency Mapping](#9-third-party-dependency-mapping)
10. [Database & Local Storage Mapping](#10-database--local-storage-mapping)

---

## 1. Project Overview

**App Name:** TouchBase (IMEI-iConnect)
**Domain:** Rotary Organization Management (Clubs, Districts, Committees, Members, Presidents)
**Original Platform:** Native iOS (Swift 4.x + Objective-C)
**Target Platform:** Flutter (Dart)
**State Management:** Provider (ChangeNotifier)
**Networking:** Dio
**Data Safety:** All model fields nullable (`String?`, `int?`, etc.)
**No Force Unwrapping:** All access via `?.`, `??`, `Consumer`, `Selector`

### Application Context

This is an **Organization Management App** for Rotary International (IMEI-Connect). The hierarchy is:

```
Organization (Rotary International)
  └── Districts
        └── Clubs (Groups)
              ├── President
              ├── Board of Directors (BOD)
              ├── Committees (Sub-Groups)
              └── Members
                    └── Family Members
```

Key business domains:
- **Authentication:** OTP-based mobile login
- **Groups/Clubs:** Create, join, manage clubs with modules
- **Members:** Directory, profiles, family details, address management
- **Events:** RSVP, attendance, event photos, SMS notifications
- **Celebrations:** Birthdays, anniversaries, event calendar
- **Gallery:** Albums with multi-photo upload
- **Documents:** Upload/download with background transfers
- **E-Bulletins:** Year-wise newsletter/annual reports
- **Announcements:** Club-level announcements
- **Service Directory:** Business/vendor listings
- **Find Rotarian/Club:** Cross-district member and club search
- **Leaderboard:** Zone/year-wise member statistics
- **Settings:** Push notification, club/group settings
- **Notifications:** Push notification management with local DB
- **Web Links:** External resource links
- **Admin Modules:** Admin-specific sub-module access
- **District Features:** District-level directories, committees, clubs

---

## 2. Original iOS Project Structure

```
IMEI-iConnect/
├── AppDelegate/
│   ├── AppDelegate.swift                    # App lifecycle, push notifications, deep links
│   └── Reach.swift                          # Reachability helper
│
├── TouchBase/                               # Main app source
│   ├── Main.storyboard                      # Primary UI storyboard
│   ├── Launch Screen.storyboard             # Splash screen
│   ├── Info.plist                           # App configuration
│   ├── GoogleService-Info.plist             # Firebase config
│   ├── CountyCodes.plist                    # Country code data
│   │
│   ├── MISC/Constant/
│   │   ├── APIConstant.swift                # All API endpoint paths + TaskType enum + HTTPMethod enum
│   │   ├── AppConstant.swift                # App-level constants (empty)
│   │   └── ToastConstant.swift              # Toast messages (empty)
│   │
│   ├── ServiceManager/
│   │   ├── WebserviceClass.swift            # PRIMARY API class (3900+ lines, 100+ methods, singleton)
│   │   └── ServiceManager.swift             # Secondary API manager (Alamofire wrapper)
│   │
│   ├── Classes/CommonClasses/
│   │   ├── CommonAccessibleHoldVariable.swift  # Shared mutable state (DTO object)
│   │   ├── CommonExtension.swift               # UI extensions, date utils, validation
│   │   ├── CommonSqlite.swift                  # SQLite helpers (FMDB)
│   │   ├── CommonUserDefault.swift             # UserDefaults wrapper (empty)
│   │   ├── NavigationSettings.swift            # Navigation customization
│   │   └── ValidationExtension.swift           # Input validation extensions
│   │
│   ├── Classes/Model/Gallery/
│   │   └── CreateAlbumModel.swift              # Album creation model
│   │
│   ├── DataBase/
│   │   ├── DBmanager.swift                     # Database manager stub
│   │   ├── StudentInfo.swift                   # Student info model
│   │   ├── CalendarInfo.swift                  # Calendar info model
│   │   ├── CalenderInfo.swift                  # Calendar info model (duplicate)
│   │   ├── ModelManager.swift                  # Model manager
│   │   └── Util.swift                          # Utility functions
│   │
│   ├── OtherClasses/
│   │   ├── ContactEdit.swift                   # Core Data contact editing
│   │   └── ContactEdit+CoreDataProperties.swift
│   │
│   ├── Controllers/
│   │   ├── ControllerObjectiveC/               # Legacy Obj-C models & result parsers
│   │   │   ├── LoginResult/                    # LoginResult, LoginResultResponse DTOs
│   │   │   ├── TBGetSubGroupDetailListResult/
│   │   │   ├── Sub_Group_List/
│   │   │   ├── ADDFamilyMember/
│   │   │   ├── DeleteResult/
│   │   │   ├── GroupCreatedScreenResult/
│   │   │   ├── UpdateFamilyMember/
│   │   │   └── ... (30+ result model directories)
│   │   │
│   │   ├── MainDashboardViewController/        # MAIN DASHBOARD
│   │   │   ├── MainDashboardViewController.swift
│   │   │   ├── CustomisedDashViewController.swift
│   │   │   ├── CustumiseMyModuleViewController.swift
│   │   │   ├── GroupView_DashBoard/
│   │   │   │   ├── IMEI BranchView/
│   │   │   │   └── RotaryIndia/
│   │   │   └── ModuleDashboardViewController.swift
│   │   │
│   │   ├── MainDashBoardWithSidebar/           # SIDEBAR NAVIGATION
│   │   │   ├── MainDashboardWithSideBarViewController.swift
│   │   │   ├── RotaryMenuViewController.swift
│   │   │   ├── RotaryBlogs/
│   │   │   ├── RotaryNews/
│   │   │   └── NotificationSetting/
│   │   │
│   │   ├── SegmentMemberFamily/                # MEMBER/FAMILY SEGMENTS
│   │   │   ├── FamilySegmentViewController.swift
│   │   │   ├── ClubEventsListViewController.swift
│   │   │   ├── GallerySegmentClass/
│   │   │   └── MemberSegmentClass/
│   │   │
│   │   ├── DirectoryViewController/            # MEMBER DIRECTORY
│   │   │   ├── DirectoryViewController.swift
│   │   │   ├── ProfileInfoController.swift
│   │   │   ├── EditDirectoryController.swift
│   │   │   ├── JitoProfileViewController.swift
│   │   │   └── ProfileDynamicNewViewController.swift
│   │   │
│   │   ├── AttendanceViewController/           # ATTENDANCE
│   │   │   ├── AttendanceViewController.swift
│   │   │   ├── ChartClasses/
│   │   │   └── SubModules/
│   │   │
│   │   ├── EventsDetailController/             # EVENTS
│   │   │   ├── EventsDetailController.swift
│   │   │   ├── EventDetailScreenShotViewController.swift
│   │   │   └── CompletedActivitiesViewController.swift
│   │   │
│   │   ├── GalleryViewController/              # GALLERY
│   │   │   ├── AddPhotoViewController.swift
│   │   │   ├── AlbumPhotosViewController.swift
│   │   │   ├── CreateAlbumViewController.swift
│   │   │   ├── GalleryOffline/
│   │   │   └── PhotosVC/
│   │   │
│   │   ├── GalleryCategory/                    # GALLERY CATEGORIES (Showcase)
│   │   │   ├── GalleryCatyegoryNewViewController.swift
│   │   │   ├── ShowCaseAlbumListViewController.swift
│   │   │   └── NewShowCasePhotoDetailsVC.swift
│   │   │
│   │   ├── DocumentListAndDetailController/    # DOCUMENTS
│   │   │   ├── DocumentListViewControlller.swift
│   │   │   ├── DocumentsDetailController.swift
│   │   │   └── ShowDocumentViewController.swift
│   │   │
│   │   ├── E-BulletinListingController/        # E-BULLETINS
│   │   │   ├── EBulletinListingController.swift
│   │   │   ├── EbulletinDetailViewController.swift
│   │   │   └── EbulletineCell.swift
│   │   │
│   │   ├── ADDViewControllers/                 # ADD/CREATE FORMS
│   │   │   ├── Add_Announcement/
│   │   │   ├── Add_Eulletine/
│   │   │   ├── Add_Events/
│   │   │   └── Sub_GroupController/
│   │   │
│   │   ├── FindARotarians/                     # FIND ROTARIAN
│   │   │   ├── FinddArotarianViewController.swift
│   │   │   ├── RotarianProfileBusinessDetailsViewController.swift
│   │   │   └── SearchFindArotarianViewController.swift
│   │   │
│   │   ├── LeaderBoard/                        # LEADERBOARD
│   │   │   ├── LeaderBoardViewController.swift
│   │   │   ├── TableViewCustomeCell.swift
│   │   │   └── LeaderBoardCollectionViewCell.swift
│   │   │
│   │   ├── ServiceDirectoryListViewController/ # SERVICE DIRECTORY
│   │   │   ├── ServiceDirectoryListViewController.swift
│   │   │   ├── CategoryServiceDirectoryViewController.swift
│   │   │   ├── WebSiteViewController.swift
│   │   │   └── WebSiteNewViewController.swift
│   │   │
│   │   ├── SubGroupDetailViewController/       # SUB-GROUPS / COMMITTEES
│   │   │   ├── SubGroupDetailViewController.swift
│   │   │   └── ChildSubgrpViewController.swift
│   │   │
│   │   ├── WebLink/                            # WEB LINKS
│   │   │   ├── WebLinkListViewController.swift
│   │   │   ├── WebLinkWebViewViewController.swift
│   │   │   └── CustomWebLinkCell.swift
│   │   │
│   │   ├── DistrictDirectoryOnline/            # DISTRICT DIRECTORY
│   │   │   ├── DistrictDirectoryOnlineViewController.swift
│   │   │   ├── DistrictDirectoryDetailsVC.swift
│   │   │   ├── ClassificationMemberList/
│   │   │   └── CallMessageCell/
│   │   │
│   │   ├── DistrictClub/                       # DISTRICT CLUB
│   │   │   ├── DistrictClubMemberListViewController.swift
│   │   │   └── DistrictClubTableViewCell.swift
│   │   │
│   │   ├── SectionTable/                       # REUSABLE SECTION TABLE
│   │   │   ├── MultipleSectionTableViewController.swift
│   │   │   ├── CollapsibleTableViewHeader.swift
│   │   │   └── customTableMultiSection.swift
│   │   │
│   │   └── mapNew/                             # MAPS
│   │       ├── MapAddressViewController.swift
│   │       └── GooglePlaceApi/
│   │
│   ├── Celebration/                            # CELEBRATIONS (root level)
│   │   ├── CelebrationViewController.swift
│   │   ├── BannerListViewController.swift
│   │   ├── BirthdayListViewController.swift
│   │   ├── DistrictEventDetailsShowViewController.swift
│   │   └── ... (9 files)
│   │
│   │── Root-level ViewControllers:
│   │   ├── AdminListWebViewViewController.swift
│   │   ├── AdminModuleListingViewController.swift
│   │   ├── AllNotificationViewController.swift
│   │   ├── AnnouncementDetailNotiViewController.swift
│   │   ├── Branch&ChapterModule.swift
│   │   ├── ChangeRequestViewController.swift
│   │   ├── EventAnnouncementwebViewViewController.swift
│   │   ├── EventDetailNotiViewController.swift
│   │   ├── NationalEventDetailViewController.swift
│   │   ├── MontlyPDFListViewControllerViewController.swift
│   │   ├── MonthlyPDFViewWebViewController.swift
│   │   ├── webViewCommonViewController.swift
│   │   ├── Connectivity.swift
│   │   ├── HttpDownloader.swift
│   │   ├── ImageLoader.swift
│   │   ├── NotificaionModel.swift
│   │   └── NotificationModel.swift
│   │
│   ├── fmdb/                                   # FMDB SQLite wrapper
│   ├── DatePicker/                             # Custom date picker XIB
│   ├── TopBarMessage/                          # Push notification banner XIB
│   ├── galleryssss/                            # Gallery helper views
│   └── Progressbar/                            # Custom progress indicators
│
├── CVCalendar/                                 # Calendar library (53 files)
├── ImageSlideShowSwift/                        # Image slideshow library (4 files)
├── WPZipArchive/                               # ZIP archive utility
├── UIImage+animatedGIF/                        # GIF support
├── Library/                                    # Shared library utilities
├── DBChooser.bundle/                           # Dropbox file chooser
├── DBChooser.framework/                        # Dropbox framework
├── DropboxSDK.framework/                       # Dropbox SDK
└── Pods/                                       # CocoaPods dependencies
```

---

## 3. Flutter Feature-First Directory Layout

```
lib/
├── main.dart                                   # App entry point, Provider setup, MaterialApp
├── app.dart                                    # App widget with MultiProvider wrapper
│
├── src/
│   ├── core/                                   # SHARED CORE LAYER
│   │   ├── constants/
│   │   │   ├── api_constants.dart              # ← APIConstant.swift (base URLs + endpoints)
│   │   │   ├── app_constants.dart              # ← AppConstant.swift (app-wide constants)
│   │   │   └── toast_constants.dart            # ← ToastConstant.swift (message strings)
│   │   │
│   │   ├── network/
│   │   │   ├── dio_client.dart                 # ← ServiceManager.swift (Dio singleton, interceptors)
│   │   │   ├── api_interceptor.dart            # ← Auth header injection, logging
│   │   │   ├── api_response.dart               # ← Generic API response wrapper
│   │   │   └── connectivity_service.dart       # ← Connectivity.swift + Reach.swift
│   │   │
│   │   ├── storage/
│   │   │   ├── local_storage.dart              # ← CommonUserDefault.swift (SharedPreferences)
│   │   │   ├── database_helper.dart            # ← DBmanager.swift + CommonSqlite.swift (sqflite)
│   │   │   └── secure_storage.dart             # ← Sensitive token storage
│   │   │
│   │   ├── models/
│   │   │   ├── api_response_model.dart         # Generic {status, message, data} wrapper
│   │   │   └── base_model.dart                 # Base model with fromJson/toJson
│   │   │
│   │   ├── extensions/
│   │   │   ├── string_extensions.dart          # ← CommonExtension.swift (email validation, etc.)
│   │   │   ├── date_extensions.dart            # ← commonClassFunction date methods
│   │   │   ├── widget_extensions.dart          # ← UIView/UILabel/UITextField extensions
│   │   │   └── context_extensions.dart         # Screen size helpers
│   │   │
│   │   ├── utils/
│   │   │   ├── image_loader.dart               # ← ImageLoader.swift (CachedNetworkImage wrapper)
│   │   │   ├── file_downloader.dart            # ← HttpDownloader.swift (dio download)
│   │   │   ├── pdf_generator.dart              # ← PDF export logic (pdf package)
│   │   │   ├── validators.dart                 # ← ValidationExtension.swift
│   │   │   └── date_utils.dart                 # ← commonClassFunction (month parsing, etc.)
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart                  # Colors, text styles, input decorations
│   │   │   ├── app_colors.dart                 # Color constants (from CommonExtension hex values)
│   │   │   └── app_text_styles.dart            # Roboto font family definitions
│   │   │
│   │   └── widgets/
│   │       ├── common_app_bar.dart             # ← NavigationSettings.swift
│   │       ├── common_loader.dart              # ← SVProgressHUD / MBProgressHUD replacement
│   │       ├── common_toast.dart               # ← Toast messages
│   │       ├── common_text_field.dart          # ← Styled text fields with bottom borders
│   │       ├── common_button.dart              # ← Styled buttons
│   │       ├── common_picker.dart              # ← UIPickerView replacement (dropdown)
│   │       ├── common_date_picker.dart         # ← UIDatePicker replacement
│   │       ├── empty_state_widget.dart         # ← "No Record" / "No Result" labels
│   │       ├── search_bar_widget.dart          # ← Search text field + icon
│   │       ├── webview_screen.dart             # ← WKWebView replacement (webview_flutter)
│   │       └── three_d_card.dart               # ← ThreeDView() shadow card
│   │
│   └── features/                               # FEATURE MODULES
│
│       ├── auth/                               # ← LOGIN + OTP FLOW
│       │   ├── models/
│       │   │   ├── login_result.dart           # ← LoginResult + LoginResultResponse Obj-C models
│       │   │   ├── login_table.dart            # ← Table struct (masterUID, grpid0, etc.)
│       │   │   └── otp_result.dart             # ← OTP verification response
│       │   ├── providers/
│       │   │   └── auth_provider.dart          # ← WebserviceClass.signinTapped + OTPverify
│       │   ├── screens/
│       │   │   ├── login_screen.dart           # ← Login ViewController (mobile + country code)
│       │   │   ├── otp_screen.dart             # ← OTP Verification ViewController
│       │   │   └── welcome_screen.dart         # ← Welcome/Group selection screen
│       │   └── widgets/
│       │       ├── country_code_picker.dart    # ← Country code UIPickerView
│       │       └── otp_input_field.dart        # ← OTP text field
│       │
│       ├── dashboard/                          # ← MAIN DASHBOARD
│       │   ├── models/
│       │   │   ├── group_result.dart           # ← TBGroupResult, GroupResult models
│       │   │   ├── module_result.dart          # ← TBGetGroupModuleResult
│       │   │   ├── dashboard_result.dart       # ← TBDashboardResult (banner data)
│       │   │   └── admin_submodules_result.dart # ← AdminSubmodulesResult
│       │   ├── providers/
│       │   │   ├── dashboard_provider.dart     # ← MainDashboardViewController logic
│       │   │   ├── group_provider.dart         # ← Group switching, module fetching
│       │   │   └── module_provider.dart        # ← CustomisedDash / CustumiseMyModule logic
│       │   ├── screens/
│       │   │   ├── dashboard_screen.dart       # ← MainDashboardViewController
│       │   │   ├── customize_modules_screen.dart # ← CustumiseMyModuleViewController
│       │   │   ├── admin_modules_screen.dart   # ← AdminModuleListingViewController
│       │   │   └── sidebar_screen.dart         # ← MainDashboardWithSideBarViewController
│       │   └── widgets/
│       │       ├── module_grid_item.dart       # ← CollectionView cell for modules
│       │       ├── banner_carousel.dart        # ← Banner/celebration slider
│       │       ├── sidebar_menu.dart           # ← RotaryMenuViewController
│       │       └── group_switcher.dart         # ← Group picker dropdown
│       │
│       ├── directory/                          # ← MEMBER DIRECTORY
│       │   ├── models/
│       │   │   ├── member_result.dart          # ← TBMemberResult
│       │   │   ├── member_detail_result.dart   # ← MemberListDetailResult
│       │   │   └── user_result.dart            # ← UserResult (profile update)
│       │   ├── providers/
│       │   │   └── directory_provider.dart     # ← DirectoryViewController logic (search, PDF)
│       │   ├── screens/
│       │   │   ├── directory_screen.dart       # ← DirectoryViewController
│       │   │   ├── profile_detail_screen.dart  # ← ProfileDynamicNewViewController
│       │   │   ├── edit_profile_screen.dart    # ← EditDirectoryController
│       │   │   └── profile_info_screen.dart    # ← ProfileInfoController
│       │   └── widgets/
│       │       ├── member_list_tile.dart        # ← Directory table cell
│       │       ├── classification_filter.dart   # ← Classification picker
│       │       └── profile_section_card.dart    # ← Profile detail sections
│       │
│       ├── events/                             # ← EVENTS
│       │   ├── models/
│       │   │   ├── event_list_result.dart      # ← EventListDetailResult
│       │   │   ├── event_detail_result.dart    # ← EventsListDetailResult
│       │   │   ├── add_event_result.dart       # ← AddEventResult
│       │   │   └── event_join_result.dart      # ← EventJoinResult
│       │   ├── providers/
│       │   │   └── events_provider.dart        # ← WebserviceClass event methods
│       │   ├── screens/
│       │   │   ├── events_list_screen.dart     # ← Event listing
│       │   │   ├── event_detail_screen.dart    # ← EventsDetailController
│       │   │   ├── add_event_screen.dart       # ← Add_Events ViewController
│       │   │   ├── event_screenshot_screen.dart # ← EventDetailScreenShotViewController
│       │   │   └── completed_activities_screen.dart # ← CompletedActivitiesViewController
│       │   └── widgets/
│       │       ├── event_card.dart             # ← Event list cell
│       │       ├── rsvp_button.dart            # ← RSVP / Question answer
│       │       └── event_share_sheet.dart      # ← Share event PDF
│       │
│       ├── celebrations/                       # ← CELEBRATIONS (Birthday, Anniversary, Events Calendar)
│       │   ├── models/
│       │   │   ├── celebration_result.dart     # ← Month event list response
│       │   │   └── birthday_result.dart        # ← TBDashboardResult (today's birthdays)
│       │   ├── providers/
│       │   │   └── celebrations_provider.dart  # ← CelebrationViewController logic
│       │   ├── screens/
│       │   │   ├── celebrations_screen.dart    # ← CelebrationViewController (tabbed)
│       │   │   ├── banner_list_screen.dart     # ← BannerListViewController
│       │   │   ├── birthday_list_screen.dart   # ← BirthdayListViewController
│       │   │   └── district_event_detail_screen.dart # ← DistrictEventDetailsShowViewController
│       │   └── widgets/
│       │       ├── calendar_grid.dart          # ← CollectionView calendar days
│       │       ├── celebration_tab_bar.dart    # ← Event/Anniversary/Birthday tabs
│       │       └── celebration_list_tile.dart  # ← List item with call/email actions
│       │
│       ├── announcements/                      # ← ANNOUNCEMENTS
│       │   ├── models/
│       │   │   ├── announcement_list_result.dart # ← TBAnnounceListResult
│       │   │   └── add_announcement_result.dart  # ← TBAddAnnouncementResult
│       │   ├── providers/
│       │   │   └── announcements_provider.dart   # ← Announcement CRUD logic
│       │   ├── screens/
│       │   │   ├── announcements_list_screen.dart # ← Announcement listing
│       │   │   ├── announcement_detail_screen.dart # ← AnnouncementDetailNotiViewController
│       │   │   └── add_announcement_screen.dart   # ← Add_Announcement ViewController
│       │   └── widgets/
│       │       └── announcement_card.dart         # ← Announcement list cell
│       │
│       ├── gallery/                            # ← GALLERY & ALBUMS
│       │   ├── models/
│       │   │   ├── album_list_result.dart      # ← TBAlbumsListResult
│       │   │   ├── album_detail_result.dart    # ← Album photos response
│       │   │   ├── create_album_model.dart     # ← CreateAlbumModel
│       │   │   └── delete_result.dart          # ← DeleteResult (shared)
│       │   ├── providers/
│       │   │   └── gallery_provider.dart       # ← Gallery CRUD + upload logic
│       │   ├── screens/
│       │   │   ├── gallery_screen.dart         # ← Album list / GalleryCatyegoryNewViewController
│       │   │   ├── album_photos_screen.dart    # ← AlbumPhotosViewController
│       │   │   ├── add_photo_screen.dart       # ← AddPhotoViewController (multi-image)
│       │   │   ├── create_album_screen.dart    # ← CreateAlbumViewController
│       │   │   ├── showcase_albums_screen.dart # ← ShowCaseAlbumListViewController
│       │   │   └── photo_detail_screen.dart    # ← NewShowCasePhotoDetailsVC
│       │   └── widgets/
│       │       ├── album_grid_item.dart        # ← Album collection cell
│       │       ├── photo_grid_item.dart        # ← Photo collection cell
│       │       └── multi_image_picker.dart     # ← 5-image batch picker
│       │
│       ├── documents/                          # ← DOCUMENT SAFE
│       │   ├── models/
│       │   │   ├── document_list_result.dart   # ← TBDocumentistResult
│       │   │   └── add_document_result.dart    # ← TBAddDocumentResult
│       │   ├── providers/
│       │   │   └── documents_provider.dart     # ← Document CRUD + download logic
│       │   ├── screens/
│       │   │   ├── documents_list_screen.dart  # ← DocumentListViewControlller
│       │   │   ├── document_detail_screen.dart # ← DocumentsDetailController
│       │   │   └── document_viewer_screen.dart # ← ShowDocumentViewController
│       │   └── widgets/
│       │       ├── document_list_tile.dart     # ← Document table cell
│       │       └── download_progress.dart      # ← Progress bar for downloads
│       │
│       ├── ebulletin/                          # ← E-BULLETINS / NEWSLETTERS
│       │   ├── models/
│       │   │   ├── ebulletin_list_result.dart  # ← TBEbulletinListResult
│       │   │   └── add_ebulletin_result.dart   # ← TBAddEbulletinResult
│       │   ├── providers/
│       │   │   └── ebulletin_provider.dart     # ← Year-wise listing + CRUD
│       │   ├── screens/
│       │   │   ├── ebulletin_list_screen.dart  # ← EBulletinListingController
│       │   │   ├── ebulletin_detail_screen.dart # ← EbulletinDetailViewController
│       │   │   └── add_ebulletin_screen.dart   # ← Add_Eulletine ViewController
│       │   └── widgets/
│       │       └── ebulletin_card.dart         # ← EbulletineCell
│       │
│       ├── attendance/                         # ← ATTENDANCE
│       │   ├── models/
│       │   │   └── attendance_result.dart      # ← Attendance list response
│       │   ├── providers/
│       │   │   └── attendance_provider.dart    # ← AttendanceViewController logic
│       │   ├── screens/
│       │   │   ├── attendance_screen.dart      # ← AttendanceViewController
│       │   │   └── attendance_detail_screen.dart # ← SubModules details
│       │   └── widgets/
│       │       ├── attendance_chart.dart        # ← ChartClasses (pie chart)
│       │       └── monthly_report_tile.dart     # ← MonthlyReportDetailTableViewCell
│       │
│       ├── find_rotarian/                      # ← FIND A ROTARIAN
│       │   ├── models/
│       │   │   └── rotarian_result.dart        # ← Rotarian search result
│       │   ├── providers/
│       │   │   └── find_rotarian_provider.dart # ← Search logic (zone, chapter, name)
│       │   ├── screens/
│       │   │   ├── find_rotarian_screen.dart   # ← FinddArotarianViewController
│       │   │   ├── rotarian_profile_screen.dart # ← RotarianProfileBusinessDetailsViewController
│       │   │   └── search_rotarian_screen.dart # ← SearchFindArotarianViewController
│       │   └── widgets/
│       │       ├── zone_chapter_picker.dart    # ← Cascading Zone → Chapter dropdowns
│       │       └── rotarian_list_tile.dart     # ← Search result cell
│       │
│       ├── find_club/                          # ← FIND A CLUB
│       │   ├── models/
│       │   │   └── club_result.dart            # ← Club list/detail response
│       │   ├── providers/
│       │   │   └── find_club_provider.dart     # ← Club search + near me logic
│       │   ├── screens/
│       │   │   ├── find_club_screen.dart       # ← Club search
│       │   │   └── club_detail_screen.dart     # ← Club details with map
│       │   └── widgets/
│       │       └── club_card.dart              # ← Club list cell
│       │
│       ├── service_directory/                  # ← SERVICE DIRECTORY
│       │   ├── models/
│       │   │   ├── service_directory_result.dart  # ← TBServiceDirectoryResult
│       │   │   ├── service_list_result.dart       # ← TBServiceDirectoryListResult
│       │   │   └── add_service_result.dart        # ← TBAddServiceResult
│       │   ├── providers/
│       │   │   └── service_directory_provider.dart # ← Service CRUD + search
│       │   ├── screens/
│       │   │   ├── service_directory_screen.dart   # ← ServiceDirectoryListViewController
│       │   │   ├── service_category_screen.dart   # ← CategoryServiceDirectoryViewController
│       │   │   └── service_website_screen.dart    # ← WebSiteNewViewController
│       │   └── widgets/
│       │       └── service_list_tile.dart         # ← Service directory cell
│       │
│       ├── subgroups/                          # ← SUB-GROUPS / COMMITTEES
│       │   ├── models/
│       │   │   ├── subgroup_list_result.dart   # ← TBGetSubGroupListResult
│       │   │   └── subgroup_detail_result.dart # ← TBGetSubGroupDetailListResult
│       │   ├── providers/
│       │   │   └── subgroups_provider.dart     # ← Sub-group CRUD
│       │   ├── screens/
│       │   │   ├── subgroup_list_screen.dart   # ← Sub-group listing
│       │   │   ├── subgroup_detail_screen.dart # ← SubGroupDetailViewController
│       │   │   ├── child_subgroup_screen.dart  # ← ChildSubgrpViewController
│       │   │   └── add_subgroup_screen.dart    # ← Sub_GroupController ViewController
│       │   └── widgets/
│       │       └── subgroup_member_tile.dart   # ← SubGrpDetailCell
│       │
│       ├── district/                           # ← DISTRICT FEATURES
│       │   ├── models/
│       │   │   └── district_result.dart        # ← District member/club/committee responses
│       │   ├── providers/
│       │   │   └── district_provider.dart      # ← District directory + club + committee
│       │   ├── screens/
│       │   │   ├── district_directory_screen.dart  # ← DistrictDirectoryOnlineViewController
│       │   │   ├── district_member_detail_screen.dart # ← DistrictDirectoryDetailsVC
│       │   │   ├── district_club_members_screen.dart  # ← DistrictClubMemberListViewController
│       │   │   └── district_committee_screen.dart     # ← District committee list
│       │   └── widgets/
│       │       ├── district_member_tile.dart    # ← District directory cell
│       │       └── call_message_cell.dart       # ← CallMessageCell
│       │
│       ├── leaderboard/                        # ← LEADERBOARD
│       │   ├── models/
│       │   │   └── leaderboard_result.dart     # ← Zone list + leaderboard data
│       │   ├── providers/
│       │   │   └── leaderboard_provider.dart   # ← Zone/year filter logic
│       │   ├── screens/
│       │   │   └── leaderboard_screen.dart     # ← LeaderBoardViewController
│       │   └── widgets/
│       │       ├── leaderboard_collection_cell.dart # ← LeaderBoardCollectionViewCell
│       │       └── leaderboard_table_cell.dart     # ← TableViewCustomeCell
│       │
│       ├── web_links/                          # ← WEB LINKS
│       │   ├── models/
│       │   │   └── web_link_result.dart        # ← Web link list response
│       │   ├── providers/
│       │   │   └── web_links_provider.dart     # ← Web link CRUD
│       │   ├── screens/
│       │   │   ├── web_links_screen.dart       # ← WebLinkListViewController
│       │   │   └── web_link_detail_screen.dart # ← WebLinkWebViewViewController
│       │   └── widgets/
│       │       └── web_link_tile.dart          # ← CustomWebLinkCell
│       │
│       ├── notifications/                      # ← NOTIFICATIONS
│       │   ├── models/
│       │   │   └── notification_model.dart     # ← NotificationModel + NotificaioModel
│       │   ├── providers/
│       │   │   └── notifications_provider.dart # ← Local DB CRUD + push handling
│       │   ├── screens/
│       │   │   ├── notifications_screen.dart   # ← AllNotificationViewController
│       │   │   └── notification_settings_screen.dart # ← NotificationSetting
│       │   └── widgets/
│       │       └── notification_tile.dart      # ← NotificationCell
│       │
│       ├── settings/                           # ← SETTINGS
│       │   ├── models/
│       │   │   ├── setting_result.dart         # ← TBSettingResult
│       │   │   └── group_setting_result.dart   # ← TBGroupSettingResult
│       │   ├── providers/
│       │   │   └── settings_provider.dart      # ← Setting get/update
│       │   ├── screens/
│       │   │   ├── settings_screen.dart        # ← Settings list
│       │   │   └── group_settings_screen.dart  # ← Group-level settings
│       │   └── widgets/
│       │       └── setting_toggle_tile.dart    # ← Setting switch cell
│       │
│       ├── profile/                            # ← MEMBER PROFILE MANAGEMENT
│       │   ├── models/
│       │   │   ├── update_family_result.dart   # ← UpdateFamilyResult
│       │   │   ├── update_address_result.dart  # ← UpdateAddressResult
│       │   │   └── bod_member_result.dart      # ← BOD member list response
│       │   ├── providers/
│       │   │   └── profile_provider.dart       # ← Profile update, family, address, photo upload
│       │   ├── screens/
│       │   │   ├── my_profile_screen.dart      # ← Member profile view
│       │   │   ├── edit_family_screen.dart     # ← ADDFamilyMember ViewController
│       │   │   ├── edit_address_screen.dart    # ← Address update ViewController
│       │   │   ├── change_request_screen.dart  # ← ChangeRequestViewController
│       │   │   ├── bod_list_screen.dart        # ← Board of Directors list
│       │   │   └── past_presidents_screen.dart # ← Past presidents list
│       │   └── widgets/
│       │       ├── family_member_card.dart     # ← Family detail row
│       │       └── address_card.dart           # ← Address detail row
│       │
│       ├── groups/                             # ← GROUP MANAGEMENT
│       │   ├── models/
│       │   │   ├── create_group_result.dart    # ← CreateGRpResult
│       │   │   ├── country_result.dart         # ← TBCountryResult
│       │   │   ├── global_search_result.dart   # ← TBGlobalSearchGroupResult
│       │   │   └── entity_info_result.dart     # ← TBEntityInfoResult
│       │   ├── providers/
│       │   │   └── groups_provider.dart        # ← Group CRUD + search + member add
│       │   ├── screens/
│       │   │   ├── create_group_screen.dart    # ← Create group form
│       │   │   ├── group_detail_screen.dart    # ← Group info detail
│       │   │   ├── add_members_screen.dart     # ← Add member to group
│       │   │   └── global_search_screen.dart   # ← GlobalSearchGroup
│       │   └── widgets/
│       │       └── group_card.dart             # ← Group list cell
│       │
│       ├── monthly_report/                     # ← MONTHLY PDF REPORTS
│       │   ├── providers/
│       │   │   └── monthly_report_provider.dart
│       │   └── screens/
│       │       ├── monthly_pdf_list_screen.dart  # ← MontlyPDFListViewControllerViewController
│       │       └── monthly_pdf_view_screen.dart  # ← MonthlyPDFViewWebViewController
│       │
│       └── maps/                               # ← MAP / LOCATION
│           ├── providers/
│           │   └── map_provider.dart           # ← Google Places API logic
│           ├── screens/
│           │   └── map_address_screen.dart     # ← MapAddressViewController
│           └── widgets/
│               └── map_view_widget.dart        # ← Google Map view
```

---

## 4. Feature-by-Feature Mapping

### 4.1 Authentication Feature

| iOS (Swift) | Flutter (Dart) | Notes |
|---|---|---|
| `WebserviceClass.signinTapped()` | `AuthProvider.login()` | ChangeNotifier method |
| `WebserviceClass.OTPverify()` | `AuthProvider.verifyOtp()` | ChangeNotifier method |
| `WebserviceClass.getAllGroupsWelcome()` | `AuthProvider.getWelcomeGroups()` | Post-login group fetch |
| `WebserviceClass.MemberDetail()` | `AuthProvider.getMemberDetails()` | Get logged-in member info |
| `LoginResult` (Obj-C) | `LoginResult` (Dart model, all nullable) | `json_serializable` |
| `LoginResultResponseDTO` (Swift struct) | `LoginResultResponse` (Dart model) | Nested: `LoginResultData` → `Ds` → `Table` |
| `UserDefaults("masterUID")` | `SharedPreferences + SecureStorage` | Provider reads from storage |
| `UserDefaults("DeviceToken")` | `FirebaseMessaging.instance.getToken()` | FCM token |

### 4.2 Dashboard Feature

| iOS (Swift) | Flutter (Dart) | Notes |
|---|---|---|
| `MainDashboardViewController` | `DashboardScreen` + `DashboardProvider` | CollectionView → GridView |
| `CustumiseMyModuleViewController` | `CustomizeModulesScreen` + `ModuleProvider` | Drag-reorder modules |
| `MainDashboardWithSideBarViewController` | `SidebarScreen` + `Drawer` | Sidebar menu |
| `RotaryMenuViewController` | `SidebarMenu` widget | Drawer content |
| `AdminModuleListingViewController` | `AdminModulesScreen` | Admin sub-modules grid |
| `GroupView_DashBoard` | `GroupSwitcher` widget | Group/club selection |

### 4.3 Directory Feature

| iOS (Swift) | Flutter (Dart) | Notes |
|---|---|---|
| `DirectoryViewController` | `DirectoryScreen` + `DirectoryProvider` | Search + PDF export |
| `ProfileDynamicNewViewController` | `ProfileDetailScreen` | Dynamic profile sections |
| `EditDirectoryController` | `EditProfileScreen` | Profile editing |
| `ProfileInfoController` | `ProfileInfoScreen` | Read-only profile |
| `pdfDataWithTableView()` | `PdfGenerator.generateDirectoryPdf()` | `pdf` package |

### 4.4 Events Feature

| iOS (Swift) | Flutter (Dart) | Notes |
|---|---|---|
| `EventsDetailController` | `EventDetailScreen` + `EventsProvider` | Detail + PDF share |
| `EventDetailScreenShotViewController` | `EventScreenshotScreen` | Event screenshot |
| `CompletedActivitiesViewController` | `CompletedActivitiesScreen` | Past events |
| `Add_Events ViewController` | `AddEventScreen` | Event creation form |
| `WebserviceClass.addEventsResult()` | `EventsProvider.addEvent()` | 25+ parameters |

### 4.5 Celebrations Feature

| iOS (Swift) | Flutter (Dart) | Notes |
|---|---|---|
| `CelebrationViewController` | `CelebrationsScreen` + `CelebrationsProvider` | Tabbed: Events/Anniversary/Birthday |
| `BannerListViewController` | `BannerListScreen` | Dashboard birthday/anniversary |
| `BirthdayListViewController` | `BirthdayListScreen` | Birthday list |
| `DistrictEventDetailsShowViewController` | `DistrictEventDetailScreen` | District event detail |

### 4.6 Gallery Feature

| iOS (Swift) | Flutter (Dart) | Notes |
|---|---|---|
| `AddPhotoViewController` | `AddPhotoScreen` + `GalleryProvider` | 5-image batch upload |
| `AlbumPhotosViewController` | `AlbumPhotosScreen` | Photo grid |
| `CreateAlbumViewController` | `CreateAlbumScreen` | Album form |
| `GalleryCatyegoryNewViewController` | `GalleryScreen` | Category-based albums |
| `ShowCaseAlbumListViewController` | `ShowcaseAlbumsScreen` | Showcase albums |

### 4.7 Documents Feature

| iOS (Swift) | Flutter (Dart) | Notes |
|---|---|---|
| `DocumentListViewControlller` | `DocumentsListScreen` + `DocumentsProvider` | Background download |
| `DocumentsDetailController` | `DocumentDetailScreen` | Document info |
| `ShowDocumentViewController` | `DocumentViewerScreen` | In-app PDF/file viewer |
| `URLSessionDownloadDelegate` | `Dio.download()` | Background download with progress |

### 4.8 Attendance Feature

| iOS (Swift) | Flutter (Dart) | Notes |
|---|---|---|
| `AttendanceViewController` | `AttendanceScreen` + `AttendanceProvider` | Event picker + list |
| `ChartClasses` | `fl_chart` package | Pie chart visualization |

---

## 5. Shared / Core Layer Mapping

### 5.1 Networking

| iOS (Swift) | Flutter (Dart) | Notes |
|---|---|---|
| `WebserviceClass` (3900+ line singleton) | Split into feature-specific Providers | Each Provider calls `DioClient` |
| `ServiceManager` | `DioClient` (Dio singleton) | Interceptors for auth/logging |
| `Alamofire.request(url, method: .post, ...)` | `dio.post(url, data: ...)` | All POST requests |
| `webServiceDelegate` (70+ methods) | Provider `notifyListeners()` | No delegates needed |
| `SVProgressHUD.show()` / `.dismiss()` | `CommonLoader` widget or `showDialog` | Loading overlay |
| `Reachability` + `Connectivity` | `connectivity_plus` package | Network status check |

### 5.2 Local Storage

| iOS (Swift) | Flutter (Dart) | Notes |
|---|---|---|
| `UserDefaults` | `SharedPreferences` | Key-value storage |
| `FMDatabase` (SQLite via FMDB) | `sqflite` package | Notification DB, offline data |
| `Core Data` (ContactEdit) | `sqflite` or `drift` | If needed for contacts |
| `NSCache` (ImageLoader) | `CachedNetworkImage` | Image caching |

### 5.3 UI Components

| iOS (Swift) | Flutter (Dart) | Notes |
|---|---|---|
| `UITableView` | `ListView.builder` | With `Consumer<Provider>` |
| `UICollectionView` | `GridView.builder` | Module grid, photo grid |
| `UIPickerView` | `DropdownButton` or `CupertinoPicker` | Zone, chapter, year selectors |
| `UIDatePicker` | `showDatePicker()` | Material date picker |
| `UISearchBar` | `SearchBar` or `TextField` with icon | Search fields |
| `WKWebView` | `webview_flutter` | Web content viewer |
| `UIActivityViewController` | `share_plus` package | Share PDF/content |
| `MFMailComposeViewController` | `url_launcher` (mailto:) | Send email |
| `MFMessageComposeViewController` | `url_launcher` (sms:) | Send SMS |
| `UIAlertController` | `showDialog` / `AlertDialog` | Alerts |
| `Storyboard` / `XIB` | Dart widget tree | No storyboards in Flutter |

### 5.4 Extensions Mapping

| iOS Extension | Flutter Equivalent | File |
|---|---|---|
| `UIImageView.imageFromServerURL()` | `CachedNetworkImage` widget | `image_loader.dart` |
| `UIView.ThreeDView()` | `Card` with `elevation` | `three_d_card.dart` |
| `UIView.messageShowToast()` | `ScaffoldMessenger.showSnackBar` or `fluttertoast` | `common_toast.dart` |
| `UITextField.functionForSetTextFieldBottomBorder()` | `InputDecoration(border: UnderlineInputBorder())` | `common_text_field.dart` |
| `String.isEmail` | `String` extension with regex | `string_extensions.dart` |
| `commonClassFunction.functionForMonthWordWise()` | `DateFormat` from `intl` package | `date_utils.dart` |
| `CGRect.Iphone / Iphone5And5s / etc.` | `MediaQuery.of(context).size` | `context_extensions.dart` |

---

## 6. State Management Strategy (Provider)

### 6.1 Provider Architecture

```
MultiProvider (in main.dart)
  ├── ChangeNotifierProvider<AuthProvider>
  ├── ChangeNotifierProvider<DashboardProvider>
  ├── ChangeNotifierProvider<GroupProvider>
  ├── ChangeNotifierProvider<ModuleProvider>
  ├── ChangeNotifierProvider<DirectoryProvider>
  ├── ChangeNotifierProvider<EventsProvider>
  ├── ChangeNotifierProvider<CelebrationsProvider>
  ├── ChangeNotifierProvider<AnnouncementsProvider>
  ├── ChangeNotifierProvider<GalleryProvider>
  ├── ChangeNotifierProvider<DocumentsProvider>
  ├── ChangeNotifierProvider<EbulletinProvider>
  ├── ChangeNotifierProvider<AttendanceProvider>
  ├── ChangeNotifierProvider<FindRotarianProvider>
  ├── ChangeNotifierProvider<FindClubProvider>
  ├── ChangeNotifierProvider<ServiceDirectoryProvider>
  ├── ChangeNotifierProvider<SubgroupsProvider>
  ├── ChangeNotifierProvider<DistrictProvider>
  ├── ChangeNotifierProvider<LeaderboardProvider>
  ├── ChangeNotifierProvider<WebLinksProvider>
  ├── ChangeNotifierProvider<NotificationsProvider>
  ├── ChangeNotifierProvider<SettingsProvider>
  ├── ChangeNotifierProvider<ProfileProvider>
  ├── ChangeNotifierProvider<GroupsProvider>
  └── ChangeNotifierProvider<MapProvider>
```

### 6.2 Mapping Swift Delegates to Provider Pattern

**Before (iOS - Delegate Pattern):**
```swift
// ViewController conforms to webServiceDelegate
class DirectoryViewController: UIViewController, webServiceDelegate {
    let loaderClass = WebserviceClass()

    override func viewDidLoad() {
        loaderClass.delegates = self
        loaderClass.getDirectoryListGroupsOFUSer(masterUID, grpID, "", "1")
    }

    // Delegate callback
    func getDirectoryResultDelegate(_ dirList: TBMemberResult) {
        // Update UI with data
    }
}
```

**After (Flutter - Provider Pattern):**
```dart
// Provider holds state and logic
class DirectoryProvider extends ChangeNotifier {
  List<MemberResult>? _members;
  bool _isLoading = false;
  String? _error;

  List<MemberResult>? get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDirectory({
    required String? masterUID,
    required String? grpID,
    String? searchText,
    String? page,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await DioClient.instance.post(
        'Member/GetDirectoryList',
        data: {
          'masterUID': masterUID ?? '',
          'grpID': grpID ?? '',
          'searchText': searchText ?? '',
          'page': page ?? '1',
        },
      );
      _members = (response.data?['list'] as List?)
          ?.map((e) => MemberResult.fromJson(e as Map<String, dynamic>))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Screen uses Consumer for reactive updates
class DirectoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DirectoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const CommonLoader();
        if (provider.error != null) return ErrorWidget(provider.error);
        return ListView.builder(
          itemCount: provider.members?.length ?? 0,
          itemBuilder: (context, index) {
            final member = provider.members?[index];
            return MemberListTile(member: member);
          },
        );
      },
    );
  }
}
```

### 6.3 CommonAccessibleHoldVariable Mapping

The iOS `CommonAccessibleHoldVariable` class (shared mutable DTO) maps to **Provider state**:

| iOS Property | Flutter Provider | Field |
|---|---|---|
| `varBodMemberName` | `ProfileProvider` | `selectedBodMember?.name` |
| `varBodMemberProfileId` | `ProfileProvider` | `selectedBodMember?.profileId` |
| `varclubName` | `FindRotarianProvider` | `selectedRotarian?.clubName` |
| `varGetWebLinkTitle` | `WebLinksProvider` | `selectedLink?.title` |
| `varGetSettingModuleID` | `SettingsProvider` | `selectedSetting?.moduleId` |
| `varDistrictID` | `DistrictProvider` | `selectedClub?.districtId` |
| `varFamilyDetails_*` | `ProfileProvider` | `selectedFamilyMember?.relation` etc. |

---

## 7. Swift ViewController to Flutter Widget Mapping Table

| # | Swift ViewController | Flutter Screen Widget | Feature Module | Provider |
|---|---|---|---|---|
| 1 | Login VC (in WebserviceClass) | `LoginScreen` | `auth/` | `AuthProvider` |
| 2 | OTP VC (in WebserviceClass) | `OtpScreen` | `auth/` | `AuthProvider` |
| 3 | Welcome VC | `WelcomeScreen` | `auth/` | `AuthProvider` |
| 4 | `MainDashboardViewController` | `DashboardScreen` | `dashboard/` | `DashboardProvider` |
| 5 | `CustumiseMyModuleViewController` | `CustomizeModulesScreen` | `dashboard/` | `ModuleProvider` |
| 6 | `AdminModuleListingViewController` | `AdminModulesScreen` | `dashboard/` | `DashboardProvider` |
| 7 | `MainDashboardWithSideBarViewController` | `SidebarScreen` | `dashboard/` | `DashboardProvider` |
| 8 | `RotaryMenuViewController` | `SidebarMenu` (widget) | `dashboard/` | — |
| 9 | `DirectoryViewController` | `DirectoryScreen` | `directory/` | `DirectoryProvider` |
| 10 | `ProfileDynamicNewViewController` | `ProfileDetailScreen` | `directory/` | `DirectoryProvider` |
| 11 | `EditDirectoryController` | `EditProfileScreen` | `directory/` | `DirectoryProvider` |
| 12 | `ProfileInfoController` | `ProfileInfoScreen` | `directory/` | `DirectoryProvider` |
| 13 | `JitoProfileViewController` | `JitoProfileScreen` | `directory/` | `DirectoryProvider` |
| 14 | `EventsDetailController` | `EventDetailScreen` | `events/` | `EventsProvider` |
| 15 | `EventDetailScreenShotViewController` | `EventScreenshotScreen` | `events/` | `EventsProvider` |
| 16 | `CompletedActivitiesViewController` | `CompletedActivitiesScreen` | `events/` | `EventsProvider` |
| 17 | Add_Events VC | `AddEventScreen` | `events/` | `EventsProvider` |
| 18 | `CelebrationViewController` | `CelebrationsScreen` | `celebrations/` | `CelebrationsProvider` |
| 19 | `BannerListViewController` | `BannerListScreen` | `celebrations/` | `CelebrationsProvider` |
| 20 | `BirthdayListViewController` | `BirthdayListScreen` | `celebrations/` | `CelebrationsProvider` |
| 21 | `DistrictEventDetailsShowViewController` | `DistrictEventDetailScreen` | `celebrations/` | `CelebrationsProvider` |
| 22 | Announcement Listing VC | `AnnouncementsListScreen` | `announcements/` | `AnnouncementsProvider` |
| 23 | `AnnouncementDetailNotiViewController` | `AnnouncementDetailScreen` | `announcements/` | `AnnouncementsProvider` |
| 24 | Add_Announcement VC | `AddAnnouncementScreen` | `announcements/` | `AnnouncementsProvider` |
| 25 | `AddPhotoViewController` | `AddPhotoScreen` | `gallery/` | `GalleryProvider` |
| 26 | `AlbumPhotosViewController` | `AlbumPhotosScreen` | `gallery/` | `GalleryProvider` |
| 27 | `CreateAlbumViewController` | `CreateAlbumScreen` | `gallery/` | `GalleryProvider` |
| 28 | `GalleryCatyegoryNewViewController` | `GalleryScreen` | `gallery/` | `GalleryProvider` |
| 29 | `ShowCaseAlbumListViewController` | `ShowcaseAlbumsScreen` | `gallery/` | `GalleryProvider` |
| 30 | `NewShowCasePhotoDetailsVC` | `PhotoDetailScreen` | `gallery/` | `GalleryProvider` |
| 31 | `DocumentListViewControlller` | `DocumentsListScreen` | `documents/` | `DocumentsProvider` |
| 32 | `DocumentsDetailController` | `DocumentDetailScreen` | `documents/` | `DocumentsProvider` |
| 33 | `ShowDocumentViewController` | `DocumentViewerScreen` | `documents/` | `DocumentsProvider` |
| 34 | `EBulletinListingController` | `EbulletinListScreen` | `ebulletin/` | `EbulletinProvider` |
| 35 | `EbulletinDetailViewController` | `EbulletinDetailScreen` | `ebulletin/` | `EbulletinProvider` |
| 36 | Add_Eulletine VC | `AddEbulletinScreen` | `ebulletin/` | `EbulletinProvider` |
| 37 | `AttendanceViewController` | `AttendanceScreen` | `attendance/` | `AttendanceProvider` |
| 38 | `FinddArotarianViewController` | `FindRotarianScreen` | `find_rotarian/` | `FindRotarianProvider` |
| 39 | `RotarianProfileBusinessDetailsViewController` | `RotarianProfileScreen` | `find_rotarian/` | `FindRotarianProvider` |
| 40 | `SearchFindArotarianViewController` | `SearchRotarianScreen` | `find_rotarian/` | `FindRotarianProvider` |
| 41 | Find Club VC | `FindClubScreen` | `find_club/` | `FindClubProvider` |
| 42 | `ServiceDirectoryListViewController` | `ServiceDirectoryScreen` | `service_directory/` | `ServiceDirectoryProvider` |
| 43 | `CategoryServiceDirectoryViewController` | `ServiceCategoryScreen` | `service_directory/` | `ServiceDirectoryProvider` |
| 44 | `SubGroupDetailViewController` | `SubgroupDetailScreen` | `subgroups/` | `SubgroupsProvider` |
| 45 | `ChildSubgrpViewController` | `ChildSubgroupScreen` | `subgroups/` | `SubgroupsProvider` |
| 46 | `DistrictDirectoryOnlineViewController` | `DistrictDirectoryScreen` | `district/` | `DistrictProvider` |
| 47 | `DistrictDirectoryDetailsVC` | `DistrictMemberDetailScreen` | `district/` | `DistrictProvider` |
| 48 | `DistrictClubMemberListViewController` | `DistrictClubMembersScreen` | `district/` | `DistrictProvider` |
| 49 | `LeaderBoardViewController` | `LeaderboardScreen` | `leaderboard/` | `LeaderboardProvider` |
| 50 | `WebLinkListViewController` | `WebLinksScreen` | `web_links/` | `WebLinksProvider` |
| 51 | `WebLinkWebViewViewController` | `WebLinkDetailScreen` | `web_links/` | `WebLinksProvider` |
| 52 | `AllNotificationViewController` | `NotificationsScreen` | `notifications/` | `NotificationsProvider` |
| 53 | `AdminListWebViewViewController` | `AdminWebViewScreen` | `dashboard/` | — |
| 54 | `ChangeRequestViewController` | `ChangeRequestScreen` | `profile/` | `ProfileProvider` |
| 55 | `NationalEventDetailViewController` | `NationalEventDetailScreen` | `events/` | `EventsProvider` |
| 56 | `MontlyPDFListViewControllerViewController` | `MonthlyPdfListScreen` | `monthly_report/` | `MonthlyReportProvider` |
| 57 | `MonthlyPDFViewWebViewController` | `MonthlyPdfViewScreen` | `monthly_report/` | `MonthlyReportProvider` |
| 58 | `webViewCommonViewController` | `CommonWebViewScreen` | `core/widgets/` | — |
| 59 | `MapAddressViewController` | `MapAddressScreen` | `maps/` | `MapProvider` |
| 60 | `ClubEventsListViewController` | `ClubEventsListScreen` | `events/` | `EventsProvider` |

---

## 8. Navigation Mapping

### iOS Navigation (Storyboard + Push)
```swift
let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileDynamic") as! ProfileDynamicNewViewController
vc.memberProfileId = selectedMember.profileId
navigationController?.pushViewController(vc, animated: true)
```

### Flutter Navigation (GoRouter or Navigator 2.0)
```dart
// Using GoRouter (recommended)
context.push('/directory/profile/${member?.profileId}');

// Route definition
GoRoute(
  path: '/directory/profile/:id',
  builder: (context, state) => ProfileDetailScreen(
    profileId: state.pathParameters['id'],
  ),
),
```

### Navigation Tree
```
/login → /otp → /welcome
/dashboard (main)
  ├── /dashboard/customize
  ├── /dashboard/admin-modules
  ├── /directory → /directory/profile/:id → /directory/edit/:id
  ├── /events → /events/:id → /events/add
  ├── /celebrations → /celebrations/birthday → /celebrations/district-event/:id
  ├── /announcements → /announcements/:id → /announcements/add
  ├── /gallery → /gallery/album/:id → /gallery/add-photo → /gallery/create-album
  ├── /documents → /documents/:id → /documents/view/:id
  ├── /ebulletin → /ebulletin/:id → /ebulletin/add
  ├── /attendance → /attendance/detail
  ├── /find-rotarian → /find-rotarian/profile/:id
  ├── /find-club → /find-club/:id
  ├── /service-directory → /service-directory/category/:id
  ├── /subgroups → /subgroups/:id
  ├── /district → /district/member/:id → /district/club-members/:id
  ├── /leaderboard
  ├── /web-links → /web-links/:id
  ├── /notifications → /notifications/settings
  ├── /settings → /settings/group
  ├── /profile → /profile/edit-family → /profile/edit-address → /profile/change-request
  └── /monthly-report → /monthly-report/view/:id
```

---

## 9. Third-Party Dependency Mapping

| iOS (CocoaPods) | Flutter (pub.dev) | Purpose |
|---|---|---|
| `Alamofire` | `dio` | HTTP networking |
| `SwiftyJSON` | `json_serializable` + `json_annotation` | JSON parsing |
| `SVProgressHUD` | `flutter_easyloading` or custom overlay | Loading indicator |
| `MBProgressHUD` | (same as above) | Loading indicator |
| `SDWebImage` | `cached_network_image` | Image caching |
| `IQKeyboardManagerSwift` | Built-in Flutter keyboard handling | Keyboard management |
| `Firebase` (Analytics, Messaging) | `firebase_core`, `firebase_analytics`, `firebase_messaging` | Firebase |
| `GoogleMaps` | `google_maps_flutter` | Maps |
| `SSZipArchive` / `WPZipArchive` | `archive` | ZIP file handling |
| `DACircularProgress` | `percent_indicator` | Circular progress |
| `MWPhotoBrowser` | `photo_view` | Photo viewer with zoom |
| `SJSegmentedScrollView` | `flutter_sticky_header` or custom | Segmented scroll |
| `FMDB` (SQLite) | `sqflite` | Local database |
| `PEAR-ImageSlideViewer-iOS` | `carousel_slider` | Image carousel |
| `PEAR-AutoLayout-iOS` | Not needed (Flutter's layout system) | Auto layout |
| `CVCalendar` | `table_calendar` | Calendar view |
| `DropboxSDK` | `dropbox_client` (if needed) | Dropbox integration |
| Reachability / Connectivity | `connectivity_plus` | Network check |
| `EventKit` | `device_calendar` | Calendar events |
| — | `provider` | State management |
| — | `go_router` | Navigation |
| — | `share_plus` | Share functionality |
| — | `url_launcher` | Open URLs, make calls, send SMS |
| — | `image_picker` | Camera/gallery access |
| — | `pdf` | PDF generation |
| — | `flutter_pdfview` | PDF viewer |
| — | `fl_chart` | Charts (pie, bar) |
| — | `fluttertoast` | Toast messages |
| — | `intl` | Date formatting, localization |
| — | `path_provider` | File system paths |
| — | `permission_handler` | Runtime permissions |

---

## 10. Database & Local Storage Mapping

### SQLite Tables (FMDB → sqflite)

| iOS Table | Flutter Table | Purpose |
|---|---|---|
| `GROUPMASTER` | `group_master` | Group/club data with notification counts |
| `MODULE_DATA_MASTER` | `module_data_master` | Module configuration per group |
| `Notification_Table` | `notifications` | Push notification local storage |

### UserDefaults → SharedPreferences Key Mapping

| iOS Key | Flutter Key | Type | Purpose |
|---|---|---|---|
| `masterUID` | `master_uid` | `String?` | Logged-in user master ID |
| `grpId0` | `group_id_primary` | `String?` | Primary group ID |
| `grpId` | `group_id` | `String?` | Current group ID |
| `firstName` | `first_name` | `String?` | User first name |
| `middleName` | `middle_name` | `String?` | User middle name |
| `lastName` | `last_name` | `String?` | User last name |
| `IMEI_Mem_Id` | `imei_member_id` | `String?` | IMEI member identifier |
| `ClubName` | `club_name` | `String?` | Current club name |
| `profileImg` | `profile_image` | `String?` | Profile image URL |
| `memberIdss` | `member_profile_id` | `String?` | Member profile ID |
| `DeviceToken` | `device_token` | `String?` | FCM push token |
| `isAdmin` | `is_admin` | `String?` | Admin flag |
| `user_auth_token_profileId` | `auth_profile_id` | `String?` | Auth profile ID |
| `user_auth_token_groupId` | `auth_group_id` | `String?` | Auth group ID |

---

**End of folder_details.md**
