import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/state_views.dart';
import '../model/corporate_card.dart';
import '../view_model/providers.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(cardsViewModelProvider);

    Widget body;
    if (vm.isLoading && vm.cards.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.error != null && vm.cards.isEmpty) {
      body = ErrorState(message: vm.error!, onRetry: vm.load);
    } else if (vm.cards.isEmpty) {
      body = const EmptyState(
        icon: Icons.credit_card_off_outlined,
        title: 'No cards yet',
        message: 'Corporate cards issued to you will appear here.',
      );
    } else {
      body = RefreshIndicator(
        onRefresh: vm.load,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          itemCount: vm.cards.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final card = vm.cards[index];
            return _CardView(
              card: card,
              onFrozenChanged: (frozen) =>
                  vm.setFrozen(card.id, frozen: frozen),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cards')),
      body: body,
    );
  }
}

class _CardView extends StatelessWidget {
  const _CardView({required this.card, required this.onFrozenChanged});

  final CorporateCard card;
  final ValueChanged<bool> onFrozenChanged;

  @override
  Widget build(BuildContext context) {
    final frozen = card.isFrozen;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: frozen
                  ? const [Color(0xFF64748B), Color(0xFF94A3B8)]
                  : const [Color(0xFF142B4A), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'SpendWise Corporate',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (frozen)
                    const Icon(
                      Icons.ac_unit_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                '••••  ••••  ••••  ${card.last4}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.holderName,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Text(
                    card.expiry,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
            border: Border(
              left: BorderSide(color: AppColors.border),
              right: BorderSide(color: AppColors.border),
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: card.usage,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE8EEF7),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${formatMoney(card.spent)} of ${formatMoney(card.limit)}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${formatMoney(card.available)} available',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Freeze card'),
                  subtitle: Text(
                    frozen ? 'Card is frozen' : 'Card is active',
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: frozen,
                  onChanged: onFrozenChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
