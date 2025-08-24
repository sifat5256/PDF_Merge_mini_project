import 'dart:ui';
import 'package:flutter/material.dart';


class FancyBusinessCardScreen extends StatelessWidget {
  const FancyBusinessCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Decorative gradient background
          const _BackgroundDecor(),
          // Scroll in case tiny screens
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _GlassCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar + name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [scheme.primary, scheme.tertiary],
                                ),
                              ),
                              padding: const EdgeInsets.all(3),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: scheme.surface,
                                child: Text(
                                  'IH', // initials placeholder
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Iqramul Hasan',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Flutter Developer • Priyojon Care',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Divider with gradient dots
                        const _FancyDivider(),

                        const SizedBox(height: 12),

                        // Contact rows
                        _InfoRow(
                          icon: Icons.phone_rounded,
                          label: '+880 1X XXX XXXX',
                          onTap: () {},
                        ),
                        _InfoRow(
                          icon: Icons.email_rounded,
                          label: 'hello@priyojon.care',
                          onTap: () {},
                        ),
                        _InfoRow(
                          icon: Icons.public_rounded,
                          label: 'priyojon.care',
                          onTap: () {},
                        ),
                        _InfoRow(
                          icon: Icons.location_on_rounded,
                          label: 'Dhaka, Bangladesh',
                          onTap: () {},
                        ),

                        const SizedBox(height: 10),

                        // QR + tagline
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: scheme.primary.withOpacity(0.25)),
                          ),
                          child: Row(
                            children: [
                              // Placeholder mini-QR (use qr_flutter for real QR)
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(colors: [scheme.primary, scheme.secondary]),
                                ),
                                child: const Center(
                                  child: Icon(Icons.qr_code_2_rounded, size: 36),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scan to save my contact',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap any item to copy or open. Share digitally—save paper!',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.call_rounded,
                                label: 'Call',
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.share_rounded,
                                label: 'Share',
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundDecor extends StatelessWidget {
  const _BackgroundDecor();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return CustomPaint(
      painter: _WavesPainter(scheme: scheme),
      child: Container(),
    );
  }
}

class _WavesPainter extends CustomPainter {
  final ColorScheme scheme;
  _WavesPainter({required this.scheme});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background gradient fill
    final rect = Offset.zero & size;
    final paintBg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          scheme.primaryContainer.withOpacity(0.35),
          scheme.secondaryContainer.withOpacity(0.25),
          scheme.surfaceVariant.withOpacity(0.2),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paintBg);

    // Soft wave shapes
    final paint1 = Paint()..color = scheme.primary.withOpacity(0.18);
    final path1 = Path()
      ..moveTo(0, h * 0.15)
      ..quadraticBezierTo(w * 0.25, h * 0.05, w * 0.5, h * 0.18)
      ..quadraticBezierTo(w * 0.8, h * 0.33, w, h * 0.22)
      ..lineTo(w, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path1, paint1);

    final paint2 = Paint()..color = scheme.secondary.withOpacity(0.14);
    final path2 = Path()
      ..moveTo(0, h)
      ..quadraticBezierTo(w * 0.3, h * 0.8, w * 0.55, h * 0.92)
      ..quadraticBezierTo(w * 0.85, h * 1.06, w, h * 0.88)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.onSurface.withOpacity(0.08)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.55),
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.02)
                    : Colors.white.withOpacity(0.35),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(0.15),
                blurRadius: 22,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _InfoRow({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: scheme.surface.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.06 : 0.7),
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(colors: [scheme.primary, scheme.secondary]),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.copy_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [scheme.primary, scheme.tertiary]),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FancyDivider extends StatelessWidget {
  const _FancyDivider();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Divider(color: scheme.outlineVariant.withOpacity(0.4), thickness: 1)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [scheme.primary, scheme.secondary]),
          ),
        ),
        Expanded(child: Divider(color: scheme.outlineVariant.withOpacity(0.4), thickness: 1)),
      ],
    );
  }
}