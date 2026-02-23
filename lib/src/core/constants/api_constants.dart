/// API constants matching iOS APIConstant.swift exactly.
/// All endpoint paths are case-sensitive and match the iOS project.
class ApiConstants {
  ApiConstants._();

  // ─── BASE URL ───────────────────────────────────────────
  static const String baseUrl = 'https://api.imeiconnect.com/api/';

  // ─── STATIC WEB PAGES ──────────────────────────────────
  static const String termsAndConditionsUrl =
      'http://touchbase.in/mobile/term-n-conditions.html';
  static const String subscribesUrl =
      'http://touchbase.in/mobile/subscribes.html';

  // ─── TIMEOUTS ──────────────────────────────────────────
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration celebrationTimeout = Duration(seconds: 120);

  // ─── LOGIN ─────────────────────────────────────────────
  static const String loginUserLogin = 'Login/UserLogin';
  static const String loginPostOtp = 'Login/PostOTP';
  static const String loginGetWelcomeScreen = 'Login/GetWelcomeScreen';
  static const String loginGetMemberDetails = 'Login/GetMemberDetails';
  static const String loginRegistration = 'Login/Registration';

  // ─── GROUP ─────────────────────────────────────────────
  static const String groupGetAllCountriesAndCategories =
      'Group/GetAllCountriesAndCategories';
  static const String groupGetAllGroupsList = 'Group/GetAllGroupsList';
  static const String groupCreateGroup = 'Group/CreateGroup';
  static const String groupCreateSubGroup = 'Group/CreateSubGroup';
  static const String groupGetGroupDetail = 'Group/GetGroupDetail';
  static const String groupGetSubGroupList = 'Group/GetSubGroupList';
  static const String groupGetSubGroupDetail = 'Group/GetSubGroupDetail';
  static const String groupAddMemberToGroup = 'Group/AddMemberToGroup';
  static const String groupAddMultipleMemberToGroup =
      'Group/AddMultipleMemberToGroup';
  static const String groupGlobalSearchGroup = 'Group/GlobalSearchGroup';
  static const String groupDeleteByModuleName = 'Group/DeleteByModuleName';
  static const String groupDeleteImage = 'Group/DeleteImage';
  static const String groupUpdateModuleDashboard =
      'Group/UpdateModuleDashboard';
  static const String groupRemoveGroupCategory = 'Group/RemoveGroupCategory';
  static const String groupUpdateMemberGroupCategory =
      'Group/UpdateMemberGroupCategory';
  static const String groupGetGroupModulesList = 'Group/GetGroupModulesList';
  static const String groupGetNotificationCount = 'Group/GetNotificationCount';
  static const String groupGetEmail = 'Group/GetEmail';
  static const String groupGetNewDashboard = 'Group/GetNewDashboard';
  static const String groupGetRotaryLibraryData = 'Group/GetRotaryLibraryData';
  static const String groupGetAdminSubModules = 'Group/getAdminSubModules';
  static const String groupGetEntityInfo = 'Group/GetEntityInfo';
  static const String groupGetAllGroupListSync = 'Group/GetAllGroupListSync';
  static const String groupGetClubDetails = 'Group/GetClubDetails';
  static const String groupGetClubHistory = 'Group/GetClubHistory';
  static const String groupFeedback = 'Group/Feedback';
  static const String groupGetZoneList = 'Group/getZonelist';
  static const String groupGetMobilePupup = 'Group/getMobilePupup';
  static const String groupUpdateMobilePupupFlag =
      'Group/UpdateMobilePupupflag';
  /// iOS: RootDashViewController.functionForSetDeviceToken()
  static const String groupUpdateDeviceTokenNumber =
      'Group/UpdateDeviceTokenNumber';
  static const String groupGetAssistanceGov = 'Group/GetAssistanceGov';
  static const String groupGetRotaryIndiaAdminModules =
      'Group/GetRotaryIndiaAdminModules';
  static const String groupRemoveSelfFromGroup = 'Group/RemoveSelfFromGroup';

