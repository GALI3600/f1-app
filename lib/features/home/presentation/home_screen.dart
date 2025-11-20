import 'package:flutter/material.dart';
import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_text_styles.dart';
import 'package:f1sync/core/theme/f1_gradients.dart';
import 'package:f1sync/core/constants/app_constants.dart';

/// Home Screen - F1Sync MVP
/// Showcases the F1 theme system with gradient app bar and styled components
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient AppBar using F1 colors
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => F1Gradients.main.createShader(bounds),
          child: const Text(
            'F1Sync',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: F1Gradients.cianRoxo,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'Phase 1: Foundation Complete! 🏁',
              style: F1TextStyles.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'F1 Theme System Implemented',
              style: F1TextStyles.bodyLarge.copyWith(
                color: F1Colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Theme Demo Card
            _buildThemeDemoCard(),

            const SizedBox(height: 16),

            // Color Palette Demo
            _buildColorPaletteCard(),

            const SizedBox(height: 16),

            // Gradient Demo
            _buildGradientDemoCard(),

            const SizedBox(height: 16),

            // Typography Demo
            _buildTypographyDemoCard(),

            const SizedBox(height: 16),

            // Components Demo
            _buildComponentsDemoCard(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.flag),
        label: const Text('Start Race'),
      ),
    );
  }

  Widget _buildThemeDemoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Configuration',
              style: F1TextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Status', 'Implemented ✅'),
            _buildInfoRow('Colors', '50+ F1 colors'),
            _buildInfoRow('Gradients', '15+ gradients'),
            _buildInfoRow('Typography', 'Complete hierarchy'),
            _buildInfoRow('Components', 'All Material themed'),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPaletteCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'F1 Color Palette',
              style: F1TextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildColorChip('Cyan', F1Colors.ciano),
                _buildColorChip('Purple', F1Colors.roxo),
                _buildColorChip('Red', F1Colors.vermelho),
                _buildColorChip('Gold', F1Colors.dourado),
                _buildColorChip('Navy', F1Colors.navy),
                _buildColorChip('Success', F1Colors.success),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientDemoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'F1 Gradients',
              style: F1TextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                _buildGradientBar('Main Spectrum', F1Gradients.main),
                const SizedBox(height: 8),
                _buildGradientBar('Cyan → Purple', F1Gradients.cianRoxo),
                const SizedBox(height: 8),
                _buildGradientBar('Purple → Red', F1Gradients.roxoVermelho),
                const SizedBox(height: 8),
                _buildGradientBar('Red → Gold', F1Gradients.vermelhoDourado),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypographyDemoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Typography',
              style: F1TextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text('Display Large', style: F1TextStyles.displayLarge.copyWith(fontSize: 32)),
            Text('Headline Medium', style: F1TextStyles.headlineMedium),
            Text('Body Large', style: F1TextStyles.bodyLarge),
            Text('Body Medium', style: F1TextStyles.bodyMedium),
            const SizedBox(height: 8),
            Text('Driver Number', style: F1TextStyles.driverNumber.copyWith(fontSize: 40)),
            Text('Lap Time: 1:23.456', style: F1TextStyles.lapTime),
            Text('Team Name', style: F1TextStyles.teamName),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentsDemoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Components',
              style: F1TextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Primary Button'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text Button'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Chip(label: Text('Soft Tire')),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.7,
              backgroundColor: F1Colors.navy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: F1TextStyles.bodyMedium),
          Text(
            value,
            style: F1TextStyles.bodyMedium.copyWith(color: F1Colors.ciano),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Text(
        name,
        style: F1TextStyles.labelSmall.copyWith(
          color: _getContrastColor(color),
        ),
      ),
    );
  }

  Widget _buildGradientBar(String name, Gradient gradient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: F1TextStyles.bodySmall),
        const SizedBox(height: 4),
        Container(
          height: 32,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
        ),
      ],
    );
  }

  Color _getContrastColor(Color color) {
    // Simple luminance check for contrast
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
