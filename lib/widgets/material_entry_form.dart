import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../features/stock/models/product.dart';
import '../features/stock/services/stock_service.dart';

class MaterialEntryForm extends StatefulWidget {
  final void Function(Product? product, int quantity) onSaved;
  final List<Product>? availableProducts;

  const MaterialEntryForm({
    super.key,
    required this.onSaved,
    this.availableProducts,
  });

  @override
  State<MaterialEntryForm> createState() => _MaterialEntryFormState();
}

class _MaterialEntryFormState extends State<MaterialEntryForm> {
  Product? _selectedProduct;
  int _quantity = 1;
  final TextEditingController _noteController = TextEditingController();
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: _quantity.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _subtotal {
    if (_selectedProduct == null || _selectedProduct!.standardPrice == null)
      return 0.0;
    return _quantity * _selectedProduct!.standardPrice!;
  }

  void _save() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a material')));
      return;
    }
    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quantity must be greater than 0')));
      return;
    }
    widget.onSaved(_selectedProduct, _quantity);
  }

  Future<Iterable<Product>> _search(String text) async {
    final q = text.trim();
    if (q.length < 2) return const <Product>[];
    final remote = await StockService.instance.searchProducts(q);
    if (remote.isNotEmpty) return remote;
    return widget.availableProducts ?? const <Product>[];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedBox = theme.colorScheme.surfaceContainerHighest;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    key: const Key('btn_close_material'),
                    icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Add Material',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    key: const Key('btn_save_material'),
                    onPressed: _save,
                    child: Text(
                      'Save',
                      style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('MATERIAL', style: _labelStyle(theme)),
                        InkWell(
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Create new products in Odoo web, not on mobile.')),
                          ),
                          child: Text(
                            'ADD NEW',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Autocomplete<Product>(
                      displayStringForOption: (Product option) => option.name,
                      optionsBuilder: (TextEditingValue value) =>
                          _search(value.text),
                      onSelected: (Product selection) =>
                          setState(() => _selectedProduct = selection),
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          key: const Key('input_material_search'),
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Search product from stock...',
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('QUANTITY', style: _labelStyle(theme)),
                              const SizedBox(height: 8),
                              TextField(
                                key: const Key('input_quantity'),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: _inputDecoration(theme),
                                controller: _quantityController,
                                onChanged: (val) => setState(
                                    () => _quantity = int.tryParse(val) ?? 0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PRICE', style: _labelStyle(theme)),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                    color: mutedBox,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  _selectedProduct != null
                                      ? '\$${_selectedProduct!.standardPrice?.toStringAsFixed(2) ?? '0.00'}'
                                      : '-',
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SUBTOTAL', style: _labelStyle(theme)),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                    color: mutedBox,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  '\$${_subtotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('NOTE', style: _labelStyle(theme)),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('input_material_note'),
                      controller: _noteController,
                      maxLines: 2,
                      decoration: _inputDecoration(theme)
                          .copyWith(hintText: 'Optional note...'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _labelStyle(ThemeData theme) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      letterSpacing: 0.5,
    );
  }

  InputDecoration _inputDecoration(ThemeData theme) {
    return InputDecoration(
      filled: true,
      fillColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
    );
  }
}
