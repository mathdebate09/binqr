import { useState } from 'react';
import { Upload, QrCode, ScanLine, Github, Computer, ExternalLink, Play, Tag } from 'lucide-react';
import logoText from '../assets/logo-text.png';
import { PhoneMockup } from './PhoneMockup';
import { Link } from 'react-router';
import { releases } from '../lib/releases';

export function LandingPage() {
  const [isDownloadOpen, setIsDownloadOpen] = useState(false);
  const [downloadTab, setDownloadTab] = useState<'apk' | 'checksum'>('apk');
  const [videoLoaded, setVideoLoaded] = useState(false);

  const YOUTUBE_ID = 'APfcLUemndo';

  const latestRelease = releases[releases.length - 1];
  const downloadOptions = latestRelease?.assets ?? [];

  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* Floating nav */}
      <nav className="fixed top-6 right-6 z-50 flex items-center gap-3">
        <Link
          to="/send"
          className="px-5 h-10 rounded-full bg-white text-black font-medium hover:bg-white/90 transition-all flex items-center"
        >
          Send
        </Link>
        <a
          href="https://github.com/mathdebate09/binqr"
          className="w-10 h-10 rounded-full border border-border hover:bg-[#1C1C1E] transition-all flex items-center justify-center"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Github className="w-4 h-4" strokeWidth={2} />
        </a>
        <a
          href="https://github.com/mathdebate09/binqr/releases/latest"
          className="w-10 h-10 rounded-full border border-border text-secondary hover:text-white hover:bg-[#1C1C1E] transition-all flex items-center justify-center"
          target="_blank"
          rel="noopener noreferrer"
          aria-label="Releases"
        >
          <Tag className="w-4 h-4" strokeWidth={2} />
        </a>
      </nav>

      {/* Hero Section */}
      <section className="relative min-h-screen flex items-center overflow-hidden">
        <div
          className="absolute inset-0 z-0"
          style={{
            background: 'radial-gradient(circle at 65% 50%, rgba(0, 122, 255, 0.08) 0%, transparent 50%)',
          }}
        />
        <div
          className="absolute inset-0 z-0"
          style={{
            backgroundImage: 'radial-gradient(circle, rgba(255, 255, 255, 0.03) 1px, transparent 1px)',
            backgroundSize: '24px 24px',
          }}
        />

        <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-12 py-20 w-full">
          <div className="grid lg:grid-cols-2 gap-16 items-center">
            <div className="space-y-8">
              <h1
                className="font-extrabold text-white leading-tight"
                style={{
                  fontSize: '64px',
                  fontWeight: 800,
                  letterSpacing: '-2px',
                  lineHeight: '1.1',
                }}
              >
                Connection-free file transfer using QR codes as a medium.
              </h1>
              <p className="text-secondary text-lg leading-relaxed max-w-xl">
                Pick a file. Flash QR codes. Receive on any device. No internet needed.
              </p>
              <div className="flex flex-wrap items-center gap-3">
                <button
                  type="button"
                  onClick={() => setIsDownloadOpen(true)}
                  className="inline-flex items-center gap-2 px-6 h-12 bg-white text-black rounded-full font-semibold hover:bg-white/90 transition-colors"
                >
                  <ExternalLink className="w-4 h-4" strokeWidth={2} />
                  Download APK
                </button>
                <Link
                  to="/send"
                  className="inline-flex items-center gap-2 px-6 h-12 border border-border rounded-full hover:bg-[#1C1C1E] transition-colors"
                >
                  <Computer className="w-4 h-4" strokeWidth={2} />
                  Send from desktop
                </Link>
                <a
                  href="https://github.com/mathdebate09/binqr"
                  className="inline-flex items-center gap-2 px-6 h-12 border border-border rounded-full hover:bg-[#1C1C1E] transition-colors"
                >
                  <Github className="w-4 h-4" strokeWidth={2} />
                  View Source
                </a>
              </div>
              <p className="text-secondary text-sm">Free · Open source · Android</p>
            </div>

            <div className="relative hidden lg:flex justify-center items-center h-150">
              <PhoneMockup
                type="send"
                className="absolute z-20 transform rotate-[-8deg] -translate-x-10"
              />
              <PhoneMockup
                type="receive"
                className="absolute z-10 transform translate-x-15 translate-y-5"
              />
            </div>

            <div className="lg:hidden overflow-x-auto pb-6 -mx-6 px-6">
              <div className="flex gap-6 min-w-max">
                <PhoneMockup type="send" />
                <PhoneMockup type="receive" />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Demo Section */}
      <section className="relative py-24 px-6 lg:px-12 overflow-hidden">
        <div
          className="absolute inset-0 z-0 pointer-events-none"
          style={{
            background: 'radial-gradient(ellipse 70% 60% at 50% 50%, rgba(0, 122, 255, 0.06) 0%, transparent 70%)',
          }}
        />

        <div className="relative z-10 max-w-7xl mx-auto">
          <div className="relative mx-auto max-w-4xl">
            {/* Faint grid lines behind the frame */}
            <div
              className="absolute -inset-12 z-0 pointer-events-none"
              style={{
                backgroundImage: `
                  linear-gradient(rgba(255,255,255,0.025) 1px, transparent 1px),
                  linear-gradient(90deg, rgba(255,255,255,0.025) 1px, transparent 1px)
                `,
                backgroundSize: '40px 40px',
                maskImage: 'radial-gradient(ellipse 80% 80% at 50% 50%, black 40%, transparent 100%)',
              }}
            />

            {/* The video container */}
            <div
              className="relative z-10 w-full overflow-hidden"
              style={{
                borderRadius: '16px',
                border: '1px solid rgba(255,255,255,0.1)',
                background: '#000',
                aspectRatio: '16/9',
                boxShadow: '0 0 80px rgba(0, 122, 255, 0.12), 0 40px 80px rgba(0,0,0,0.6)',
              }}
            >
              {!videoLoaded ? (
                <button
                  type="button"
                  onClick={() => setVideoLoaded(true)}
                  className="absolute inset-0 w-full h-full group"
                  aria-label="Play demo video"
                >
                  {/* YouTube thumbnail */}
                  <img
                    src={`https://img.youtube.com/vi/${YOUTUBE_ID}/maxresdefault.jpg`}
                    alt="binqr demo thumbnail"
                    className="w-full h-full object-cover"
                    style={{ filter: 'brightness(0.55)' }}
                  />

                  {/* Play button */}
                  <div className="absolute inset-0 flex items-center justify-center">
                    <div
                      className="relative flex items-center justify-center transition-transform duration-200 group-hover:scale-110"
                      style={{
                        width: 72,
                        height: 72,
                        borderRadius: '50%',
                        background: 'rgba(255,255,255,0.12)',
                        border: '1.5px solid rgba(255,255,255,0.25)',
                        backdropFilter: 'blur(8px)',
                      }}
                    >
                      <Play className="w-7 h-7 text-white fill-white translate-x-0.5" strokeWidth={0} />
                    </div>
                  </div>

                  {/* Bottom-left label */}
                  <div className="absolute bottom-5 left-5 text-left pointer-events-none">
                    <p className="text-white font-semibold text-base">binqr-demo.mov</p>
                  </div>
                </button>
              ) : (
                <iframe
                  className="absolute inset-0 w-full h-full"
                  src={`https://www.youtube.com/embed/${YOUTUBE_ID}?autoplay=1&rel=0&modestbranding=1`}
                  title="binqr demo"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                />
              )}
            </div>
          </div>
        </div>
      </section>

      {/* How it works */}
      <section className="relative py-2 px-6 lg:px-12">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-secondary text-sm uppercase tracking-wider mb-12">
            How it works
          </h2>
          <div className="grid md:grid-cols-3 gap-6">
            <div className="relative bg-card rounded-[20px] p-8 border border-border overflow-hidden">
              <div className="absolute top-4 right-4 text-[#1C1C1E] font-bold opacity-50" style={{ fontSize: '72px', lineHeight: '1' }}>01</div>
              <div className="relative z-10">
                <Upload className="w-6 h-6 mb-6 text-white" strokeWidth={1.5} />
                <h3 className="text-white font-semibold text-xl mb-3">Select</h3>
                <p className="text-secondary text-sm leading-relaxed">
                  Pick any file from your Android device. binqr splits it into 2000-byte binary chunks, each MD5-checksummed.
                </p>
              </div>
            </div>
            <div className="relative bg-card rounded-[20px] p-8 border border-border overflow-hidden">
              <div className="absolute top-4 right-4 text-[#1C1C1E] font-bold opacity-50" style={{ fontSize: '72px', lineHeight: '1' }}>02</div>
              <div className="relative z-10">
                <QrCode className="w-6 h-6 mb-6 text-white" strokeWidth={1.5} />
                <h3 className="text-white font-semibold text-xl mb-3">Flash</h3>
                <p className="text-secondary text-sm leading-relaxed">
                  Your screen cycles QR codes at 10 per second. The sender loops indefinitely until the receiver signals done.
                </p>
              </div>
            </div>
            <div className="relative bg-card rounded-[20px] p-8 border border-border overflow-hidden">
              <div className="absolute top-4 right-4 text-[#1C1C1E] font-bold opacity-50" style={{ fontSize: '72px', lineHeight: '1' }}>03</div>
              <div className="relative z-10">
                <ScanLine className="w-6 h-6 mb-6 text-white" strokeWidth={1.5} />
                <h3 className="text-white font-semibold text-xl mb-3">Receive</h3>
                <p className="text-secondary text-sm leading-relaxed">
                  Point your camera at the sender's screen. Chunks are verified and assembled in real time. File is saved to your device when complete.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer CTA + Footer combined */}
      <section className="relative py-16 px-6 lg:px-12">
        <div className="max-w-7xl mx-auto">
          <div className="bg-card rounded-[20px] p-12 border border-border mb-12">
            <div>
              <h2 className="text-white font-bold text-4xl mb-4 flex items-center gap-3">
                <span>Get</span>
                <img src={logoText} alt="binqr" className="h-14 w-auto -ml-4" />
              </h2>
              <p className="text-secondary mb-8 leading-relaxed">
                Free and open source. No accounts, no pairing, no internet required.
              </p>
              <div className="flex flex-wrap items-center gap-3">
                <button
                  type="button"
                  onClick={() => setIsDownloadOpen(true)}
                  className="inline-flex items-center gap-2 px-6 h-12 bg-white text-black rounded-full font-semibold hover:bg-white/90 transition-colors"
                >
                  <ExternalLink className="w-4 h-4" strokeWidth={2} />
                  Download APK
                </button>
              </div>
            </div>
          </div>

          <div className="flex flex-col md:flex-row items-center justify-between gap-4 text-sm text-secondary">
            <p>© 2026 mathdebate09/binqr · MIT License</p>
            <div className="flex items-center gap-4">
              <button
                type="button"
                onClick={() => setIsDownloadOpen(true)}
                className="hover:text-white transition-colors"
              >
                APK
              </button>
              <span>·</span>
              <a href="https://github.com/mathdebate09/binqr" className="hover:text-white transition-colors">
                GitHub
              </a>
              <span>·</span>
              <span>Built with Flutter & Vite</span>
            </div>
          </div>
        </div>
      </section>

      {/* Download Modal */}
      {isDownloadOpen ? (
        <div
          className="fixed inset-0 z-60 flex items-center justify-center px-6 py-10"
          role="dialog"
          aria-modal="true"
          aria-label="Download options"
        >
          <button
            type="button"
            aria-label="Close"
            onClick={() => setIsDownloadOpen(false)}
            className="absolute inset-0 bg-black/60"
          />

          <div
            className="relative z-10 w-full max-w-lg rounded-[20px] border border-white/10 bg-[#0f0f11] p-7 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="flex items-start justify-between gap-4 mb-5">
              <div>
                <h2 className="text-white text-lg font-medium">Download APK</h2>
                <p className="text-white/45 text-sm mt-1">
                  Not sure? Pick arm64-v8a, it works on ~95% of devices.
                </p>
              </div>
              <button
                type="button"
                onClick={() => setIsDownloadOpen(false)}
                className="w-8 h-8 rounded-full border border-white/12 text-white/50 hover:text-white hover:border-white/25 transition-colors flex items-center justify-center text-sm shrink-0"
              >
                ✕
              </button>
            </div>

            {/* Tab toggle */}
            <div className="flex gap-1 bg-white/5 rounded-full p-0.75 w-fit mb-5">
              {(['apk', 'checksum'] as const).map((tab) => (
                <button
                  key={tab}
                  type="button"
                  onClick={() => setDownloadTab(tab)}
                  className={`px-4.5 py-1.5 rounded-full text-xs font-medium transition-all ${downloadTab === tab
                    ? 'bg-white text-black'
                    : 'text-white/45 hover:text-white/70'
                    }`}
                >
                  {tab === 'apk' ? 'APK' : 'Checksum'}
                </button>
              ))}
            </div>

            {/* Cards */}
            <div className="flex flex-col gap-2">
              {downloadOptions.map((option) => (
                <div
                  key={option.id}
                  className={`flex items-center justify-between gap-3 rounded-[14px] px-4 py-3.5 border ${option.recommended
                    ? 'bg-white/4 border-white/20'
                    : 'bg-white/3 border-white/8'
                    }`}
                >
                  <div className="min-w-0">
                    <div className="flex items-center gap-2 mb-0.5">
                      <span className="text-white text-sm font-medium">{option.id}</span>
                      {option.recommended && (
                        <span className="text-[11px] text-white/50 border border-white/20 rounded-full px-2 py-px">
                          Recommended
                        </span>
                      )}
                    </div>
                    <p className="text-white/40 text-xs">{option.reason}</p>
                    {downloadTab === 'apk' ? (
                      <p className="text-white/30 text-xs mt-1">{option.size}</p>
                    ) : (
                      <p className="text-white/30 text-[11px] font-mono mt-1 truncate max-w-55">
                        {option.sha256.slice(0, 20)}…
                      </p>
                    )}
                  </div>

                  {downloadTab === 'apk' ? (
                    <a
                      href={option.href}
                      className="shrink-0 inline-flex items-center gap-1.5 px-3.5 py-2 bg-white/8 border border-white/12 rounded-full text-white text-xs font-medium hover:bg-white/15 transition-colors"
                    >
                      <ExternalLink className="w-3.5 h-3.5" strokeWidth={2} />
                      Download
                    </a>
                  ) : (
                    <a
                      href={option.sha1Href}
                      className="shrink-0 inline-flex items-center gap-1.5 px-3.5 py-2 bg-white/8 border border-white/12 rounded-full text-white text-xs font-medium hover:bg-white/15 transition-colors"
                    >
                      <ExternalLink className="w-3.5 h-3.5" strokeWidth={2} />
                      .sha1
                    </a>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>
      ) : null}
    </div>
  );
}