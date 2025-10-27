import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Sign up a new user and auto-sign-in. Returns the authenticated User.
  Future<User?> signUp(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: null, // Disable email confirmation redirect
    );
    return response.user;
  }

  // Sign in existing user. Returns the authenticated User if sign in succeeded.
  Future<User?> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    return _client.auth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Fetch the current user's profile row from "profiles" table
  Future<Map<String, dynamic>?> fetchProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final data =
          await _client.from('profiles').select().eq('id', user.id).single();

      return data as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // Upsert profile map into "profiles" table
  Future<Map<String, dynamic>?> upsertProfile(
      Map<String, dynamic> profile) async {
    try {
      final data =
          await _client.from('profiles').upsert(profile).select().single();

      return data as Map<String, dynamic>;
    } catch (e) {
      print('Error upserting profile: $e');
      return null;
    }
  }
}
