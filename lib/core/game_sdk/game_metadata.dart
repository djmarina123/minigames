/// Metadados exibidos no catálogo do hub.
class GameMetadata {
  const GameMetadata({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.icon = '🎮',
    this.enabled = true,
    this.featured = false,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String icon;
  final bool enabled;
  final bool featured;
}
