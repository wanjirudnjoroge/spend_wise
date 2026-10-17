import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../core/utils/safe_notifier.dart';
import '../model/corporate_card.dart';
import '../repositories/card_repository.dart';

class CardsViewModel extends ChangeNotifier with SafeNotifier {
  CardsViewModel(this._repository);

  final CardRepository _repository;

  List<CorporateCard> _cards = const [];
  bool _isLoading = false;
  String? _error;

  List<CorporateCard> get cards => List.unmodifiable(_cards);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _cards = await _repository.fetchCards();
    } catch (error) {
      _error = errorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setFrozen(String id, {required bool frozen}) async {
    try {
      final updated = await _repository.setFrozen(id, frozen: frozen);
      _cards = [for (final card in _cards) card.id == id ? updated : card];
      _error = null;
      return true;
    } catch (error) {
      _error = errorMessage(error);
      return false;
    } finally {
      notifyListeners();
    }
  }
}
