/// App-level constants matching iOS AppConstant.swift and UserDefaults keys.
/// SharedPreferences key names mapped from iOS UserDefaults keys.
class AppConstants {
  AppConstants._();

  // ─── APP INFO ──────────────────────────────────────────
  static const String appName = 'TouchBase';
  static const String appBundleId = 'com.imeiconnect.touchbaseFlutter';

  // ─── AUTH HEADER ───────────────────────────────────────
  static const String authorizationHeader =
      'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==';

  // ─── SHARED PREFERENCES KEYS ──────────────────────────
  // Primary user identity keys (mapped from iOS UserDefaults)

  /// iOS: masterUID
  static const String keyMasterUid = 'master_uid';

  /// iOS: grpId0
  static const String keyGroupIdPrimary = 'group_id_primary';

  /// iOS: grpId
  static const String keyGroupId = 'group_id';

  /// iOS: firstName
  static const String keyFirstName = 'first_name';

  /// iOS: middleName
  static const String keyMiddleName = 'middle_name';

  /// iOS: lastName
  static const String keyLastName = 'last_name';

  /// iOS: IMEI_Mem_Id
  static const String keyImeiMemberId = 'imei_member_id';

  /// iOS: ClubName
  static const String keyClubName = 'club_name';

  /// iOS: profileImg
  static const String keyProfileImage = 'profile_image';

  /// iOS: memberIdss
  static const String keyMemberProfileId = 'member_profile_id';

  /// iOS: DeviceToken
  static const String keyDeviceToken = 'device_token';

  /// iOS: isAdmin
  static const String keyIsAdmin = 'is_admin';

  /// iOS: user_auth_token_profileId
  static const String keyAuthProfileId = 'auth_profile_id';

  /// iOS: user_auth_token_groupId
  static const String keyAuthGroupId = 'auth_group_id';

  // ─── SESSION KEYS ─────────────────────────────────────
  /// iOS: grpProfileId / grpProfileid
  static const String keyGrpProfileId = 'grp_profile_id';

  /// iOS: isGrpAdmin
  static const String keyIsGrpAdmin = 'is_grp_admin';

  /// iOS: Session_Club_ID
  static const String keySessionClubId = 'session_club_id';

  /// iOS: Session_Club_TYPE
  static const String keySessionClubType = 'session_club_type';

  /// iOS: Session_District_ID
  static const String keySessionDistrictId = 'session_district_id';

  /// iOS: Session_Website
  static const String keySessionWebsite = 'session_website';

  /// iOS: Session_AutorizationToken
  static const String keySessionAuthToken = 'session_auth_token';

  /// iOS: Session_SelectedIndexValue
  static const String keySessionSelectedIndex = 'session_selected_index';

  /// iOS: session_Login_Type
  static const String keySessionLoginType = 'session_login_type';

  /// iOS: session_Mobile_Number
  static const String keySessionMobileNumber = 'session_mobile_number';

  /// iOS: session_grpProfileid
  static const String keySessionGrpProfileId = 'session_grp_profile_id';

  /// iOS: session_IsFirstTime
  static const String keySessionIsFirstTime = 'session_is_first_time';

  /// iOS: session_lastUpdateDate
  static const String keySessionLastUpdateDate = 'session_last_update_date';

  /// iOS: session_notificationCount
  static const String keySessionNotificationCount =
      'session_notification_count';

  /// iOS: session_GetGroupId
  static const String keySessionGetGroupId = 'session_get_group_id';

  /// iOS: session_GetModuleId
  static const String keySessionGetModuleId = 'session_get_module_id';

  /// iOS: session_GetFeedValue
  static const String keySessionGetFeedValue = 'session_get_feed_value';

  /// iOS: session_GetFilterTypeValue
  static const String keySessionGetFilterTypeValue =
      'session_get_filter_type_value';

  /// iOS: session_LinkValue
  static const String keySessionLinkValue = 'session_link_value';

  /// iOS: session_LinkValueAnnouncement
  static const String keySessionLinkValueAnnouncement =
      'session_link_value_announcement';

  /// iOS: session_EntityId
  static const String keySessionEntityId = 'session_entity_id';

  /// iOS: session_IsEntityExitInModuleScreen
  static const String keySessionIsEntityExitInModule =
      'session_is_entity_exit_in_module';

  /// iOS: session_createdByORUserIdOrProfileId
  static const String keySessionCreatedByProfileId =
      'session_created_by_profile_id';

  /// iOS: Session_ModuleNameForNavigationHeading_FindAClubOrClubs
  static const String keySessionModuleNameNavHeading =
      'session_module_name_nav_heading';

  /// iOS: Session_RssFeedFirstTime
  static const String keySessionRssFeedFirstTime =
      'session_rss_feed_first_time';

  // ─── MEMBER DETAIL KEYS ───────────────────────────────
  /// iOS: MobileNo / mobileNo
  static const String keyMobileNo = 'mobile_no';

