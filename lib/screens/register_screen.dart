import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/page_transition.dart';
import '../widgets/custom_snackbar.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _rememberUser = false;

  late final AnimationController _mainAnimationController;
  late final AnimationController _glowAnimationController;

  late final Animation<double> _formAnimation;
  late final Animation<double> _stockcitoAnimation;
  late final Animation<double> _logoAnimation;
  late final Animation<double> _ampersandAnimation;

  @override
  void initState() {
    super.initState();
    _mainAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _stockcitoAnimation = _createAnimation(0.0, 0.5);
    _logoAnimation = _createAnimation(0.2, 0.7);
    _ampersandAnimation = _createAnimation(0.4, 0.9);
    _formAnimation = _createAnimation(0.5, 1.0);

    _mainAnimationController.forward();
  }

  Animation<double> _createAnimation(double begin, double end) {
    return CurvedAnimation(
      parent: _mainAnimationController,
      curve: Interval(begin, end, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _glowAnimationController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validar que se acepten los términos
    if (!_rememberUser) {
      CustomSnackBar.showWarning(
        context: context,
        message: 'Debes aceptar los términos y condiciones para continuar.',
      );
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final authViewModel = context.read<AuthViewModel>();
      final success = await authViewModel.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      );
      if (success && mounted) {
        CustomSnackBar.showSuccess(
          context: context,
          message: '¡Cuenta creada exitosamente! Bienvenido a Planeta Motos.',
        );
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(
          context: context,
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Row(
          children: [
            if (!isSmallScreen)
              Expanded(
                child: AnimatedBuilder(
                  animation: _mainAnimationController,
                  builder: (context, child) => Container(
                    color: Colors.black,
                    child: _DynamicDotBackground(child: child!),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _AnimatedLoginComponent(
                            animation: _stockcitoAnimation,
                            child: Image.asset(
                              'assets/images/logs.png',
                              height: 200,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _AnimatedLoginComponent(
                            animation: _ampersandAnimation,
                            child: AnimatedBuilder(
                              animation: _glowAnimationController,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      for (int i = 1; i <= 2; i++)
                                        BoxShadow(
                                          color: theme.primaryColor.withOpacity(
                                            0.5 * _glowAnimationController.value,
                                          ),
                                          spreadRadius: i * 5.0 * _glowAnimationController.value,
                                          blurRadius: 20.0,
                                        ),
                                    ],
                                  ),
                                  child: child,
                                );
                              },
                              child: Text(
                                '&',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: theme.primaryColor.withOpacity(0.9),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _AnimatedLoginComponent(
                            animation: _logoAnimation,
                            fromOffset: const Offset(0, 0.2),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 280,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Container(
                color: theme.colorScheme.surface,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _AnimatedLoginComponent(
                        animation: _formAnimation,
                        fromOffset: const Offset(0.2, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isSmallScreen) ...[
                              Image.asset(
                                'assets/images/logo.png',
                                height: 120,
                              ),
                              const SizedBox(height: 32),
                            ],
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Únete a',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w300,
                                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  'Planeta Motos',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Gestión Inteligente de Stock',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _usernameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre de usuario',
                                      prefixIcon: Icon(Icons.person_outline),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Por favor, ingresa tu nombre de usuario';
                                      }
                                      if (value.trim().length < 3) {
                                        return 'El nombre de usuario debe tener al menos 3 caracteres';
                                      }
                                      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                                        return 'Solo se permiten letras, números y guiones bajos';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Icons.email_outlined),
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Por favor, ingresa tu email';
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                        return 'Por favor, ingresa un email válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Contraseña',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Por favor, ingresa tu contraseña';
                                      }
                                      if (value.length < 6) {
                                        return 'La contraseña debe tener al menos 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    decoration: InputDecoration(
                                      labelText: 'Confirmar contraseña',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                      ),
                                      border: const OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Por favor, confirma tu contraseña';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Las contraseñas no coinciden';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberUser,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberUser = value ?? false;
                                          });
                                        },
                                        activeColor: theme.primaryColor,
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Acepto los términos y condiciones',
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.primaryColor,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text(
                                      'Crear Cuenta',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '¿Ya tienes una cuenta?',
                                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).push(
                                          ElegantPageRoute(
                                            child: const LoginScreen(),
                                            isForward: false,
                                          ),
                                        ),
                                        child: Text(
                                          'Inicia Sesión',
                                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),
                            Column(
                              children: [
                                Text(
                                  'De Stockcito para Planeta Motos',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Desarrollado por Hid33n-Studiios © ${DateTime.now().year}',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _AnimatedLoginComponent(
                              animation: _formAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.yellow, Colors.orange],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.yellow.withOpacity(0.4),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Versión Única',
                                  style: GoogleFonts.bebasNeue(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedLoginComponent extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset fromOffset;

  const _AnimatedLoginComponent({
    required this.animation,
    required this.child,
    this.fromOffset = const Offset(0, -0.1),
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: fromOffset, end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }
}

class _DynamicDotBackground extends StatefulWidget {
  final Widget child;
  const _DynamicDotBackground({required this.child});

  @override
  State<_DynamicDotBackground> createState() => _DynamicDotBackgroundState();
}

class _DynamicDotBackgroundState extends State<_DynamicDotBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotPainter(animation: _controller),
      child: widget.child,
    );
  }
}

class _DotPainter extends CustomPainter {
  final Animation<double> animation;
  _DotPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.04);
    const double spacing = 40.0;
    final double offset = animation.value * spacing;

    for (double i = (offset % spacing) - spacing; i < size.width; i += spacing) {
      for (double j = (offset % spacing) - spacing; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter oldDelegate) => false;
} 