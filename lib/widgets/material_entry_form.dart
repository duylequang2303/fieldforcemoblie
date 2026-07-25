import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../features/stock/models/product.dart';

class MaterialEntryForm extends StatefulWidget {
  final VoidCallback onSaved;
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

  // Mock list of products from Odoo
  final List<Product> _mockProducts = [
    Product()..name = 'AC Filter (Standard)'..standardPrice = 25.00,
    Product()..name = 'AC Gas Refill'..standardPrice = 80.00,
    Product()..name = 'Copper Pipe (1m)'..standardPrice = 15.50,
  ];

  double get _subtotal {
    if (_selectedProduct == null || _selectedProduct!.standardPrice == null) {
      return 0.0;
    }
    return _quantity * _selectedProduct!.standardPrice!;
  }

  void _save() {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a material')),
      );
      return;
    }
    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be greater than 0')),
      );
      return;
    }
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.background,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
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
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MATERIAL
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('MATERIAL', style: _labelStyle(theme)),
                        InkWell(
                          onTap: () {
                            // TODO: Add new product flow
                          },
                          child: Text(
                            'ADD NEW',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Autocomplete<Product>(
                      displayStringForOption: (Product option) => option.name,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Product>.empty();
                        }
                        final items = widget.availableProducts ?? _mockProducts;
                        return items.where((Product option) {
                          return option.name
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (Product selection) {
                        setState(() {
                          _selectedProduct = selection;
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          key: const Key('input_material_search'),
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Search product...',
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
                    
                    // QUANTITY / PRICE / SUBTOTAL
                    Row(
                      children: [
                        // Quantity
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
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: _inputDecoration(theme),
                                controller: _quantityController,
                                onChanged: (val) {
                                  setState(() {
                                    _quantity = int.tryParse(val) ?? 0;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Price
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PRICE', style: _labelStyle(theme)),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant?.withOpacity(0.5) ?? Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _selectedProduct != null 
                                      ? '\$${_selectedProduct!.standardPrice?.toStringAsFixed(2) ?? '0.00'}' 
                                      : '-',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Subtotal
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SUBTOTAL', style: _labelStyle(theme)),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant?.withOpacity(0.5) ?? Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '\$${_subtotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // NOTE
                    Text('NOTE', style: _labelStyle(theme)),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('input_material_note'),
                      controller: _noteController,
                      maxLines: 2,
                      decoration: _inputDecoration(theme).copyWith(
                        hintText: 'Optional note...',
                      ),
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
