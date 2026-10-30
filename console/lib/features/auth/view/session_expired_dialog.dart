import 'package:console/app_exporter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Over the screen where the service refused the token: signing in again
/// keeps it (an unsaved canvas too); the sign-in page closes the session
class SessionExpiredDialog extends StatefulWidget {
  const SessionExpiredDialog({super.key});

  /// Over the root navigator, without a way to close it but signing in
  static Future<void> open() => showGeneralDialog(
    context: app.context,
    barrierDismissible: false,
    barrierColor: app.colors.neutral.black.withValues(alpha: 0.72),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const SessionExpiredDialog(),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );

  @override
  State<SessionExpiredDialog> createState() => _SessionExpiredDialogState();
}

class _SessionExpiredDialogState extends State<SessionExpiredDialog> {
  final AuthCubit _auth = app.di.find<AuthCubit>();
  late final TextEditingController _userController = TextEditingController(
    text: _auth.username,
  );
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_submitted) setState(() => _submitted = true);
    if (_formKey.currentState?.validate() ?? false) {
      _auth.login(
        username: _userController.text,
        password: _passwordController.text,
      );
    }
  }

  void _toSignInPage() {
    Navigator.of(context).pop();
    _auth.logout();
  }

  String? _required(String? v) =>
      v?.isEmpty == true ? app.intl.common.required : null;

  @override
  Widget build(BuildContext context) {
    final t = app.intl.login;
    // the username is known after a login in this tab, not after a reload
    final knownUser = _auth.username != null;
    return BlocConsumer<AuthCubit, AuthState>(
      bloc: _auth,
      listener: (context, state) {
        if (state is AuthProcessingOKState) {
          TextInput.finishAutofillContext();
          Navigator.of(context).pop();
          // the rail's workspaces may have failed with the old token
          app.di.find<WorkspaceCubit>().load();
        }
      },
      builder: (context, state) {
        final loading = state is AuthProcessInProgressState;
        return Align(
          alignment: const Alignment(0, -0.4),
          child: Container(
            width: 420,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: app.colors.primary.background2,
              borderRadius: app.dimensions.border.borderRadius.m,
              border: Border.all(color: app.colors.primary.background3),
            ),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: app.colors.primary.primaryFaded.withValues(
                            alpha: 0.16,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 22,
                          color: app.colors.primary.primaryLight,
                        ),
                      ),
                    ),
                    16.gap(),
                    Text(
                      t.expiredTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 28 / 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    6.gap(),
                    Text(
                      t.expiredDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: app.colors.neutral.grey3,
                      ),
                    ),
                    if (state is AuthProcessingErrorState) ...[
                      16.gap(),
                      AppFormAlert(
                        title: state.exception.message,
                        message:
                            state.exception.type == GlobalExceptionType.auth
                            ? t.failedHint
                            : null,
                      ),
                    ],
                    16.gap(),
                    AppFormInput(
                      controller: _userController,
                      label: t.username,
                      hint: t.usernameHint,
                      enabled: !knownUser,
                      autofocus: !knownUser,
                      validator: _required,
                      autofillHints: const [AutofillHints.username],
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _signIn(),
                    ),
                    16.gap(),
                    AppFormPasswordInput(
                      controller: _passwordController,
                      label: t.password,
                      hint: t.passwordHint,
                      validator: _required,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _signIn(),
                    ),
                    16.gap(),
                    PrimaryButton.primary(
                      onPressed: _signIn,
                      isLoading: loading,
                      title: loading ? t.signingIn : t.button,
                      h: 46,
                    ),
                    8.gap(),
                    TextButton(
                      onPressed: loading ? null : _toSignInPage,
                      style: TextButton.styleFrom(
                        foregroundColor: app.colors.primary.primaryFaded,
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                      child: Text(t.toSignInPage),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