  // ─── MEMBER ────────────────────────────────────────────
  static const String memberUpdateProfile = 'Member/UpdateProfile';
  static const String memberGetDirectoryList = 'Member/GetDirectoryList';
  static const String memberGetMember = 'Member/GetMember';
  static const String memberGetMemberListSync = 'Member/GetMemberListSync';
  static const String memberUpdateProfileDetails =
      'member/UpdateProfileDetails';
  static const String memberUpdateAddressDetails =
      'Member/UpdateAddressDetails';
  static const String memberUpdateFamilyDetails = 'Member/UpdateFamilyDetails';
  static const String memberGetUpdatedProfileDetails =
      'Member/GetUpdatedmemberProfileDetails';
  static const String memberUploadProfilePhoto = 'Member/UploadProfilePhoto';
  static const String memberGetBodList = 'Member/GetBODList';
  static const String memberGetGoverningCouncil = 'Member/GetGoverningCouncl';
  static const String memberUpdateMember = 'Member/UpdateMemebr';
  static const String memberUpdateProfilePersonalDetails =
      'Member/UpdateProfilePersonalDetails';
  /// iOS: RootDashViewController.getRequest — GET with query params
  static const String memberGetMemberDetails = 'Member/GetMemberDetails';

  // ─── EVENT ─────────────────────────────────────────────
  static const String eventGetEventDetails = 'Event/GetEventDetails';
  static const String eventGetEventList = 'Event/GetEventList';
  static const String eventAddEventNew = 'Event/AddEvent_New';
  static const String eventAnsweringEvent = 'Event/AnsweringEvent';
  static const String eventGetSmsCountDetails = 'Event/Getsmscountdetails';

  // ─── ANNOUNCEMENT ──────────────────────────────────────
  static const String announcementGetList =
      'Announcement/GetAnnouncementList';
  static const String announcementGetDetails =
      'Announcement/GetAnnouncementDetails';
  static const String announcementAdd = 'Announcement/AddAnnouncement';

  // ─── DOCUMENT ──────────────────────────────────────────
  static const String documentAdd = 'DocumentSafe/AddDocument';
  static const String documentGetList = 'DocumentSafe/GetDocumentList';
  static const String documentUpdateIsRead =
      'DocumentSafe/UpdateDocumentIsRead';

  // ─── E-BULLETIN ────────────────────────────────────────
  static const String ebulletinAdd = 'Ebulletin/AddEbulletin';
  static const String ebulletinGetYearWiseList =
      'Ebulletin/GetYearWiseEbulletinList';

  // ─── GALLERY ───────────────────────────────────────────
  static const String galleryGetAlbumsList = 'Gallery/GetAlbumsList';
  static const String galleryGetAlbumsListNew = 'Gallery/GetAlbumsList_New';
  /// iOS uses _New variant for photo list throughout the codebase
  static const String galleryGetAlbumPhotoList = 'Gallery/GetAlbumPhotoList_New';
  static const String galleryAddUpdateAlbum = 'Gallery/AddUpdateAlbum_New';
  static const String galleryAddUpdateAlbumPhoto =
      'Gallery/AddUpdateAlbumPhoto';
  static const String galleryDeleteAlbumPhoto = 'Gallery/DeleteAlbumPhoto';
  static const String galleryGetAlbumDetails = 'Gallery/GetAlbumDetails_New';
  static const String galleryGetShowcaseDetails =
      'Gallery/GetShowcaseDetails';
  static const String galleryGetMerList = 'Gallery/GetMER_List';
  static const String galleryGetYear = 'Gallery/GetYear';
  static const String galleryFillYearList = 'Gallery/Fillyearlist';
  static const String galleryValidateDirectBeneficiaries =
      'Gallery/validateDirectBeneficiaries';
  static const String galleryGetBodMemberCount = 'Gallery/GEtBODMember_Cnt';

