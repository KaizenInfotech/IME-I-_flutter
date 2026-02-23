/// Toast and alert messages matching iOS ToastConstant.swift and
/// all hardcoded messages found across the iOS codebase.
class ToastConstants {
  ToastConstants._();

  // ─── INTERNET / CONNECTIVITY ──────────────────────────
  static const String noInternetConnection =
      'No internet connection. Please check your Internet Connection and try again.';
  static const String noInternetAvailable = 'No internet available.';
  static const String noInternetAccess = 'No internet access.';
  static const String pleaseCheckInternet =
      'Please check your internet connection, Please try again later';
  static const String makeDeviceConnected =
      'Make sure your device is connected to the internet.';

  // ─── SERVER / NETWORK ERRORS ──────────────────────────
  static const String couldNotConnectToServer =
      'Could not connect to server, please try again.';
  static const String somethingWentWrong =
      'Something went wrong, Please try again later';
  static const String somethingWentWrongGeneric = 'Something went wrong';
  static const String oopsSomethingWentWrong =
      'Oops! Something went wrong. Please check your Internet Connection and try again.';
  static const String requestFailed =
      'Oops! Something went wrong. This request failed, please try again.';
  static const String errorFetchingData =
      'Error occuring, While fetching data from server.';
  static const String pleaseWait = 'Loading... Please Wait..';
  static const String processing = 'Processing...';
  static const String loading = 'Loading...';
  static const String networkIssue = 'Network issue';

  // ─── SUCCESS MESSAGES ─────────────────────────────────
  static const String addedSuccessfully = 'Added successfully.';
  static const String updatedSuccessfully = 'Updated successfully.';
  static const String deletedSuccessfully = 'Deleted successfully.';
  static const String submittedSuccessfully = 'Submitted Successfully';
  static const String successfullySent = 'Successfully Sent.';
  static const String copiedToClipboard = 'Copied to clipboard';

  // ─── DELETE MESSAGES ──────────────────────────────────
  static const String couldNotDelete =
      'Could not DELETE, please Try Again!';
  static const String failedToDelete = 'Failed to DELETE, please Try again!';
  static const String deleteFailedRetry = 'Delete failed, Please try again!';
  static const String failedToDeleteGeneric = 'Failed to Delete...';
  static const String activityDeletedSuccessfully =
      'Activity deleted successfully.';
  static const String memberDeletedSuccessfully =
      'Member deleted successfully.';
  static const String cannotDeleteYourselfAdmin =
      'You are the Admin , You Can\'t Delete Yourself.';

  // ─── ALBUM / GALLERY ─────────────────────────────────
  static const String albumAddedSuccessfully = 'Album added successfully';
  static const String albumUpdatedSuccessfully = 'Album updated successfully.';
  static const String albumDeletedSuccessfully = 'Album deleted successfully.';
  static const String albumImageDeletedSuccessfully =
      'Album image Deleted successfully.';
  static const String photoDeletedSuccessfully = 'Photo deleted sucessfully';
  static const String photoRecordNotFound = 'Photo record not found.';
  static const String imagesUploadSuccessfully = 'Images Upload successfully.';
  static const String maxFivePhotosAllowed = 'Maximum 5 photos are allowed';
  static const String oneImageMandatory = 'One image is mandatory';
  static const String coverPhotoMandatory = 'Cover photo is mandatory';
  static const String pleaseFirstAddAlbum = 'Please first add album.';
  static const String pleaseSelectAtleastOnePhoto =
      'Please select atleast one photo';
  static const String noImageAvailableFirst =
      'No Image Availble First Add Image.';

  // ─── IMAGE UPLOAD ─────────────────────────────────────
  static const String imageUploadFailed =
      'Image Upload failed, Please try again!';
  static const String fileUploadFailed = 'File upload failed, Please Try Again!';
  static const String imageChangedSuccessfully = 'Image changed successfully';
  static const String profilePicChanged = 'Profile Pic Changed..';
  static const String updateProfilePicFailed = 'Update Profile Pic Failed..';
  static const String profileImageRemovedSuccessfully =
      'Profile image removed successfully';
  static const String familyImageRemovedSuccessfully =
      'Family image removed successfully';

