# lh_community

LH community Flutter plugin.

## Getting Started
```shell
dart pub cache clean
```

### Xoá luôn cái folder lib/generated nó mới chạy dc
```shell
flutter pub run intl_utils:generate -v
```

```shell
dart pub global activate flutter_gen
```

```shell
dart pub global activate intl_utils
dart pub global run intl_utils:generate
```
```shell
flutter gen-l10n
```

### Generate string resources
```shell
flutter gen-l10n
```

## Run
```shell
dart pub run build_runner
```
```shell
dart run build_runner build --delete-conflicting-outputs
```

```shell
fluttergen -c pubspec.yaml
```