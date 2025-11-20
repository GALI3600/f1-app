# 02 - Network & Cache Layer

**Phase:** 2
**Priority:** CRITICAL
**Status:** ⚪ TODO
**Estimated:** 9-11 hours

## Description

Implement complete network layer with Dio, 3-layer cache system, and shared services.

## Tasks

### Task 2.1: Network Layer (Dio)
**Status:** ⚪ TODO
**Time:** 3-4h
**Dependencies:** Task 1.3

**Subtasks:**
- [ ] Create `ApiException` hierarchy (Network, Timeout, Server, Parse)
- [ ] Create `ApiClient` with Dio configuration
- [ ] Create `ApiInterceptor` for logging/retry
- [ ] Create `RateLimiter` (60 req/min)
- [ ] Add Riverpod providers

**Files:**
- `lib/core/network/api_exception.dart`
- `lib/core/network/api_client.dart`
- `lib/core/network/api_interceptor.dart`
- `lib/core/network/rate_limiter.dart`

**Tests:**
- Test timeout handling
- Test retry logic
- Test rate limiting

### Task 2.2: Cache System (3 Layers)
**Status:** ⚪ TODO
**Time:** 4-5h
**Dependencies:** Task 2.1

**Subtasks:**
- [ ] Create `CacheEntry` model
- [ ] Implement `MemoryCache` (TTL 5min-1h)
- [ ] Implement `DiskCache` with Hive (TTL 7-30 days)
- [ ] Create `CacheService` facade
- [ ] Configure cache strategy per data type

**Files:**
- `lib/shared/services/cache/cache_entry.dart`
- `lib/shared/services/cache/memory_cache.dart`
- `lib/shared/services/cache/disk_cache.dart`
- `lib/shared/services/cache/cache_service.dart`

**Cache Strategy:**
- Memory → Disk → Network fallback

### Task 2.3: Shared Services
**Status:** ⚪ TODO
**Time:** 2h
**Dependencies:** Task 2.2

**Subtasks:**
- [ ] Create `StorageService` (SharedPreferences wrapper)
- [ ] Create `ConnectivityService` (network status)
- [ ] Create `DateTimeUtil` (date/timezone formatting)
- [ ] Add Riverpod providers

**Files:**
- `lib/shared/services/storage_service.dart`
- `lib/shared/services/connectivity_service.dart`
- `lib/shared/utils/date_time_util.dart`

## Dependencies

- Requires Phase 1 completion
- Dio package
- Hive package
- connectivity_plus package

## Success Criteria

- [ ] API client working with OpenF1
- [ ] Cache system operational (all 3 layers)
- [ ] Network error handling robust
- [ ] Rate limiting working
- [ ] All services have providers

## Next Steps

After completion, proceed to Phase 3: Data Models
