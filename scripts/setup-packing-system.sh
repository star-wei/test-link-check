#!/bin/bash

# 装箱方案系统 MVP 开发脚本

echo "🚀 开始创建装箱方案系统..."

# Step 1: 项目初始化
echo "📦 Step 1: 初始化 Vite 项目..."
npm create vite@latest . -- --template react-ts -y

# 等待一下确保 package.json 创建完成
sleep 2

# 安装依赖
echo "📦 安装依赖..."
npm install @dnd-kit/core zustand jspdf xlsx lucide-react clsx
npm install -D tailwindcss postcss autoprefixer

# 初始化 Tailwind
echo "🎨 初始化 Tailwind CSS..."
npx tailwindcss init -p

# 配置 tailwind.config.js
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

# 配置 CSS
cat > src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

# Step 2: 创建类型定义
echo "📝 Step 2: 创建类型定义..."
mkdir -p src/types

cat > src/types/index.ts << 'EOF'
export interface Product {
  id: string;
  name: string;
  length: number;
  width: number;
  height: number;
  weight: number;
  quantity: number;
}

export interface BoxType {
  id: string;
  name: string;
  length: number;
  width: number;
  height: number;
  maxWeight: number;
}

export interface Position {
  x: number;
  y: number;
}

export interface PlacedItem extends Product {
  position: Position;
  rotation: number;
}

export interface PackedBox {
  boxType: BoxType;
  items: PlacedItem[];
}
EOF

# Step 3: 创建 Store
echo "🗃️ Step 3: 创建 Zustand Store..."
mkdir -p src/stores

cat > src/stores/packingStore.ts << 'EOF'
import { create } from 'zustand';
import { Product, BoxType, PlacedItem } from '../types';

interface PackingState {
  products: Product[];
  selectedBox: BoxType | null;
  placedItems: PlacedItem[];
  
  // Actions
  setProducts: (products: Product[]) => void;
  addProduct: (product: Product) => void;
  removeProduct: (id: string) => void;
  setSelectedBox: (box: BoxType) => void;
  placeItem: (item: PlacedItem) => void;
  removePlacedItem: (id: string) => void;
  clearPlacedItems: () => void;
}

const defaultBoxes: BoxType[] = [
  { id: '1', name: '小号箱', length: 30, width: 20, height: 20, maxWeight: 5 },
  { id: '2', name: '中号箱', length: 40, width: 30, height: 30, maxWeight: 10 },
  { id: '3', name: '大号箱', length: 60, width: 40, height: 40, maxWeight: 20 },
];

export const usePackingStore = create<PackingState>((set) => ({
  products: [],
  selectedBox: defaultBoxes[1],
  placedItems: [],
  
  setProducts: (products) => set({ products }),
  addProduct: (product) => set((state) => ({ 
    products: [...state.products, product] 
  })),
  removeProduct: (id) => set((state) => ({ 
    products: state.products.filter(p => p.id !== id) 
  })),
  setSelectedBox: (box) => set({ selectedBox: box }),
  placeItem: (item) => set((state) => ({ 
    placedItems: [...state.placedItems, item] 
  })),
  removePlacedItem: (id) => set((state) => ({ 
    placedItems: state.placedItems.filter(i => i.id !== id) 
  })),
  clearPlacedItems: () => set({ placedItems: [] }),
}));

export { defaultBoxes };
EOF

# Step 4: 创建组件
echo "🧩 Step 4: 创建组件..."
mkdir -p src/components

# BoxSelector 组件
cat > src/components/BoxSelector.tsx << 'EOF'
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
EOF

# DataImport 组件
cat > src/components/DataImport.tsx << 'EOF'
import { useState, useRef } from 'react';
import { usePackingStore } from '../stores/packingStore';
import { Product } from '../types';
import { Upload, Trash2, Package } from 'lucide-react';
import * as XLSX from 'xlsx';

