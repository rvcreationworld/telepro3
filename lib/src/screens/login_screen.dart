import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _entrance;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _LoginHeader(
              animation: CurvedAnimation(
                parent: _entrance,
                curve: Curves.easeOutCubic,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
              child: _Entrance(
                animation: _entrance,
                interval: const Interval(.32, 1, curve: Curves.easeOutCubic),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: .38),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .14),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline),
                              hintText: 'Email or phone',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(18),
                            ),
                          ),
                          const Divider(height: 1, indent: 18, endIndent: 18),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              hintText: 'Password',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    FilledButton(
                      onPressed: _busy ? null : _login,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _busy
                            ? const SizedBox(
                                key: ValueKey('busy'),
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Login',
                                key: ValueKey('label'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Forgot password?'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter your login details')));
      return;
    }
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, animation, __) =>
            FadeTransition(opacity: animation, child: const HomeScreen()),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: ClipPath(
        clipper: _HeaderClipper(),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFA7ABFF), Color(0xFF666CEB)],
            ),
          ),
          child: Stack(
            children: [
              _orb(left: 34, top: -36, size: 76, delay: .0),
              _orb(left: 138, top: -42, size: 58, delay: .08),
              _orb(right: 42, top: 52, size: 62, delay: .14),
              Center(
                child: _Entrance(
                  animation: animation,
                  interval: const Interval(
                    .12,
                    .85,
                    curve: Curves.easeOutCubic,
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_in_talk_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'TelePro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Calls that connect to your workflow',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orb({
    double? left,
    double? right,
    required double top,
    required double size,
    required double delay,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: _Entrance(
        animation: animation,
        interval: Interval(delay, .72 + delay, curve: Curves.easeOutBack),
        offset: const Offset(0, -22),
        child: Container(
          width: size,
          height: size * 2.1,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .2),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..lineTo(0, size.height - 48)
    ..quadraticBezierTo(
      size.width * .48,
      size.height + 8,
      size.width,
      size.height - 70,
    )
    ..lineTo(size.width, 0)
    ..close();

  @override
  bool shouldReclip(_HeaderClipper oldClipper) => false;
}

class _Entrance extends StatelessWidget {
  const _Entrance({
    required this.animation,
    required this.child,
    required this.interval,
    this.offset = const Offset(0, 28),
  });
  final Animation<double> animation;
  final Widget child;
  final Interval interval;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: interval);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: offset / 100, end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}
