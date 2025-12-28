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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: FilterType.values.length,
        itemBuilder: (context, index) {
          final filter = FilterType.values[index];
          return _buildFilterChip(
            context,
            label: filter.displayName,
            type: filter,
            icon: _getFilterIcon(filter),
          );
        },
      ),
    );
  }

  /// 필터 타입에 따른 아이콘 반환
  IconData _getFilterIcon(FilterType type) {
    switch (type) {
      case FilterType.none:
        return Icons.block;

      // 색상 변환
      case FilterType.grayscale:
        return Icons.filter_b_and_w;
      case FilterType.rgb:
        return Icons.palette;
      case FilterType.hsv:
        return Icons.color_lens;
      case FilterType.lab:
        return Icons.science;

      // 이미지 변환
      case FilterType.rotate:
        return Icons.rotate_right;
      case FilterType.flipHorizontal:
        return Icons.swap_horiz;
      case FilterType.flipVertical:
        return Icons.swap_vert;
      case FilterType.flipBoth:
        return Icons.cached;

      // 블러
      case FilterType.blur:
        return Icons.blur_on;
      case FilterType.medianBlur:
        return Icons.grain;
      case FilterType.bilateralFilter:
        return Icons.blur_circular;

      // 엣지 검출
      case FilterType.canny:
        return Icons.auto_fix_high;
      case FilterType.sobel:
        return Icons.grid_on;
      case FilterType.laplacian:
        return Icons.all_out;

      // 이미지 향상
      case FilterType.sharpen:
        return Icons.details;
      case FilterType.equalizeHist:
        return Icons.contrast;

      // 형태학
      case FilterType.erode:
        return Icons.remove_circle_outline;
      case FilterType.dilate:
        return Icons.add_circle_outline;
      case FilterType.morphOpen:
        return Icons.wb_sunny_outlined;
      case FilterType.morphClose:
        return Icons.nights_stay;
      case FilterType.morphGradient:
        return Icons.gradient;
      case FilterType.morphTophat:
        return Icons.vertical_align_top;
      case FilterType.morphBlackhat:
        return Icons.vertical_align_bottom;

      // 임계값
      case FilterType.threshold:
        return Icons.exposure;
      case FilterType.adaptiveThreshold:
        return Icons.auto_awesome;

      // 노이즈 제거
      case FilterType.denoise:
        return Icons.cleaning_services;
      case FilterType.denoiseColored:
        return Icons.cleaning_services_outlined;

      // 그리기
      case FilterType.draw:
        return Icons.edit;
    }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
    );
  }
}
