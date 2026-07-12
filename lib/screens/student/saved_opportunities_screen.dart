import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/opportunity_model.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../../widgets/app_header.dart';
import '../../widgets/opportunity_card.dart';

class SavedOpportunitiesScreen extends StatefulWidget {
  const SavedOpportunitiesScreen({super.key});

  @override
  State<SavedOpportunitiesScreen> createState() =>
      _SavedOpportunitiesScreenState();
}

class _SavedOpportunitiesScreenState extends State<SavedOpportunitiesScreen> {
  List<OpportunityModel>? _opportunities;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final bmState = context.read<BookmarkCubit>().state;
    final ids = bmState is BookmarkLoaded
        ? List<String>.from(bmState.savedOpportunityIds)
        : <String>[];
    if (ids.isEmpty) {
      setState(() {
        _opportunities = [];
        _loading = false;
      });
      return;
    }
    try {
      final opps = await context
          .read<BookmarkRepository>()
          .getSavedOpportunities(ids);
      if (mounted) {
        setState(() {
          _opportunities = opps;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ALUAppBar(
        showBack: true,
        title: 'ALU Connect',
        userInitials: authState is AuthAuthenticated
            ? authState.user.initials
            : 'U',
      ),
      body: BlocListener<BookmarkCubit, BookmarkState>(
        listener: (context, state) => _fetch(),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Text(_error!,
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.onSurfaceVariant)),
      );
    }
    final opps = _opportunities ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saved Opportunities', style: AppTextStyles.headlineLg),
              const SizedBox(height: 4),
              Text(
                '${opps.length} bookmarked role${opps.length == 1 ? '' : 's'}',
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (opps.isEmpty)
          Expanded(child: _EmptyState())
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              itemCount: opps.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final opp = opps[i];
                return Stack(
                  children: [
                    OpportunityCard(
                      opportunity: opp,
                      onTap: () => Navigator.pushNamed(
                          context, '/student/opportunity/${opp.id}'),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is AuthAuthenticated) {
                            context
                                .read<BookmarkCubit>()
                                .toggleOpportunity(authState.user.id, opp.id);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bookmark_rounded,
                              color: AppColors.primary, size: 18),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_outline_rounded,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text('No saved opportunities', style: AppTextStyles.headlineSm),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on any opportunity\nto save it here for later.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
