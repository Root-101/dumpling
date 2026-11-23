import 'package:service/dumpling.dart';

/// A `201` with what was created and where it is now (`Location`: the path of
/// the request followed by [id]).
ResponseEntity created(RequestEntity request, String id, Object body) =>
    ResponseEntity(
      201,
      body: body,
      headers: {'Location': '${request.requestedUri.path}/$id'},
    );
