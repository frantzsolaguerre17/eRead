import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expression.dart';

class ExpressionService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// ➕ Ajouter une expression
  Future<Expression> addExpression(Expression exp) async {
    final res = await supabase
        .from('expression')
        .insert(exp.toJson())
        .select()
        .single();
    return Expression.fromJson(res);
  }

  /// 🔄 Récupérer les expressions du livre pour l'utilisateur actuel
  Future<List<Expression>> fetchExpressions(String bookId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('expression')
        .select()
        .eq('book_id', bookId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Expression.fromJson(json))
        .toList();
  }

  /// 🗑️ Supprimer une expression
  Future<void> deleteExpression(String id) async {
    await supabase
        .from('expression')
        .delete()
        .eq('id', id);
  }

  /// ✏️ Modifier une expression
  Future<void> updateExpression(Expression exp) async {
    await supabase
        .from('expression')
        .update(exp.toJson())
        .eq('id', exp.id);
  }
}
