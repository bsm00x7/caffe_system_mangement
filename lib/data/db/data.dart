import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Data {
  static final _instance = Supabase.instance.client;


  static Future<List<Map<String, dynamic>>> getAllUser()async{
    return await _instance
        .from('users')
        .select()
        .order('created_at', ascending: false);
  }

  static Future<void> affectationEmployer()async{

    await _instance.from('affectation').insert({});

  }
  static Future<List<Map<String, dynamic>>> getAllItem()async{

    return await _instance.from('items').select();
  }
}