import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guarded_core/configuration/guarded_configuration.dart';
import 'package:guarded_core/guarded_core.dart';

abstract class GuardedWidgetBase extends ConsumerStatefulWidget {
  const GuardedWidgetBase({super.key});

  bool get keepOldDataOnLoading => false;
  GuardExecutor get executor => GuardExecutors.sequential;
  Widget build(BuildContext context, WidgetRef ref);
  Iterable<GuardBase> get rawGuards;
  Iterable<GuardedConfiguration> get rawConfiguration => const [];

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GuardedWidgetState();
}

class _GuardedWidgetState extends ConsumerState<GuardedWidgetBase> {
  @override
  Widget build(BuildContext context) {
    return GuardedConfigurationScope(
      configurations: widget.rawConfiguration.toList(),
      child: GuardedWidgetImpl(
        build: widget.build,
        executor: widget.executor,
        keepOldDataOnLoading: widget.keepOldDataOnLoading,
        rawGuards: widget.rawGuards,
      ),
    );
  }
}

class GuardedWidgetImpl extends ConsumerStatefulWidget {
  const GuardedWidgetImpl({
    super.key,
    required this.keepOldDataOnLoading,
    required this.executor,
    required this.build,
    required this.rawGuards,
  });

  final bool keepOldDataOnLoading;
  final GuardExecutor executor;
  final Widget Function(BuildContext context, WidgetRef ref) build;
  final Iterable<GuardBase> rawGuards;

  @override
  ConsumerState<GuardedWidgetImpl> createState() => _GuardedWidgetBaseState();
}

class _GuardedWidgetBaseState extends ConsumerState<GuardedWidgetImpl> {
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
    if (widget.keepOldDataOnLoading && result is GuardCheckResultLoading) {
      return;
    }
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

  Widget _mapResult(GuardCheckResult result, BuildContext context) {
    return result.map(
      pass: (_) => widget.build(context, ref),
      wrap: (v) => v.builder(child: widget.build(context, ref)),
      loading: (_) => const GuardedLoading(),
      none: (_) => const GuardedNone(),
      widget: (v) => v.widget,
      action: (v) {
        this.result = v.action(context, ref);
        return _mapResult(this.result, context);
      },
      error: (v) => GuardedError(error: v.error, stackTrace: v.stackTrace),
    );
  }

  @override
  Widget build(BuildContext context) {
    check();

    return StreamBuilder(
      stream: internalRebuild.stream,
      builder: (context, _) => _mapResult(result, context),
    );
  }
}