export function DataImport() {
  const { products, setProducts, removeProduct } = usePackingStore();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [dragOver, setDragOver] = useState(false);
  
  const handleFileUpload = (file: File) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      const data = e.target?.result;
      const workbook = XLSX.read(data, { type: 'binary' });
      const sheetName = workbook.SheetNames[0];
      const worksheet = workbook.Sheets[sheetName];
      const jsonData = XLSX.utils.sheet_to_json(worksheet);
      
      const parsedProducts: Product[] = jsonData.map((row: any, index: number) => ({
        id: `prod-${index}`,
        name: row['商品名称'] || row['name'] || `商品${index + 1}`,
        length: Number(row['长'] || row['length'] || 10),
        width: Number(row['宽'] || row['width'] || 10),
        height: Number(row['高'] || row['height'] || 10),
        weight: Number(row['重量'] || row['weight'] || 0.1),
        quantity: Number(row['数量'] || row['quantity'] || 1),
      }));
      
      setProducts(parsedProducts);
    };
    reader.readAsBinaryString(file);
  };
  
  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setDragOver(false);
    const file = e.dataTransfer.files[0];
    if (file && file.name.endsWith('.xlsx')) {
      handleFileUpload(file);
    }
  };
  
  return (
    <div className="bg-white p-4 rounded-lg shadow h-full">
      <div className="flex items-center gap-2 mb-4">
        <Package className="w-5 h-5 text-blue-600" />
        <h2 className="font-semibold">商品列表</h2>
      </div>
      
      {/* 上传区域 */}
      <div
        onClick={() => fileInputRef.current?.click()}
        onDrop={handleDrop}
        onDragOver={(e) => { e.preventDefault(); setDragOver(true); }}
        onDragLeave={() => setDragOver(false)}
        className={`border-2 border-dashed rounded-lg p-6 text-center cursor-pointer transition-colors mb-4 ${
          dragOver ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'
        }`}
      >
        <Upload className="w-8 h-8 mx-auto mb-2 text-gray-400" />
        <p className="text-sm text-gray-600">点击或拖拽上传 Excel</p>
        <p className="text-xs text-gray-400 mt-1">支持 .xlsx 格式</p>
        <input
          ref={fileInputRef}
          type="file"
          accept=".xlsx"
          onChange={(e) => e.target.files?.[0] && handleFileUpload(e.target.files[0])}
          className="hidden"
        />
      </div>
      
      {/* 商品列表 */}
      <div className="space-y-2 max-h-96 overflow-y-auto">
        {products.length === 0 ? (
          <p className="text-center text-gray-400 py-8">暂无商品数据</p>
        ) : (
          products.map((product) => (
            <div
              key={product.id}
              draggable
              className="border rounded-lg p-3 bg-gray-50 cursor-move hover:bg-gray-100 transition-colors"
            >
              <div className="flex justify-between items-start">
                <div>
                  <div className="font-medium text-sm">{product.name}</div>
                  <div className="text-xs text-gray-500 mt-1">
                    {product.length}×{product.width}×{product.height}cm · {product.weight}kg
                  </div>
                </div>
                <button
                  onClick={() => removeProduct(product.id)}
                  className="text-red-500 hover:text-red-700 p-1"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            </div>
          ))
        )}
      </div>
      
      {products.length > 0 && (
        <div className="mt-4 pt-4 border-t text-sm text-gray-500">
          共 {products.length} 个商品，可拖拽到右侧箱子
        </div>
      )}
    </div>
  );
}
EOF

# BoxView2D 组件
cat > src/components/BoxView2D.tsx << 'EOF'
import { usePackingStore } from '../stores/packingStore';
import { PlacedItem } from '../types';
import { Package, RotateCcw } from 'lucide-react';

export function BoxView2D() {
  const { selectedBox, placedItems, removePlacedItem, clearPlacedItems } = usePackingStore();
  
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
EOF

# Step 5: 更新 App.tsx
echo "🔧 Step 5: 更新主应用..."

cat > src/App.tsx << 'EOF'
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
EOF

# Step 6: 构建测试
echo "🔨 Step 6: 构建测试..."
npm run build

echo "✅ 装箱方案系统 MVP 开发完成！"
echo "📁 项目位置: ~/Projects/packing-system-ui"
echo "🚀 运行 'npm run dev' 启动开发服务器"
