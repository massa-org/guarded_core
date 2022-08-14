## [0.1.1] - 2022-08-14

fix:
- unwanted transit to loading when `keepOldDataOnLoading: true` and check return loading

## [0.1.0] - 2022-08-14

feat(initial):
- extract guarded_core extract from internal projects
- split core and implementation

diff from internal:
- extract executor from GuardedWidgetBase
- GuardedWidgetBase support sync updates
- GuardBase remove behavior and change `check` method signature
- behavior action now must be applied before return result from check
- add some tests