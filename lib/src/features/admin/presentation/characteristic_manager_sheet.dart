part of '../../../../main.dart';

class CharacteristicManagerSheet extends StatefulWidget {
  const CharacteristicManagerSheet({super.key});

  @override
  State<CharacteristicManagerSheet> createState() =>
      _CharacteristicManagerSheetState();
}

class _CharacteristicManagerSheetState
    extends State<CharacteristicManagerSheet> {
  late final TextEditingController _addController;
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _addController = TextEditingController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _addController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addCharacteristic() {
    final characteristic = _cleanCharacteristicLabel(_addController.text);
    if (characteristic.isEmpty) return;
    if (characteristic.length > fragranceCharacteristicNameMaxLength) {
      _showMessage('Characteristics can only be 24 characters long.');
      return;
    }

    final added = PerfumeScope.read(context).addCharacteristic(characteristic);
    if (!added) {
      _showMessage('$characteristic is already in the characteristics list.');
      return;
    }

    _addController.clear();
    _showMessage('$characteristic added.');
  }

  Future<void> _renameCharacteristic(String characteristic) async {
    final controller = TextEditingController(text: characteristic);
    final nextCharacteristic = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename characteristic'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: fragranceCharacteristicNameMaxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            decoration: const InputDecoration(labelText: 'Characteristic name'),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (!mounted) return;
    if (nextCharacteristic == null) return;
    final cleaned = _cleanCharacteristicLabel(nextCharacteristic);
    if (cleaned.isEmpty) return;
    if (cleaned.length > fragranceCharacteristicNameMaxLength) {
      _showMessage('Characteristics can only be 24 characters long.');
      return;
    }

    final renamed = PerfumeScope.read(
      context,
    ).renameCharacteristic(characteristic, cleaned);
    if (!renamed) {
      _showMessage('Could not rename characteristic. It may already exist.');
      return;
    }

    _showMessage('$characteristic renamed to $cleaned.');
  }

  Future<void> _deleteCharacteristic(String characteristic) async {
    final store = PerfumeScope.read(context);
    final usageCount = store.characteristicUsageCount(characteristic);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete characteristic?'),
          content: Text(
            usageCount == 0
                ? '$characteristic will be removed from the selectable characteristics list.'
                : '$characteristic is used by $usageCount product(s). Deleting it also removes it from those products.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmed != true) return;
    store.deleteCharacteristic(characteristic);
    _showMessage('$characteristic deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final store = PerfumeScope.watch(context);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final visibleCharacteristics = store.fragranceCharacteristicOptions
        .where(
          (characteristic) =>
              characteristic.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList(growable: false);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: .86,
        minChildSize: .56,
        maxChildSize: .96,
        expand: false,
        builder: (context, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFCF6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Manage characteristics',
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const ValueKey('characteristic-add-field'),
                              controller: _addController,
                              maxLength: fragranceCharacteristicNameMaxLength,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              decoration: const InputDecoration(
                                labelText: 'Add a characteristic',
                                prefixIcon: Icon(Icons.add_rounded),
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _addCharacteristic(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filled(
                            key: const ValueKey('characteristic-add-button'),
                            tooltip: 'Add characteristic',
                            onPressed: _addCharacteristic,
                            icon: const Icon(Icons.check_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const ValueKey('characteristic-manager-search'),
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search characteristics',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    setState(() {
                                      _query = '';
                                      _searchController.clear();
                                    });
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: visibleCharacteristics.isEmpty
                      ? Center(
                          child: Text(
                            'No characteristics found',
                            style: theme.textTheme.titleMedium,
                          ),
                        )
                      : ListView.separated(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: visibleCharacteristics.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final characteristic =
                                visibleCharacteristics[index];
                            final usageCount = store.characteristicUsageCount(
                              characteristic,
                            );

                            return ListTile(
                              key: ValueKey(
                                'managed-characteristic-$characteristic',
                              ),
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(characteristic),
                              subtitle: Text(
                                usageCount == 0
                                    ? 'Not used yet'
                                    : 'Used by $usageCount product(s)',
                              ),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    tooltip: 'Rename characteristic',
                                    onPressed: () =>
                                        _renameCharacteristic(characteristic),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete characteristic',
                                    onPressed: () =>
                                        _deleteCharacteristic(characteristic),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
