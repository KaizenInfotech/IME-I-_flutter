import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../storage/local_storage.dart';

// ─── Auth ──────────────────────────────────────────────────────────
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';

// ─── Dashboard ─────────────────────────────────────────────────────
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/dashboard/screens/customize_modules_screen.dart';
import '../../features/dashboard/screens/admin_modules_screen.dart';
import '../../features/dashboard/screens/admin_web_view_screen.dart';
import '../../features/dashboard/models/admin_submodules_result.dart';

// ─── Directory ─────────────────────────────────────────────────────
import '../../features/directory/screens/directory_screen.dart';
import '../../features/directory/screens/profile_detail_screen.dart';
import '../../features/directory/screens/edit_profile_screen.dart';
import '../../features/directory/screens/jito_profile_screen.dart';
import '../../features/directory/models/member_detail_result.dart';

// ─── Events ────────────────────────────────────────────────────────
import '../../features/events/screens/events_list_screen.dart';
import '../../features/events/screens/event_detail_screen.dart';
import '../../features/events/screens/add_event_screen.dart';
import '../../features/events/screens/national_event_detail_screen.dart';
import '../../features/events/screens/club_events_list_screen.dart';
import '../../features/events/models/event_detail_result.dart';

// ─── Celebrations ──────────────────────────────────────────────────
import '../../features/celebrations/screens/celebrations_screen.dart';
import '../../features/celebrations/screens/birthday_list_screen.dart';
import '../../features/celebrations/screens/district_event_detail_screen.dart';
import '../../features/celebrations/models/celebration_result.dart';

// ─── Announcements ─────────────────────────────────────────────────
import '../../features/announcements/screens/announcements_list_screen.dart';
import '../../features/announcements/screens/announcement_detail_screen.dart';
import '../../features/announcements/screens/add_announcement_screen.dart';
import '../../features/announcements/models/announcement_list_result.dart';

// ─── Gallery ───────────────────────────────────────────────────────
import '../../features/gallery/screens/gallery_screen.dart';
import '../../features/gallery/screens/album_photos_screen.dart';
import '../../features/gallery/screens/add_photo_screen.dart';
import '../../features/gallery/screens/create_album_screen.dart';
import '../../features/gallery/models/album_detail_result.dart';

// ─── Documents ─────────────────────────────────────────────────────
import '../../features/documents/screens/documents_list_screen.dart';
import '../../features/documents/screens/document_detail_screen.dart';
import '../../features/documents/screens/document_viewer_screen.dart';
import '../../features/documents/models/document_list_result.dart';

// ─── E-Bulletin ────────────────────────────────────────────────────
import '../../features/ebulletin/screens/ebulletin_list_screen.dart';
import '../../features/ebulletin/screens/ebulletin_detail_screen.dart';
import '../../features/ebulletin/screens/add_ebulletin_screen.dart';
import '../../features/ebulletin/models/ebulletin_list_result.dart';

// ─── Attendance ────────────────────────────────────────────────────
import '../../features/attendance/models/attendance_result.dart';
import '../../features/attendance/screens/attendance_screen.dart';
import '../../features/attendance/screens/attendance_detail_screen.dart';

// ─── Find Rotarian ─────────────────────────────────────────────────
import '../../features/find_rotarian/screens/find_rotarian_screen.dart';
import '../../features/find_rotarian/screens/rotarian_profile_screen.dart';

// ─── Find Club ─────────────────────────────────────────────────────
import '../../features/find_club/screens/find_club_screen.dart';
import '../../features/find_club/screens/club_detail_screen.dart';

// ─── Service Directory ─────────────────────────────────────────────
import '../../features/service_directory/screens/service_directory_screen.dart';
import '../../features/service_directory/screens/service_category_screen.dart';

// ─── Subgroups ─────────────────────────────────────────────────────
import '../../features/subgroups/screens/subgroup_list_screen.dart';
import '../../features/subgroups/screens/subgroup_detail_screen.dart';

// ─── District ──────────────────────────────────────────────────────
import '../../features/district/screens/district_directory_screen.dart';
import '../../features/district/screens/district_member_detail_screen.dart';
import '../../features/district/screens/district_club_members_screen.dart';

