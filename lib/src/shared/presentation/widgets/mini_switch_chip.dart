part of '../../../../main.dart';

class _MiniSwitchChip extends StatelessWidget {
  const _MiniSwitchChip({
    required this.label,
    required this.enabled,
    required this.onChanged,
    required this.background,
    required this.foreground,
  });

  final String label;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 5, 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
            size: 15,
            color: foreground,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 40,
            height: 28,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch.adaptive(
                key: const ValueKey('admin-dummy-data-toggle'),
                value: enabled,
                onChanged: onChanged,
                activeThumbColor: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
