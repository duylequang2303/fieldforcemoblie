import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/schedule_property.dart';

class SchedulePropertyDetailPage extends StatelessWidget {
  final ScheduleProperty property;

  const SchedulePropertyDetailPage({super.key, required this.property});

  // ── Action helpers ──────────────────────────────────────────────────────────

  Future<void> _call(BuildContext context) async {
    final phone = property.phone;
    if (phone == null || phone.isEmpty) {
      _snack(context, 'No phone number available');
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) _snack(context, 'Cannot open dialer');
    }
  }

  Future<void> _sms(BuildContext context) async {
    final phone = property.phone;
    if (phone == null || phone.isEmpty) {
      _snack(context, 'No phone number available');
      return;
    }
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) _snack(context, 'Cannot open SMS app');
    }
  }

  Future<void> _email(BuildContext context) async {
    final em = property.email;
    if (em == null || em.isEmpty) {
      _snack(context, 'No email address available');
      return;
    }
    final uri = Uri(scheme: 'mailto', path: em);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) _snack(context, 'Cannot open email app');
    }
  }

  Future<void> _maps(BuildContext context) async {
    final lat = property.lat;
    final lng = property.lng;
    if (lat == null || lng == null || (lat == 0 && lng == 0)) {
      _snack(context, 'No GPS coordinates available');
      return;
    }
    final label = Uri.encodeComponent(property.address);
    // Try Google Maps first, fallback to geo:
    final gmap = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(gmap)) {
      await launchUrl(gmap, mode: LaunchMode.externalApplication);
    } else {
      final geo = Uri(scheme: 'geo', path: '$lat,$lng', query: 'q=$lat,$lng($label)');
      if (await canLaunchUrl(geo)) {
        await launchUrl(geo);
      } else {
        if (context.mounted) _snack(context, 'Cannot open Maps');
      }
    }
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final p = property;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        title: Text(
          p.address,
          style: TextStyle(
            color: cs.onPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Address card ─────────────────────────────────────────────────
            Card(
              elevation: 0,
              color: cs.surfaceContainerHighest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: cs.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Location', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(p.address, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    if (p.suburb.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(p.suburb, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
                    ],
                    if (p.ownerName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Owner: ${p.ownerName}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
                    ],
                    if (p.lat != null && p.lng != null) ...[
                      const SizedBox(height: 4),
                      Text('${p.lat!.toStringAsFixed(5)}, ${p.lng!.toStringAsFixed(5)}',
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.4))),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Contact info ──────────────────────────────────────────────────
            if (p.phone != null || p.email != null) ...[
              Card(
                elevation: 0,
                color: cs.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.contacts_outlined, color: cs.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Contact', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      if (p.phone != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 16, color: cs.onSurface.withValues(alpha: 0.5)),
                            const SizedBox(width: 8),
                            Text(p.phone!, style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ],
                      if (p.email != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 16, color: cs.onSurface.withValues(alpha: 0.5)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(p.email!, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── 4 Action buttons ──────────────────────────────────────────────
            Row(
              children: [
                _ActionBtn(
                  icon: Icons.phone,
                  label: 'Call',
                  enabled: p.phone != null,
                  onTap: () => _call(context),
                  color: cs.primary,
                ),
                const SizedBox(width: 12),
                _ActionBtn(
                  icon: Icons.sms_outlined,
                  label: 'SMS',
                  enabled: p.phone != null,
                  onTap: () => _sms(context),
                  color: cs.primary,
                ),
                const SizedBox(width: 12),
                _ActionBtn(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  enabled: p.email != null,
                  onTap: () => _email(context),
                  color: cs.primary,
                ),
                const SizedBox(width: 12),
                _ActionBtn(
                  icon: Icons.navigation_outlined,
                  label: 'Maps',
                  enabled: p.lat != null && p.lng != null,
                  onTap: () => _maps(context),
                  color: cs.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Reusable action button ────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final Color color;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final effectiveColor = enabled ? color : cs.onSurface.withValues(alpha: 0.3);

    return Expanded(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: enabled ? color.withValues(alpha: 0.1) : cs.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? color.withValues(alpha: 0.3) : cs.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: effectiveColor, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: effectiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}