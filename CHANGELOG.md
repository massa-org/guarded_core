## [0.4.2] - 2024-04-04

fix: 
- skip rebuild if value emited from guard is current result

## [0.4.1] - 2022-05-03

fix:
- guarded configuration 
- tests for guarded configuration
- test missed provider scope

## [0.4.0] - 2022-02-06

feat:
- change configuration injecting method (loading, none, error widget)
- allow to define custom configuration 

## [0.3.0] - 2022-11-03

deps:
- bump riverpod deps to 2.0.0

## [0.2.0] - 2022-09-11

feat: 
- add action check result - that aplies on next build only if guarded is still mounted
- add wrap check result - that allow to wrap passing result widget

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