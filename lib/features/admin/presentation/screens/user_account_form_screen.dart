import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/role.dart';
import '../providers/admin_list_providers.dart';
import '../providers/admin_providers.dart';

class UserAccountFormScreen extends ConsumerStatefulWidget {
  final String churchId;

  const UserAccountFormScreen({super.key, required this.churchId});

  @override
  ConsumerState<UserAccountFormScreen> createState() =>
      _UserAccountFormScreenState();
}

class _UserAccountFormScreenState extends ConsumerState<UserAccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  Role? _selectedRole;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _roleLabel(RoleName name) {
    switch (name) {
      case RoleName.superAdmin:
        return 'Super Admin';
      case RoleName.pasteur:
        return 'Pasteur';
      case RoleName.tresorier:
        return 'Trésorier';
      case RoleName.secretaire:
        return 'Secrétaire';
      case RoleName.responsableClasse:
        return 'Responsable de classe';
      case RoleName.membreLecture:
        return 'Membre (lecture)';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) {
      if (_selectedRole == null) {
        setState(() => _submitError = 'Choisis un rôle');
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final createUserAccount = ref.read(createUserAccountProvider);
    final result = await createUserAccount(
      churchId: widget.churchId,
      username: _usernameController.text,
      plainPassword: _passwordController.text,
      roleId: _selectedRole!.id,
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
    final rolesAsync = ref.watch(rolesListProvider(widget.churchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau compte')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Nom d\'utilisateur'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Le nom d\'utilisateur est obligatoire'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe (8 caractères min.)'),
                validator: (value) => (value == null || value.length < 8)
                    ? 'Au moins 8 caractères'
                    : null,
              ),
              const SizedBox(height: 12),
              rolesAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (error, _) => Text('Erreur : $error'),
                data: (roles) {
                  if (roles.isEmpty) {
                    return const Text(
                      'Aucun rôle disponible — initialise les rôles par défaut depuis l\'écran Administration.',
                    );
                  }
                  return DropdownButtonFormField<Role>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Rôle'),
                    items: roles
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(_roleLabel(r.name)),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedRole = value),
                  );
                },
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
                    : const Text('Créer le compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
