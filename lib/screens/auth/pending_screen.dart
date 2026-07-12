import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PendingScreen extends StatefulWidget {
  const PendingScreen({super.key});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _statusStream;
  String? _userId;
  String? _rejectionReason;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _userId = authState.user.id;
      _statusStream = FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .snapshots();
    }
  }

  void _onStatusChange(String status, String? reason) {
    if (status == 'approved') {
      Navigator.pushReplacementNamed(context, '/onboarding/startup');
    } else if (status == 'rejected') {
      setState(() => _rejectionReason = reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _statusStream == null
            ? _buildContent(context, null)
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _statusStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data()!;
                    final status = data['status'] as String?;
                    if (status == 'approved') {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _onStatusChange('approved', null);
                      });
                    } else if (status == 'rejected' &&
                        _rejectionReason == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _onStatusChange(
                              'rejected', data['rejectionReason'] as String?);
                        }
                      });
                    }
                  }
                  return _buildContent(context, _rejectionReason);
                },
              ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, String? rejectionReason) {
    final isRejected = rejectionReason != null;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: isRejected
                  ? const LinearGradient(
                      colors: [AppColors.error, Color(0xFFFF6B6B)])
                  : AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRejected
                  ? Icons.cancel_outlined
                  : Icons.hourglass_top_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isRejected ? 'Verification Unsuccessful' : 'Verification Pending',
            style: AppTextStyles.headlineLg,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (isRejected) ...[
            Text(
              'ALU Career Development reviewed your submission but could not verify your startup at this time.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reason',
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.error)),
                  const SizedBox(height: 6),
                  Text(rejectionReason,
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.onSurface)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'If you believe this is a mistake, you can resubmit with updated documents.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Text(
              'Thank you! Your details have been sent to our team for verification.',
              style: AppTextStyles.bodyLg
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We will review your ALU startup status and activate your account within 24 hours. This page updates automatically when approved.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Once approved, this screen advances automatically — no need to refresh.',
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),
          TextButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
              Navigator.pushNamedAndRemoveUntil(
                  context, '/sign-in', (route) => false);
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sign out'),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
