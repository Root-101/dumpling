/// Where a wire was dropped
class DropTarget {
  final String destinationId;
  final String? folderId;

  const DropTarget(this.destinationId, this.folderId);

  @override
  bool operator ==(Object other) =>
      other is DropTarget &&
      other.destinationId == destinationId &&
      other.folderId == folderId;

  @override
  int get hashCode => Object.hash(destinationId, folderId);
}
