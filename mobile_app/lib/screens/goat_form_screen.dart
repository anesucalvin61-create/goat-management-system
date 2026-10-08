import 'package:flutter/material.dart';

import '../models/goat.dart';
import '../services/supabase_service.dart';

class GoatFormScreen extends StatefulWidget {
  final Goat? goat;

  const GoatFormScreen({super.key, this.goat});

  @override
  State<GoatFormScreen> createState() => _GoatFormScreenState();
}

class _GoatFormScreenState extends State<GoatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goatNumberController = TextEditingController();
  final _ownerController = TextEditingController();
  final _dobController = TextEditingController();
  final _vaccinationDateController = TextEditingController();
  final _herdSizeController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.goat != null) {
      _goatNumberController.text = widget.goat!.goatNumber;
      _ownerController.text = widget.goat!.owner;
      _dobController.text = widget.goat!.dateOfBirth;
      _vaccinationDateController.text = widget.goat!.vaccinationDate;
      _herdSizeController.text = widget.goat!.herdSize.toString();
      _notesController.text = widget.goat!.notes;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final goat = Goat(
        id: widget.goat?.id,
        goatNumber: _goatNumberController.text.trim(),
        owner: _ownerController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
        vaccinationDate: _vaccinationDateController.text.trim(),
        herdSize: int.tryParse(_herdSizeController.text.trim()) ?? 0,
        notes: _notesController.text.trim(),
      );

      final service = GoatService();

      if (widget.goat == null) {
        await service.addGoat(goat);
      } else {
        await service.updateGoat(goat);
      }

      if (!mounted) return;
      Navigator.of(context).pop(goat);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save goat: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goat == null ? 'Add Goat' : 'Edit Goat'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _goatNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Goat Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ownerController,
                  decoration: const InputDecoration(
                    labelText: 'Owner',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vaccinationDateController,
                  decoration: const InputDecoration(
                    labelText: 'Vaccination Date',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _herdSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of Goats',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(widget.goat == null ? 'Save Goat' : 'Update Goat'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
