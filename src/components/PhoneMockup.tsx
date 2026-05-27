import { QrCode } from 'lucide-react';
import logoQr from '../assets/logo-qr.png';

interface PhoneMockupProps {
  type: 'send' | 'receive';
  className?: string;
}

export function PhoneMockup({ type, className = '' }: PhoneMockupProps) {
  return (
    <div className={`relative ${className}`}>
      {/* Phone frame */}
      <div className="relative w-70 h-140 bg-[#1C1C1E] rounded-[40px] border-8 border-[#0A0A0A] overflow-hidden">
        {/* Status bar */}
        <div className="absolute top-0 left-0 right-0 h-10 bg-[#0F0F0F]/50 backdrop-blur-sm flex items-center justify-between px-6">
          <span className="text-white text-xs">9:41</span>
          <div className="flex items-center gap-1">
            <div className="w-4 h-3 border border-white/60 rounded-sm" />
            <div className="w-1 h-3 bg-white/60 rounded-full" />
          </div>
        </div>

        {type === 'send' ? (
          <SendScreen />
        ) : (
          <ReceiveScreen />
        )}

        {/* Home indicator */}
        <div className="absolute bottom-2 left-1/2 -translate-x-1/2 w-32 h-1 bg-white/30 rounded-full" />
      </div>
    </div>
  );
}

function SendScreen() {
  return (
    <div className="w-full h-full pt-12 pb-8 px-6 flex flex-col">
      {/* Header */}
      <div className="mb-6">
        <h2 className="text-white font-semibold text-lg mb-1">Sending</h2>
        <p className="text-[#8E8E93] text-sm">document.pdf • 42.3 KB</p>
      </div>

      {/* QR Code Display */}
      <div className="flex-1 flex items-center justify-center mb-6">
        <div className="w-52 h-52 bg-white rounded-2xl p-4 flex items-center justify-center">
          <img
            src={logoQr}
            alt="binqr QR"
            className="w-full h-full object-contain rounded-xl"
          />
        </div>
      </div>

      {/* Progress bar */}
      <div className="mb-4">
        <div className="flex justify-between text-xs text-[#8E8E93] mb-2">
          <span>Chunk 23 / 53</span>
          <span>43%</span>
        </div>
        <div className="h-1.5 bg-[#2C2C2E] rounded-full overflow-hidden">
          <div className="h-full w-[43%] bg-[#007AFF] rounded-full" />
        </div>
      </div>

      {/* Stop button */}
      <button className="w-full h-12 bg-[#FF3B30] rounded-full text-white font-semibold">
        Stop
      </button>
    </div>
  );
}

function ReceiveScreen() {
  return (
    <div className="w-full h-full pt-12 pb-8 px-6 flex flex-col">
      {/* Header */}
      <div className="mb-6">
        <h2 className="text-white font-semibold text-lg mb-1">Receiving</h2>
        <p className="text-[#8E8E93] text-sm">Point camera at QR codes</p>
      </div>

      {/* Camera viewfinder */}
      <div className="flex-1 flex items-center justify-center mb-6 relative">
        <div className="w-full h-64 bg-[#0A0A0A] rounded-2xl relative overflow-hidden">
          {/* Scan frame */}
          <div className="absolute inset-8 border-2 border-[#007AFF] rounded-xl">
            {/* Corner decorators */}
            <div className="absolute -top-0.5 -left-0.5 w-6 h-6 border-t-4 border-l-4 border-[#007AFF]" />
            <div className="absolute -top-0.5 -right-0.5 w-6 h-6 border-t-4 border-r-4 border-[#007AFF]" />
            <div className="absolute -bottom-0.5 -left-0.5 w-6 h-6 border-b-4 border-l-4 border-[#007AFF]" />
            <div className="absolute -bottom-0.5 -right-0.5 w-6 h-6 border-b-4 border-r-4 border-[#007AFF]" />
          </div>

          {/* Simulated QR in viewfinder */}
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="w-24 h-24 bg-white/10 rounded">
              <QrCode className="w-full h-full text-white/40" strokeWidth={1} />
            </div>
          </div>
        </div>
      </div>

      {/* Progress panel */}
      <div className="bg-[#1C1C1E] rounded-2xl p-4 border border-[#2C2C2E]">
        <div className="flex justify-between text-xs text-[#8E8E93] mb-2">
          <span>32 / 53 chunks</span>
          <span>60%</span>
        </div>
        <div className="h-1.5 bg-[#2C2C2E] rounded-full overflow-hidden">
          <div className="h-full w-[60%] bg-[#007AFF] rounded-full" />
        </div>
      </div>
    </div>
  );
}
