import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/subgroup.dart';
import '../providers/community_providers.dart';

const _subgroupTypes = ['jeunesse', 'chorale', 'femmes', 'hommes', 'autre'];

class SubgroupFormScreen extends ConsumerStatefulWidget {
  final String churchId;

  const SubgroupFormScreen({super.key, required this.churchId});

  @override
  ConsumerState<SubgroupFormScreen> createState() => _SubgroupFormScreenState();
}

class _SubgroupFormScreenState extends ConsumerState<SubgroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _type = _subgroupTypes.first;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final repository = ref.read(subgroupRepositoryProvider);
    final subgroup = Subgroup(
      id: const Uuid().v4(),
      churchId: widget.churchId,
      name: _nameController.text.trim(),
      type: _type,
    );

    final result = await repository.createSubgroup(subgroup);

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
      appBar: AppBar(title: const Text('Nouveau sous-groupe')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom du sous-groupe'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Le nom est obligatoire'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: _subgroupTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _type = value ?? _type),
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
                    : const Text('Créer le sous-groupe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
