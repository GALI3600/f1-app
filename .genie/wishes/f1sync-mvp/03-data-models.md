# 03 - Core Data Models

**Phase:** 3
**Priority:** HIGH
**Status:** ⚪ TODO
**Estimated:** 5-6 hours

## Description

Create all core data models using Freezed and json_serializable for the OpenF1 API.

## Tasks

### Task 3.1: Data Models (Freezed + JSON)
**Status:** ⚪ TODO
**Time:** 5-6h
**Dependencies:** Task 2.1

**Subtasks:**
- [ ] Create `Meeting` model (GP weekend)
- [ ] Create `Session` model (FP, Quali, Race)
- [ ] Create `Driver` model + extensions (team color, avatar)
- [ ] Create `Lap` model (lap times, sectors)
- [ ] Create `Position` model (driver positions)
- [ ] Create `Weather` model (track conditions)
- [ ] Create `RaceControl` model (race director messages)
- [ ] Create `Stint` model (tire strategy)
- [ ] Run `build_runner` to generate code

**Files:**
- `lib/shared/models/meeting.dart`
- `lib/shared/models/meeting.freezed.dart` (generated)
- `lib/shared/models/meeting.g.dart` (generated)
- `lib/shared/models/session.dart`
- `lib/shared/models/driver.dart`
- `lib/shared/models/lap.dart`
- `lib/shared/models/position.dart`
- `lib/shared/models/weather.dart`
- `lib/shared/models/race_control.dart`
- `lib/shared/models/stint.dart`

**Command:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Model Details

### Meeting
- `meetingKey`, `meetingName`, `location`
- `countryCode`, `circuitShortName`
- `dateStart`, `gmtOffset`, `year`

### Driver
- `driverNumber`, `fullName`, `nameAcronym`
- `teamName`, `teamColour`, `headshotUrl`
- Extensions: `teamColor`, `avatarUrl`, `displayName`

### Session
- `sessionKey`, `sessionName`, `sessionType`
- `dateStart`, `dateEnd`
- Linked to Meeting

### Lap
- `lapNumber`, `lapDuration`
- `durationSector1/2/3`
- `segmentsSector1/2/3`
- Speed traps

## Dependencies

- freezed package
- json_serializable package
- build_runner package

## Success Criteria

- [ ] All 8 models created
- [ ] Code generation successful
- [ ] No build errors
- [ ] Models match API structure
- [ ] Extensions working correctly

## Next Steps

After completion, proceed to Phase 4: Data Layer (Repositories)
