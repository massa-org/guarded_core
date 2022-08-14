import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'executors/guard_executors.dart';
import 'guard_base.dart';
import 'guard_check_result.dart';
import 'guard_executor.dart';

abstract class GuardedWidgetBase extends ConsumerStatefulWidget {
  const GuardedWidgetBase({Key? key}) : super(key: key);

  bool get keepOldDataOnLoading => false;
  GuardExecutor get executor => GuardExecutors.sequential;

  Widget build(BuildContext context, WidgetRef ref);

  Widget get guardedLoadingWidget;
  Widget get guardedNoneWidget;
  Widget Function(GuardCheckResultError error) get guardedErrorBuilder;

  Iterable<GuardBase> get rawGuards;

  @override
  ConsumerState<GuardedWidgetBase> createState() => _GuardedWidgetBaseState();
}

class _GuardedWidgetBaseState extends ConsumerState<GuardedWidgetBase> {
  GuardCheckResult result = const GuardCheckResult.loading();
  int currentRunId = 0;

  final internalRebuild = StreamController<void>.broadcast();

  @override
  void dispose() {
    internalRebuild.close();
    super.dispose();
  }

  void update(
    GuardCheckResult result, {
    required bool sync,
    required int runId,
  }) {
    if (runId != currentRunId) return;
    this.result = result;
    if (!sync) {
      internalRebuild.add(null);
    }
  }

  void check() {
    if (!widget.keepOldDataOnLoading) {
      result = const GuardCheckResult.loading();
    }

    widget.executor.execute(
      context,
      ref,
      widget.rawGuards,
      update,
      currentRunId = currentRunId + 1,
      () => currentRunId,
    );
  }

  @override
  Widget build(BuildContext context) {
    check();

    return StreamBuilder(
      stream: internalRebuild.stream,
      builder: (context, _) {
        return result.map(
          pass: (_) => widget.build(context, ref),
          loading: (_) => widget.guardedLoadingWidget,
          none: (_) => widget.guardedNoneWidget,
          widget: (v) => v.widget,
          error: widget.guardedErrorBuilder,
        );
      },
    );
  }
}
