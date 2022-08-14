// import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guarded_core/guarded_core.dart';

import 'common/guarded.dart';
import 'common/guards.dart';

void main() {
  group('sync guard', () {
    for (final r in resultToText) {
      GuardCheckResult result = r[0];
      String text = r[1];
      testWidgets(text, (tester) async {
        await tester.pumpWidget(wrapGuards([GuardWithResult(result)]));
        expect(find.text(text), findsOneWidget);
      });
    }
  });

  group('future guard', () {
    for (final r in resultToText) {
      GuardCheckResult result = r[0];
      String text = r[1];
      testWidgets(text, (tester) async {
        await tester.pumpWidget(wrapGuards([GuardWithAsyncResult(result)]));

        expect(find.text('loading'), findsOneWidget);
        await tester.pump();
        expect(find.text(text), findsOneWidget);
      });
    }
  });

  group('syncronous future guard', () {
    for (final r in resultToText) {
      GuardCheckResult result = r[0];
      String text = r[1];
      testWidgets(text, (tester) async {
        await tester.pumpWidget(wrapGuards([
          GuardWithSynchronousFutureResult(result),
        ]));
        expect(find.text(text), findsOneWidget);
      });
    }
  });

  // check if sync ref guard transition as
  //  loading -> state -> new-state
  group('sync ref guard', () {
    for (final r in resultToText) {
      GuardCheckResult result = r[0];
      String text = r[1];
      testWidgets(text, (tester) async {
        final controller = StreamController<GuardCheckResult>();
        await tester.pumpWidget(wrapRefGuards(
          [GuardWithSyncRefResult()],
          controller.stream,
        ));

        controller.add(result);

        expect(find.text('loading'), findsOneWidget);
        await tester.pump();
        expect(find.text(text), findsOneWidget);

        controller.add(const GuardCheckResult.widget(Text('new result')));
        // HACK await propogate value to provider
        await Future.microtask(() => null);

        await tester.pump();
        expect(find.text('new result'), findsOneWidget);
      });
    }
  });

  // check if async ref guard transition as
  //  loading -> state -> loading -> new-state
  group('async ref guard', () {
    for (final r in resultToText) {
      GuardCheckResult result = r[0];
      String text = r[1];
      testWidgets(text, (tester) async {
        final controller = StreamController<GuardCheckResult>();
        await tester.pumpWidget(wrapRefGuards(
          [GuardWithAsyncRefResult()],
          controller.stream,
        ));

        controller.add(result);

        expect(find.text('loading'), findsOneWidget);
        await tester.pump();
        expect(find.text(text), findsOneWidget);

        controller.add(const GuardCheckResult.widget(Text('new result')));
        // HACK await propogate value to provider
        await Future.microtask(() => null);

        await tester.pump();
        expect(find.text('loading'), findsOneWidget);
        await tester.pump();
        expect(find.text('new result'), findsOneWidget);
      });
    }
  });

  // check if async ref guard with `keep:true` transition as
  //  loading -> state -> new-state
  group('async ref guard with keep', () {
    for (final r in resultToText) {
      GuardCheckResult result = r[0];
      String text = r[1];
      testWidgets(text, (tester) async {
        final controller = StreamController<GuardCheckResult>();
        await tester.pumpWidget(wrapRefGuards(
          [GuardWithAsyncRefResult()],
          controller.stream,
          keepOldDataOnLoading: true,
        ));

        controller.add(result);

        expect(find.text('loading'), findsOneWidget);
        await tester.pump();
        expect(find.text(text), findsOneWidget);

        controller.add(const GuardCheckResult.widget(Text('new result')));
        // HACK await propogate value to provider
        await Future.microtask(() => null);

        await tester.pump();
        expect(find.text(text), findsOneWidget);
        await tester.pump();
        expect(find.text('new result'), findsOneWidget);
      });
    }
  });
}
