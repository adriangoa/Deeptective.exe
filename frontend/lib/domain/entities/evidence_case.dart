enum MediaType { audio, video, text, image }

class EvidenceCase {
  final String id;
  final String title;
  final int depthLevel;
  final String sourceUrl;
  final MediaType mediaType;

  const EvidenceCase({
    required this.id,
    required this.title,
    required this.depthLevel,
    required this.sourceUrl,
    required this.mediaType,
  });
}