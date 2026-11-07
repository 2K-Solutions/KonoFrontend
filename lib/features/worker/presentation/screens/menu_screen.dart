import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konofrontend/core/theme.dart';
import 'package:konofrontend/core/widgets/app_text_field.dart';
import 'package:konofrontend/core/widgets/bottom_action_bar.dart';
import 'package:konofrontend/features/worker/data/menu_sync.dart';
import 'package:konofrontend/features/worker/domain/menu_item.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key, required this.category});

  final MenuCategory category;

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final _searchController = TextEditingController();
  final Map<String, int> _quantities = {};
  late MenuCategory _category = widget.category;
  String _query = '';
  // Shown while a new search runs so the list doesn't flash a spinner on every keystroke.
  List<MenuItem>? _previousItems;
  bool _isCheckingMenu = false;

  bool get _isDrinks => _category == MenuCategory.drinks;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _changeQuantity(MenuItem item, int delta) {
    setState(() {
      final quantity = (_quantities[item.id] ?? 0) + delta;
      if (quantity <= 0) {
        _quantities.remove(item.id);
      } else {
        _quantities[item.id] = quantity;
      }
    });
  }

  void _switchCategory() {
    setState(() {
      _category = _isDrinks ? MenuCategory.food : MenuCategory.drinks;
      _searchController.clear();
      _query = '';
      _previousItems = null;
    });
  }

  Future<void> _checkMenu() async {
    setState(() => _isCheckingMenu = true);
    final result = await ref.read(menuSyncProvider.notifier).checkForUpdates();
    if (!mounted) return;
    setState(() => _isCheckingMenu = false);

    final message = switch (result) {
      MenuCheckResult.upToDate => 'The menu is up to date.',
      MenuCheckResult.updated => 'The menu has been updated.',
      MenuCheckResult.failed => 'Could not check the menu. Please try again.',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(menuItemsProvider((category: _category, query: _query)));
    if (items.hasValue) _previousItems = items.value;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _isCheckingMenu ? null : _checkMenu,
            tooltip: 'Check for menu updates',
            color: Colors.white,
            icon: _isCheckingMenu
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.sync),
          ),
          TextButton.icon(
            onPressed: _switchCategory,
            icon: Icon(_isDrinks ? Icons.restaurant_outlined : Icons.local_bar_outlined),
            label: Text(_isDrinks ? 'Food' : 'Drinks'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isDrinks ? 'Drinks' : 'Food', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Tap + to add items to the order.', style: TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 24),
              Expanded(
                child: items.when(
                  data: (data) => _buildList(data),
                  loading: () => _previousItems == null
                      ? const Center(child: CircularProgressIndicator())
                      : _buildList(_previousItems!),
                  error: (error, _) => const Center(
                    child: Text(
                      'Could not load the menu. Please try again.',
                      style: TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: _isDrinks ? 'Search drinks' : 'Search food',
                hint: _isDrinks ? 'Drink name' : 'Dish name',
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value.trim()),
                suffixIcon: const Icon(Icons.search),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        actions: [
          BottomAction(icon: Icons.arrow_back, label: 'Back', onTap: () => context.pop()),
          BottomAction(icon: Icons.receipt_long_outlined, label: 'Order', onTap: () {}),
          BottomAction(
            icon: Icons.check_circle_outline,
            label: 'Confirm',
            color: AppColors.success,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<MenuItem> items) {
    if (items.isEmpty && _query.isEmpty) {
      return _EmptyMessage(_isDrinks ? 'No drinks on the menu yet.' : 'No food on the menu yet.');
    }
    if (items.isEmpty) {
      return _EmptyMessage(_isDrinks ? 'No drinks match your search.' : 'No food matches your search.');
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _MenuItemRow(
          item: item,
          quantity: _quantities[item.id] ?? 0,
          onAdd: () => _changeQuantity(item, 1),
          onRemove: () => _changeQuantity(item, -1),
          onEdit: () {},
        );
      },
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  const _MenuItemRow({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.onEdit,
  });

  final MenuItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final isSelected = quantity > 0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _StepButton(icon: Icons.remove, onPressed: isSelected ? onRemove : null),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                Text(
                  '${item.price.toStringAsFixed(2)} €',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          if (isSelected)
            Text(
              '$quantity×',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.textMuted,
            tooltip: 'Add note',
          ),
          _StepButton(icon: Icons.add, onPressed: onAdd, filled: true),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed, this.filled = false});

  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null ? AppColors.primary.withValues(alpha: 0.3) : AppColors.primary;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
      side: filled ? BorderSide.none : BorderSide(color: color),
    );

    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: filled ? color : Colors.white,
        shape: shape,
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          child: Icon(icon, color: filled ? Colors.white : color, size: 20),
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: AppColors.textMuted),
        textAlign: TextAlign.center,
      ),
    );
  }
}
