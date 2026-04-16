import { usePackingStore } from '../stores/packingStore';
import type { PlacedItem } from '../types';
import { Package, RotateCcw } from 'lucide-react';

export function BoxView2D() {
  const { selectedBox, placedItems, clearPlacedItems } = usePackingStore();
  
  if (!selectedBox) {
    return (
      <div className="bg-white p-4 rounded-lg shadow h-96 flex items-center justify-center">
        <p className="text-gray-400">请先选择箱型</p>
      </div>
    );
  }
  
  const scale = 4; // 1cm = 4px
  const boxWidth = selectedBox.length * scale;
  const boxHeight = selectedBox.width * scale;
  
  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    const productData = e.dataTransfer.getData('product');
    if (!productData) return;
    
    const product = JSON.parse(productData);
    const rect = e.currentTarget.getBoundingClientRect();
    const x = (e.clientX - rect.left) / scale;
    const y = (e.clientY - rect.top) / scale;
    
    // 检查是否在箱子范围内
    if (x + product.length > selectedBox.length || y + product.width > selectedBox.width) {
      alert('商品超出箱子范围！');
      return;
    }
    
    const placedItem: PlacedItem = {
      ...product,
      position: { x, y },
      rotation: 0,
    };
    
    usePackingStore.getState().placeItem(placedItem);
  };
  
  const handleDragStart = (e: React.DragEvent, product: PlacedItem) => {
    e.dataTransfer.setData('product', JSON.stringify(product));
  };
  
  return (
    <div className="bg-white p-4 rounded-lg shadow">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <Package className="w-5 h-5 text-blue-600" />
          <h2 className="font-semibold">装箱视图</h2>
        </div>
        {placedItems.length > 0 && (
          <button
            onClick={clearPlacedItems}
            className="text-sm text-red-600 hover:text-red-700 flex items-center gap-1"
          >
            <RotateCcw className="w-4 h-4" />
            清空
          </button>
        )}
      </div>
      
      {/* 2D 箱子视图 */}
      <div
        onDrop={handleDrop}
        onDragOver={(e) => e.preventDefault()}
        className="relative bg-amber-50 border-2 border-amber-200 rounded"
        style={{ width: boxWidth, height: boxHeight, margin: '0 auto' }}
      >
        {/* 网格线 */}
        <div className="absolute inset-0 opacity-20">
          {Array.from({ length: Math.floor(selectedBox.length / 10) }).map((_, i) => (
            <div
              key={`v-${i}`}
              className="absolute top-0 bottom-0 border-l border-amber-300"
              style={{ left: (i + 1) * 10 * scale }}
            />
          ))}
          {Array.from({ length: Math.floor(selectedBox.width / 10) }).map((_, i) => (
            <div
              key={`h-${i}`}
              className="absolute left-0 right-0 border-t border-amber-300"
              style={{ top: (i + 1) * 10 * scale }}
            />
          ))}
        </div>
        
        {/* 已放置的商品 */}
        {placedItems.map((item, index) => (
          <div
            key={`${item.id}-${index}`}
            draggable
            onDragStart={(e) => handleDragStart(e, item)}
            className="absolute bg-blue-500 text-white text-xs rounded shadow-md cursor-move hover:bg-blue-600 flex items-center justify-center overflow-hidden"
            style={{
              left: item.position.x * scale,
              top: item.position.y * scale,
              width: item.length * scale,
              height: item.width * scale,
            }}
            title={`${item.name} (${item.length}×${item.width}cm)`}
          >
            <span className="truncate px-1">{item.name}</span>
          </div>
        ))}
        
        {/* 尺寸标注 */}
        <div className="absolute -bottom-6 left-0 right-0 text-center text-xs text-gray-500">
          {selectedBox.length}cm
        </div>
        <div className="absolute -left-6 top-0 bottom-0 flex items-center">
          <span className="text-xs text-gray-500 -rotate-90 whitespace-nowrap">
            {selectedBox.width}cm
          </span>
        </div>
      </div>
      
      {/* 提示 */}
      <p className="text-center text-sm text-gray-400 mt-8">
        从左侧拖拽商品到此处
      </p>
    </div>
  );
}
