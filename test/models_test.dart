import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1sync/features/drivers/data/models/driver.dart';
import 'package:f1sync/features/meetings/data/models/meeting.dart';
import 'package:f1sync/features/sessions/data/models/session.dart';
import 'package:f1sync/features/laps/data/models/lap.dart';

/// Extension providing helper methods for Driver model in tests
extension DriverTestExtension on Driver {
  /// Team color as Flutter Color object
  Color get teamColor {
    final hex = teamColour.startsWith('#') ? teamColour : '#$teamColour';
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  /// Avatar URL with fallback to placeholder
  String get avatarUrl {
    return headshotUrl ?? 'https://via.placeholder.com/150?text=$nameAcronym';
  }
}

void main() {
  group('Data Models JSON Serialization Tests', () {
    test('Driver model - fromJolpica', () {
      final json = {
        'driverId': 'max_verstappen',
        'permanentNumber': '1',
        'code': 'VER',
        'givenName': 'Max',
        'familyName': 'Verstappen',
        'dateOfBirth': '1997-09-30',
        'nationality': 'Dutch',
      };

      final driver = Driver.fromJolpica(json);
      expect(driver.driverNumber, 1);
      expect(driver.fullName, 'Max Verstappen');
      expect(driver.nameAcronym, 'VER');
      expect(driver.nationality, 'Dutch');
    });

    test('Meeting model - fromJson', () {
      final json = {
        'meeting_key': 5,
        'meeting_name': 'Monaco Grand Prix',
        'meeting_official_name': 'Monaco Grand Prix',
        'location': 'Monte Carlo',
        'country_code': 'MC',
        'country_name': 'Monaco',
        'country_key': 0,
        'circuit_short_name': 'Monaco',
        'circuit_key': 0,
        'date_start': '2023-05-28T14:00:00+00:00',
        'gmt_offset': '+02:00',
        'year': 2023,
      };

      final meeting = Meeting.fromJson(json);
      expect(meeting.meetingKey, 5);
      expect(meeting.meetingName, 'Monaco Grand Prix');
      expect(meeting.year, 2023);
      expect(meeting.round, 5);
    });

    test('Meeting model - fromJolpica', () {
      final json = {
        'season': '2023',
        'round': '5',
        'raceName': 'Monaco Grand Prix',
        'Circuit': {
          'circuitId': 'monaco',
          'circuitName': 'Circuit de Monaco',
          'Location': {
            'locality': 'Monte Carlo',
            'country': 'Monaco',
          },
        },
        'date': '2023-05-28',
        'time': '13:00:00Z',
      };

      final meeting = Meeting.fromJolpica(json);
      expect(meeting.meetingKey, 5);
      expect(meeting.meetingName, 'Monaco Grand Prix');
      expect(meeting.year, 2023);
      expect(meeting.location, 'Monte Carlo');
    });

    test('Session model - fromJson', () {
      final json = {
        'session_key': 501,
        'meeting_key': 5,
        'session_name': 'Race',
        'session_type': 'Race',
        'date_start': '2023-05-28T13:00:00+00:00',
        'date_end': '2023-05-28T15:00:00+00:00',
        'gmt_offset': '+02:00',
        'location': 'Monte Carlo',
        'country_code': 'MC',
        'country_name': 'Monaco',
        'circuit_short_name': 'Monaco',
        'circuit_key': 0,
        'year': 2023,
      };

      final session = Session.fromJson(json);
      expect(session.sessionKey, 501);
      expect(session.sessionType, 'Race');
      expect(session.isRace, true);
      expect(session.round, 5);
    });

    test('Lap model - fromJson with nullable fields', () {
      final json = {
        'date_start': '2023-05-28T13:30:00+00:00',
        'driver_number': 1,
        'lap_number': 10,
        'lap_duration': 75.123,
        'is_pit_out_lap': false,
        'duration_sector_1': 18.5,
        'duration_sector_2': 32.1,
        'duration_sector_3': 24.523,
        'segments_sector_1': [2049, 2049, 2049],
        'segments_sector_2': [2049, 2049, 2049],
        'segments_sector_3': [2048, 2048, 2064],
        'i1_speed': 290,
        'i2_speed': 265,
        'st_speed': null,
        'session_key': 501,
        'meeting_key': 5,
      };

      final lap = Lap.fromJson(json);
      expect(lap.lapNumber, 10);
      expect(lap.lapDuration, 75.123);
      expect(lap.i1Speed, 290);
      expect(lap.stSpeed, null);
    });

    test('Lap model - fromJolpica', () {
      final json = {
        'driverId': 'max_verstappen',
        'position': '1',
        'time': '1:15.123',
        'lapNumber': 10,
        'round': 5,
        'season': 2023,
      };

      final lap = Lap.fromJolpica(json);
      expect(lap.lapNumber, 10);
      expect(lap.driverId, 'max_verstappen');
      expect(lap.position, 1);
      expect(lap.lapDuration, closeTo(75.123, 0.001));
    });
  });

  group('Driver Extensions Tests', () {
    test('teamColor extension converts hex to Color', () {
      final driver = Driver(
        driverNumber: 1,
        broadcastName: 'M VERSTAPPEN',
        fullName: 'Max VERSTAPPEN',
        nameAcronym: 'VER',
        firstName: 'Max',
        lastName: 'Verstappen',
        teamName: 'Red Bull Racing',
        teamColour: '3671C6',
        countryCode: 'NED',
      );

      final color = driver.teamColor;
      expect(color.toARGB32(), 0xFF3671C6);
    });

    test('avatarUrl extension provides fallback', () {
      final driver = Driver(
        driverNumber: 1,
        broadcastName: 'M VERSTAPPEN',
        fullName: 'Max VERSTAPPEN',
        nameAcronym: 'VER',
        firstName: 'Max',
        lastName: 'Verstappen',
        teamName: 'Red Bull Racing',
        teamColour: '3671C6',
        countryCode: 'NED',
        headshotUrl: null,
      );

      expect(driver.avatarUrl, contains('VER'));
    });
  });
}
