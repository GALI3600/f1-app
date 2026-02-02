import 'package:logger/logger.dart';
import '../../../../core/constants/jolpica_constants.dart';
import '../../../../shared/services/cache/cache_service.dart';
import '../../domain/repositories/driver_career_repository.dart';
import '../datasources/driver_career_remote_data_source.dart';
import '../models/driver_career.dart';

final _logger = Logger();

/// Implementation of DriverCareerRepository with caching support
class DriverCareerRepositoryImpl implements DriverCareerRepository {
  final DriverCareerRemoteDataSource _remoteDataSource;
  final CacheService _cacheService;

  /// Cache key prefix for driver career data
  static const String _cacheKeyPrefix = 'driver_career_';

  DriverCareerRepositoryImpl(this._remoteDataSource, this._cacheService);

  @override
  Future<DriverCareer?> getDriverCareer(String driverId) async {
    final cacheKey = '$_cacheKeyPrefix$driverId';
    _logger.i('[CareerRepo] Getting career for $driverId');

    // Try to get from cache first (with error handling)
    try {
      final cached = await _cacheService.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        final cachedCareer = _deserializeCareer(cached);
        // Check if cached data looks rate-limited (ignore it if so)
        final looksRateLimited = cachedCareer.totalRaces > 100 &&
            cachedCareer.wins == 0 &&
            cachedCareer.poles == 0;
        if (looksRateLimited) {
          _logger.w('[Cache] Cached data for $driverId looks rate-limited, ignoring and fetching fresh');
          await _cacheService.invalidate(cacheKey);
        } else {
          _logger.i('[Cache] HIT for driver career: $driverId');
          return cachedCareer;
        }
      } else {
        _logger.i('[Cache] MISS for driver career: $driverId');
      }
    } catch (e) {
      _logger.w('[Cache] Error reading cache for $driverId: $e');
      // Continue to fetch from API
    }

    _logger.i('[CareerRepo] Fetching from API for $driverId');

    // Fetch from API
    try {
      final career = await _remoteDataSource.getDriverCareer(driverId);

      // Store in cache if successful and data looks valid
      if (career != null) {
        // Don't cache if data looks rate-limited (driver with 100+ races but 0 wins is suspicious)
        final looksRateLimited = career.totalRaces > 100 && career.wins == 0 && career.poles == 0;
        if (looksRateLimited) {
          _logger.w('[Cache] Data looks rate-limited for $driverId (${career.totalRaces} races but 0 wins/poles), NOT caching');
        } else {
          try {
            await _cacheService.set(
              cacheKey,
              _serializeCareer(career),
              JolpicaConstants.cacheTTL,
            );
            _logger.i('[Cache] Stored career for $driverId (TTL: ${JolpicaConstants.cacheTTL.inDays} days)');
          } catch (e) {
            _logger.w('[Cache] Error storing cache for $driverId: $e');
            // Cache failure is not critical, continue
          }
        }
      } else {
        _logger.w('[CareerRepo] API returned null for $driverId');
      }

      return career;
    } catch (e, stack) {
      _logger.e('[CareerRepo] Error fetching career for $driverId: $e');
      _logger.e('[CareerRepo] Stack: $stack');
      return null;
    }
  }

  @override
  Future<DriverCareer?> getDriverCareerByNumber(int driverNumber) async {
    _logger.i('[CareerRepo] getDriverCareerByNumber called for #$driverNumber');
    final driverId = JolpicaConstants.getDriverId(driverNumber);
    if (driverId == null) {
      _logger.w('[CareerRepo] No driver ID mapping for driver #$driverNumber');
      return null;
    }
    _logger.i('[CareerRepo] Mapped driver #$driverNumber to driverId: $driverId');
    return await getDriverCareer(driverId);
  }

  /// Serialize DriverCareer to Map for caching
  Map<String, dynamic> _serializeCareer(DriverCareer career) {
    return {
      'driverId': career.driverId,
      'fullName': career.fullName,
      'nationality': career.nationality,
      'dateOfBirth': career.dateOfBirth,
      'permanentNumber': career.permanentNumber,
      'totalRaces': career.totalRaces,
      'wins': career.wins,
      'podiums': career.podiums,
      'poles': career.poles,
      'fastestLaps': career.fastestLaps,
      'championships': career.championships,
      'seasons': career.seasons,
      'careerPoints': career.careerPoints,
      'currentSeasonPosition': career.currentSeasonPosition,
      'currentSeasonPoints': career.currentSeasonPoints,
      'championshipYears': career.championshipYears,
      'firstRace': career.firstRace,
      'lastRace': career.lastRace,
    };
  }

  /// Deserialize Map back to DriverCareer
  DriverCareer _deserializeCareer(Map<String, dynamic> map) {
    return DriverCareer(
      driverId: map['driverId'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      nationality: map['nationality'] as String? ?? '',
      dateOfBirth: map['dateOfBirth'] as String?,
      permanentNumber: map['permanentNumber'] as String?,
      totalRaces: map['totalRaces'] as int? ?? 0,
      wins: map['wins'] as int? ?? 0,
      podiums: map['podiums'] as int? ?? 0,
      poles: map['poles'] as int? ?? 0,
      fastestLaps: map['fastestLaps'] as int? ?? 0,
      championships: map['championships'] as int? ?? 0,
      seasons: map['seasons'] as int? ?? 0,
      careerPoints: (map['careerPoints'] as num?)?.toDouble() ?? 0.0,
      currentSeasonPosition: map['currentSeasonPosition'] as int?,
      currentSeasonPoints: (map['currentSeasonPoints'] as num?)?.toDouble(),
      championshipYears: (map['championshipYears'] as List?)?.cast<int>(),
      firstRace: map['firstRace'] as String?,
      lastRace: map['lastRace'] as String?,
    );
  }

  /// Invalidate cached career data for a driver
  Future<void> invalidateCache(String driverId) async {
    final cacheKey = '$_cacheKeyPrefix$driverId';
    await _cacheService.invalidate(cacheKey);
    _logger.i('[Cache] Invalidated career cache for: $driverId');
  }

  /// Invalidate all cached career data
  Future<void> invalidateAllCareerCache() async {
    final count = await _cacheService.invalidateByPrefix(_cacheKeyPrefix);
    _logger.i('[Cache] Invalidated $count career cache entries');
  }
}
