import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/application/application_cubit.dart';
import '../../blocs/application/application_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/opportunity_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class ApplyScreen extends StatefulWidget {
  final OpportunityModel opportunity;
  const ApplyScreen({super.key, required this.opportunity});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pitchCtrl = TextEditingController();
  String? _cvFileName;
  String? _cvPath;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _nameCtrl.text = authState.user.fullName;
      _emailCtrl.text = authState.user.email;
    }
    _pitchCtrl.addListener(_onPitchChanged);
  }

  void _onPitchChanged() {
    final words = _pitchCtrl.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    setState(() => _wordCount = words);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pitchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() {
        _cvFileName = result.files.single.name;
        _cvPath = result.files.single.path;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    if (_wordCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write why you\'re interested in this role.')),
      );
      return;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    context.read<ApplicationCubit>().submit(
          student: authState.user,
          opportunityId: widget.opportunity.id,
          roleTitle: widget.opportunity.roleTitle,
          startupName: widget.opportunity.startupName,
          pitch: _pitchCtrl.text.trim(),
          cvPath: _cvPath,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Apply', style: AppTextStyles.headlineSm),
      ),
      body: BlocListener<ApplicationCubit, ApplicationState>(
        listener: (context, state) {
          if (state is ApplicationSubmitSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text('Application Submitted!', style: AppTextStyles.headlineMd),
                    const SizedBox(height: 8),
                    Text(
                      'Your application for ${widget.opportunity.roleTitle} at ${widget.opportunity.startupName} has been sent.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'View Applications',
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/student/home',
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ApplicationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.work_outline, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.opportunity.roleTitle,
                              style: AppTextStyles.labelLg.copyWith(color: Colors.white),
                            ),
                            Text(
                              widget.opportunity.startupName,
                              style: AppTextStyles.bodyMd.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Full Name',
                  hint: 'Your full name',
                  controller: _nameCtrl,
                  readOnly: true,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  hint: 'your@alustudent.com',
                  controller: _emailCtrl,
                  readOnly: true,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Why are you interested?', style: AppTextStyles.labelLg),
                    Text(
                      '$_wordCount / ${AppConstants.maxApplicationWords} words',
                      style: AppTextStyles.labelMd.copyWith(
                        color: _wordCount > AppConstants.maxApplicationWords
                            ? AppColors.error
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pitchCtrl,
                  maxLines: 6,
                  style: AppTextStyles.bodyMd,
                  decoration: InputDecoration(
                    hintText: 'In 150 words or less, tell us why you\'re the right fit for this role and what excites you about this opportunity...',
                    hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please share why you\'re interested';
                    if (_wordCount > AppConstants.maxApplicationWords) {
                      return 'Please keep it under ${AppConstants.maxApplicationWords} words';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text('Upload CV', style: AppTextStyles.labelLg),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickCV,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _cvFileName != null ? AppColors.primary : AppColors.outlineVariant,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _cvFileName != null ? Icons.check_circle : Icons.upload_file_outlined,
                          color: _cvFileName != null ? AppColors.primary : AppColors.outline,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _cvFileName ?? 'Tap to upload PDF, DOC',
                          style: AppTextStyles.labelLg.copyWith(
                            color: _cvFileName != null ? AppColors.primary : AppColors.outline,
                          ),
                        ),
                        if (_cvFileName == null)
                          Text(
                            'Optional — helps startups learn more about you',
                            style: AppTextStyles.labelMd.copyWith(color: AppColors.outline),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<ApplicationCubit, ApplicationState>(
                  builder: (context, state) => AppButton(
                    label: 'Submit Application',
                    isLoading: state is ApplicationLoading,
                    icon: const Icon(Icons.send_outlined, color: Colors.white, size: 18),
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