  // ─── ATTENDANCE ────────────────────────────────────────
  static const String attendanceGetList = 'Attendance/GetAttendanceListNew';
  static const String attendanceGetDetails = 'Attendance/getAttendanceDetails';
  static const String attendanceAddEdit = 'Attendance/AttendanceAddEdit';
  static const String attendanceDelete = 'Attendance/AttendanceDelete';
  static const String attendanceGetEventsListNew =
      'Attendance/GetAttendanceEventsListNew';
  static const String attendanceGetMemberDetails =
      'Attendance/getAttendanceMemberDetails';
  static const String attendanceGetAnnsDetails =
      'Attendance/getAttendanceAnnsDetails';
  static const String attendanceGetAnnetsDetails =
      'Attendance/getAttendanceAnnetsDetails';
  static const String attendanceGetVisitorsDetails =
      'Attendance/getAttendanceVisitorsDetails';
  static const String attendanceGetRotariansDetails =
      'Attendance/getAttendanceRotariansDetails';
  static const String attendanceGetDistrictDelegateDetails =
      'Attendance/getAttendanceDistrictDeleagateDetails';

  // ─── CELEBRATIONS ──────────────────────────────────────
  static const String celebrationGetMonthEventList =
      'Celebrations/GetMonthEventList';
  static const String celebrationGetEventMinDetails =
      'Celebrations/GetEventMinDetails';
  static const String celebrationGetMonthEventListTypeWise =
      'Celebrations/GetMonthEventListTypeWise';
  static const String celebrationGetMonthEventListDetails =
      'Celebrations/GetMonthEventListDetails';
  static const String celebrationGetTodaysBirthday =
      'Celebrations/GetTodaysBirthday';
  /// iOS: National-level celebration variants (isCategory == "2")
  static const String celebrationGetMonthEventListTypeWiseNational =
      'Celebrations/GetMonthEventListTypeWise_National';
  static const String celebrationGetMonthEventListDetailsNational =
      'Celebrations/GetMonthEventListDetails_National';

  // ─── SERVICE DIRECTORY ─────────────────────────────────
  static const String serviceDirectoryGetCategories =
      'ServiceDirectory/GetServiceCategoriesData';
  static const String serviceDirectoryGetList =
      'ServiceDirectory/GetServiceDirectoryCategories';
  static const String serviceDirectoryGetDetails =
      'ServiceDirectory/GetServiceDirectoryDetails';
  static const String serviceDirectoryAdd =
      'ServiceDirectory/AddServiceDirectory';
  static const String serviceDirectoryGetSync =
      'OfflineData/GetServiceDirectoryListSync';

  // ─── SETTINGS ──────────────────────────────────────────
  static const String settingGetTouchbaseSetting =
      'setting/GetTouchbaseSetting';
  static const String settingTouchbaseSetting = 'setting/TouchbaseSetting';
  static const String settingGroupSetting = 'Setting/GroupSetting';
  static const String settingGetGroupSetting = 'Setting/GetGroupSetting';

  // ─── FIND CLUB ─────────────────────────────────────────
  static const String findClubGetClubList = 'FindClub/GetClubList';
  static const String findClubGetClubDetails = 'FindClub/GetClubDetails';
  static const String findClubGetClubsNearMe = 'FindClub/GetClubsNearMe';
  static const String findClubGetPublicAlbumsList =
      'FindClub/GetPublicAlbumsList';
  static const String findClubGetPublicEventsList =
      'FindClub/GetPublicEventsList';
  static const String findClubGetPublicNewsletterList =
      'FindClub/GetPublicNewsletterList';
  static const String findClubGetClubMembers = 'FindClub/GetClubMembers';
  static const String findClubGetCommitteeList = 'FindClub/GetCommitteelist';

  // ─── FIND ROTARIAN ────────────────────────────────────
  static const String findRotarianGetZoneChapterList =
      'FindRotarian/GetZonechapterlist';
  static const String findRotarianGetList = 'FindRotarian/GetRotarianList';
  static const String findRotarianGetDetails =
      'FindRotarian/GetRotarianDetails';
  static const String findRotarianGetDetailsAlt =
      'FindRotarian/GetrotarianDetails';
  static const String findRotarianGetCategoryList =
      'FindRotarian/GetCategoryList';
  static const String findRotarianGetMemberGradeList =
      'FindRotarian/GetMemberGradeList';
  static const String findRotarianGetClubList = 'FindRotarian/GetClubList';

