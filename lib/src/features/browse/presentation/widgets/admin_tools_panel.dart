part of '../../../../../main.dart';

class _AdminToolsPanel extends StatelessWidget {
  const _AdminToolsPanel({
    required this.productCount,
    required this.noteCount,
    required this.characteristicCount,
    required this.dummyDataEnabled,
    required this.onDummyDataChanged,
    required this.onAddProduct,
    required this.onManageNotes,
    required this.onManageCharacteristics,
  });

  final int productCount;
  final int noteCount;
  final int characteristicCount;
  final bool dummyDataEnabled;
  final ValueChanged<bool> onDummyDataChanged;
  final VoidCallback onAddProduct;
  final VoidCallback onManageNotes;
  final VoidCallback onManageCharacteristics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF17201D).withValues(alpha: .08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF17201D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Color(0xFFCFF3E8),
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Admin tools',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MiniChip(
                icon: Icons.inventory_2_outlined,
                label: '$productCount products',
                foreground: theme.colorScheme.primary,
                background: theme.colorScheme.primary.withValues(alpha: .1),
              ),
              _MiniChip(
                icon: Icons.edit_note_rounded,
                label: '$noteCount notes',
                foreground: theme.colorScheme.secondary,
                background: theme.colorScheme.secondary.withValues(alpha: .12),
              ),
              _MiniChip(
                icon: Icons.auto_awesome_outlined,
                label: '$characteristicCount characteristics',
                foreground: const Color(0xFF6C5A8A),
                background: const Color(0xFFEFE7FF),
              ),
              _MiniSwitchChip(
                label: 'Dummy data',
                enabled: dummyDataEnabled,
                onChanged: onDummyDataChanged,
                foreground: const Color(0xFF2F6B5F),
                background: const Color(0xFFEAF3EE),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AdminCommandChip(
                key: const ValueKey('admin-add-product-button'),
                onPressed: onAddProduct,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add product'),
              ),
              _AdminCommandChip(
                key: const ValueKey('admin-manage-notes-button'),
                onPressed: onManageNotes,
                icon: const Icon(Icons.edit_note_rounded),
                label: Text('Notes ($noteCount)'),
              ),
              _AdminCommandChip(
                key: const ValueKey('admin-manage-characteristics-button'),
                onPressed: onManageCharacteristics,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text('Characteristics ($characteristicCount)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminCommandChip extends StatelessWidget {
  const _AdminCommandChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Widget icon;
  final Widget label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.primary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withValues(alpha: .08)),
          ),
          child: IconTheme(
            data: IconThemeData(color: foreground, size: 18),
            child: DefaultTextStyle(
              style: theme.textTheme.labelMedium!.copyWith(
                color: const Color(0xFF17201D),
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [icon, const SizedBox(width: 6), label],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
