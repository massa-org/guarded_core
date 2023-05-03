import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guarded_core/guarded_core.dart';

import 'common/guarded.dart';
import 'common/guards.dart';

void main() {
  // run all cases defined in resultToText array

  group('sync guard', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        await tester.pumpWidget(wrapGuards([GuardWithResult(result)]));

        caseExpect();
      });
    });
  });

  group('future guard', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        await tester.pumpWidget(wrapGuards([GuardWithAsyncResult(result)]));

        expect(find.text('loading'), findsOneWidget);
        await tester.pump();
        caseExpect();
      });
    });
  });

  group('syncronous future guard', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        await tester.pumpWidget(wrapGuards([
          GuardWithSynchronousFutureResult(result),
        ]));
        caseExpect();
      });
    });
  });

  // check if sync ref guard transition as
  //  loading -> state -> new-state
  group('sync ref guard', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        final controller = StreamController<GuardCheckResult>();
        await tester.pumpWidget(wrapRefGuards(
          [GuardWithSyncRefResult()],
          controller.stream,
        ));

        controller.add(result);

        expect(find.text('loading'), findsOneWidget);
        await tester.pump();
        caseExpect();

        controller.add(const GuardCheckResult.widget(Text('new result')));
        // HACK await propogate value to provider
        await Future.microtask(() => null);

        await tester.pump();
        expect(find.text('new result'), findsOneWidget);
      });
    });
  });

  // check if async ref guard transition as
  //  loading -> state -> loading -> new-state
  group('async ref guard', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        final controller = StreamController<GuardCheckResult>();
        await tester.pumpWidget(wrapRefGuards(
          [GuardWithAsyncRefResult()],
          controller.stream,
        ));

        controller.add(result);

        expect(find.text('loading'), findsOneWidget);
        await tester.pump();
        caseExpect();

        controller.add(const GuardCheckResult.widget(Text('new result')));
        // HACK await propogate value to provider
        await Future.microtask(() => null);

        await tester.pump();
        expect(find.text('loading'), findsOneWidget);
        await tester.pump();
        expect(find.text('new result'), findsOneWidget);
      });
    });
  });

  // check if async ref guard with `keep:true` transition as
  //  loading -> state -> new-state
  group('async ref guard with keep', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        final controller = StreamController<GuardCheckResult>();
        await tester.pumpWidget(wrapRefGuards(
          [GuardWithAsyncRefResult()],
          controller.stream,
          keepOldDataOnLoading: true,
        ));

        controller.add(result);

        expect(find.text('loading'), findsOneWidget);
        await tester.pump();
        caseExpect();

        controller.add(const GuardCheckResult.widget(Text('new result')));
        // HACK await propogate value to provider
        await Future.microtask(() => null);

        await tester.pump();
        caseExpect();
        await tester.pump();
        expect(find.text('new result'), findsOneWidget);
      });
    });
  });
}