  // ─── FILE / DOCUMENT ──────────────────────────────────
  static const String downloadedSuccessfully = 'Downloaded file successfully';
  static const String downloadLinkNotAvailable = 'Download link not Available';
  static const String fileAttachedSuccessfully =
      'File is attached successfully';
  static const String fileSizeLimit10Mb =
      'File size can not be more than 10 MB';
  static const String videoSizeLimit20Mb =
      'Video size can not be more than 20 MB';
  static const String onlyPdfAllowed = 'only PDF file is allowed';
  static const String onlyPdfCanBeShared = 'Only Pdf files can be shared';
  static const String onlyPdfOrDocAllowed =
      'Only pdf or doc file can be attached';
  static const String selectDocumentToShare = 'Select a Document to Share!';
  static const String fileNotAvailable =
      'Something went wrong, File not available.';
  static const String documentAlreadyDownloaded =
      'This Document is already downloaded';
  static const String documentDownloadHint =
      'Once downloaded, please click the folder symbol on the top right corner to view the file.';

  // ─── ANNOUNCEMENT ─────────────────────────────────────
  static const String announcementDeletedSuccessfully =
      'Announcement deleted Successfully';

  // ─── EVENT ────────────────────────────────────────────
  static const String eventDeletedSuccessfully = 'Event deleted Successfully';
  static const String eventNameCannotBeBlank = 'Event Name can not be blank';
  static const String eventDateCannotBeBlank = 'Event date can not be blank';
  static const String eventDescCannotBeBlank =
      'Event description cannot be blank';
  static const String pleaseEnterEventVenue = 'Please enter event Venue';
  static const String pleaseEnterEventDate =
      'Please Enter an Event Date & Time';
  static const String pleaseEnterEventTitle =
      'Please enter the event "Title"';
  static const String pleaseEnterEventDescription =
      'Please enter the event "Description"';

  // ─── ATTENDANCE ───────────────────────────────────────
  static const String attendanceAddedSuccessfully =
      'Attendance added successfully';
  static const String attendanceUpdatedSuccessfully =
      'Attendance updated successfully';
  static const String attendanceDeletedSuccessfully =
      'Attendance deleted successfully';

  // ─── NEWSLETTER ───────────────────────────────────────
  static const String newsletterDeletedSuccessfully =
      'Newsletter deleted Successfully.';

  // ─── DOCUMENT ─────────────────────────────────────────
  static const String documentDeletedSuccessfully =
      'Document deleted Successfully';

  // ─── SETTINGS ─────────────────────────────────────────
  static const String failedToUpdateSetting =
      'Failed to update setting, try again later.';

  // ─── PROFILE ──────────────────────────────────────────
  static const String profileUpdatedSuccessfully =
      'Profile updated successfully.';
  static const String emailUpdatedSuccessfully =
      'Email updated successfully!.';
  static const String numberUpdatedSuccessfully =
      'Number updated successfully!.';
  static const String companyNameUpdatedSuccessfully =
      'Company Name updated successfully!.';
  static const String dobUpdatedSuccessfully =
      'Date of Birth Updated Successfully.';
  static const String nameCanNotBeChanged = 'Name can not be changed';
  static const String telephoneCanNotBeChanged =
      'Telephone No. can not be changed';
  static const String districtDesignationCanNotBeChanged =
      'District Designation can not be changed';
  static const String nameOrRelationCannotBeBlank =
      'name or relation can not be blank';

  // ─── VALIDATION MESSAGES ──────────────────────────────
  static const String pleaseEnterTitle = 'Please enter title';
  static const String pleaseEnterDescription = 'Please enter Description';
  static const String pleaseEnterName = 'Please enter name';
  static const String pleaseEnterTheName = 'Please enter the Name';
  static const String pleaseEnterTheTitle = 'Please enter the Title';
  static const String pleaseEnterTheDescription =
      'Please enter the Description';
  static const String pleaseEnterMobileNumber =
      'Please enter a Mobile Number';
  static const String pleaseEnterValidMobile =
      'Please enter a valid mobile number.';
  static const String pleaseEnterValidEmail =
      'Please enter a valid Email Address';
  static const String pleaseEnterValidEmailId =
      'Please enter Valid Email Id';
  static const String pleaseEnterValidEmailForFamily =
      'Please enter a valid Email ID for family member.';
  static const String pleaseEnterValidUrl = 'Please enter valid url';
  static const String pleaseEnterValidWebUrl = 'Please enter valid web URL';
  static const String pleaseEnterFeedback = 'Please enter feedback.';
  static const String pleaseEnterPublishDate =
      'Please enter a Publish Date & Time';
  static const String pleaseEnterExpiryDate =
      'Please enter an Expiry Date & Time';
  static const String pleaseEnterSubGroupName =
      'Please enter a Sub Group Name';
  static const String pleaseEnterDocumentTitle =
      'Please enter a Document Title';
  static const String pleaseEnterLinkOrUploadPdf =
      'Please enter either a link or upload pdf file';
  static const String pleaseEnterQuestion = 'Please enter Question.';
  static const String pleaseEnterTextForOption =
      'Please enter text for option';
  static const String pleaseEnterClubName = 'Please enter club name';
  static const String pleaseEnterSecondaryMobile =
      'Please enter secondary mobile number';
  static const String pleaseEnterChangeRequestText =
      'Please enter your text for change request';
  static const String mobileCannotStartWithZero =
      'Mobile number cannot start with zero(0).';

