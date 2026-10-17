import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/model/corporate_card.dart';

void main() {
  test('usage and available are derived from limit and spent', () {
    final card = CorporateCard.fromJson({
      'id': 1,
      'holder_name': 'Amina',
      'last4': '4821',
      'expiry': '09/28',
      'limit': 100000,
      'spent': 25000,
    });

    expect(card.usage, 0.25);
    expect(card.available, 75000.0);
    expect(card.isFrozen, isFalse);
  });

  test('usage is clamped and safe when the limit is zero', () {
    const over = CorporateCard(
      id: '1',
      holderName: 'A',
      last4: '1111',
      expiry: '01/30',
      limit: 100,
      spent: 500,
    );
    const none = CorporateCard(
      id: '2',
      holderName: 'B',
      last4: '2222',
      expiry: '01/30',
      limit: 0,
      spent: 0,
    );

    expect(over.usage, 1.0);
    expect(none.usage, 0.0);
  });
}
