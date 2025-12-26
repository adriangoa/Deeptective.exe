export enum MediaType {
    AUDIO = 'audio',
    VIDEO = 'video',
    TEXT = 'text',
    IMAGE = 'image'
}

export class EvidenceCase {
    constructor(
        public readonly id: string,
        public readonly title: string,
        public readonly depthLevel: 1 | 2 | 3, // 1: Superficial, 3: Deep Web
        public readonly sourceUrl: string,
        public readonly mediaType: MediaType,
        public readonly discoveredAt: Date
    ) { }
}