  // ─── SELECTION VALIDATION ─────────────────────────────
  static const String pleaseSelectCountry = 'Please select country';
  static const String pleaseSelectCountryCode = 'Please Select Country Code';
  static const String pleaseSelectCategory = 'Please select category';
  static const String pleaseSelectAtleastOneGroup =
      'Please Select atleast 1 Group';
  static const String pleaseSelectAtleastOneMember =
      'Please Select atleast 1 Member';
  static const String pleaseSelectAtleastOneEmail =
      'Please select at least one Email id';
  static const String pleaseSelectAtleastOneNumber =
      'Please select at least One Number';
  static const String pleaseSelectAtleastOneContact =
      'Please select at least one contact number';
  static const String pleaseSelectYear = 'Please select Year';
  static const String pleaseSelectQuestionType = 'Please select question type';
  static const String pleaseSelectAccessType = 'Please select Access Type';
  static const String pleaseSelectPublishDate = 'Please select Publish Date';
  static const String pleaseSelectExpiryDate = 'Please select Expiry Date';
  static const String pleaseSelectProjectDate = 'Please select Project date';
  static const String pleaseSelectCountryForBusiness =
      'Please select country for business address';
  static const String pleaseSelectCountryForResidential =
      'Please select country for residential address';
  static const String pleaseSelectCountryForSecondary =
      'Please select country for secondary mobile number';
  static const String pleaseSelectCountryForFamily =
      'Select Country for family detail member';
  static const String pleaseFillAtleastOneField =
      'Please fill at least one field for Member Search';
  static const String pleaseFillAtleastOneSearchCriteria =
      'Please Fill Atleast One Search Criteria';

  // ─── DATE VALIDATION ──────────────────────────────────
  static const String publishDateGreaterThanExpiry =
      'Publish date can not be greater than from Expiry date';
  static const String publishDateLessThanExpiry =
      'Publish date should be less than Expiry date';
  static const String publishExpiryCannotBeSame =
      'Publish date and Expiry date should not be same';
  static const String publishExpiryDateTimeSame =
      'Publish Date & Time should not be same as Expiry Date & Time';
  static const String pleaseEnterPublishDateFirst =
      'Please enter publish date first';
  static const String pleaseEnterExpiryDateEventFirst =
      'Please enter expiry date, event date first';
  static const String expiryDateTimeShouldBeGreater =
      'Please make the Expiry Date & Time greater than the Publish Date & Time';
  static const String publishDateTimeShouldBeGreaterThanCurrent =
      'Please make the Publish Date & Time greater than the current date & Time';
  static const String reminderDateTimeGreaterThanPublish =
      'Reminder Date & Time should be greater than the Publish Date & Time';
  static const String reminderDateTimeLessThanExpiry =
      'Reminder Date & Time should be less than Expiry Date & Time';
  static const String expiryGreaterThanEventDate =
      'Expiry Date and Time should be greater than Event Date and Time.';
  static const String publishLessThanEventDate =
      'Publish Date and Time Should be Less than Event Date and Time.';

  // ─── CONTACT / EMAIL AVAILABILITY ─────────────────────
  static const String emailNotAvailable = 'Email Id not available.';
  static const String emailIdNotAvailable = 'Email ID not available!';
  static const String mobileNumberNotAvailable = 'Mobile Number not available!';
  static const String whatsappNumberNotAvailable =
      'What\'s app number not available!';
  static const String whatsappNumberNotFound = 'Whatsapp number not found';
  static const String phoneNumberNotFound = 'Phone number not found';
  static const String emailNotFound = 'Email not found';
  static const String whatsappNotInstalled = 'WhatsApp is not installed.';

