import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:guarded_core/guard_base.dart';
import 'package:guarded_core/guard_check_result.dart';

import 'common/guarded.dart';
import 'common/guards.dart';

void _test(
  String testName,
  GuardCheckResult result,
  void Function() defaultCaseExpect,
  void Function() caseExpect,
  GuardBase guard,
  bool keep,
) {
  testWidgets(testName, (tester) async {
    final controller = StreamController<GuardCheckResult>();
    await tester.pumpWidget(wrapRefGuards(
      [guard],
      controller.stream,
      keepOldDataOnLoading: keep,
    ));

    controller.add(result);

    expect(find.text('loading'), findsOneWidget);
    await tester.pump();
    defaultCaseExpect();

    controller.add(const GuardCheckResult.loading());
    // HACK await propogate value to provider
    await Future.microtask(() => null);

    // first check for sync check complete and async start
    await tester.pump();
    caseExpect();

    // second check to await when async check is complete
    await tester.pump();
    caseExpect();
  });
}

void main() {
  casesRunner((testName, result, caseExpect) {
    group(
      'keep: true, sync',
      () => _test(testName, result, caseExpect, caseExpect,
          GuardWithSyncRefResult(), true),
    );
    group(
      'keep: true, async',
      () => _test(testName, result, caseExpect, caseExpect,
          GuardWithAsyncRefResult(), true),
    );

    group(
      'keep: false, sync',
      () => _test(
        testName,
        result,
        caseExpect,
        () => expect(find.text('loading'), findsOneWidget),
        GuardWithSyncRefResult(),
        false,
      ),
    );
    group(
      'keep: false, async',
      () => _test(
        testName,
        result,
        caseExpect,
        () => expect(find.text('loading'), findsOneWidget),
        GuardWithAsyncRefResult(),
        false,
      ),
    );
  });
}
