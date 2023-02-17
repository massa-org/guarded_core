import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'guarded_configuration_none.dart';
part 'guarded_configuration_loading.dart';
part 'guarded_configuration_error.dart';

abstract class GuardedConfiguration {
  static T? watch<T>(WidgetRef ref) {
    return ref.watch(
      guardedConfigurationProvider.select((value) => value[T] as T?),
    );
  }
}

final guardedConfigurationProvider = Provider<Map<Type, GuardedConfiguration>>(
  (ref) => {},
);

class GuardedConfigurationScope extends StatelessWidget {
  const GuardedConfigurationScope({
    super.key,
    required this.configurations,
    required this.child,
  });

  final Widget child;
  final Iterable<GuardedConfiguration> configurations;

  @override
  Widget build(BuildContext context) {
    if (configurations.isEmpty) return child;
    return ProviderScope(
      overrides: [
        guardedConfigurationProvider.overrideWithValue(
          Map.fromEntries(
            configurations.map((e) => MapEntry(e.runtimeType, e)),
          ),
        )
      ],
      child: child,
    );
  }
}

class Guarded {
  static GuardedConfiguration loadingWidget(Widget widget) {
    return GuardedConfigurationLoadingWidget(widget);
  }

  static GuardedConfiguration noneWidget(Widget widget) {
    return GuardedConfigurationNoneWidget(widget);
  }

  static GuardedConfiguration errorBuilder(
    Widget Function(dynamic error, StackTrace? stackTrace) builder,
  ) {
    return GuardedConfigurationErrorBuilder(builder);
  }

  static GuardedConfiguration errorWidget(Widget widget) {
    return GuardedConfigurationErrorBuilder((_, __) => widget);
  }
}
