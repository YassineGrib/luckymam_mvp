import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../models/assistant_models.dart';

/// Interactive card view rendering recommendation cards in chat bubbles.
class AssistantCardView extends StatelessWidget {
  const AssistantCardView({
    super.key,
    required this.card,
    this.onAction,
  });

  final AssistantCard card;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    final bgCard = isDark ? const Color(0xFF282332) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.primaryLight.withValues(alpha: 0.25);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFFD6C8E6).withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: switch (card) {
        final ProductCard c => _buildProductCard(context, c, isDark, l10n),
        final AppointmentCard c => _buildAppointmentCard(context, c, isDark, l10n),
        final AlbumCard c => _buildAlbumCard(context, c, isDark, l10n),
        final SubscriptionCard c => _buildSubscriptionCard(context, c, isDark, l10n),
        final WeatherCard c => _buildWeatherCard(context, c, isDark, l10n),
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductCard c,
    bool isDark,
    dynamic l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.primaryLight,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1D1B20),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${c.priceDZD} DZD',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (c.why.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            c.why,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: isDark ? Colors.white70 : const Color(0xFF5A5364),
            ),
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              onAction?.call();
              context.pushNamed('marketplace');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.assistantCardProductCta,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    AppointmentCard c,
    bool isDark,
    dynamic l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: Color(0xFF0D9488),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1D1B20),
                    ),
                  ),
                  if (c.childAlias != null)
                    Text(
                      c.childAlias!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (c.reason.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            c.reason,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: isDark ? Colors.white70 : const Color(0xFF5A5364),
            ),
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              onAction?.call();
              context.pushNamed('health');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0D9488),
              side: const BorderSide(color: Color(0xFF0D9488)),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.assistantCardAppointmentCta,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumCard(
    BuildContext context,
    AlbumCard c,
    bool isDark,
    dynamic l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Color(0xFFEC4899),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                c.title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1D1B20),
                ),
              ),
            ),
          ],
        ),
        if (c.reason.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            c.reason,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: isDark ? Colors.white70 : const Color(0xFF5A5364),
            ),
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              onAction?.call();
              context.pushNamed('album-templates');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC4899),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.assistantCardAlbumCta,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    SubscriptionCard c,
    bool isDark,
    dynamic l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFFF59E0B),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'LuckyMam ${c.tier.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
          ],
        ),
        if (c.benefit.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            c.benefit,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: isDark ? Colors.white70 : const Color(0xFF5A5364),
            ),
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              onAction?.call();
              context.pushNamed('subscription');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.assistantCardSubscriptionCta,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard(
    BuildContext context,
    WeatherCard c,
    bool isDark,
    dynamic l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.wb_sunny_rounded,
                color: Color(0xFF0284C7),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.assistantCardWeatherTitle,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1D1B20),
                    ),
                  ),
                  Text(
                    '${c.tempC.round()}°C',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          c.summary,
          style: TextStyle(
            fontSize: 12,
            height: 1.3,
            color: isDark ? Colors.white70 : const Color(0xFF5A5364),
          ),
        ),
        if (c.outingIdea.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '💡 ${c.outingIdea}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0284C7),
            ),
          ),
        ],
      ],
    );
  }
}
