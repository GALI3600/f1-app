# 07-09 - Features: Meetings, Drivers & Sessions

**Phases:** 7, 8, 9
**Priority:** MEDIUM-HIGH
**Status:** ⚪ TODO
**Estimated:** 24-30 hours

## Description

Implement the three main feature screens: Meetings (GP history), Drivers (list & detail), and Sessions (race details).

---

## PHASE 7: MEETINGS FEATURE

### Task 7.1: Meetings List & History
**Time:** 5-6h
**Dependencies:** Task 4.2, Task 5.1

**Subtasks:**
- [ ] Create `MeetingsListProvider` with year filter
- [ ] Create `GPListTile` widget
- [ ] Create `YearSelector` widget (chips)
- [ ] Create `MeetingsHistoryScreen`
- [ ] Implement search by circuit/country
- [ ] Add pagination/infinite scroll

**Files:**
- `lib/features/meetings/presentation/providers/meetings_list_provider.dart`
- `lib/features/meetings/presentation/widgets/gp_list_tile.dart`
- `lib/features/meetings/presentation/widgets/year_selector.dart`
- `lib/features/meetings/presentation/screens/meetings_history_screen.dart`

### Task 7.2: Meeting Detail
**Time:** 4-5h
**Dependencies:** Task 7.1

**Subtasks:**
- [ ] Create `MeetingDetailProvider`
- [ ] Create `GPHeaderCard` widget
- [ ] Create `SessionScheduleList` widget
- [ ] Create `MeetingDetailScreen`
- [ ] Add session navigation
- [ ] Implement share GP

**Files:**
- `lib/features/meetings/presentation/providers/meeting_detail_provider.dart`
- `lib/features/meetings/presentation/widgets/gp_header_card.dart`
- `lib/features/meetings/presentation/widgets/session_schedule_list.dart`
- `lib/features/meetings/presentation/screens/meeting_detail_screen.dart`

---

## PHASE 8: DRIVERS FEATURE

### Task 8.1: Drivers List
**Time:** 4-5h
**Dependencies:** Task 4.2, Task 5.1

**Subtasks:**
- [ ] Create `DriversListProvider`
- [ ] Create `DriverCard` widget (with photo)
- [ ] Create `DriversListScreen` (grid view)
- [ ] Add filters (by team)
- [ ] Add sorting (name, number, team)
- [ ] Add search

**Files:**
- `lib/features/drivers/presentation/providers/drivers_list_provider.dart`
- `lib/features/drivers/presentation/widgets/driver_card.dart`
- `lib/features/drivers/presentation/screens/drivers_list_screen.dart`

### Task 8.2: Driver Detail
**Time:** 6-7h
**Dependencies:** Task 8.1, fl_chart package

**Subtasks:**
- [ ] Create `DriverDetailProvider` (driver + laps + stints)
- [ ] Create `DriverProfileHeader` widget
- [ ] Create `LapTimesChart` widget (fl_chart)
- [ ] Create `StintsTimeline` widget
- [ ] Create `DriverDetailScreen` with tabs
- [ ] Implement share profile

**Files:**
- `lib/features/drivers/presentation/providers/driver_detail_provider.dart`
- `lib/features/drivers/presentation/widgets/driver_profile_header.dart`
- `lib/features/drivers/presentation/widgets/lap_times_chart.dart`
- `lib/features/drivers/presentation/widgets/stints_timeline.dart`
- `lib/features/drivers/presentation/screens/driver_detail_screen.dart`

**Tabs:**
1. Overview (stats, current position)
2. Laps (lap times chart)
3. Strategy (tire stints timeline)

---

## PHASE 9: SESSIONS FEATURE

### Task 9.1: Session Detail
**Time:** 5-6h
**Dependencies:** Task 4.2, Task 5.1

**Subtasks:**
- [ ] Create `SessionDetailProvider`
- [ ] Create `WeatherWidget` (temp, humidity, rain)
- [ ] Create `SessionResultCard` widget
- [ ] Create `RaceControlFeed` widget
- [ ] Create `SessionDetailScreen`
- [ ] Add tabs (Results, Weather, Race Control)

**Files:**
- `lib/features/sessions/presentation/providers/session_detail_provider.dart`
- `lib/features/sessions/presentation/widgets/weather_widget.dart`
- `lib/features/sessions/presentation/widgets/session_result_card.dart`
- `lib/features/sessions/presentation/widgets/race_control_feed.dart`
- `lib/features/sessions/presentation/screens/session_detail_screen.dart`

---

## Screen Specifications

### Meetings List
- List/Grid of past GPs by year
- Year selector (chips: 2024, 2023, 2022...)
- Search bar
- Each item: GP name, date, circuit, winner
- Tap → Meeting Detail

### Meeting Detail
- Header: GP name, location, circuit, dates
- Sessions list: FP1, FP2, FP3, Quali, Race
- Weather info
- Race control messages
- Navigate to session details

### Drivers List
- Grid of driver cards
- Photo, name, number, team
- Team color strip
- Filter by team
- Sort options
- Search
- Tap → Driver Detail

### Driver Detail
- Large header with photo
- Driver info: name, number, team, country
- Tabs:
  - Overview: Current stats
  - Laps: Lap times chart
  - Strategy: Tire stints

### Session Detail
- Session info: name, date, circuit
- Results table (if available)
- Weather widget (live/historical)
- Race control feed
- Navigate to driver details from results

---

## Dependencies

- Task 4.2 (Repositories)
- Task 5.1 (UI Components)
- fl_chart package
- intl package

## Success Criteria

- [ ] All 3 features functional
- [ ] Navigation between features working
- [ ] Data loading correctly
- [ ] UI polished and consistent
- [ ] Error states handled
- [ ] Loading states smooth

## Next Steps

After completion, proceed to Phase 10: Navigation & Routing final integration
