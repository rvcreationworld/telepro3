import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

class DialerScreen extends StatefulWidget {
  const DialerScreen({super.key});

  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> {
  String _number = '';
  static const _keys = [
    ('1', ''),
    ('2', 'ABC'),
    ('3', 'DEF'),
    ('4', 'GHI'),
    ('5', 'JKL'),
    ('6', 'MNO'),
    ('7', 'PQRS'),
    ('8', 'TUV'),
    ('9', 'WXYZ'),
    ('*', ''),
    ('0', '+'),
    ('#', ''),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 650;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, compact ? 8 : 20, 24, 16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Keypad',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _number.isEmpty ? null : _backspace,
                    onLongPress: _clear,
                    icon: const Icon(Icons.backspace_outlined),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 140),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween(begin: .98, end: 1.0).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Text(
                      _number.isEmpty ? 'Enter a number' : _number,
                      key: ValueKey(_number),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontSize: _number.isEmpty ? 22 : 34,
                        fontWeight: FontWeight.w700,
                        color:
                            _number.isEmpty ? AppColors.muted : AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
              RepaintBoundary(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisExtent: compact ? 66 : 78,
                    mainAxisSpacing: compact ? 4 : 8,
                    crossAxisSpacing: 22,
                  ),
                  itemCount: _keys.length,
                  itemBuilder: (context, index) {
                    final key = _keys[index];
                    return _DialKey(
                      digit: key.$1,
                      letters: key.$2,
                      onTap: () => _append(key.$1),
                      onLongPress: key.$1 == '0' ? () => _append('+') : null,
                    );
                  },
                ),
              ),
              SizedBox(height: compact ? 8 : 14),
              Semantics(
                button: true,
                label: 'Call $_number',
                child: FilledButton(
                  onPressed: _number.isEmpty ? null : _call,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    disabledBackgroundColor: AppColors.success.withValues(
                      alpha: .25,
                    ),
                    shape: const CircleBorder(),
                    fixedSize: Size.square(compact ? 62 : 70),
                  ),
                  child: const Icon(
                    Icons.phone_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _append(String value) => setState(() => _number += value);
  void _backspace() {
    if (_number.isNotEmpty) {
      setState(() => _number = _number.substring(0, _number.length - 1));
    }
  }

  void _clear() => setState(() => _number = '');

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: _number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _DialKey extends StatelessWidget {
  const _DialKey({
    required this.digit,
    required this.letters,
    required this.onTap,
    this.onLongPress,
  });
  final String digit;
  final String letters;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkResponse(
          onTap: onTap,
          onLongPress: onLongPress,
          containedInkWell: true,
          highlightShape: BoxShape.circle,
          radius: 38,
          child: SizedBox.square(
            dimension: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  digit,
                  style: const TextStyle(
                    fontSize: 26,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                if (letters.isNotEmpty)
                  Text(
                    letters,
                    style: const TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}