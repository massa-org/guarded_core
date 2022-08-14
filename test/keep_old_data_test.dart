import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:guarded_core/guard_base.dart';
import 'package:guarded_core/guard_check_result.dart';

import 'common/guarded.dart';
import 'common/guards.dart';

void _test(
  String text,
  GuardCheckResult result,
  String expectedText,
  GuardBase guard,
  bool keep,
) {
  testWidgets(text, (tester) async {
    final controller = StreamController<GuardCheckResult>();
    await tester.pumpWidget(wrapRefGuards(
      [guard],
      controller.stream,
      keepOldDataOnLoading: keep,
    ));

    controller.add(result);

    expect(find.text('loading'), findsOneWidget);
    await tester.pump();
    expect(find.text(text), findsOneWidget);

    controller.add(const GuardCheckResult.loading());
    // HACK await propogate value to provider
    await Future.microtask(() => null);

    // first check for sync check complete and async start
    await tester.pump();
    expect(find.text(expectedText), findsOneWidget);

    // second check to await when async check is complete
    await tester.pump();
    expect(find.text(expectedText), findsOneWidget);
  });
}

void main() {
  for (final r in resultToText) {
    GuardCheckResult result = r[0];
    String text = r[1];

    group(
      'keep: true, sync',
      () => _test(text, result, text, GuardWithSyncRefResult(), true),
    );
    group(
      'keep: true, async',
      () => _test(text, result, text, GuardWithAsyncRefResult(), true),
    );

    group(
      'keep: false, sync',
      () => _test(text, result, 'loading', GuardWithSyncRefResult(), false),
    );
    group(
      'keep: false, async',
      () => _test(text, result, 'loading', GuardWithAsyncRefResult(), false),
    );
  }
}
