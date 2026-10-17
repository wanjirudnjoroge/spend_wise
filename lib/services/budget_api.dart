import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../model/budget.dart';

abstract class BudgetApi {
  Future<List<Budget>> fetchBudgets();

  Future<Budget> saveBudget(Budget budget);

  Future<void> deleteBudget(String id);
}

class HttpBudgetApi implements BudgetApi {
  HttpBudgetApi(this._client);

  final ApiClient _client;

  @override
  Future<List<Budget>> fetchBudgets() async {
    final json = await _client.get(AppConstants.budgetsEndpoint);
    final items = json['data'] as List<dynamic>? ?? const [];
    return items
        .map((item) => Budget.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Budget> saveBudget(Budget budget) async {
    final json = budget.id.isEmpty
        ? await _client.post(
            AppConstants.budgetsEndpoint,
            body: budget.toJson(),
          )
        : await _client.put(
            '${AppConstants.budgetsEndpoint}/${budget.id}',
            body: budget.toJson(),
          );
    return Budget.fromJson(json);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _client.delete('${AppConstants.budgetsEndpoint}/$id');
  }
}
