import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui_kit/glass_container.dart';
import '../../../../core/ui_kit/tactile_feedback.dart';
import '../../data/security_service.dart';

class NoteSecurityModal extends StatefulWidget {
  final String noteTitle;
  final VoidCallback onAuthenticated;

  const NoteSecurityModal({
    super.key,
    required this.noteTitle,
    required this.onAuthenticated,
  });

  static void show(
    BuildContext context, {
    required String noteTitle,
    required VoidCallback onAuthenticated,
  }) {
    TactileFeedback.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NoteSecurityModal(
        noteTitle: noteTitle,
        onAuthenticated: onAuthenticated,
      ),
    );
  }

  @override
  State<NoteSecurityModal> createState() => _NoteSecurityModalState();
}

class _NoteSecurityModalState extends State<NoteSecurityModal> with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _pulseAnim;
  bool _isError = false;
  String _errorMessage = '';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin(String input) async {
    final isValid = await SecurityService.verifyPin(input);
    if (!mounted) return;
    if (isValid) {
      TactileFeedback.success();
      Navigator.pop(context);
      widget.onAuthenticated();
    } else {
      TactileFeedback.heavy();
      setState(() {
        _isError = true;
        _errorMessage = 'Incorrect PIN (Default: 1234)';
      });
      _pinController.clear();
    }
  }

  Future<void> _triggerBiometric() async {
    if (_isAuthenticating) return;
    TactileFeedback.medium();
    setState(() {
      _isAuthenticating = true;
      _isError = false;
    });

    final success = await SecurityService.authenticateBiometrics();
    if (!mounted) return;
    setState(() => _isAuthenticating = false);

    if (success) {
      TactileFeedback.success();
      Navigator.pop(context);
      widget.onAuthenticated();
    } else {
      TactileFeedback.heavy();
      setState(() {
        _isError = true;
        _errorMessage = 'Biometric verification failed';
      });
    }
  }

  void _showChangePinDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Security PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current PIN', hintText: 'Default 1234'),
            ),
            TextField(
              controller: newCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New 4-Digit PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (await SecurityService.verifyPin(oldCtrl.text) && newCtrl.text.length == 4) {
                await SecurityService.setPin(newCtrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN updated successfully')));
                }
              } else {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Invalid current PIN or format')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: onSurfaceVar.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
            ),
            ScaleTransition(
              scale: _pulseAnim,
              child: GestureDetector(
                onTap: _triggerBiometric,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primary.withValues(alpha: 0.25), primary.withValues(alpha: 0.08)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: primary.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: Icon(Icons.fingerprint_rounded, size: 48, color: primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Security Lock', style: AppTypography.title(onSurface, size: 18, weight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              widget.noteTitle.isEmpty ? 'Private Note' : widget.noteTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(primary, size: 13, weight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Touch sensor or enter your 4-digit PIN', textAlign: TextAlign.center, style: AppTypography.caption(onSurfaceVar, size: 11)),
            const SizedBox(height: 20),
            SizedBox(
              width: 180,
              child: TextField(
                controller: _pinController,
                autofocus: false,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, letterSpacing: 12, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: TextStyle(fontSize: 22, letterSpacing: 12, color: onSurfaceVar.withValues(alpha: 0.4)),
                  filled: true,
                  fillColor: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: onSurfaceVar.withValues(alpha: 0.2))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primary, width: 1.5)),
                ),
                onChanged: (val) {
                  if (val.length == 4) _verifyPin(val);
                },
              ),
            ),
            if (_isError) ...[
              const SizedBox(height: 8),
              Text(_errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _triggerBiometric,
                  icon: const Icon(Icons.fingerprint, size: 18),
                  label: const Text('Unlock with Biometrics'),
                  style: TextButton.styleFrom(foregroundColor: primary),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _showChangePinDialog,
                  icon: const Icon(Icons.password, size: 16),
                  label: const Text('Change PIN'),
                  style: TextButton.styleFrom(foregroundColor: onSurfaceVar),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
