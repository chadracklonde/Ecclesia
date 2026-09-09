import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/secretariat_providers.dart';

class InventoryFormScreen extends ConsumerStatefulWidget {
  final String churchId;

  const InventoryFormScreen({super.key, required this.churchId});

  @override
  ConsumerState<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends ConsumerState<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _conditionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _conditionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.tryParse(_quantityController.text.trim()) ?? -1;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final createItem = ref.read(createInventoryItemProvider);
    final result = await createItem(
      churchId: widget.churchId,
      name: _nameController.text,
      category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      quantity: quantity,
      condition: _conditionController.text.trim().isEmpty ? null : _conditionController.text.trim(),
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isSubmitting = false;
        _submitError = failure.message;
      }),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel article')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom de l\'article'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Le nom est obligatoire'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Catégorie (optionnel)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantité'),
                validator: (value) {
                  final parsed = int.tryParse((value ?? '').trim());
                  if (parsed == null || parsed < 0) {
                    return 'Quantité invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Emplacement (optionnel)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(labelText: 'État (optionnel)'),
              ),
              const SizedBox(height: 20),
              if (_submitError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _submitError!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Ajouter l\'article'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
