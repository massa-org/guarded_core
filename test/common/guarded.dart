import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guarded_core/guarded_core.dart';

import 'guards.dart';

class GuardedWidget extends GuardedWidgetBase {
  final List<GuardBase> guards;

  @override
  final bool keepOldDataOnLoading;

  const GuardedWidget(
    this.guards, {
    Key? key,
    this.keepOldDataOnLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Text('pass');
  }

  @override
  Widget Function(GuardCheckResultError error) get guardedErrorBuilder =>
      (error) => const Text('error');

  @override
  Widget get guardedLoadingWidget => const Text('loading');

  @override
  Widget get guardedNoneWidget => const Text('none');

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
      resultStreamProvider.overrideWithProvider(StreamProvider((_) => stream)),
    ],
    child: GuardedWidget(
      guards,
      keepOldDataOnLoading: keepOldDataOnLoading,
    ),
  ));
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
];
