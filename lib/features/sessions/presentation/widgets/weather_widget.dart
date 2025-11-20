import 'package:flutter/material.dart';
import '../../../weather/data/models/weather.dart';
import '../../../../core/theme/f1_colors.dart';

/// Weather card displaying current weather conditions
class WeatherWidget extends StatelessWidget {
  final Weather weather;

  const WeatherWidget({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getWeatherIcon(),
                  size: 48,
                  color: F1Colors.ciano,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getWeatherCondition(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        _formatDateTime(weather.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Temperature row
            Row(
              children: [
                Expanded(
                  child: _WeatherDataItem(
                    icon: Icons.thermostat,
                    label: 'Air Temp',
                    value: '${weather.airTemperature.toStringAsFixed(1)}°C',
                  ),
                ),
                Expanded(
                  child: _WeatherDataItem(
                    icon: Icons.whatshot,
                    label: 'Track Temp',
                    value: '${weather.trackTemperature.toStringAsFixed(1)}°C',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Humidity and Wind
            Row(
              children: [
                Expanded(
                  child: _WeatherDataItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '${weather.humidity}%',
                  ),
                ),
                Expanded(
                  child: _WeatherDataItem(
                    icon: Icons.air,
                    label: 'Wind',
                    value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Rainfall and Pressure
            Row(
              children: [
                Expanded(
                  child: _WeatherDataItem(
                    icon: Icons.umbrella,
                    label: 'Rainfall',
                    value: weather.rainfall == 1 ? 'Yes' : 'No',
                    valueColor: weather.rainfall == 1 ? F1Colors.vermelho : null,
                  ),
                ),
                Expanded(
                  child: _WeatherDataItem(
                    icon: Icons.speed,
                    label: 'Pressure',
                    value: '${weather.pressure.toStringAsFixed(1)} mbar',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Wind Direction
            _WeatherDataItem(
              icon: Icons.explore,
              label: 'Wind Direction',
              value: '${weather.windDirection}° (${_getWindDirection(weather.windDirection)})',
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon() {
    if (weather.rainfall == 1) {
      return Icons.thunderstorm;
    } else if (weather.trackTemperature > 40) {
      return Icons.wb_sunny;
    } else if (weather.humidity > 70) {
      return Icons.cloud;
    } else {
      return Icons.wb_sunny_outlined;
    }
  }

  String _getWeatherCondition() {
    if (weather.rainfall == 1) {
      return 'Rainy';
    } else if (weather.trackTemperature > 40) {
      return 'Hot & Sunny';
    } else if (weather.humidity > 70) {
      return 'Cloudy';
    } else {
      return 'Clear';
    }
  }

  String _getWindDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

/// Individual weather data item
class _WeatherDataItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _WeatherDataItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: F1Colors.ciano.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
