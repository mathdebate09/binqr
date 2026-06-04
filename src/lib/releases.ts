export type ReleaseAsset = {
  id: string;
  label: string;
  href: string;
  sha1Href: string;
  sha256: string;
  size: string;
  reason: string;
  recommended: boolean;
};

export type Release = {
  version: string;
  tag: string;
  date: string;
  summary: string;
  releaseHref: string;
  assets: ReleaseAsset[];
};

export const releases: Release[] = [
  {
    version: '1.0.0',
    tag: 'v1.0.0',
    date: '2026-06-04',
    summary: 'Initial public release of binqr for Android.',
    releaseHref: 'https://github.com/mathdebate09/binqr/releases/tag/v1.0.0',
    assets: [
      {
        id: 'arm64-v8a',
        label: 'binqr-v1.0.0-arm64-v8a.apk',
        href: 'https://github.com/mathdebate09/binqr/releases/download/v1.0.0/binqr-v1.0.0-arm64-v8a.apk',
        sha1Href: 'https://github.com/mathdebate09/binqr/releases/download/v1.0.0/binqr-v1.0.0-arm64-v8a.apk.sha1',
        sha256: 'df697822ba3fae768d4347ba8a06f01cc106701a0344d3cf6df77cdfaa05524b',
        size: '24.6 MB',
        reason: 'Modern Android phone/tablet (2015 or newer)',
        recommended: true,
      },
      {
        id: 'armeabi-v7a',
        label: 'binqr-v1.0.0-armeabi-v7a.apk',
        href: 'https://github.com/mathdebate09/binqr/releases/download/v1.0.0/binqr-v1.0.0-armeabi-v7a.apk',
        sha1Href: 'https://github.com/mathdebate09/binqr/releases/download/v1.0.0/binqr-v1.0.0-armeabi-v7a.apk.sha1',
        sha256: '9114cb52f286bb9eec9c8bf7d245c93a69af625a61500ec97389da78e134834b',
        size: '20.6 MB',
        reason: 'Older Android phone/tablet (pre-2015)',
        recommended: false,
      },
      {
        id: 'x86_64',
        label: 'binqr-v1.0.0-x86_64.apk',
        href: 'https://github.com/mathdebate09/binqr/releases/download/v1.0.0/binqr-v1.0.0-x86_64.apk',
        sha1Href: 'https://github.com/mathdebate09/binqr/releases/download/v1.0.0/binqr-v1.0.0-x86_64.apk.sha1',
        sha256: 'd45090eb47e369203460753e2506f54d312d8b9be60448e8e0f31b6363d51ad3',
        size: '27 MB',
        reason: 'Android Emulator (AVD)',
        recommended: false,
      },
    ],
  },
];
