import 'package:supabase_flutter/supabase_flutter.dart';

class Data {
  static final _instance = Supabase.instance.client;


  Future<List<Map<String, dynamic>>> getAllUser()async{
    return await _instance
        .from('users')
        .select()
        .order('created_at', ascending: false);
  }
}