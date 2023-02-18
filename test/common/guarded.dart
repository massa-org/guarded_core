import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guarded_core/configuration/guarded_configuration.dart';
import 'package:guarded_core/guarded_core.dart';

import 'guards.dart';

class GuardedWidget extends GuardedWidgetBase {
  final List<GuardBase> guards;

  final bool? keepOldData;

  @override
  bool get keepOldDataOnLoading => keepOldData ?? super.keepOldDataOnLoading;

  const GuardedWidget(
    this.guards, {
    Key? key,
    this.keepOldData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Text('pass');
  }

  @override
  get rawConfiguration => [
        Guarded.loadingWidget(const Text('loading')),
        Guarded.errorWidget(const Text('error')),
        Guarded.noneWidget(const Text('none')),
      ];

  @override
  Iterable<GuardBase> get rawGuards => guards;
}

Widget wrapForTest(Widget child) {
  return MaterialApp(home: child);
}

Widget wrapGuards(List<GuardBase> guards) {
  return wrapForTest(GuardedWidget(guards));
}

Widget wrapRefGuards(
  List<GuardBase> guards,
  Stream<GuardCheckResult> stream, {
  bool keepOldDataOnLoading = false,
}) {
  return wrapForTest(ProviderScope(
    overrides: [
      resultStreamProvider.overrideWith((_) => stream),
    ],
    child: GuardedWidget(
      guards,
      keepOldData: keepOldDataOnLoading,
    ),
  ));
}

class _Wrapper extends StatelessWidget {
  const _Wrapper({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('_wrapper_'),
        child,
      ],
    );
  }
}

final resultToText = [
  <dynamic>[const GuardCheckResult.loading(), 'loading'],
  <dynamic>[const GuardCheckResult.pass(), 'pass'],
  <dynamic>[const GuardCheckResult.none(), 'none'],
  <dynamic>[const GuardCheckResult.error('error'), 'error'],
  <dynamic>[const GuardCheckResult.widget(Text('widget')), 'widget'],
  <dynamic>[
    GuardCheckResult.action(
      (_, __) => const GuardCheckResult.widget(Text('after_action')),
    ),
    'after_action'
  ],
  <dynamic>[
    const GuardCheckResult.wrap(_Wrapper.new),
    '_wrapper_',
    ['_wrapper_', 'pass']
  ],
];

void casesRunner(
    void Function(
  String testName,
  GuardCheckResult result,
  void Function() caseExpect,
)
        runner) {
  for (final r in resultToText) {
    GuardCheckResult result = r[0];
    String testName = r[1];

    List<String> expects = (r.length > 2) ? r[2] : [testName];
    runner(
      testName,
      result,
      () {
        for (final test in expects) {
          expect(find.text(test), findsOneWidget);
        }
      },
    );
  }
}
