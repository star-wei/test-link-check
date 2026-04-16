import { usePackingStore, defaultBoxes } from '../stores/packingStore';
import { Box } from 'lucide-react';

export function BoxSelector() {
  const { selectedBox, setSelectedBox, placedItems } = usePackingStore();
  
  const calculateUtilization = () => {
    if (!selectedBox || placedItems.length === 0) return 0;
    
    const boxArea = selectedBox.length * selectedBox.width;
    const usedArea = placedItems.reduce((sum, item) => {
      return sum + (item.length * item.width);
    }, 0);
    
    return Math.min(Math.round((usedArea / boxArea) * 100), 100);
  };
  
  const utilization = calculateUtilization();
  
  return (
    <div className="bg-white p-4 rounded-lg shadow mb-4">
      <div className="flex items-center gap-2 mb-3">
        <Box className="w-5 h-5 text-blue-600" />
        <h2 className="font-semibold">选择箱型</h2>
      </div>
      
      <div className="flex gap-2 mb-4">
        {defaultBoxes.map((box) => (
          <button
            key={box.id}
            onClick={() => setSelectedBox(box)}
            className={`px-4 py-2 rounded-lg border transition-colors ${
              selectedBox?.id === box.id
                ? 'bg-blue-600 text-white border-blue-600'
                : 'bg-white text-gray-700 border-gray-300 hover:border-blue-400'
            }`}
          >
            <div className="text-sm font-medium">{box.name}</div>
            <div className="text-xs opacity-75">
              {box.length}×{box.width}×{box.height}cm
            </div>
          </button>
        ))}
      </div>
      
      {selectedBox && (
        <div className="flex items-center gap-4 text-sm">
          <div>
            <span className="text-gray-500">当前箱型:</span>
            <span className="ml-1 font-medium">{selectedBox.name}</span>
          </div>
          <div>
            <span className="text-gray-500">空间利用率:</span>
            <span className={`ml-1 font-bold ${
              utilization > 80 ? 'text-green-600' : utilization > 50 ? 'text-yellow-600' : 'text-red-600'
            }`}>
              {utilization}%
            </span>
          </div>
          <div>
            <span className="text-gray-500">已放商品:</span>
            <span className="ml-1 font-medium">{placedItems.length} 件</span>
          </div>
        </div>
      )}
    </div>
  );
}
