import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guarded_core/configuration/guarded_configuration.dart';
import 'package:guarded_core/guarded_core.dart';

import 'common/guarded.dart';
import 'common/guards.dart';

void main() {
  // check default widget if configuration not provided
  group('no configuration', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        await tester.pumpWidget(
          wrapGuards(
            [GuardWithAsyncResult(result)],
            [],
          ),
        );

        expect(find.byType(GuardedLoading), findsOneWidget);
        await tester.pump();

        result.maybeMap(
          loading: (_) => expect(find.byType(GuardedLoading), findsOneWidget),
          error: (_) => expect(find.byType(GuardedError), findsOneWidget),
          none: (_) => expect(find.byType(GuardedNone), findsOneWidget),
          orElse: () => caseExpect(),
        );
      });
    });
  });

  group('direct configuration', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        await tester.pumpWidget(
          wrapGuards(
            [GuardWithAsyncResult(result)],
            [
              Guarded.loadingWidget(const Text('loading')),
              Guarded.errorWidget(const Text('error')),
              Guarded.noneWidget(const Text('none')),
            ],
          ),
        );

        expect(find.text('loading'), findsOneWidget);
        await tester.pump();

        caseExpect();
      });
    });
  });

  // check if we can use parrent configuration
  group('parrent configuration', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: GuardedConfigurationScope(
              configurations: [
                Guarded.loadingWidget(const Text('loading')),
                Guarded.errorWidget(const Text('error')),
                Guarded.noneWidget(const Text('none')),
              ],
              child: wrapGuards(
                [GuardWithAsyncResult(result)],
                [],
              ),
            ),
          ),
        );
        expect(find.text('loading'), findsOneWidget);
        await tester.pump();

        caseExpect();
      });
    });
  });

  // check if we can rewrite parrent configuration
  group('parrent configuration rewrite', () {
    casesRunner((testName, result, caseExpect) {
      testWidgets(testName, (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: GuardedConfigurationScope(
              configurations: [
                Guarded.loadingWidget(const Text('loading')),
                Guarded.errorWidget(const Text('error')),
                Guarded.noneWidget(const Text('none')),
              ],
              child: wrapGuards(
                [GuardWithAsyncResult(result)],
                [
                  Guarded.loadingWidget(const Text('custom loading')),
                ],
              ),
            ),
          ),
        );
        expect(find.text('custom loading'), findsOneWidget);
        await tester.pump();
        if (result is! GuardCheckResultLoading) {
          caseExpect();
        } else {
          expect(find.text('custom loading'), findsOneWidget);
        }
      });
    });
  });
}
