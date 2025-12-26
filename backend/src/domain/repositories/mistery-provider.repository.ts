import { EvidenceCase } from '../entities/evidence-case.entity';

export interface MisteryProvider {
    searchEvidence(query: string): Promise<EvidenceCase[]>;
    getCaseDetails(id: string): Promise<EvidenceCase | null>;
    verifySourceIntegrity(url: string): Promise<boolean>;
}
