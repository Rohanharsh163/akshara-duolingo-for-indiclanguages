import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Replace these with your actual Supabase project credentials
  static const String supabaseUrl = 'https://bmtryitmpmwhjlzsfbkm.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJtdHJ5aXRtcG13aGpsenNmYmttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEwMDM4OTEsImV4cCI6MjA2NjU3OTg5MX0.vzfdd8ryFWuuFM5NpurNhXQfUfiwdjeBn2j-zJo8APg';
  
  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  // Get Supabase client
  static SupabaseClient get client => Supabase.instance.client;
  
  // Get auth client
  static GoTrueClient get auth => Supabase.instance.client.auth;
  
  // Get database client
  static SupabaseQueryBuilder get database => Supabase.instance.client.from('users');
}

// Extension methods for easier Supabase operations
extension SupabaseExtensions on SupabaseClient {
  // Get users table
  SupabaseQueryBuilder get users => from('users');
  
  // Get current user
  User? get currentUser => auth.currentUser;
  
  // Get auth state changes stream
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;
} 