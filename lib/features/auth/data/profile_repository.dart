import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';
import '../../../services/supabase_client_provider.dart';

class ProfileRepository {
  final SupabaseClient _client = SupabaseClientProvider.client;

  Future<ProfileModel> upsertProfile({
    required String displayName,
    required bool isGuest,
  }) async {
    final response = await _client.rpc(
      'upsert_profile',
      params: {
        'p_display_name': displayName,
        'p_is_guest': isGuest,
      },
    );

    return ProfileModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<ProfileModel?> fetchCurrentProfile() async {
    final user = SupabaseClientProvider.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;

    return ProfileModel.fromJson(Map<String, dynamic>.from(response));
  }
}
