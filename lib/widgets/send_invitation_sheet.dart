import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/invitation/invitation_cubit.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/mock/mock_data.dart';
import '../data/models/opportunity_model.dart';
import '../data/models/user_model.dart';
import 'app_button.dart';

class SendInvitationSheet extends StatefulWidget {
  final UserModel student;
  final String startupId;
  final String startupName;

  const SendInvitationSheet({
    super.key,
    required this.student,
    required this.startupId,
    required this.startupName,
  });

  @override
  State<SendInvitationSheet> createState() => _SendInvitationSheetState();
}

class _SendInvitationSheetState extends State<SendInvitationSheet> {
  final _messageCtrl = TextEditingController();
  OpportunityModel? _selectedOpportunity;
  List<OpportunityModel> _opportunities = [];

  @override
  void initState() {
    super.initState();
    _opportunities =
        MockDB().getOpportunitiesForStartup(widget.startupId);
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final opp = _selectedOpportunity;
    if (opp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role.')),
      );
      return;
    }
    if (_messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a personal message.')),
      );
      return;
    }
    context.read<InvitationCubit>().send(
          startupId: widget.startupId,
          startupName: widget.startupName,
          studentId: widget.student.id,
          studentName: widget.student.fullName,
          opportunityId: opp.id,
          roleTitle: opp.roleTitle,
          message: _messageCtrl.text.trim(),
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Invitation sent to ${widget.student.fullName}!'),
        backgroundColor: AppColors.statusAccepted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.student.initials,
                      style: AppTextStyles.labelLg
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invite to Apply', style: AppTextStyles.headlineSm),
                    Text(
                      widget.student.fullName,
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Select Role', style: AppTextStyles.labelLg),
            const SizedBox(height: 8),
            if (_opportunities.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No active roles. Post an opportunity first.',
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              )
            else
              ...(_opportunities.map((opp) {
                final selected = _selectedOpportunity?.id == opp.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedOpportunity = opp),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(opp.roleTitle,
                                  style: AppTextStyles.labelLg),
                              Text(
                                opp.category,
                                style: AppTextStyles.labelMd.copyWith(
                                    color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle,
                              color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                );
              })),
            const SizedBox(height: 16),
            Text('Personal Message', style: AppTextStyles.labelLg),
            const SizedBox(height: 8),
            TextField(
              controller: _messageCtrl,
              maxLines: 3,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText:
                    'Introduce yourself and explain why you\'re reaching out...',
                hintStyle: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.outline),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Send Invitation',
              icon: const Icon(Icons.send_outlined,
                  color: Colors.white, size: 18),
              onPressed: _opportunities.isEmpty ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}
