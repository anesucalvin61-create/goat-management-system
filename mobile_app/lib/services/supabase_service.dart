import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/goat.dart';

class GoatService {
  final SupabaseClient client = Supabase.instance.client;

  Future<AuthResponse> signIn(String email, String password) async {
    return client.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return client.auth.signUp(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<List<Goat>> getGoats() async {
    final response = await client
        .from('goats')
        .select()
        .order('created_at', ascending: false);

    final rows = response as List<dynamic>;
    return rows.map((row) => Goat.fromMap(Map<String, dynamic>.from(row))).toList();
  }

  Future<void> addGoat(Goat goat) async {
    await client.from('goats').insert(goat.toMap());
  }

  Future<void> updateGoat(Goat goat) async {
    if (goat.id == null || goat.id!.isEmpty) {
      throw Exception('Goat id is required for update');
    }

    await client.from('goats').update(goat.toMap()).eq('id', goat.id!);
  }

  Future<void> deleteGoat(String id) async {
    await client.from('goats').delete().eq('id', id);
  }

  Future<Map<String, int>> getStats() async {
    final goats = await getGoats();

    final total = goats.length;
    final vaccinated = goats.where((goat) => goat.vaccinationDate.isNotEmpty).length;
    final owners = goats.map((goat) => goat.owner.trim()).where((owner) => owner.isNotEmpty).toSet().length;

    return {
      'total': total,
      'vaccinated': vaccinated,
      'owners': owners,
    };
  }
}
