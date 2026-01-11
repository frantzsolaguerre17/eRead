import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/expression.dart';
import '../services/expression_service.dart';

class ExpressionController extends ChangeNotifier {
  final ExpressionService service = ExpressionService();
  final SupabaseClient supabase = Supabase.instance.client;

  List<Expression> _expressions = [];
  bool isLoading = false;

  List<Expression> get expressions => _expressions;

  Future<void> fetchExpressions(String bookId) async {
    isLoading = true;
    notifyListeners();

    _expressions = await service.fetchExpressions(bookId);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addExpression(Expression exp) async {
    final inserted = await service.addExpression(exp);
    _expressions.insert(0, inserted);
    notifyListeners();
  }

  Future<void> updateExpression(Expression exp) async {
    await service.updateExpression(exp);
    final i = _expressions.indexWhere((e) => e.id == exp.id);
    if (i != -1) {
      _expressions[i] = exp;
      notifyListeners();
    }
  }

  Future<void> deleteExpression(String id) async {
    await service.deleteExpression(id);
    _expressions.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// ⭐ FAVORIS
  Future<void> toggleFavorite(Expression exp) async {
    exp.isFavorite = !exp.isFavorite;
    notifyListeners();
    await service.toggleFavorite(exp.id, exp.isFavorite);
  }


  Future<void> fetchFavoriteVocabulary() async {
    try {
      isLoading = true;
      notifyListeners();

      final user = supabase.auth.currentUser;
      if (user == null) {
        _expressions = [];
        return;
      }

      final response = await supabase
          .from('vocabulary')
          .select()
          .eq('user_id', user.id)
          .eq('is_favorite', true)
          .order('created_at', ascending: false);

      _expressions = (response as List)
          .map((json) => Expression.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur fetchFavoriteVocabulary: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<int> getLearnedExpressionsCount() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    final res = await Supabase.instance.client
        .from('expression')
        .select('*')
        .eq('user_id', userId)
        .count();

    return res.count ?? 0;
  }

}
