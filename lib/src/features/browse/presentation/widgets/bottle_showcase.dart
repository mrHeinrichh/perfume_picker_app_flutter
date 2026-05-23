part of '../../../../../main.dart';

class _BottleShowcase extends StatelessWidget {
  const _BottleShowcase();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3F7D72),
                    Color(0xFFE46D55),
                    Color(0xFF6C5A8A),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 850),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 18 * (1 - value)),
                  child: Transform.scale(scale: value, child: child),
                );
              },
              child: Container(
                width: 118,
                height: 136,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .2),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF17201D).withValues(alpha: .92),
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      color: Color(0xFFFFE7D7),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 18,
            child: Container(
              width: 52,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
