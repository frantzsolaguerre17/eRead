import 'package:flutter/material.dart';
import '../models/expression.dart';
import '../services/expression_service.dart';

class ExpressionController extends ChangeNotifier {
  final ExpressionService service = ExpressionService();

  List<Expression> _expressions = [];
  bool isLoading = false;

  List<Expression> get expressions => _expressions;

  /// 🔄 Récupérer les expressions pour un livre
  Future<void> fetchExpressions(String bookId) async {
    try {
      isLoading = true;
      notifyListeners();

      _expressions = await service.fetchExpressions(bookId);
    } catch (e) {
      debugPrint('Erreur fetchExpressions : $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ➕ Ajouter une expression
  Future<void> addExpression(Expression exp) async {
    try {
      final inserted = await service.addExpression(exp);
      _expressions.add(inserted);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur addExpression : $e');
      throw Exception('Erreur insertion expression');
    }
  }

  /// ✏️ Modifier une expression
  Future<void> updateExpression(Expression exp) async {
    try {
      await service.updateExpression(exp);

      final index = _expressions.indexWhere((e) => e.id == exp.id);
      if (index != -1) {
        _expressions[index] = exp;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur updateExpression : $e');
    }
  }

  /// 🗑️ Supprimer une expression
  Future<void> deleteExpression(String id) async {
    try {
      await service.deleteExpression(id);
      _expressions.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur deleteExpression : $e');
    }
  }
}
