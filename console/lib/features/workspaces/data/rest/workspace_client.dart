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
}

//---------- WORKSPACE REQUEST ----------
class WorkspaceRequest {
  final String name;
  final String? description;

  /// ARGB (`Color.toARGB32`)
  final int? color;

  WorkspaceRequest({required this.name, this.description, this.color});

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description, 'color': color};
  }
}

//---------- WORKSPACE RESPONSE ----------
class WorkspaceResponse {
  final String slug;
  final String name;
  final String? description;
  final int? color;

  /// Only in the list
  final WorkspaceStatsResponse? stats;

  WorkspaceResponse({
    required this.slug,
    required this.name,
    required this.description,
    required this.color,
    required this.stats,
  });

  factory WorkspaceResponse.fromJson(Map<String, dynamic> json) {
    return WorkspaceResponse(
      slug: json['slug'],
      name: json['name'],
      description: json['description'],
      color: json['color'],
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

  WorkspaceStatsResponse({
    required this.sources,
    required this.destinations,
    required this.configs,
    required this.failing,
    required this.running,
    required this.lastRunAt,
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
    );
  }
}
