import '../entities/evidence_case.dart';

abstract class MisteryProvider {
  Future<List<EvidenceCase>> fetchMysteries(String query);
  Future<EvidenceCase?> getCaseById(String id);
}