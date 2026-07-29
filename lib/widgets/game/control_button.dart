import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;
  final String? badgeText;
  final Color? badgeColor;

  const ControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active ? AppColors.primary : Colors.grey.shade300,
                      width: active ? 1.6 : 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: disabled
                        ? Colors.grey.shade300
                        : (active ? AppColors.primary : Colors.black54),
                  ),
                ),
                if (badgeText != null)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.4),
                      ),
                      child: Text(
                        badgeText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: disabled ? Colors.grey.shade300 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