// ─── Leaderboard ───────────────────────────────────────────────────
import '../../features/leaderboard/screens/leaderboard_screen.dart';

// ─── Web Links ─────────────────────────────────────────────────────
import '../../features/web_links/screens/web_links_screen.dart';
import '../../features/web_links/screens/web_link_detail_screen.dart';
import '../../features/web_links/models/web_link_result.dart';

// ─── Notifications ─────────────────────────────────────────────────
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/notifications/screens/notification_settings_screen.dart';
import '../../features/notifications/screens/notification_event_detail_screen.dart';

// ─── Settings ──────────────────────────────────────────────────────
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/group_settings_screen.dart';

// ─── Profile ───────────────────────────────────────────────────────
import '../../features/profile/screens/my_profile_screen.dart';
import '../../features/profile/screens/edit_family_screen.dart';
import '../../features/profile/screens/edit_address_screen.dart';
import '../../features/profile/screens/change_request_screen.dart';

// ─── Groups ────────────────────────────────────────────────────────
import '../../features/groups/screens/group_detail_screen.dart';
import '../../features/groups/screens/add_members_screen.dart';
import '../../features/groups/screens/global_search_screen.dart';

// ─── Monthly Report ────────────────────────────────────────────────
import '../../features/monthly_report/screens/monthly_pdf_list_screen.dart';
import '../../features/monthly_report/screens/monthly_pdf_view_screen.dart';

// ─── Governing Council ─────────────────────────────────────────────
import '../../features/governing_council/screens/governing_council_screen.dart';

// ─── Sub Committee ─────────────────────────────────────────────────
import '../../features/sub_committee/screens/sub_committee_screen.dart';
import '../../features/sub_committee/screens/sub_committee_members_screen.dart';
import '../../features/sub_committee/screens/sub_committee_profile_screen.dart';
import '../../features/sub_committee/models/sub_committee_result.dart';

// ─── MER / iMelange ───────────────────────────────────────────────
import '../../features/mer/screens/mer_dashboard_screen.dart';

// ─── Past Presidents ───────────────────────────────────────────────
import '../../features/profile/screens/past_presidents_screen.dart';

// ─── Branch & Chapter ──────────────────────────────────────────────
import '../../features/branch_chapter/screens/branch_chapter_screen.dart';
import '../../features/branch_chapter/screens/branch_dashboard_screen.dart';
import '../../features/branch_chapter/screens/branch_members_screen.dart';
import '../../features/branch_chapter/screens/executive_committee_screen.dart';
import '../../features/branch_chapter/screens/past_events_screen.dart';
import '../../features/branch_chapter/screens/past_event_detail_screen.dart';
import '../../features/branch_chapter/models/past_event_result.dart';

// ─── Find Member ───────────────────────────────────────────────────
import '../../features/find_rotarian/screens/find_member_screen.dart';

// ─── Maps ──────────────────────────────────────────────────────────
import '../../features/maps/screens/map_address_screen.dart';

/// Helper to extract extra map from GoRouterState.
Map<String, dynamic> _extra(GoRouterState state) =>
    state.extra as Map<String, dynamic>? ?? {};

