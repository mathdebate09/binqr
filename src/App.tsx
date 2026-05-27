import { BrowserRouter, Routes, Route } from 'react-router';
import { LandingPage } from './components/LandingPage';
import { SendPage } from './components/SendPage';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/send" element={<SendPage />} />
      </Routes>
    </BrowserRouter>
  );
}