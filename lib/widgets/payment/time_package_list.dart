import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/currency_provider.dart';

import '../../models/time_package.dart';

class TimePackageList extends ConsumerWidget {
  final List<TimePackage> packages;
  final int? selectedPackageId;
  final Function(TimePackage) onSelected;
  final String currency;

  const TimePackageList({
    super.key,
    required this.packages,
    this.selectedPackageId,
    required this.onSelected,
    this.currency = 'USD',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyProvider);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: packages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final pkg = packages[index];
        final isSelected = selectedPackageId == pkg.id;
        return _PackageCard(
          package: pkg,
          isSelected: isSelected,
          onTap: () => onSelected(pkg),
          currencyState: currencyState,
        );
      },
    );
  }
}

class _PackageCard extends StatelessWidget {
  final TimePackage package;
  final bool isSelected;
  final VoidCallback onTap;
  final CurrencyState currencyState;

  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.onTap,
    required this.currencyState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),

        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.08)
            : theme.colorScheme.surface,

        gradient: isSelected
            ? LinearGradient(
                colors: [Colors.white.withOpacity(0.65), Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.onPrimary.withOpacity(0.25)
              : Colors.black.withOpacity(0.08),
          width: 1,
        ),

        // Outside shadow
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.25)
                : Colors.black.withOpacity(0.08),
            blurRadius: isSelected ? 18 : 10,
            spreadRadius: isSelected ? 1 : 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.7),
                          ]
                        : [Colors.grey.shade200, Colors.grey.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  package.isDailyPass
                      ? Icons.all_inclusive
                      : Icons.access_time_rounded,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          package.durationText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (package.isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.orange, Colors.deepOrange],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'POPULAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      package.isDailyPass
                          ? 'Unlimited viewing today'
                          : 'Watch ${package.durationSeconds ~/ 60} minutes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyState
                        .convertFromBase(package.price)
                        .toStringAsFixed(2),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                  if (!package.isDailyPass)
                    Text(
                      '${currencyState.convertFromBase(package.pricePerMinute).toStringAsFixed(2)}/min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
