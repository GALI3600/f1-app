import 'package:flutter_test/flutter_test.dart';
import 'package:f1sync/shared/models/models.dart';

void main() {
  group('Data Models JSON Serialization Tests', () {
    test('Driver model - fromJson/toJson', () {
      final json = {
        'driver_number': 1,
        'broadcast_name': 'M VERSTAPPEN',
        'full_name': 'Max VERSTAPPEN',
        'name_acronym': 'VER',
        'first_name': 'Max',
        'last_name': 'Verstappen',
        'team_name': 'Red Bull Racing',
        'team_colour': '3671C6',
        'country_code': 'NED',
        'headshot_url': 'https://example.com/driver.png',
        'session_key': 9158,
        'meeting_key': 1219,
      };

      final driver = Driver.fromJson(json);
      expect(driver.driverNumber, 1);
      expect(driver.broadcastName, 'M VERSTAPPEN');
      expect(driver.teamColour, '3671C6');
      expect(driver.initials, 'VER');

      final backToJson = driver.toJson();
      expect(backToJson['driver_number'], 1);
      expect(backToJson['team_colour'], '3671C6');
    });

    test('Meeting model - fromJson/toJson', () {
      final json = {
        'meeting_key': 1221,
        'meeting_name': 'São Paulo Grand Prix',
        'meeting_official_name': 'FORMULA 1 ROLEX GRANDE PRÊMIO DE SÃO PAULO 2023',
        'location': 'São Paulo',
        'country_code': 'BRA',
        'country_name': 'Brazil',
        'country_key': 31,
        'circuit_short_name': 'Interlagos',
        'circuit_key': 18,
        'date_start': '2023-11-03T14:30:00+00:00',
        'gmt_offset': '-03:00:00',
        'year': 2023,
      };

      final meeting = Meeting.fromJson(json);
      expect(meeting.meetingKey, 1221);
      expect(meeting.meetingName, 'São Paulo Grand Prix');
      expect(meeting.year, 2023);

      final backToJson = meeting.toJson();
      expect(backToJson['meeting_key'], 1221);
    });

    test('Session model - fromJson/toJson', () {
      final json = {
        'session_key': 9140,
        'meeting_key': 1216,
        'session_name': 'Sprint',
        'session_type': 'Race',
        'date_start': '2023-07-29T15:05:00+00:00',
        'date_end': '2023-07-29T15:35:00+00:00',
        'gmt_offset': '02:00:00',
        'location': 'Spa-Francorchamps',
        'country_code': 'BEL',
        'country_name': 'Belgium',
        'circuit_short_name': 'Spa-Francorchamps',
        'circuit_key': 7,
        'year': 2023,
      };

      final session = Session.fromJson(json);
      expect(session.sessionKey, 9140);
      expect(session.sessionType, 'Race');

      final backToJson = session.toJson();
      expect(backToJson['session_key'], 9140);
    });

    test('Lap model - fromJson/toJson with nullable fields', () {
      final json = {
        'date_start': '2023-09-16T13:59:07.606000+00:00',
        'driver_number': 1,
        'lap_number': 10,
        'lap_duration': 91.743,
        'is_pit_out_lap': false,
        'duration_sector_1': 26.966,
        'duration_sector_2': 38.657,
        'duration_sector_3': 26.12,
        'segments_sector_1': [2049, 2049, 2049, 2051],
        'segments_sector_2': [2049, 2049, 2049, 2049],
        'segments_sector_3': [2048, 2048, 2048, 2064],
        'i1_speed': 307,
        'i2_speed': 277,
        'st_speed': null,
        'session_key': 9161,
        'meeting_key': 1219,
      };

      final lap = Lap.fromJson(json);
      expect(lap.lapNumber, 10);
      expect(lap.lapDuration, 91.743);
      expect(lap.i1Speed, 307);
      expect(lap.stSpeed, null);

      final backToJson = lap.toJson();
      expect(backToJson['lap_number'], 10);
    });

    test('Position model - fromJson/toJson', () {
      final json = {
        'date': '2023-08-26T09:30:47.199000+00:00',
        'driver_number': 1,
        'position': 1,
        'session_key': 9144,
        'meeting_key': 1217,
      };

      final position = Position.fromJson(json);
      expect(position.driverNumber, 1);
      expect(position.position, 1);

      final backToJson = position.toJson();
      expect(backToJson['driver_number'], 1);
    });

    test('Weather model - fromJson/toJson', () {
      final json = {
        'date': '2023-05-07T18:42:25.233000+00:00',
        'air_temperature': 27.8,
        'humidity': 58,
        'pressure': 1018.7,
        'rainfall': 0,
        'track_temperature': 52.5,
        'wind_direction': 136,
        'wind_speed': 2.4,
        'session_key': 9078,
        'meeting_key': 1208,
      };

      final weather = Weather.fromJson(json);
      expect(weather.airTemperature, 27.8);
      expect(weather.rainfall, 0);

      final backToJson = weather.toJson();
      expect(backToJson['air_temperature'], 27.8);
    });

    test('RaceControl model - fromJson/toJson with nullable fields', () {
      final json = {
        'date': '2023-06-04T14:21:01+00:00',
        'category': 'Flag',
        'flag': 'YELLOW',
        'lap_number': 35,
        'message': 'YELLOW FLAG SECTOR 2 - DEBRIS',
        'scope': 'Sector',
        'sector': 2,
        'driver_number': 1,
        'session_key': 9102,
        'meeting_key': 1211,
      };

      final raceControl = RaceControl.fromJson(json);
      expect(raceControl.category, 'Flag');
      expect(raceControl.flag, 'YELLOW');
      expect(raceControl.sector, 2);

      final backToJson = raceControl.toJson();
      expect(backToJson['flag'], 'YELLOW');
    });

    test('Stint model - fromJson/toJson', () {
      final json = {
        'compound': 'SOFT',
        'driver_number': 1,
        'lap_end': 25,
        'lap_start': 1,
        'stint_number': 1,
        'tyre_age_at_start': 0,
        'session_key': 9165,
        'meeting_key': 1219,
      };

      final stint = Stint.fromJson(json);
      expect(stint.compound, 'SOFT');
      expect(stint.stintNumber, 1);

      final backToJson = stint.toJson();
      expect(backToJson['compound'], 'SOFT');
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
        sessionKey: 9158,
        meetingKey: 1219,
      );

      final color = driver.teamColor;
      expect(color.value, 0xFF3671C6);
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
        sessionKey: 9158,
        meetingKey: 1219,
      );

      expect(driver.avatarUrl, contains('VER'));
    });
  });
}
