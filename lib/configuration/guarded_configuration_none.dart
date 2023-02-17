part of 'guarded_configuration.dart';

class GuardedConfigurationNoneWidget extends GuardedConfiguration {
  static GuardedConfigurationNoneWidget? watch(WidgetRef ref) =>
      GuardedConfiguration.watch<GuardedConfigurationNoneWidget>(ref);

  GuardedConfigurationNoneWidget(this.noneWidget);

  final Widget noneWidget;
}

class GuardedNone extends ConsumerWidget {
  const GuardedNone({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = GuardedConfigurationNoneWidget.watch(ref);
    if (config != null) return config.noneWidget;
    return const SizedBox.shrink();
  }
}
