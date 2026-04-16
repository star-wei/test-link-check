import { BoxSelector } from './components/BoxSelector';
import { DataImport } from './components/DataImport';
import { BoxView2D } from './components/BoxView2D';
import { Package } from 'lucide-react';

function App() {
  return (
    <div className="min-h-screen bg-gray-100">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex items-center gap-3">
            <Package className="w-8 h-8 text-blue-600" />
            <div>
              <h1 className="text-xl font-bold text-gray-900">装箱方案系统</h1>
              <p className="text-sm text-gray-500">智能装箱计算与可视化</p>
            </div>
          </div>
        </div>
      </header>
      
      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 py-6">
        {/* Box Selector */}
        <BoxSelector />
        
        {/* Two Column Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Left: Product List */}
          <div className="lg:col-span-1">
            <DataImport />
          </div>
          
          {/* Right: Box View */}
          <div className="lg:col-span-2">
            <BoxView2D />
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;
