import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guarded_core/guarded_core.dart';

import 'common/guarded.dart';
import 'common/guards.dart';

class CallableGuard implements GuardBase {
  bool wasCalled = false;

  CallableGuard();

  @override
  FutureOr<GuardCheckResult> check(BuildContext context, WidgetRef ref) {
    wasCalled = true;
    return const GuardCheckResult.pass();
  }
}

class SecondGuard extends GuardWithResult {
  SecondGuard() : super(const GuardCheckResult.widget(Text('second-guard')));
}

void main() {
  group('async ref -> second guard', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        final controller = StreamController<GuardCheckResult>();
        await tester.pumpWidget(wrapRefGuards(
          [
            GuardWithAsyncRefResult(),
            SecondGuard(),
          ],
          controller.stream,
        ));

        controller.add(result);

        expect(find.text('loading'), findsOneWidget);
        await tester.pump();

        _expectSecondGuardOrCase(result, caseExpect);
        controller.add(const GuardCheckResult.pass());
        await Future.microtask(() {});
        await tester.pump();
        expect(find.text('loading'), findsOneWidget);
        await tester.pump();
        expect(find.text('second-guard'), findsOneWidget);
      });
    });
  });

  group('sync ref -> second guard', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        final controller = StreamController<GuardCheckResult>();
        await tester.pumpWidget(wrapRefGuards(
          [
            GuardWithSyncRefResult(),
            SecondGuard(),
          ],
          controller.stream,
        ));

        controller.add(result);

        expect(find.text('loading'), findsOneWidget);
        await tester.pump();
        _expectSecondGuardOrCase(result, caseExpect);
        controller.add(const GuardCheckResult.pass());
        await Future.microtask(() {});
        await tester.pump();
        expect(find.text('second-guard'), findsOneWidget);
      });
    });
  });

  group('keep ref -> second guard', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        final controller = StreamController<GuardCheckResult>();
        await tester.pumpWidget(wrapRefGuards(
          [
            GuardWithAsyncRefResult(),
            SecondGuard(),
          ],
          controller.stream,
          keepOldDataOnLoading: true,
        ));

        controller.add(result);

        expect(find.text('loading'), findsOneWidget);
        await tester.pump();

        _expectSecondGuardOrCase(result, caseExpect);
        controller.add(const GuardCheckResult.pass());
        // HACK await propogate value to provider
        await Future.microtask(() => null);

        await tester.pump();

        _expectSecondGuardOrCase(result, caseExpect);

        await tester.pump();
        expect(find.text('second-guard'), findsOneWidget);
      });
    });
  });

  group('execution order', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        final callableGuard = CallableGuard();
        final passCallableGuard = CallableGuard();
        final neverCallableGuard = CallableGuard();

        final controller = StreamController<GuardCheckResult>();
        await tester.pumpWidget(wrapRefGuards(
          [
            callableGuard,
            GuardWithAsyncRefResult(),
            passCallableGuard,
            SecondGuard(),
            neverCallableGuard,
          ],
          controller.stream,
        ));

        controller.add(result);

        expect(find.text('loading'), findsOneWidget);
        await tester.pump();
        _expectSecondGuardOrCase(result, caseExpect);
        expect(callableGuard.wasCalled, true);
        expect(passCallableGuard.wasCalled, result is GuardCheckResultPass);
        expect(neverCallableGuard.wasCalled, false);
      });
    });
  });
}

void _expectSecondGuardOrCase(
  GuardCheckResult result,
  void Function() caseExpect,
) {
  if (result is GuardCheckResultPass) {
    expect(find.text('second-guard'), findsOneWidget);
  } else {
    caseExpect();
  }
}
