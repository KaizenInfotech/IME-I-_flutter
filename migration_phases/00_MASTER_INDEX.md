# iOS to Flutter Migration - Master Phase Index

## Project: TouchBase (IMEI-iConnect)
## Total Phases: 34

---

## How to Use

1. Open each phase file in order (Phase 1 first, Phase 34 last)
2. Copy the **Command Prompt** section from the phase file
3. Paste it into a **new Claude Code conversation**
4. Wait for Claude to complete the phase
5. Verify the expected output files were created
6. Move to the next phase

**Important:** Start a fresh Claude Code conversation for each phase to keep context clean.

---

## Phase Execution Order

### FOUNDATION (Phases 1-8) - Do these in exact order

| # | Phase | File | Depends On |
|---|-------|------|------------|
| 1 | Project Setup & pubspec.yaml | `phase_01_project_setup.md` | Nothing |
| 2 | Core Constants | `phase_02_core_constants.md` | Phase 1 |
| 3 | Core Network Layer (http) | `phase_03_core_network.md` | Phase 2 |
| 4 | Core Storage (SQLite + SharedPrefs) | `phase_04_core_storage.md` | Phase 2 |
| 5 | Core Extensions & Utils | `phase_05_core_extensions.md` | Phase 2 |
| 6 | Core Theme & Colors | `phase_06_core_theme.md` | Phase 5 |
| 7 | Core Common Widgets | `phase_07_core_widgets.md` | Phase 6 |
| 8 | Core Base Model | `phase_08_core_base_model.md` | Phase 3 |

### GATEWAY FEATURES (Phases 9-10) - Do these in exact order

| # | Phase | File | Depends On |
|---|-------|------|------------|
| 9 | Auth (Login + OTP + Welcome) | `phase_09_auth_feature.md` | Phases 3,4,7,8 |
| 10 | Dashboard | `phase_10_dashboard_feature.md` | Phase 9 |

### FEATURE MODULES (Phases 11-30) - Independent of each other, all depend on Phase 10

| # | Phase | File | Depends On |
|---|-------|------|------------|
| 11 | Member Directory | `phase_11_directory_feature.md` | Phase 10 |
| 12 | Events | `phase_12_events_feature.md` | Phase 10 |
| 13 | Celebrations | `phase_13_celebrations_feature.md` | Phase 10 |
| 14 | Announcements | `phase_14_announcements_feature.md` | Phase 10 |
| 15 | Gallery & Albums | `phase_15_gallery_feature.md` | Phase 10 |
| 16 | Documents | `phase_16_documents_feature.md` | Phase 10 |
| 17 | E-Bulletin | `phase_17_ebulletin_feature.md` | Phase 10 |
| 18 | Attendance | `phase_18_attendance_feature.md` | Phase 10 |
| 19 | Find Rotarian | `phase_19_find_rotarian_feature.md` | Phase 10 |
| 20 | Find Club | `phase_20_find_club_feature.md` | Phase 10 |
| 21 | Service Directory | `phase_21_service_directory_feature.md` | Phase 10 |
| 22 | Sub-Groups / Committees | `phase_22_subgroups_feature.md` | Phase 10 |
| 23 | District Features | `phase_23_district_feature.md` | Phase 10 |
| 24 | Leaderboard | `phase_24_leaderboard_feature.md` | Phase 10 |
| 25 | Web Links | `phase_25_web_links_feature.md` | Phase 10 |
| 26 | Notifications | `phase_26_notifications_feature.md` | Phase 10 |
| 27 | Settings | `phase_27_settings_feature.md` | Phase 10 |
| 28 | Profile & Family | `phase_28_profile_feature.md` | Phase 10 |
| 29 | Groups Management | `phase_29_groups_feature.md` | Phase 10 |
| 30 | Monthly Report & Maps | `phase_30_monthly_report_maps.md` | Phase 10 |

### INTEGRATION (Phases 31-34) - Do these in exact order after all features

| # | Phase | File | Depends On |
|---|-------|------|------------|
| 31 | Navigation & Routing (GoRouter) | `phase_31_navigation_routing.md` | All features |
| 32 | Main App Entry + MultiProvider | `phase_32_main_app_entry.md` | Phase 31 |
| 33 | Missing Components Audit | `phase_33_missing_components.md` | Phase 32 |
| 34 | Final Compilation & Verification | `phase_34_final_verification.md` | Phase 33 |

---

## Global Rules (Applied to ALL Phases)

1. **No Force Unwraps** - ALL model fields must be nullable (String?, int?, etc.)
2. **Exact API Match** - Use EXACT same API endpoints and parameters as iOS
3. **Exact Logic Match** - Follow EXACT same business logic as iOS Swift code
4. **Clean Architecture** - Feature-first folder structure with models/providers/screens/widgets
5. **State Management** - Provider (ChangeNotifier) + Consumer + FutureBuilder
6. **Networking** - http package via ApiClient singleton
7. **Null Safety** - Use ?. ?? ?? '' patterns everywhere
8. **No Shared Mutable State** - Replace iOS globals with Provider state
