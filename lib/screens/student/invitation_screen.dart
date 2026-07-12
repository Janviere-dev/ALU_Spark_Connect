import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/invitation/invitation_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/invitation_model.dart';
import '../../widgets/app_button.dart';

class InvitationScreen extends StatefulWidget {
  final String invitationId;
  const InvitationScreen({super.key, required this.invitationId});

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<InvitationCubit>().loadForStudent(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 18, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('ALU Connect',
            style:
                AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
      ),
      body: BlocConsumer<InvitationCubit, InvitationState>(
        listener: (context, state) {
          if (state is InvitationResponded) {
            final accepted =
                state.invitation.status == InvitationStatus.accepted;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(accepted
                    ? 'Invitation accepted! The startup will be in touch.'
                    : 'Invitation declined.'),
                backgroundColor:
                    accepted ? AppColors.statusAccepted : AppColors.error,
              ),
            );
            Navigator.pop(context);
          }
          if (state is InvitationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is InvitationLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          InvitationModel? invitation;
          if (state is InvitationsLoaded) {
            try {
              invitation = state.invitations
                  .firstWhere((i) => i.id == widget.invitationId);
            } catch (_) {}
          }

          if (invitation == null) {
            return Center(
              child: Text('Invitation not found.',
                  style: AppTextStyles.bodyMd),
            );
          }

          final inv = invitation;
          final isPending = inv.status == InvitationStatus.pending;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Header card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.inventory_2_outlined,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          inv.status == InvitationStatus.accepted
                              ? 'ACCEPTED'
                              : inv.status == InvitationStatus.declined
                                  ? 'DECLINED'
                                  : 'INVITATION',
                          style: AppTextStyles.labelSm
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(inv.startupName,
                          style: AppTextStyles.headlineMd
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 6),
                      Text(
                        "You've been invited to apply for the",
                        style: AppTextStyles.bodyMd.copyWith(
                            color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      RichText(
                        text: TextSpan(
                          text: inv.roleTitle,
                          style: AppTextStyles.labelLg
                              .copyWith(color: Colors.white),
                          children: [
                            TextSpan(
                              text: ' role.',
                              style: AppTextStyles.bodyMd.copyWith(
                                  color:
                                      Colors.white.withValues(alpha: 0.85)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _PillRow(
                          icon: Icons.schedule_outlined,
                          label: inv.timeAgo),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Message card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: AppColors.darkHeroGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Message from ${inv.startupName}',
                                  style: AppTextStyles.labelLg),
                              Text(
                                'Startup Founder',
                                style: AppTextStyles.labelMd.copyWith(
                                    color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '"${inv.message}"',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (isPending) ...[
                  AppButton(
                    label: 'Accept Invitation',
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.white, size: 18),
                    onPressed: () => context
                        .read<InvitationCubit>()
                        .accept(inv.id),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Decline',
                    isOutlined: true,
                    labelColor: AppColors.error,
                    icon: const Icon(Icons.cancel_outlined,
                        color: AppColors.error, size: 18),
                    onPressed: () => context
                        .read<InvitationCubit>()
                        .decline(inv.id),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: inv.status == InvitationStatus.accepted
                          ? AppColors.statusAccepted.withValues(alpha: 0.08)
                          : AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          inv.status == InvitationStatus.accepted
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: inv.status == InvitationStatus.accepted
                              ? AppColors.statusAccepted
                              : AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          inv.status == InvitationStatus.accepted
                              ? 'You accepted this invitation'
                              : 'You declined this invitation',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: inv.status == InvitationStatus.accepted
                                ? AppColors.statusAccepted
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PillRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PillRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(label,
              style: AppTextStyles.labelMd.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
