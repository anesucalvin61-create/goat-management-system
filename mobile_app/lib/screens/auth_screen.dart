import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/goat.dart';
import '../services/report_service.dart';
import '../services/supabase_service.dart';
import 'goat_form_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoginMode = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = GoatService();
      final response = _isLoginMode
          ? await service.signIn(_emailController.text, _passwordController.text)
          : await service.signUp(_emailController.text, _passwordController.text);

      if (!mounted) return;

      if (response.user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.agriculture_rounded,
                          size: 72,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Goat Management',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLoginMode ? 'Sign in to your herd dashboard' : 'Create a new account',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Password is required';
                            }
                            if (value.trim().length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _isLoading ? null : _submit,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.arrow_forward_rounded),
                          label: Text(_isLoginMode ? 'Sign In' : 'Create Account'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() => _isLoginMode = !_isLoginMode);
                          },
                          child: Text(
                            _isLoginMode
                                ? 'Need an account? Sign up'
                                : 'Already have an account? Sign in',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GoatService _service = GoatService();
  final ReportService _reportService = ReportService();
  late Future<List<Goat>> _goatsFuture;

  @override
  void initState() {
    super.initState();
    _goatsFuture = _service.getGoats();
  }

  Future<void> _refreshGoats() async {
    setState(() {
      _goatsFuture = _service.getGoats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herd Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await _service.signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<Goat>(
            MaterialPageRoute(builder: (_) => const GoatFormScreen()),
          );
          if (result != null) {
            await _refreshGoats();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Goat'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGoats,
        child: FutureBuilder<List<Goat>>(
          future: _goatsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Failed to load goats: ${snapshot.error}'),
              );
            }

            final goats = snapshot.data ?? <Goat>[];

            final totalGoats = goats.length;
            final vaccinated = goats.where((goat) => goat.vaccinationDate.isNotEmpty).length;
            final owners = goats.map((goat) => goat.owner.trim()).where((owner) => owner.isNotEmpty).toSet().length;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(child: _SummaryCard(title: 'Total Goats', value: '$totalGoats')),
                    const SizedBox(width: 12),
                    Expanded(child: _SummaryCard(title: 'Vaccinated', value: '$vaccinated')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _SummaryCard(title: 'Owners', value: '$owners')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Herd Size',
                        value: '${goats.fold<int>(0, (sum, goat) => sum + goat.herdSize)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          await _reportService.printReport(goats);
                        },
                        icon: const Icon(Icons.print_outlined),
                        label: const Text('Print Report'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () async {
                          await _reportService.downloadPdf(goats);
                        },
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Export PDF'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (goats.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No goats registered yet.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  )
                else
                  ...goats.map((goat) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.agriculture_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(goat.goatNumber),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Owner: ${goat.owner}'),
                            Text('DOB: ${goat.dateOfBirth}'),
                            Text('Vaccination: ${goat.vaccinationDate}'),
                            Text('Herd Size: ${goat.herdSize}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final updatedGoat = await Navigator.of(context).push<Goat>(
                                MaterialPageRoute(
                                  builder: (_) => GoatFormScreen(goat: goat),
                                ),
                              );
                              if (updatedGoat != null) {
                                await _refreshGoats();
                              }
                            } else if (value == 'delete') {
                              if (goat.id != null) {
                                await _service.deleteGoat(goat.id!);
                                await _refreshGoats();
                              }
                            }
                          },
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
