import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/member.dart';
import '../providers/member_providers.dart';

class MemberFormScreen extends ConsumerStatefulWidget {
  final String churchId;

  const MemberFormScreen({super.key, required this.churchId});

  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  Sex _sex = Sex.female;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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

    final createMember = ref.read(createMemberProvider);
    // NOTE DE PORTÉE : churchCode fixé en dur ('RTC') pour cette démo.
    // Dès qu'un ChurchRepository existera (Étape 9, Administration), il
    // faudra le lire depuis le contexte de l'église courante plutôt que
    // de le figer ici.
    final result = await createMember(
      churchId: widget.churchId,
      churchCode: 'RTC',
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      sex: _sex,
      initialStatus: MemberStatus.probation,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isSubmitting = false;
          _submitError = failure.message;
        });
      },
      (_) {
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau membre')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Le prénom est obligatoire'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Le nom est obligatoire'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Sex>(
                value: _sex,
                decoration: const InputDecoration(labelText: 'Sexe'),
                items: const [
                  DropdownMenuItem(value: Sex.female, child: Text('Féminin')),
                  DropdownMenuItem(value: Sex.male, child: Text('Masculin')),
                ],
                onChanged: (value) => setState(() => _sex = value ?? _sex),
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
                    : const Text('Créer le membre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
