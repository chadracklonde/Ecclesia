import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/service.dart';
import '../providers/liturgy_providers.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  final String churchId;

  const ServiceFormScreen({super.key, required this.churchId});

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _themeController = TextEditingController();
  DateTime _date = DateTime.now();
  ServiceType _type = ServiceType.dominical;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final createService = ref.read(createServiceProvider);
    final result = await createService(
      churchId: widget.churchId,
      date: _date,
      type: _type,
      theme: _themeController.text.trim().isEmpty ? null : _themeController.text.trim(),
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

  String _typeLabel(ServiceType type) {
    switch (type) {
      case ServiceType.dominical:
        return 'Culte dominical';
      case ServiceType.special:
        return 'Culte spécial';
      case ServiceType.veillee:
        return 'Veillée';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau culte')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${_date.day}/${_date.month}/${_date.year}'),
              trailing: TextButton(onPressed: _pickDate, child: const Text('Changer')),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ServiceType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type de culte'),
              items: ServiceType.values
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(_typeLabel(type))))
                  .toList(),
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _themeController,
              decoration: const InputDecoration(labelText: 'Thème (optionnel)'),
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
                  : const Text('Créer le culte'),
            ),
          ],
        ),
      ),
    );
  }
}
