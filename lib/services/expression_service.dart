import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/expression.dart';

class ExpressionService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Expression>> fetchExpressions(String bookId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final res = await supabase
        .from('expression')
        .select()
        .eq('book_id', bookId)
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => Expression.fromJson(e))
        .toList();
  }

  Future<Expression> addExpression(Expression exp) async {
    final res = await supabase
        .from('expression')
        .insert(exp.toJson())
        .select()
        .single();

    return Expression.fromJson(res);
  }

  Future<void> updateExpression(Expression exp) async {
    await supabase
        .from('expression')
        .update(exp.toJson())
        .eq('id', exp.id)
        .eq('user_id', exp.userId);
  }

  Future<void> deleteExpression(String id) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase
        .from('expression')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);
  }

  /// ⭐ FAVORIS
  Future<void> toggleFavorite(String id, bool value) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase
        .from('expression')
        .update({'is_favorite': value})
        .eq('id', id)
        .eq('user_id', user.id);
  }
}