  /// iOS: Email / email
  static const String keyEmail = 'email';

  /// iOS: DOB / dOB
  static const String keyDob = 'dob';

  /// iOS: DOA
  static const String keyDoa = 'doa';

  /// iOS: Designation / designation
  static const String keyDesignation = 'designation';

  /// iOS: DistrictDesignation
  static const String keyDistrictDesignation = 'district_designation';

  /// iOS: DistrictID
  static const String keyDistrictId = 'district_id';

  /// iOS: bloodGroup
  static const String keyBloodGroup = 'blood_group';

  /// iOS: Secondry_num
  static const String keySecondaryNum = 'secondary_num';

  /// iOS: Whatsapp_num
  static const String keyWhatsappNum = 'whatsapp_num';

  /// iOS: Company_name
  static const String keyCompanyName = 'company_name';

  /// iOS: MembershipGrade / Membership_Grade
  static const String keyMembershipGrade = 'membership_grade';

  /// iOS: IMEI_Membership_Id
  static const String keyImeiMembershipId = 'imei_membership_id';

  // ─── UI STATE KEYS ────────────────────────────────────
  /// iOS: isRootVisitedFirst
  static const String keyIsRootVisitedFirst = 'is_root_visited_first';

  /// iOS: splashOver
  static const String keySplashOver = 'splash_over';

  /// iOS: isitFirstTimeForDismissHUD
  static const String keyIsFirstTimeForDismissHud =
      'is_first_time_for_dismiss_hud';

  /// iOS: ShowHideMonthlyReportModule
  static const String keyShowHideMonthlyReport = 'show_hide_monthly_report';

  /// iOS: updatedOnForVersion
  static const String keyUpdatedOnForVersion = 'updated_on_for_version';

  /// iOS: isCategory_Session
  static const String keyIsCategorySession = 'is_category_session';

  /// iOS: moduleId_Session
  static const String keyModuleIdSession = 'module_id_session';

  /// iOS: moduleName_Session
  static const String keyModuleNameSession = 'module_name_session';

  // ─── ALBUM / GALLERY SESSION KEYS ─────────────────────
  /// iOS: session_AlbumID
  static const String keySessionAlbumId = 'session_album_id';

  /// iOS: session_NewImageAddedSuccess
  static const String keySessionNewImageAdded = 'session_new_image_added';

  /// iOS: session_IsComingFromImageSave
  static const String keySessionIsComingFromImageSave =
      'session_is_coming_from_image_save';

  /// iOS: ImageCountFiveOrNot
  static const String keyImageCountFiveOrNot = 'image_count_five_or_not';

  // ─── DOCUMENT SESSION KEYS ────────────────────────────
  /// iOS: session_IsComingFromDownloadedvieworUploadDocumnetScreen
  static const String keySessionIsComingFromDownloadOrUpload =
      'session_is_coming_from_download_or_upload';

  // ─── PROFILE SESSION KEYS ────────────────────────────
  /// iOS: session_IsComingFromEditUpdateProfileForUpdateUserProfile
  static const String keySessionIsComingFromEditProfile =
      'session_is_coming_from_edit_profile';

  /// iOS: session_IsComingFromProfileDynamicBack
  static const String keySessionIsComingFromProfileBack =
      'session_is_coming_from_profile_back';

  /// iOS: IsComingFromProfileScreen
  static const String keyIsComingFromProfileScreen =
      'is_coming_from_profile_screen';

  // ─── CALENDAR SESSION KEYS ────────────────────────────
  /// iOS: session_IsFirstTimeCalendarSlot
  static const String keySessionIsFirstTimeCalendar =
      'session_is_first_time_calendar';

  // ─── LOCATION SESSION KEYS ────────────────────────────
  /// iOS: session_setGetLatitude
  static const String keySessionLatitude = 'session_latitude';

  /// iOS: session_setGetLongitude
  static const String keySessionLongitude = 'session_longitude';

  /// iOS: session_setGetFormattedAddress
  static const String keySessionFormattedAddress =
      'session_formatted_address';

  // ─── VERSION & UPDATE KEYS ────────────────────────────
  /// iOS: versionNumber / versionss
  static const String keyVersionNumber = 'version_number';

  /// iOS: ios_latest_version_number
  static const String keyLatestVersionNumber = 'latest_version_number';

  /// iOS: ios_force_update_store_url
  static const String keyForceUpdateStoreUrl = 'force_update_store_url';

  // ─── NOTIFICATION KEYS ────────────────────────────────
  /// iOS: session_notificationBirAnniEventNar
  static const String keySessionNotificationBirAnniEvent =
      'session_notification_bir_anni_event';

  /// iOS: session_notificationCountForModule
  static const String keySessionNotificationCountForModule =
      'session_notification_count_for_module';
}
