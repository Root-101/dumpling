import 'package:get/get.dart';

/// The only dependency on Get, the framework underneath, must live ONLY in this class

/// DI stands for Dependency Injection
/// The facade reduces the coupling of the app with the dependency injection
/// plugin in use.
/// Get is used here, but switching to another one, such as get_it, only means
/// changing the implementation of `find` and `put`.
///
/// To switch to get_it, for example, replace the implementation
/// of `put` with: `getIt.registerSingleton<SomeDependency>(SomeDependency());`
/// and of `find` with: `getIt<AppModel>();`
/// or their equivalents in each case
class DI {
  static final DI _instance = DI._internal();

  DI._internal();

  factory DI() => _instance;

  S put<S>(S dependency, {String? tag}) => Get.put<S>(dependency, tag: tag);

  S find<S>({String? tag}) => Get.find<S>(tag: tag);

  bool isRegistered<S>({String? tag}) => Get.isRegistered<S>(tag: tag);
}
