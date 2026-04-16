import { useState, useRef } from 'react';
import { usePackingStore } from '../stores/packingStore';
import type { Product } from '../types';
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
