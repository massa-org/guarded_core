part of 'guarded_configuration.dart';

class GuardedConfigurationErrorBuilder extends GuardedConfiguration {
  static GuardedConfigurationErrorBuilder? watch(WidgetRef ref) =>
      GuardedConfiguration.watch<GuardedConfigurationErrorBuilder>(ref);

  GuardedConfigurationErrorBuilder(this.errorBuilder);

  final Widget Function(dynamic error, StackTrace? stackTrace) errorBuilder;
}

class GuardedError extends ConsumerWidget {
  const GuardedError({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  final dynamic error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = GuardedConfigurationErrorBuilder.watch(ref);

    if (config != null) return config.errorBuilder(error, stackTrace);
    return const SizedBox.shrink();
  }
}