  // ─── MEMBER (PROFILE) ────────────────────────────────────
  static const String memberSaveProfile = 'Member/Saveprofile';

  // ─── SUB-GROUPS ──────────────────────────────────────────
  static const String subgroupGetList = 'Group/GetSubGroupList';
  static const String subgroupGetDetail = 'Group/GetSubGroupDetail';
  static const String subgroupCreate = 'Group/CreateSubGroup';

  // ─── LEADERBOARD ──────────────────────────────────────
  static const String getLeaderBoardDetails =
      'LeaderBoard/GetLeaderBoardDetails';
  static const String getZoneList = 'Group/getZonelist';

  // ─── DISTRICT ──────────────────────────────────────────
  static const String districtGetMemberListSync =
      'District/GetDistrictMemberListSync';
  static const String districtGetClubs = 'District/GetClubs';
  static const String districtGetCommittee = 'District/GetDistrictCommittee';
  static const String districtGetClassificationListNew =
      'District/GetClassificationList_New';
  static const String districtGetMemberByClassification =
      'District/GetMemberByClassification';
  static const String districtGetMemberWithDynamicFields =
      'District/GetMemberWithDynamicFields';

  // ─── DISTRICT COMMITTEE ─────────────────────────────────
  static const String districtCommitteeDetails =
      'DistrictCommittee/districtCommitteeDetails';

  // ─── CLUB MONTHLY REPORT ────────────────────────────────
  static const String clubMonthlyReportGetList =
      'ClubMonthlyReport/GetMonthlyReportList';
  static const String clubMonthlyReportSendSms =
      'ClubMonthlyReport/SendSMSAndMailToNonSubmitedReports';

  // ─── VERSION CHECK ──────────────────────────────────────
  static const String versionGetVersionList = 'versionList/GetVersionList';

  // ─── OFFLINE DATA ─────────────────────────────────────
  static const String offlineGetServiceDirectoryListSync =
      'OfflineData/GetServiceDirectoryListSync';

  // ─── PAST PRESIDENTS ──────────────────────────────────
  static const String pastPresidentsGetList =
      'PastPresidents/getPastPresidentsList';

  // ─── WEB LINK ─────────────────────────────────────────
  static const String webLinkGetList = 'WebLink/GetWebLinksList';

  // ─── JITO / VOICE OF JITO ────────────────────────────
  static const String jitoGetRotaryLibraryData = 'Jito/GetRotaryLibraryData';

  // ─── UPLOAD ───────────────────────────────────────────
  static const String uploadImage = 'upload/UploadImage';

  // ─── API PARAMETER KEYS (matching iOS constants) ──────
  static const String paramProfileId = 'profileId';
  static const String paramGroupId = 'groupId';
  static const String paramUpdatedOn = 'updatedOn';
  static const String paramModuleId = 'moduleId';
  static const String paramAlbumId = 'albumId';
  static const String paramGroupProfileId = 'groupProfileID';
  static const String paramMonth = 'month';
  static const String paramYear = 'year';
  static const String paramModuleID = 'moduleID';
  static const String paramGrpId = 'grpID';
  static const String paramMasterUID = 'masterUID';
  static const String paramDocId = 'DocID';
  static const String paramMemberProfileId = 'memberProfileID';
  static const String paramSelectedDate = 'selectedDate';
  static const String paramName = 'name';
  static const String paramClassification = 'classification';
  static const String paramClub = 'club';
  static const String paramDistrictNumber = 'district_number';

  // ─── API RESPONSE KEYS ────────────────────────────────
  static const String responseSuccess = 'success';
  static const String responseData = 'data';
  static const String responseError = 'error';
  static const String responseMessage = 'message';
}
