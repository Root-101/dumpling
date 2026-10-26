import 'package:console/app_exporter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class LoginScreenNavigator {
  String get name => RouteNames.login;

  String get path => '/login';

  Widget builder(BuildContext context, GoRouterState state) {
    return const LoginScreen();
  }
}

/// The only user comes from the env (`DUMPLING_ADMIN_USER`,
/// `DUMPLING_ADMIN_PASSWORD`): there is no sign up or password recovery
class LoginScreen extends StatefulWidget {
  static final LoginScreenNavigator navigator = LoginScreenNavigator();

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// After the first submit attempt it validates on every change, so an error
  /// goes away as soon as the field is filled
  bool _submitted = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_submitted) setState(() => _submitted = true);
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        username: _userController.text,
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // On success the router leaves the login by itself (it listens to
        // AuthCubit), to the page asked for before logging in. Closing the
        // autofill context first lets the browser offer to save the password
        if (state is AuthProcessingOKState) {
          TextInput.finishAutofillContext();
        }
      },
      child: Scaffold(
        backgroundColor: app.colors.primary.background1,
        // Scaffold gives its body loose constraints: the dots cover it all
        body: SizedBox.expand(
          child: CustomPaint(
            painter: GridDotPainter(
              offset: Offset.zero,
              scale: 1,
              color: app.colors.neutral.white.withValues(alpha: 0.11),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(app.dimensions.padding.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const DumplingWordmark(height: 40),
                        app.dimensions.padding.xxl.gap(),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: _buildPanel(),
                        ),
                        app.dimensions.padding.xxl.gap(),
                        Text(
                          app.intl.app.version(version: AppGlobal.version),
                          style: TextStyle(
                            fontSize: 12,
                            color: app.colors.neutral.grey4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: app.dimensions.padding.xxl,
                  right: app.dimensions.padding.xxl,
                  child: const LanguageWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: app.colors.primary.background2,
        borderRadius: app.dimensions.border.borderRadius.m,
        border: Border.all(color: app.colors.primary.background3),
      ),
      // The password goes to the browser's password manager (it offers to
      // save it and fills it in), never to the console's own storage
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final loading = state is AuthProcessInProgressState;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    app.intl.login.title,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  app.dimensions.padding.xs.gap(),
                  Text(
                    app.intl.login.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: app.colors.neutral.grey4,
                    ),
                  ),
                  if (state is AuthProcessingErrorState) ...[
                    18.gap(),
                    AppFormAlert(
                      title: state.exception.message,
                      message: state.exception.type == GlobalExceptionType.auth
                          ? app.intl.login.failedHint
                          : null,
                    ),
                  ],
                  18.gap(),
                  AppFormInput(
                    controller: _userController,
                    label: app.intl.login.username,
                    hint: app.intl.login.usernameHint,
                    autofocus: true,
                    validator: (v) =>
                        v?.isEmpty == true ? app.intl.common.required : null,
                    autofillHints: const [AutofillHints.username],
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _onLogin(),
                  ),
                  18.gap(),
                  AppFormPasswordInput(
                    controller: _passwordController,
                    label: app.intl.login.password,
                    hint: app.intl.login.passwordHint,
                    validator: (v) =>
                        v?.isEmpty == true ? app.intl.common.required : null,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _onLogin(),
                  ),
                  18.gap(),
                  PrimaryButton.primary(
                    onPressed: _onLogin,
                    isLoading: loading,
                    title: loading
                        ? app.intl.login.signingIn
                        : app.intl.login.button,
                    h: 48,
                  ),
                  18.gap(),
                  const _EnvHint(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Where the user comes from: the names of the variables in monospace
class _EnvHint extends StatelessWidget {
  static const _user = 'DUMPLING_ADMIN_USER';
  static const _password = 'DUMPLING_ADMIN_PASSWORD';

  const _EnvHint();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 12,
      height: 18 / 12,
      color: app.colors.neutral.grey4,
    );
    final mono = AppText.mono.copyWith(
      fontSize: 12,
      height: 18 / 12,
      color: app.colors.neutral.grey2,
    );
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: '${app.intl.login.envHint} '),
          TextSpan(text: _user, style: mono),
          TextSpan(text: ' ${app.intl.login.envHintAnd} '),
          TextSpan(text: _password, style: mono),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
