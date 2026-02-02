import 'package:freezed_annotation/freezed_annotation.dart';

part 'constructor_standing.freezed.dart';
part 'constructor_standing.g.dart';

/// Constructor (team) standing in the championship
@freezed
@JsonSerializable(createFactory: false)
class ConstructorStanding with _$ConstructorStanding {
  const ConstructorStanding._();

  const factory ConstructorStanding({
    required int position,
    required double points,
    required int wins,
    required String constructorId,
    required String name,
    required String nationality,
    String? teamColour,
  }) = _ConstructorStanding;

  /// Create ConstructorStanding from Jolpica API response
  factory ConstructorStanding.fromJolpica(Map<String, dynamic> json) {
    final constructor = json['Constructor'] as Map<String, dynamic>? ?? {};
    final constructorId = constructor['constructorId'] as String? ?? '';

    return ConstructorStanding(
      position: int.tryParse(json['position']?.toString() ?? '') ?? 0,
      points: double.tryParse(json['points']?.toString() ?? '') ?? 0.0,
      wins: int.tryParse(json['wins']?.toString() ?? '') ?? 0,
      constructorId: constructorId,
      name: constructor['name'] as String? ?? '',
      nationality: constructor['nationality'] as String? ?? '',
      teamColour: _getConstructorColour(constructorId),
    );
  }

  factory ConstructorStanding.fromJson(Map<String, dynamic> json) =>
      ConstructorStanding.fromJolpica(json);

  Map<String, dynamic> toJson() => _$ConstructorStandingToJson(this);
}

/// Get team colour by constructor ID
String? _getConstructorColour(String constructorId) {
  const colours = {
    'red_bull': '3671C6',
    'ferrari': 'E8002D',
    'mercedes': '27F4D2',
    'mclaren': 'FF8000',
    'aston_martin': '229971',
    'alpine': 'FF87BC',
    'williams': '64C4FF',
    'rb': '6692FF',
    'sauber': '52E252',
    'haas': 'B6BABD',
    'cadillac': 'D4AF37',
    'audi': '6E6E6E',
  };
  return colours[constructorId];
}