  // ─── CAMERA / DEVICE ──────────────────────────────────
  static const String cameraNotFound =
      'Camera Not Found, this device has no Camera';
  static const String deviceHasNoCamera = 'This device has no Camera';

  // ─── REGISTRATION ─────────────────────────────────────
  static const String registrationSuccess = 'Registration done successfully';
  static const String registrationRequestSuccess =
      'Registration Request success.';
  static const String registrationRequestFailed =
      'Registration Request Failed';

  // ─── LOCATION ─────────────────────────────────────────
  static const String unableToGetLocation =
      'Unable To Get Your Current Location. Please Try Again.';
  static const String addressNotValid = 'Address is not valid';
  static const String unableToFindLocation =
      'Unable to find the location as the address may be incomplete.';

  // ─── WHATSAPP ─────────────────────────────────────────
  static const String whatsappSentSuccessfully = 'Whatsapp send successfully';
  static const String whatsappBalanceZero =
      'Balance WhatsApp count is 0. Please recharge';

  // ─── MAIL ─────────────────────────────────────────────
  static const String mailCancelled = 'Mail cancelled';
  static const String mailSaved = 'Mail saved';
  static const String mailSent = 'Mail sent';
  static const String yourEmailNotExist = 'Your Email ID Not Exist!.';

  // ─── RSVP ─────────────────────────────────────────────
  static const String rsvpResetToZero = 'RSVP result will be reset to 0';

  // ─── GENERIC ──────────────────────────────────────────
  static const String noRecordFound = 'No record found.';
  static const String noResultFound = 'No result found';
  static const String noResult = 'No Result';
  static const String noResults = 'No Results';
  static const String noDataAvailable = 'No data available.';
  static const String noNewUpdatesFound = 'No new updates found';
  static const String comingSoon = 'Coming Soon';
  static const String failed = 'Failed';
  static const String failedPleaseTryLater = 'Failed, Please try again later';
  static const String pleaseTryAgainLater = 'Please try again later';
  static const String pleaseLoadDirectoryFirst =
      'Please first load Directory contacts to view your profile.';

  // ─── VERSION UPDATE ───────────────────────────────────
  static const String newVersionAvailable =
      'There is a newer version avaliable for download! Please update the app by visiting the Apple Store';

  // ─── CONFIRMATION DIALOGS ─────────────────────────────
  static const String confirmDeletePhoto = 'Are you Confirm Delete Photo';
  static const String areYouSureDelete = 'Are you sure you want to delete ?';
  static const String areYouSureDeleteActivity =
      'Are you sure you want to delete this Activity';
  static const String areYouSureDeletePhoto =
      'Are you sure you want to delete this Photo ?';
  static const String areYouSureDeleteAlbum =
      'Are you sure you want to delete this album';
  static const String areYouSureDeleteDocument =
      'Are you sure you want to delete this document?';
  static const String wantToDeleteDocument =
      'Want to delete this document ?';
  static const String selectFileToUpload = 'Select file to upload';
  static const String whereImageFrom = 'Where would you like the image from?';
  static const String chooseOption = 'Choose Option';

  // ─── PROJECT SPECIFIC ─────────────────────────────────
  static const String cannotDeleteMainProject =
      'This is main project, You can not delete this project.';
  static const String cannotMoveMainProject =
      'This is main project, You can not move this project.';
  static const String descriptionLimit2000Sms =
      'Description cannot be more than 2000 characters for SMS.';
  static const String reminderAddedSuccessfully =
      'Reminder added successfully!';
  static const String setDateTimeForReminder =
      'Please set the date and time for the reminder.';

  // ─── ALERT TITLES ─────────────────────────────────────
  static const String alertTitleDocument = 'Document';
  static const String alertTitleConfirm = 'Confirm';
  static const String alertTitleConfirmation = 'Confirmation';
  static const String alertTitleThankYou = 'Thank You!';
  static const String alertTitleMessage = 'Message';
  static const String alertTitleDownloading = 'Downloading...';

  // ─── BUTTON TITLES ────────────────────────────────────
  static const String buttonOk = 'OK';
  static const String buttonCancel = 'Cancel';
  static const String buttonClose = 'Close';
  static const String buttonYes = 'Yes';
  static const String buttonNo = 'No';
}
