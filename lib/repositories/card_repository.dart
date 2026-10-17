import '../model/corporate_card.dart';
import '../services/card_api.dart';

class CardRepository {
  CardRepository(this._api);

  final CardApi _api;

  Future<List<CorporateCard>> fetchCards() => _api.fetchCards();

  Future<CorporateCard> setFrozen(String id, {required bool frozen}) =>
      _api.setFrozen(id, frozen: frozen);
}
