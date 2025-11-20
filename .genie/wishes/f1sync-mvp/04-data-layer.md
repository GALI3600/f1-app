# 04 - Data Layer (DataSources & Repositories)

**Phase:** 4
**Priority:** HIGH
**Status:** ⚪ TODO
**Estimated:** 8-10 hours

## Description

Implement remote data sources for API calls and repositories with cache integration.

## Tasks

### Task 4.1: Remote Data Sources
**Status:** ⚪ TODO
**Time:** 4-5h
**Dependencies:** Task 3.1

**Subtasks:**
- [ ] Create `MeetingsRemoteDataSource` (endpoint: `/meetings`)
- [ ] Create `SessionsRemoteDataSource` (endpoint: `/sessions`)
- [ ] Create `DriversRemoteDataSource` (endpoint: `/drivers`)
- [ ] Create `LapsRemoteDataSource` (endpoint: `/laps`)
- [ ] Add error handling and JSON parsing

**Files:**
- `lib/features/meetings/data/datasources/meetings_remote_data_source.dart`
- `lib/features/sessions/data/datasources/sessions_remote_data_source.dart`
- `lib/features/drivers/data/datasources/drivers_remote_data_source.dart`
- `lib/features/laps/data/datasources/laps_remote_data_source.dart`

**Methods per DataSource:**
- `getMeetings({meetingKey, year, ...})`
- `getSessions({sessionKey, meetingKey})`
- `getDrivers({sessionKey, driverNumber})`
- `getLaps({sessionKey, driverNumber, lapNumber})`

### Task 4.2: Repositories with Cache
**Status:** ⚪ TODO
**Time:** 4-5h
**Dependencies:** Task 4.1, Task 2.2

**Subtasks:**
- [ ] Create `MeetingsRepository` (cache: 7 days)
- [ ] Create `SessionsRepository` (cache: 1 hour)
- [ ] Create `DriversRepository` (cache: 1 hour)
- [ ] Create `LapsRepository` (cache: 1h current, 7d historical)
- [ ] Implement cache invalidation logic
- [ ] Add Riverpod providers

**Files:**
- `lib/features/meetings/data/repositories/meetings_repository.dart`
- `lib/features/meetings/data/repositories/meetings_repository.g.dart`
- `lib/features/sessions/data/repositories/sessions_repository.dart`
- `lib/features/drivers/data/repositories/drivers_repository.dart`
- `lib/features/laps/data/repositories/laps_repository.dart`

**Cache Strategy:**
```
Repository → Check Cache → DataSource → API
           ↓
        Return Data
```

## Repository Pattern

```dart
class MeetingsRepository {
  final MeetingsRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  Future<List<Meeting>> getMeetings({String? meetingKey}) async {
    // 1. Try cache first
    final cacheKey = 'meetings_$meetingKey';
    final cached = await _cacheService.get(cacheKey);
    if (cached != null) return cached;

    // 2. Fetch from API
    final meetings = await _remoteDataSource.getMeetings(meetingKey: meetingKey);

    // 3. Cache result
    await _cacheService.set(cacheKey, meetings, ttl: Duration(days: 7));

    return meetings;
  }
}
```

## Dependencies

- Task 2.2 (Cache System)
- Task 3.1 (Data Models)
- API client configured

## Success Criteria

- [ ] All 4 data sources implemented
- [ ] All 4 repositories with cache
- [ ] API calls working
- [ ] Cache strategy functional
- [ ] Error handling robust
- [ ] Providers registered

## Next Steps

After completion, proceed to Phase 5: UI Components
