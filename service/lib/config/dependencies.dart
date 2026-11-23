import 'package:service/dumpling.dart';

/// Repos, services and controllers, each found once with `di.find()`: none is
/// built by hand. In order (each finds the ones above it, lazily); start()
/// calls it after the infrastructure (database, cipher, scheduler, JWT).
void registerDependencies() {
  di
    //--------------- Repos ---------------\
    ..putLazy<WorkspaceTableRepo>(() => WorkspaceTableRepo(di.find()))
    ..putLazy<SourceTableRepo>(() => SourceTableRepo(di.find()))
    ..putLazy<DestinationTableRepo>(() => DestinationTableRepo(di.find()))
    ..putLazy<ConfigTableRepo>(() => ConfigTableRepo(di.find()))
    ..putLazy<RunTableRepo>(() => RunTableRepo(di.find()))
    ..putLazy<ApiKeyTableRepo>(() => ApiKeyTableRepo(di.find()))
    ..putLazy<CanvasRepo>(() => CanvasRepo(di.find()))
    //--------------- Services ---------------\
    ..putLazy<WorkspaceService>(WorkspaceService.new)
    ..putLazy<SourceService>(SourceService.new)
    ..putLazy<DestinationService>(DestinationService.new)
    ..putLazy<ConfigService>(ConfigService.new)
    ..putLazy<RunService>(RunService.new)
    ..putLazy<ApiKeyService>(ApiKeyService.new)
    ..putLazy<CanvasService>(CanvasService.new)
    ..putLazy<TransferService>(TransferService.new)
    //--------------- Controllers ---------------\
    ..putLazy<AuthController>(AuthController.new)
    ..putLazy<WorkspaceController>(WorkspaceController.new)
    ..putLazy<SourceController>(SourceController.new)
    ..putLazy<DestinationController>(DestinationController.new)
    ..putLazy<ConfigController>(ConfigController.new)
    ..putLazy<RunController>(RunController.new)
    ..putLazy<ApiKeyController>(ApiKeyController.new)
    ..putLazy<CanvasController>(CanvasController.new)
    ..putLazy<TransferController>(TransferController.new);
}
