import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../model/corporate_card.dart';

abstract class CardApi {
  Future<List<CorporateCard>> fetchCards();
  Future<CorporateCard> setFrozen(String id, {required bool frozen});
}

class HttpCardApi implements CardApi {
  HttpCardApi(this._client);

  final ApiClient _client;

  @override
  Future<List<CorporateCard>> fetchCards() async {
    final json = await _client.get(AppConstants.cardsEndpoint);
    final items = json['data'] as List<dynamic>? ?? const [];
    return items
        .map((item) => CorporateCard.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CorporateCard> setFrozen(String id, {required bool frozen}) async {
    final json = await _client.patch(
      '${AppConstants.cardsEndpoint}/$id',
      body: {'is_frozen': frozen},
    );
    return CorporateCard.fromJson(json);
  }
}
