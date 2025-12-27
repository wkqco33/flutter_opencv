import 'dart:typed_data';
import 'package:flutter/material.dart';

/// 이미지 뷰어 위젯
/// 
/// 이미지를 표시하거나 이미지가 없을 때 플레이스홀더를 보여줍니다.
/// 라이브 카메라 모드일 때는 "LIVE" 배지를 표시합니다.
class ImageViewer extends StatelessWidget {
  /// 표시할 이미지 바이트
  final Uint8List? imageBytes;
  
  /// 라이브 카메라 모드 여부
  final bool isLiveMode;
  
  const ImageViewer({
    super.key,
    this.imageBytes,
    this.isLiveMode = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 이미지 또는 플레이스홀더
          _buildContent(colorScheme),
          
          // 라이브 배지
          if (isLiveMode) _buildLiveBadge(),
        ],
      ),
    );
  }
  
  /// 이미지 또는 플레이스홀더 빌드
  Widget _buildContent(ColorScheme colorScheme) {
    if (imageBytes != null) {
      // 이미지가 있으면 표시
      // gaplessPlayback: true - 프레임 전환시 깜빡임 방지 (스트리밍에 유용)
      return Image.memory(
        imageBytes!,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      );
    } else {
      // 이미지가 없으면 플레이스홀더 표시
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '이미지를 선택하세요',
            style: TextStyle(
              color: colorScheme.outline,
              fontSize: 16,
            ),
          ),
        ],
      );
    }
  }
  
  /// 라이브 배지 빌드
  Widget _buildLiveBadge() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              color: Colors.white,
              size: 8,
            ),
            SizedBox(width: 4),
            Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
