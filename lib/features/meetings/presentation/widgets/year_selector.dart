import 'package:f1sync/core/theme/f1_colors.dart';
import 'package:f1sync/core/theme/f1_gradients.dart';
import 'package:flutter/material.dart';

/// Year Selector Widget
/// Horizontal chip selector for filtering meetings by year
/// - F1 gradient when selected
/// - Updates selectedYearProvider
class YearSelector extends StatelessWidget {
  final int selectedYear;
  final ValueChanged<int> onYearChanged;
  final List<int> availableYears;

  const YearSelector({
    super.key,
    required this.selectedYear,
    required this.onYearChanged,
    this.availableYears = const [2023, 2024, 2025],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: availableYears.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final year = availableYears[index];
          final isSelected = year == selectedYear;

          return _YearChip(
            year: year,
            isSelected: isSelected,
            onTap: () => onYearChanged(year),
          );
        },
      ),
    );
  }
}

class _YearChip extends StatelessWidget {
  final int year;
  final bool isSelected;
  final VoidCallback onTap;

  const _YearChip({
    required this.year,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return _SelectedChip(year: year, onTap: onTap);
    }

    return _UnselectedChip(year: year, onTap: onTap);
  }
}

/// Selected year chip with gradient background
class _SelectedChip extends StatelessWidget {
  final int year;
  final VoidCallback onTap;

  const _SelectedChip({
    required this.year,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: F1Gradients.cianRoxo,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: F1Colors.ciano.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          year.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Unselected year chip with border only
class _UnselectedChip extends StatelessWidget {
  final int year;
  final VoidCallback onTap;

  const _UnselectedChip({
    required this.year,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: F1Colors.ciano.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Text(
          year.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: F1Colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
