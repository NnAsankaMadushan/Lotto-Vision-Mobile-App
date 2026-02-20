import 'package:flutter/material.dart';

Color lottoScreenBackgroundColor(BuildContext context) {
  return Theme.of(context).colorScheme.surface;
}

class LottoGradientBackground extends StatelessWidget {
  const LottoGradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: lottoScreenBackgroundColor(context),
      child: child,
    );
  }
}

Widget buildLottoAppBarGradient(BuildContext context) {
  return ColoredBox(
    color: lottoScreenBackgroundColor(context),
  );
}

class LottoBrandedAppBarTitle extends StatelessWidget {
  const LottoBrandedAppBarTitle({
    super.key,
    required this.section,
  });

  final String section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      section,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}

Widget buildLottoBackButton(BuildContext context) {
  return IconButton(
    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    icon: const Icon(Icons.arrow_back_ios_new_rounded),
    onPressed: () {
      Navigator.of(context).maybePop();
    },
  );
}
