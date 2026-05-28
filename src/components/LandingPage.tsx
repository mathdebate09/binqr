import { Upload, QrCode, ScanLine, Github, Computer, ExternalLink } from 'lucide-react';
import logoText from '../assets/logo-text.png';
import { PhoneMockup } from './PhoneMockup';
import { Link } from 'react-router';

export function LandingPage() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* Unconventional floating nav - top right corner */}
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
      </nav>

      {/* Hero Section - Full viewport */}
      <section className="relative min-h-screen flex items-center overflow-hidden">
        {/* Radial glow background - only blue accent use #1 */}
        <div
          className="absolute inset-0 z-0"
          style={{
            background: 'radial-gradient(circle at 65% 50%, rgba(0, 122, 255, 0.08) 0%, transparent 50%)',
          }}
        />

        {/* Dot pattern overlay */}
        <div
          className="absolute inset-0 z-0"
          style={{
            backgroundImage: 'radial-gradient(circle, rgba(255, 255, 255, 0.03) 1px, transparent 1px)',
            backgroundSize: '24px 24px',
          }}
        />

        <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-12 py-20 w-full">
          <div className="grid lg:grid-cols-2 gap-16 items-center">
            {/* Left column - Content */}
            <div className="space-y-8">

              {/* Headline */}
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

              {/* Subtext */}
              <p className="text-secondary text-lg leading-relaxed max-w-xl">
                Pick a file. Flash QR codes. Receive on any device. No internet needed.
              </p>

              {/* CTAs */}
              <div className="flex flex-wrap items-center gap-3">
                <a
                  href="https://github.com/mathdebate09/binqr/releases/download/v1.0.0/binqr-v1.0.0-arm64-v8a.apk"
                  className="inline-flex items-center gap-2 px-6 h-12 bg-white text-black rounded-full font-semibold hover:bg-white/90 transition-colors"
                >
                  <ExternalLink className="w-4 h-4" strokeWidth={2} />
                  Download APK
                </a>
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

              {/* Meta info */}
              <p className="text-secondary text-sm">
                Free · Open source · Android
              </p>
            </div>

            {/* Right column - Phone mockups */}
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

            {/* Mobile: horizontal scroll mockups */}
            <div className="lg:hidden overflow-x-auto pb-6 -mx-6 px-6">
              <div className="flex gap-6 min-w-max">
                <PhoneMockup type="send" />
                <PhoneMockup type="receive" />
              </div>
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
            {/* Step 01 */}
            <div className="relative bg-card rounded-[20px] p-8 border border-border overflow-hidden">
              <div
                className="absolute top-4 right-4 text-[#1C1C1E] font-bold opacity-50"
                style={{ fontSize: '72px', lineHeight: '1' }}
              >
                01
              </div>
              <div className="relative z-10">
                <Upload className="w-6 h-6 mb-6 text-white" strokeWidth={1.5} />
                <h3 className="text-white font-semibold text-xl mb-3">Select</h3>
                <p className="text-secondary text-sm leading-relaxed">
                  Pick any file from your Android device. binqr splits it into 2000-byte binary chunks, each MD5-checksummed.
                </p>
              </div>
            </div>

            {/* Step 02 */}
            <div className="relative bg-card rounded-[20px] p-8 border border-border overflow-hidden">
              <div
                className="absolute top-4 right-4 text-[#1C1C1E] font-bold opacity-50"
                style={{ fontSize: '72px', lineHeight: '1' }}
              >
                02
              </div>
              <div className="relative z-10">
                <QrCode className="w-6 h-6 mb-6 text-white" strokeWidth={1.5} />
                <h3 className="text-white font-semibold text-xl mb-3">Flash</h3>
                <p className="text-secondary text-sm leading-relaxed">
                  Your screen cycles QR codes at 10 per second. The sender loops indefinitely until the receiver signals done.
                </p>
              </div>
            </div>

            {/* Step 03 */}
            <div className="relative bg-card rounded-[20px] p-8 border border-border overflow-hidden">
              <div
                className="absolute top-4 right-4 text-[#1C1C1E] font-bold opacity-50"
                style={{ fontSize: '72px', lineHeight: '1' }}
              >
                03
              </div>
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
          {/* CTA Card */}
          <div className="bg-card rounded-[20px] p-12 border border-border mb-12">
            <div>
              <h2 className="text-white font-bold text-4xl mb-4 flex items-center gap-3">
                <span>Get</span>
                <img
                  src={logoText}
                  alt="binqr"
                  className="h-14 w-auto -ml-4"
                />
              </h2>
              <p className="text-secondary mb-8 leading-relaxed">
                Free and open source. No accounts, no pairing, no internet required.
              </p>
              <div className="flex flex-wrap items-center gap-3">
                <a
                  href="https://github.com/mathdebate09/binqr/releases/download/v1.0.0/binqr-v1.0.0-arm64-v8a.apk"
                  className="inline-flex items-center gap-2 px-6 h-12 bg-white text-black rounded-full font-semibold hover:bg-white/90 transition-colors"
                >
                  <ExternalLink className="w-4 h-4" strokeWidth={2} />
                  Download APK
                </a>
              </div>
            </div>
          </div>

          {/* Footer bar */}
          <div className="flex flex-col md:flex-row items-center justify-between gap-4 text-sm text-secondary">
            <p>© 2026 mathdebate09/binqr · MIT License</p>
            <div className="flex items-center gap-4">
              <a href="https://github.com/mathdebate09/binqr/releases/download/v1.0.0/binqr-v1.0.0-arm64-v8a.apk" className="hover:text-white transition-colors">
                APK
              </a>
              <span>·</span>
              <a href="https://github.com/mathdebate09/binqr" className="hover:text-white transition-colors">
                GitHub
              </a>
              <span>·</span>
              <span>Built with Flutter & Next.js</span>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
