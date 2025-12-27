import 'package:flutter/material.dart';
import '../models/filter_type.dart';

/// 필터 선택기 위젯
/// 
/// 사용 가능한 필터들을 가로 스크롤 리스트로 표시하고
/// 사용자가 필터를 선택할 수 있게 합니다.
class FilterSelector extends StatelessWidget {
  /// 현재 선택된 필터
  final FilterType selectedFilter;
  
  /// 필터 선택시 호출될 콜백
  final ValueChanged<FilterType> onFilterSelected;
  
  const FilterSelector({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(
            context,
            label: 'None',
            type: FilterType.none,
            icon: Icons.block,
          ),
          _buildFilterChip(
            context,
            label: 'Grayscale',
            type: FilterType.grayscale,
            icon: Icons.filter_b_and_w,
          ),
          _buildFilterChip(
            context,
            label: 'Blur',
            type: FilterType.blur,
            icon: Icons.blur_on,
          ),
          _buildFilterChip(
            context,
            label: 'Canny',
            type: FilterType.canny,
            icon: Icons.auto_fix_high,
          ),
          _buildFilterChip(
            context,
            label: 'Rotate',
            type: FilterType.rotate,
            icon: Icons.rotate_right,
          ),
          _buildFilterChip(
            context,
            label: 'Draw',
            type: FilterType.draw,
            icon: Icons.edit,
          ),
        ],
      ),
    );
  }
  
  /// 필터 칩 빌드
  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required FilterType type,
    required IconData icon,
  }) {
    final isSelected = selectedFilter == type;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        avatar: Icon(
          icon,
          size: 18,
          color: isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant,
        ),
        selected: isSelected,
        onSelected: (_) => onFilterSelected(type),
        showCheckmark: false,
        labelStyle: TextStyle(
          color: isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        selectedColor: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
    );
  }
}