/// App-wide GoRouter configuration.
/// Mirrors the iOS Main.storyboard navigation tree.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: _authGuard,
    errorBuilder: (_, _) => const _NotFoundScreen(),
    routes: [
      // ═══════════════════════════════════════════════════════════
      // AUTH ROUTES: /splash → /login → /otp → /welcome
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final e = _extra(state);
          return OtpScreen(
            mobileNumber: e['mobileNumber'] as String? ?? '',
            countryCode: e['countryCode'] as String? ?? '',
            loginType: e['loginType'] as String? ?? '0',
            otp: e['otp'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/welcome',
        builder: (_, _) => const WelcomeScreen(),
      ),

      // ═══════════════════════════════════════════════════════════
      // MAIN ROUTES: /dashboard (with drawer)
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: '/dashboard',
        builder: (_, _) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'customize',
            builder: (_, state) {
              final e = _extra(state);
              return CustomizeModulesScreen(
                groupId: e['groupId'] as String? ?? '',
                memberProfileId: e['memberProfileId'] as String? ?? '',
                groupName: e['groupName'] as String? ?? '',
              );
            },
          ),
          GoRoute(
            path: 'admin-modules',
            builder: (_, state) {
              final e = _extra(state);
              return AdminModulesScreen(
                adminModules:
                    e['adminModules'] as List<AdminSubmodule>? ?? const [],
                groupId: e['groupId'] as String? ?? '',
                isCategory: e['isCategory'] as String? ?? '',
                isAdmin: e['isAdmin'] as String? ?? '',
                profileId: e['profileId'] as String? ?? '',
                moduleName: e['moduleName'] as String?,
              );
            },
          ),
          GoRoute(
            path: 'admin-webview',
            builder: (_, state) {
              final e = _extra(state);
              return AdminWebViewScreen(
                url: e['url'] as String? ?? '',
                title: e['title'] as String?,
              );
            },
          ),
        ],
      ),

      // ═══════════════════════════════════════════════════════════
      // FEATURE ROUTES
      // ═══════════════════════════════════════════════════════════

      // ─── Directory ──────────────────────────────────────────
      GoRoute(
        path: '/directory',
        builder: (_, state) {
          final e = _extra(state);
          return DirectoryScreen(
            moduleName: e['moduleName'] as String?,
            isCategory: e['isCategory'] as String?,
            groupUniqueName: e['groupUniqueName'] as String?,
          );
        },
        routes: [
          GoRoute(
            path: 'profile/:id',
            builder: (_, state) {
              final e = _extra(state);
              return ProfileDetailScreen(
                memberProfileId: state.pathParameters['id'] ?? '',
                groupId: e['groupId'] as String? ?? '',
                memberName: e['memberName'] as String? ?? '',
                isCategory: e['isCategory'] as String? ?? '',
                groupUniqueName: e['groupUniqueName'] as String? ?? '',
                adminProfileId: e['adminProfileId'] as String? ?? '',
              );
            },
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (_, state) {
              final e = _extra(state);
              final member = e['member'] as MemberDetail?;
              if (member == null) return const _NotFoundScreen();
              return EditProfileScreen(
                member: member,
                profileId: state.pathParameters['id'] ?? '',
                groupId: e['groupId'] as String? ?? '',
              );
            },
          ),
          GoRoute(
            path: 'jito-profile/:id',
            builder: (_, state) {
              final e = _extra(state);
              return JitoProfileScreen(
                memberProfileId: state.pathParameters['id'] ?? '',
                groupId: e['groupId'] as String? ?? '',
                memberName: e['memberName'] as String?,
              );
            },
          ),
        ],
      ),

      // ─── Events ─────────────────────────────────────────────
      GoRoute(
        path: '/events',
        builder: (_, state) {
          final e = _extra(state);
          return EventsListScreen(
            moduleName: e['moduleName'] as String?,
            isCategory: e['isCategory'] as String?,
            isAdmin: e['isAdmin'] as bool? ?? false,
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) {
              final e = _extra(state);
              return EventDetailScreen(
                eventID: state.pathParameters['id'] ?? '',
                groupProfileID: e['groupProfileID'] as String? ?? '',
                grpId: e['grpId'] as String? ?? '',
                eventTitle: e['eventTitle'] as String? ?? '',
                isCategory: e['isCategory'] as String? ?? '',
                isAdmin: e['isAdmin'] as bool? ?? false,
              );
            },
          ),
          GoRoute(
            path: 'add',
            builder: (_, state) {
              final e = _extra(state);
              return AddEventScreen(
                grpId: e['grpId'] as String? ?? '',
                groupProfileID: e['groupProfileID'] as String? ?? '',
                isCategory: e['isCategory'] as String? ?? '',
                editEvent: e['editEvent'] as EventsDetail?,
              );
            },
          ),
          GoRoute(
            path: 'national/:id',
            builder: (_, state) {
              final e = _extra(state);
              return NationalEventDetailScreen(
                eventId: state.pathParameters['id'],
                groupId: e['groupId'] as String?,
                profileId: e['profileId'] as String?,
                titleName: e['titleName'] as String?,
                dateOfEvent: e['dateOfEvent'] as String?,
                description: e['description'] as String?,
                eventVenue: e['eventVenue'] as String?,
                photoUrl: e['photoUrl'] as String?,
                regLink: e['regLink'] as String?,
                isFrom: e['isFrom'] as String?,
              );
            },
          ),
          GoRoute(
            path: 'club-events',
            builder: (_, state) {
              final e = _extra(state);
              return ClubEventsListScreen(
                groupId: e['groupId'] as String? ?? '',
                profileId: e['profileId'] as String?,
                moduleName: e['moduleName'] as String?,
              );
            },
          ),
        ],
      ),

      // ─── Celebrations ───────────────────────────────────────
      GoRoute(
        path: '/celebrations',
        builder: (_, state) {
          final e = _extra(state);
          return CelebrationsScreen(
            groupId: e['groupId'] as String?,
            profileId: e['profileId'] as String?,
          );
        },
        routes: [
          GoRoute(
            path: 'birthday',
            builder: (_, state) {
              final e = _extra(state);
              return BirthdayListScreen(
                groupId: e['groupId'] as String?,
              );
            },
          ),
          GoRoute(
            path: 'district-event',
            builder: (_, state) {
              final event = state.extra as CelebrationEvent;
              return DistrictEventDetailScreen(event: event);
            },
          ),
        ],
      ),

      // ─── Announcements ──────────────────────────────────────
      GoRoute(
        path: '/announcements',
        builder: (_, state) {
          final e = _extra(state);
          return AnnouncementsListScreen(
            groupId: e['groupId'] as String?,
            profileId: e['profileId'] as String?,
            moduleId: e['moduleId'] as String? ?? '3',
          );
        },
        routes: [
          GoRoute(
            path: 'detail',
            builder: (_, state) {
              final e = _extra(state);
              return AnnouncementDetailScreen(
                announcement: e['announcement'] as AnnounceList,
              );
            },
          ),
          GoRoute(
            path: 'add',
            builder: (_, state) {
              final e = _extra(state);
              return AddAnnouncementScreen(
                groupId: e['groupId'] as String? ?? '',
                profileId: e['profileId'] as String? ?? '',
                moduleId: e['moduleId'] as String? ?? '',
                isSubGrpAdmin: e['isSubGrpAdmin'] as bool? ?? false,
                existingAnnouncement:
                    e['existingAnnouncement'] as AnnounceList?,
              );
            },
          ),
        ],
      ),

      // ─── Gallery ────────────────────────────────────────────
      GoRoute(
        path: '/gallery',
        builder: (_, state) {
          final e = _extra(state);
          return GalleryScreen(
            groupId: e['groupId'] as String?,
            profileId: e['profileId'] as String?,
            moduleId: e['moduleId'] as String? ?? '',
            isAdmin: e['isAdmin'] as bool? ?? false,
          );
        },
        routes: [
          GoRoute(
            path: 'album/:id',
            builder: (_, state) {
              final e = _extra(state);
              return AlbumPhotosScreen(
                albumId: state.pathParameters['id'] ?? '',
                albumTitle: e['albumTitle'] as String? ?? '',
                groupId: e['groupId'] as String? ?? '',
                isAdmin: e['isAdmin'] as bool? ?? false,
                profileId: e['profileId'] as String? ?? '',
              );
            },
          ),
          GoRoute(
            path: 'add-photo',
            builder: (_, state) {
              final e = _extra(state);
              return AddPhotoScreen(
                albumId: e['albumId'] as String? ?? '',
                groupId: e['groupId'] as String? ?? '',
                profileId: e['profileId'] as String? ?? '',
              );
            },
          ),
          GoRoute(
            path: 'create-album',
            builder: (_, state) {
              final e = _extra(state);
              return CreateAlbumScreen(
                groupId: e['groupId'] as String? ?? '',
                profileId: e['profileId'] as String? ?? '',
                moduleId: e['moduleId'] as String? ?? '',
                existingAlbum: e['existingAlbum'] as AlbumDetail?,
              );
            },
          ),
        ],
      ),

      // ─── Documents ──────────────────────────────────────────
      GoRoute(
        path: '/documents',
        builder: (_, state) {
          final e = _extra(state);
          return DocumentsListScreen(
            groupId: e['groupId'] as String?,
            profileId: e['profileId'] as String?,
            isAdmin: e['isAdmin'] as bool? ?? false,
            moduleId: e['moduleId'] as String? ?? '',
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) {
              final e = _extra(state);
              final document = e['document'] as DocumentItem?;
              if (document == null) return const _NotFoundScreen();
              return DocumentDetailScreen(
                document: document,
                profileId: e['profileId'] as String? ?? '',
                isAdmin: e['isAdmin'] as bool? ?? false,
              );
            },
          ),
          GoRoute(
            path: 'view/:id',
            builder: (_, state) {
              final e = _extra(state);
              return DocumentViewerScreen(
                filePath: e['filePath'] as String? ?? '',
                docType: e['docType'] as String? ?? 'pdf',
                title: e['title'] as String?,
              );
            },
          ),
        ],
      ),

      // ─── E-Bulletin ─────────────────────────────────────────
      GoRoute(
        path: '/ebulletin',
        builder: (_, state) {
          final e = _extra(state);
          return EbulletinListScreen(
            groupId: e['groupId'] as String?,
            profileId: e['profileId'] as String?,
            isAdmin: e['isAdmin'] as bool? ?? false,
            moduleId: e['moduleId'] as String? ?? '',
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) {
              final e = _extra(state);
              final ebulletin = e['ebulletin'] as EbulletinItem?;
              if (ebulletin == null) return const _NotFoundScreen();
              return EbulletinDetailScreen(
                ebulletin: ebulletin,
                profileId: e['profileId'] as String? ?? '',
                isAdmin: e['isAdmin'] as bool? ?? false,
              );
            },
          ),
          GoRoute(
            path: 'add',
            builder: (_, state) {
              final e = _extra(state);
              return AddEbulletinScreen(
                groupId: e['groupId'] as String? ?? '',
                profileId: e['profileId'] as String? ?? '',
                moduleId: e['moduleId'] as String? ?? '',
                isSubGrpAdmin: e['isSubGrpAdmin'] as bool? ?? false,
              );
            },
          ),
        ],
      ),

      // ─── Attendance ─────────────────────────────────────────
      GoRoute(
        path: '/attendance',
        builder: (_, state) {
          final e = _extra(state);
          return AttendanceScreen(
            groupId: e['groupId'] as String?,
            isAdmin: e['isAdmin'] as bool? ?? false,
          );
        },
        routes: [
          GoRoute(
            path: 'detail',
            builder: (_, state) {
              final e = _extra(state);
              return AttendanceDetailScreen(
                attendanceItem: e['attendanceItem'] as AttendanceItem,
                isAdmin: e['isAdmin'] as bool? ?? false,
              );
            },
          ),
        ],
      ),

      // ─── Find Rotarian ──────────────────────────────────────
      GoRoute(
        path: '/find-rotarian',
        builder: (_, _) => const FindRotarianScreen(),
        routes: [
          GoRoute(
            path: 'profile/:id',
            builder: (_, state) {
              return RotarianProfileScreen(
                memberProfileId: state.pathParameters['id'] ?? '',
              );
            },
          ),
        ],
      ),

      // ─── Find Club ──────────────────────────────────────────
      GoRoute(
        path: '/find-club',
        builder: (_, _) => const FindClubScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) {
              final e = _extra(state);
              return ClubDetailScreen(
                groupId: state.pathParameters['id'] ?? '',
                clubName: e['clubName'] as String? ?? 'Club Details',
              );
            },
          ),
        ],
      ),

      // ─── Branch & Chapter ──────────────────────────────────────
      GoRoute(
        path: '/branch-chapter',
        builder: (_, _) => const BranchChapterScreen(),
      ),

      // ─── Branch Dashboard (iOS: BranchDashboardViewController) ──
      GoRoute(
        path: '/branch-dashboard',
        builder: (_, state) {
          final e = _extra(state);
          return BranchDashboardScreen(
            branchName: e['branchName'] as String? ?? '',
            clubName: e['clubName'] as String? ?? '',
          );
        },
        routes: [
          GoRoute(
            path: 'members',
            builder: (_, state) {
              final e = _extra(state);
              return BranchMembersScreen(
                branchName: e['branchName'] as String? ?? '',
                groupId: e['groupId'] as String? ?? '',
              );
            },
          ),
          GoRoute(
            path: 'past-chairmen',
            builder: (_, state) {
              final e = _extra(state);
              return PastPresidentsScreen(
                groupId: e['groupId'] as String? ?? '',
                moduleName: 'Past Chairmen',
              );
            },
          ),
          GoRoute(
            path: 'executive-committee',
            builder: (_, state) {
              final e = _extra(state);
              return ExecutiveCommitteeScreen(
                groupId: e['groupId'] as String? ?? '',
              );
            },
          ),
          GoRoute(
            path: 'past-events',
            builder: (_, state) {
              final e = _extra(state);
              return PastEventsScreen(
                groupId: e['groupId'] as String? ?? '',
              );
            },
            routes: [
              GoRoute(
                path: 'detail',
                builder: (_, state) {
                  final e = _extra(state);
                  final event = e['event'] as PastEventAlbum;
                  return PastEventDetailScreen(
                    event: event,
                    year: e['year'] as String? ?? '',
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // ─── Find Member (IMEI) ───────────────────────────────────
      GoRoute(
        path: '/find-member',
        builder: (_, _) => const FindMemberScreen(),
      ),

      // ─── Governing Council ────────────────────────────────────
      GoRoute(
        path: '/governing-council',
        builder: (_, _) => const GoverningCouncilScreen(),
      ),

      // ─── Sub Committee ────────────────────────────────────────
      GoRoute(
        path: '/sub-committee',
        builder: (_, _) => const SubCommitteeScreen(),
        routes: [
          GoRoute(
            path: 'members',
            builder: (_, state) {
              final e = _extra(state);
              return SubCommitteeMembersScreen(
                committeeId: e['committeeId'] as int? ?? 0,
                committeeName:
                    e['committeeName'] as String? ?? 'Committee',
              );
            },
            routes: [
              GoRoute(
                path: 'profile',
                builder: (_, state) {
                  final e = _extra(state);
                  final member = e['member'] as SubCommitteeMember;
                  return SubCommitteeProfileScreen(member: member);
                },
              ),
            ],
          ),
        ],
      ),

      // ─── MER / iMelange ──────────────────────────────────────
      GoRoute(
        path: '/mer',
        builder: (_, state) {
          final e = _extra(state);
          return MerDashboardScreen(
            type: e['type'] as String? ?? '1',
            title: e['title'] as String? ?? 'MER(I)',
          );
        },
      ),

      // ─── Past Presidents ──────────────────────────────────────
      GoRoute(
        path: '/past-presidents',
        builder: (_, state) {
          final e = _extra(state);
          return PastPresidentsScreen(
            groupId: e['groupId'] as String? ?? '',
          );
        },
      ),

      // ─── Service Directory ──────────────────────────────────
      GoRoute(
        path: '/service-directory',
        builder: (_, _) => const ServiceDirectoryScreen(),
        routes: [
          GoRoute(
            path: 'category/:id',
            builder: (_, state) {
              final e = _extra(state);
              return ServiceCategoryScreen(
                categoryName: e['categoryName'] as String? ??
                    state.pathParameters['id'] ??
                    '',
              );
            },
          ),
        ],
      ),

      // ─── Subgroups ──────────────────────────────────────────
      GoRoute(
        path: '/subgroups',
        builder: (_, state) {
          final e = _extra(state);
          return SubgroupListScreen(
            isAdmin: e['isAdmin'] as bool? ?? false,
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) {
              final e = _extra(state);
              return SubgroupDetailScreen(
                subgrpId: state.pathParameters['id'] ?? '',
                title: e['title'] as String? ?? 'Subgroup',
              );
            },
          ),
        ],
      ),

      // ─── District ───────────────────────────────────────────
      GoRoute(
        path: '/district',
        builder: (_, state) {
          final e = _extra(state);
          return DistrictDirectoryScreen(
            groupId: e['groupId'] as String? ?? '',
          );
        },
        routes: [
          GoRoute(
            path: 'member/:id',
            builder: (_, state) {
              final e = _extra(state);
              return DistrictMemberDetailScreen(
                memberProfileId: state.pathParameters['id'] ?? '',
                groupId: e['groupId'] as String? ?? '',
              );
            },
          ),
          GoRoute(
            path: 'club-members/:id',
            builder: (_, state) {
              return DistrictClubMembersScreen(
                groupId: state.pathParameters['id'] ?? '',
              );
            },
          ),
        ],
      ),

      // ─── Leaderboard ────────────────────────────────────────
      GoRoute(
        path: '/leaderboard',
        builder: (_, state) {
          final e = _extra(state);
          return LeaderboardScreen(
            groupId: e['groupId'] as String? ?? '',
            profileId: e['profileId'] as String? ?? '',
            moduleName: e['moduleName'] as String? ?? 'Leaderboard',
          );
        },
      ),

      // ─── Web Links ──────────────────────────────────────────
      GoRoute(
        path: '/web-links',
        builder: (_, state) {
          final e = _extra(state);
          return WebLinksScreen(
            groupId: e['groupId'] as String? ?? '',
            moduleName: e['moduleName'] as String? ?? 'Web Links',
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) {
              final e = _extra(state);
              final item = e['item'] as WebLinkItem?;
              if (item == null) return const _NotFoundScreen();
              return WebLinkDetailScreen(
                item: item,
                moduleName: e['moduleName'] as String? ?? 'Web Links',
              );
            },
          ),
        ],
      ),

      // ─── Notifications ──────────────────────────────────────
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (_, state) {
              final e = _extra(state);
              return NotificationSettingsScreen(
                groupId: e['groupId'] as String? ?? '',
                groupProfileId: e['groupProfileId'] as String? ?? '',
                moduleName:
                    e['moduleName'] as String? ?? 'Notification Settings',
              );
            },
          ),
          // Android: UpcomingEventDetails — shows event from notification payload
          GoRoute(
            path: 'event-detail',
            builder: (_, state) {
              final e = _extra(state);
              return NotificationEventDetailScreen(
                eventTitle: e['eventTitle'] as String? ?? '',
                eventDate: e['eventDate'] as String? ?? '',
                eventDesc: e['eventDesc'] as String? ?? '',
                eventImg: e['eventImg'] as String? ?? '',
                regLink: e['regLink'] as String? ?? '',
                venue: e['venue'] as String? ?? '',
              );
            },
          ),
        ],
      ),

      // ─── Settings ───────────────────────────────────────────
      GoRoute(
        path: '/settings',
        builder: (_, state) {
          final e = _extra(state);
          return SettingsScreen(
            mainMasterId: e['mainMasterId'] as String? ?? '',
          );
        },
        routes: [
          GoRoute(
            path: 'group',
            builder: (_, state) {
              final e = _extra(state);
              return GroupSettingsScreen(
                groupId: e['groupId'] as String? ?? '',
                groupProfileId: e['groupProfileId'] as String? ?? '',
                moduleName: e['moduleName'] as String? ?? 'Group Settings',
              );
            },
          ),
        ],
      ),

      // ─── Profile ────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        builder: (_, state) {
          final e = _extra(state);
          return MyProfileScreen(
            profileId: e['profileId'] as String? ?? '',
            groupId: e['groupId'] as String? ?? '',
            memberName: e['memberName'] as String?,
            clubName: e['clubName'] as String?,
            pic: e['pic'] as String?,
            mobile: e['mobile'] as String?,
            email: e['email'] as String?,
            personalDetails:
                e['personalDetails'] as List<Map<String, String>>?,
            familyMembers: e['familyMembers'] as List<Map<String, String>>?,
            addresses: e['addresses'] as List<Map<String, String>>?,
          );
        },
        routes: [
          GoRoute(
            path: 'edit-family',
            builder: (_, state) {
              final e = _extra(state);
              return EditFamilyScreen(
                profileId: e['profileId'] as String? ?? '',
                familyMemberId: e['familyMemberId'] as String?,
                initialName: e['initialName'] as String?,
                initialRelationship: e['initialRelationship'] as String?,
                initialDob: e['initialDob'] as String?,
                initialAnniversary: e['initialAnniversary'] as String?,
                initialContact: e['initialContact'] as String?,
                initialEmail: e['initialEmail'] as String?,
                initialBloodGroup: e['initialBloodGroup'] as String?,
                initialParticulars: e['initialParticulars'] as String?,
              );
            },
          ),
          GoRoute(
            path: 'edit-address',
            builder: (_, state) {
              final e = _extra(state);
              return EditAddressScreen(
                profileId: e['profileId'] as String? ?? '',
                groupId: e['groupId'] as String? ?? '',
                addressId: e['addressId'] as String?,
                initialAddressType: e['initialAddressType'] as String?,
                initialAddress: e['initialAddress'] as String?,
                initialCity: e['initialCity'] as String?,
                initialState: e['initialState'] as String?,
                initialCountry: e['initialCountry'] as String?,
                initialPincode: e['initialPincode'] as String?,
                initialPhoneNo: e['initialPhoneNo'] as String?,
                initialFax: e['initialFax'] as String?,
              );
            },
          ),
          GoRoute(
            path: 'change-request',
            builder: (_, state) {
              final e = _extra(state);
              return ChangeRequestScreen(
                memberId: e['memberId'] as String? ?? '',
              );
            },
          ),
        ],
      ),

      // ─── Groups ─────────────────────────────────────────────
      GoRoute(
        path: '/groups',
        builder: (_, _) => const GlobalSearchScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) {
              final e = _extra(state);
              return GroupDetailScreen(
                groupId: state.pathParameters['id'] ?? '',
                memberMainId: e['memberMainId'] as String? ?? '',
                moduleName: e['moduleName'] as String? ?? 'Group Detail',
              );
            },
          ),
          GoRoute(
            path: 'add-members/:id',
            builder: (_, state) {
              return AddMembersScreen(
                groupId: state.pathParameters['id'] ?? '',
              );
            },
          ),
        ],
      ),

      // ─── Monthly Report ─────────────────────────────────────
      GoRoute(
        path: '/monthly-report',
        builder: (_, _) => const MonthlyPdfListScreen(),
        routes: [
          GoRoute(
            path: 'view/:id',
            builder: (_, state) {
              final e = _extra(state);
              return MonthlyPdfViewScreen(
                urlStr: e['urlStr'] as String? ?? '',
                isLocalFile: e['isLocalFile'] as bool? ?? false,
                moduleName: e['moduleName'] as String? ?? 'Document',
              );
            },
          ),
        ],
      ),

      // ─── Maps ───────────────────────────────────────────────
      GoRoute(
        path: '/maps/address',
        builder: (_, state) {
          final e = _extra(state);
          return MapAddressScreen(
            initialLatitude: e['initialLatitude'] as double?,
            initialLongitude: e['initialLongitude'] as double?,
            initialAddress: e['initialAddress'] as String?,
          );
        },
      ),
    ],
  );

  /// Auth guard: redirect to /login if not authenticated.
  /// Checks SharedPreferences for masterUID — if null, redirect to login.
  static String? _authGuard(BuildContext context, GoRouterState state) {
    final isLoggedIn = LocalStorage.instance.isLoggedIn;
    final path = state.matchedLocation;

    const publicPaths = ['/splash', '/login', '/otp', '/welcome'];
    final isPublicRoute = publicPaths.contains(path);

    // Not logged in → force to login (unless already on a public route)
    if (!isLoggedIn && !isPublicRoute) {
      return '/splash';
    }

    // Already logged in + on splash/login page → go straight to dashboard
    if (isLoggedIn && (path == '/login' || path == '/splash')) {
      return '/dashboard';
    }

    return null;
  }
}

/// Simple 404 / error page with "Page not found" message and back button.
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
