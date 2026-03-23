import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

class ReflectScreen extends StatefulWidget {
  const ReflectScreen({super.key});

  @override
  State<ReflectScreen> createState() => _ReflectScreenState();
}

class _ReflectScreenState extends State<ReflectScreen> {
  final _gratitude1 = TextEditingController();
  final _gratitude2 = TextEditingController();
  final _gratitude3 = TextEditingController();
  final _reflection = TextEditingController();
  final _intention = TextEditingController();
  bool _saved = false;

  @override
  void dispose() {
    _gratitude1.dispose();
    _gratitude2.dispose();
    _gratitude3.dispose();
    _reflection.dispose();
    _intention.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'The Sacred Interval',
              style: GoogleFonts.playfairDisplay(
                fontSize: 17,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            centerTitle: true,
          ),

          // Hero image header
          SliverToBoxAdapter(
            child: _HeroHeader(today: today, isDark: isDark),
          ),

          // Gratitude section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.add, size: 16, color: textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Gratitude',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _JournalField(
                    controller: _gratitude1,
                    hint: 'I am grateful for...',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _JournalField(
                    controller: _gratitude2,
                    hint: 'Something small that brought joy...',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _JournalField(
                    controller: _gratitude3,
                    hint: 'A person I appreciate...',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // Divider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Divider(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                thickness: 0.5,
              ),
            ),
          ),

          // Reflections section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 16, color: textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Reflections',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _JournalField(
                controller: _reflection,
                hint:
                    'What moved you today? Where did you find peace?',
                isDark: isDark,
                minLines: 4,
                maxLines: 8,
              ),
            ),
          ),

          // Divider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Divider(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                thickness: 0.5,
              ),
            ),
          ),

          // Intentions section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.star_outline, size: 16, color: textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Intentions for Tomorrow',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _JournalField(
                controller: _intention,
                hint: 'One word to guide your next journey...',
                isDark: isDark,
              ),
            ),
          ),

          // Save button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: _SaveButton(saved: _saved, isDark: isDark, onTap: _save),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─── Hero Header ─────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.today, required this.isDark});
  final String today;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A2F28),
                  const Color(0xFF0D1F1A),
                ]
              : [
                  const Color(0xFF3D7A6F),
                  const Color(0xFF2A5A52),
                ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'TODAY IS',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            today,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Journal Field ───────────────────────────────────────────────────────────

class _JournalField extends StatelessWidget {
  const _JournalField({
    required this.controller,
    required this.hint,
    required this.isDark,
    this.minLines = 1,
    this.maxLines = 3,
  });

  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final fillColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final hintColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: hintColor.withOpacity(0.6),
        ),
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Save Button ─────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.saved,
    required this.isDark,
    required this.onTap,
  });

  final bool saved;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor =
        isDark ? AppColors.primaryLight : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: saved ? const Color(0xFF2D7A6F) : activeColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            saved ? '✓  REFLECTION SAVED' : 'SAVE REFLECTION',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
