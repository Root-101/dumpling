import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';

class WorkspaceClient extends BaseClient {
  WorkspaceClient(super.dio);

  String get _workspacesUrl => '$baseUrl/workspaces';

  Future<List<WorkspaceResponse>> list({String? token}) async {
    Response rawResponse = await dio.get(
      _workspacesUrl,
      options: options(token: token),
    );
    return (rawResponse.data as List)
        .map((e) => WorkspaceResponse.fromJson(e))
        .toList();
  }

  Future<WorkspaceResponse> create({
    required WorkspaceRequest request,
    String? token,
  }) async {
    Response rawResponse = await dio.post(
      _workspacesUrl,
      data: request.toJson(),
      options: options(token: token),
    );
    return WorkspaceResponse.fromJson(rawResponse.data);
  }

  /// Replaces its data (defaults included); the slug stays
  Future<WorkspaceResponse> update({
    required String slug,
    required WorkspaceRequest request,
    String? token,
  }) async {
    Response rawResponse = await dio.put(
      '$_workspacesUrl/$slug',
      data: request.toJson(),
      options: options(token: token),
    );
    return WorkspaceResponse.fromJson(rawResponse.data);
  }

  /// With everything in it; the files already in the buckets stay
  Future<void> delete({required String slug, String? token}) async {
    await dio.delete('$_workspacesUrl/$slug', options: options(token: token));
  }
}

//---------- WORKSPACE REQUEST ----------
class WorkspaceRequest {
  final String name;
  final String? description;

  /// ARGB (`Color.toARGB32`)
  final int? color;

  /// `schedule`, `compression`, `object_key`; null: the service's
  final Map<String, String>? defaults;

  WorkspaceRequest({
    required this.name,
    this.description,
    this.color,
    this.defaults,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'color': color,
      'defaults': ?defaults,
    };
  }
}

//---------- WORKSPACE RESPONSE ----------
class WorkspaceResponse {
  final String slug;
  final String name;
  final String? description;
  final int? color;
  final Map<String, dynamic>? defaults;
  final DateTime? createdAt;

  /// Only in the list
  final WorkspaceStatsResponse? stats;

  WorkspaceResponse({
    required this.slug,
    required this.name,
    required this.description,
    required this.color,
    required this.defaults,
    required this.createdAt,
    required this.stats,
  });

  factory WorkspaceResponse.fromJson(Map<String, dynamic> json) {
    return WorkspaceResponse(
      slug: json['slug'],
      name: json['name'],
      description: json['description'],
      color: json['color'],
      defaults: json['defaults'],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at']),
      stats: json['stats'] == null
          ? null
          : WorkspaceStatsResponse.fromJson(json['stats']),
    );
  }
}

//---------- WORKSPACE STATS RESPONSE ----------
class WorkspaceStatsResponse {
  final int sources;
  final int destinations;
  final int configs;
  final int failing;
  final int running;
  final DateTime? lastRunAt;
  final List<WorkspacePreviewLink> preview;

  WorkspaceStatsResponse({
    required this.sources,
    required this.destinations,
    required this.configs,
    required this.failing,
    required this.running,
    required this.lastRunAt,
    required this.preview,
  });

  factory WorkspaceStatsResponse.fromJson(Map<String, dynamic> json) {
    return WorkspaceStatsResponse(
      sources: json['sources'],
      destinations: json['destinations'],
      configs: json['configs'],
      failing: json['failing'],
      running: json['running'],
      lastRunAt: json['last_run_at'] == null
          ? null
          : DateTime.parse(json['last_run_at']),
      preview: [
        for (final l in (json['preview'] as List? ?? const []))
          (
            source: l['source'] as String,
            destination: l['destination'] as String,
            failing: l['failing'] as bool,
          ),
      ],
    );
  }
}
