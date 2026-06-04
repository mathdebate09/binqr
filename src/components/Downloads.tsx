import { useMemo, useState } from 'react';
import { ExternalLink, Search, Tag } from 'lucide-react';
import { Link } from 'react-router';
import { releases, type Release } from '../lib/releases';

export function Downloads() {
    const [query, setQuery] = useState('');
    const [tab, setTab] = useState<'apk' | 'checksum'>('apk');

    const normalizedQuery = query.trim().toLowerCase();
    const filteredReleases = useMemo(() => {
        if (!normalizedQuery) {
            return releases;
        }

        return releases.reduce<Release[]>((acc, release) => {
            const versionMatch = release.version.toLowerCase().includes(normalizedQuery);
            const assets = versionMatch
                ? release.assets
                : release.assets.filter((asset) => asset.id.toLowerCase().includes(normalizedQuery));

            if (versionMatch || assets.length > 0) {
                acc.push({ ...release, assets });
            }

            return acc;
        }, []);
    }, [normalizedQuery]);

    const totalAssets = filteredReleases.reduce((sum, release) => sum + release.assets.length, 0);

    return (
        <div className="min-h-screen bg-background text-foreground">
            <nav className="fixed top-6 right-6 z-50 flex items-center gap-3">
                <Link
                    to="/"
                    className="px-5 h-10 rounded-full border border-border text-white/80 hover:text-white hover:bg-[#1C1C1E] transition-all flex items-center"
                >
                    Home
                </Link>
                <Link
                    to="/send"
                    className="px-5 h-10 rounded-full bg-white text-black font-medium hover:bg-white/90 transition-all flex items-center"
                >
                    Send
                </Link>
                <a
                    href="https://github.com/mathdebate09/binqr/releases/latest"
                    className="w-10 h-10 rounded-full border border-border text-secondary hover:text-white hover:bg-[#1C1C1E] transition-all flex items-center justify-center"
                    target="_blank"
                    rel="noopener noreferrer"
                    aria-label="Latest release"
                >
                    <Tag className="w-4 h-4" strokeWidth={2} />
                </a>
            </nav>

            <section className="relative pt-28 pb-12 px-6 lg:px-12">
                <div className="max-w-6xl mx-auto">
                    <div className="flex flex-col gap-6">
                        <div>
                            <h1 className="text-white text-4xl md:text-5xl font-semibold leading-tight">
                                Downloads
                            </h1>
                        </div>

                        <div className="flex flex-col sm:flex-row sm:items-center gap-4">
                            <div className="relative w-full sm:max-w-md">
                                <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-white/40" />
                                <input
                                    type="search"
                                    value={query}
                                    onChange={(event) => setQuery(event.target.value)}
                                    placeholder="Search version or architecture"
                                    className="w-full pl-11 pr-4 py-3 rounded-full bg-white/6 border border-white/8 text-sm text-white placeholder:text-white/35 focus:outline-none focus:border-white/30"
                                    aria-label="Search downloads"
                                />
                            </div>

                            <div className="flex items-center gap-1 bg-white/5 rounded-full p-0.75 w-fit">
                                {(['apk', 'checksum'] as const).map((currentTab) => (
                                    <button
                                        key={currentTab}
                                        type="button"
                                        onClick={() => setTab(currentTab)}
                                        className={`px-4.5 py-1.5 rounded-full text-xs font-medium transition-all ${tab === currentTab
                                            ? 'bg-white text-black'
                                            : 'text-white/45 hover:text-white/70'
                                            }`}
                                    >
                                        {currentTab === 'apk' ? 'APK' : 'Checksum'}
                                    </button>
                                ))}
                            </div>
                        </div>

                        <p className="text-white/40 text-xs">
                            {filteredReleases.length} release{filteredReleases.length === 1 ? '' : 's'} · {totalAssets} file
                            {totalAssets === 1 ? '' : 's'}
                        </p>
                    </div>
                </div>
            </section>

            <section className="px-6 lg:px-12 pb-20">
                <div className="max-w-6xl mx-auto flex flex-col gap-8">
                    {filteredReleases.length === 0 ? (
                        <div className="bg-card border border-border rounded-[20px] p-10 text-center">
                            <p className="text-white text-lg font-semibold">No releases match your search.</p>
                            <p className="text-secondary text-sm mt-2">
                                Try a version like 1.0.0 or an architecture like arm64-v8a.
                            </p>
                        </div>
                    ) : (
                        filteredReleases.map((release) => (
                            <div key={release.tag} className="bg-card border border-border rounded-3xl p-7 md:p-9">
                                <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-6">
                                    <div>
                                        <div className="flex flex-wrap items-center gap-3">
                                            <span className="text-white text-2xl font-semibold">binqr {release.version}</span>
                                            <span className="text-[11px] uppercase tracking-widest text-white/50 border border-white/15 rounded-full px-3 py-1">
                                                {release.tag}
                                            </span>
                                        </div>
                                        <p className="text-secondary text-sm mt-2 max-w-2xl">{release.summary}</p>
                                        <p className="text-white/40 text-xs mt-3">Released {release.date}</p>
                                    </div>
                                    <a
                                        href={release.releaseHref}
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        className="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-white/15 text-white/70 hover:text-white hover:border-white/30 transition-colors text-xs"
                                    >
                                        <ExternalLink className="w-3.5 h-3.5" strokeWidth={2} />
                                        Release notes
                                    </a>
                                </div>

                                <div className="mt-6 grid gap-3">
                                    {release.assets.map((asset) => (
                                        <div
                                            key={asset.id}
                                            className={`flex flex-col md:flex-row md:items-center md:justify-between gap-4 rounded-2xl px-4 py-4 border ${asset.recommended
                                                ? 'bg-white/4 border-white/20'
                                                : 'bg-white/3 border-white/8'
                                                }`}
                                        >
                                            <div className="min-w-0">
                                                <div className="flex items-center gap-2 mb-1">
                                                    <span className="text-white text-sm font-medium">{asset.id}</span>
                                                    {asset.recommended ? (
                                                        <span className="text-[11px] text-white/50 border border-white/20 rounded-full px-2 py-px">
                                                            Recommended
                                                        </span>
                                                    ) : null}
                                                </div>
                                                <p className="text-white/30 text-[11px] mt-1 truncate max-w-105">{asset.label}</p>
                                            </div>

                                            {tab === 'apk' ? (
                                                <a
                                                    href={asset.href}
                                                    className="shrink-0 inline-flex items-center gap-1.5 px-4 py-2 bg-white/8 border border-white/12 rounded-full text-white text-xs font-medium hover:bg-white/15 transition-colors"
                                                >
                                                    <ExternalLink className="w-3.5 h-3.5" strokeWidth={2} />
                                                    Download APK
                                                </a>
                                            ) : (
                                                <a
                                                    href={asset.sha1Href}
                                                    className="shrink-0 inline-flex items-center gap-1.5 px-4 py-2 bg-white/8 border border-white/12 rounded-full text-white text-xs font-medium hover:bg-white/15 transition-colors"
                                                >
                                                    <ExternalLink className="w-3.5 h-3.5" strokeWidth={2} />
                                                    Download .sha1
                                                </a>
                                            )}
                                        </div>
                                    ))}
                                </div>
                            </div>
                        ))
                    )}
                </div>
            </section>
        </div>
    );
}
