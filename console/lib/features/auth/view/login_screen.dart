import 'package:console/app_exporter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  /// Id of the [LoadingOverlay] over the form's side, not the whole screen
  static const String _loadingId = 'login';

  void _onLogin() {
    // Enter in a field still reaches here under the overlay
    if (context.read<AuthCubit>().state is AuthProcessInProgressState) return;
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
        if (state is AuthProcessInProgressState) {
          app.loading.show(id: _loadingId);
        } else {
          app.loading.hide(id: _loadingId);
        }
      },
      child: Scaffold(
        backgroundColor: app.colors.primary.background1,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 900;
            return Stack(
              fit: StackFit.expand,
              children: [
                if (narrow)
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Identity(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 40,
                          ),
                          tags: false,
                        ),
                        _withLoading(_buildForm()),
                      ],
                    ),
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _Identity(
                          // 8% of its column, as on the canvas
                          padding: EdgeInsets.symmetric(
                            horizontal: constraints.maxWidth * 5 / 9 * 0.08,
                            vertical: 64,
                          ),
                          tags: true,
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: app.colors.surface.control,
                              ),
                            ),
                          ),
                          child: _withLoading(
                            Center(
                              child: SingleChildScrollView(child: _buildForm()),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                Positioned(
                  top: app.dimensions.padding.xxl,
                  right: app.dimensions.padding.xxl,
                  child: const LanguageWidget(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// The blur and spinner of the sign-in, only over the form's side
  Widget _withLoading(Widget child) => LoadingOverlay(
    id: _loadingId,
    overlayWidgetBuilder: LoadingOverlayStyles.form,
    child: child,
  );

  /// The panel with the version under it
  Widget _buildForm() {
    return Padding(
      padding: EdgeInsets.all(app.dimensions.padding.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _buildPanel(),
          ),
          app.dimensions.padding.xxl.gap(),
          Text(
            app.intl.app.version(version: AppGlobal.version),
            style: TextStyle(fontSize: 12, color: app.colors.neutral.grey4),
          ),
        ],
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
                    title: app.intl.login.button,
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

/// Left of the login: the mark, the name with its tagline and what dumpling
/// is, over a faint grid
class _Identity extends StatelessWidget {
  final EdgeInsets padding;
  final bool tags;

  const _Identity({required this.padding, required this.tags});

  @override
  Widget build(BuildContext context) {
    final glow = app.colors.brand.primaryDeep;
    return CustomPaint(
      painter: GridLinePainter(
        color: app.colors.primary.primaryFaded.withValues(alpha: 0.05),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const DumplingLogo(height: 127),
                  34.gap(),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // the violet glow behind "dump"
                      Positioned(
                        left: 89 - 108,
                        top: 46 - 108,
                        width: 216,
                        height: 216,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                glow.withValues(alpha: 0.30),
                                glow.withValues(alpha: 0),
                              ],
                              stops: const [0, 0.65],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            app.assets.name,
                            width: 296.4,
                            height: 79.2,
                            semanticsLabel: 'Dumpling',
                          ),
                          12.gap(),
                          Padding(
                            padding: const EdgeInsets.only(left: 1),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: '${app.intl.login.tagline} '),
                                  TextSpan(
                                    text: app.intl.login.taglineAccent,
                                    style: TextStyle(
                                      color: app.colors.primary.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 32,
                                height: 1,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.6,
                                color: app.colors.text.brand,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (tags) ...[
              32.gap(),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Tag(
                      label: app.intl.login.tagLightweight,
                      color: app.colors.primary.secondary,
                    ),
                    _Tag(
                      label: app.intl.login.tagCanvas,
                      color: app.colors.primary.primaryFaded,
                    ),
                    _Tag(
                      label: app.intl.login.tagWinter,
                      color: app.colors.primary.primaryFaded,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: app.colors.surface.surface1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: app.colors.surface.control),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          8.gap(),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: app.colors.text.brand,
            ),
          ),
        ],
      ),
    );
  }
}
