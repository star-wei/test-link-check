# 装箱方案系统 - MVP 开发计划

## 时间线（48小时）

### Day 1 - 核心骨架（24h）
- [x] 项目初始化：React + TypeScript + Vite + Tailwind
- [x] 2D 装箱可视化组件（CSS Grid 俯视图）
- [x] 拖拽交互（@dnd-kit）
- [x] 基础状态管理（Zustand）

### Day 2 - 功能完善（24h）
- [x] 数据导入（Excel解析 + 模拟API）
- [x] 箱型选择器
- [x] 导出功能（PDF清单 + Excel）
- [x] 异常提示系统

## 页面结构

```
src/
├── components/
│   ├── DataImport/          # 数据导入
│   ├── PackingEditor/       # 核心编辑区
│   │   ├── BoxView2D.tsx    # 2D俯视图
│   │   ├── ItemList.tsx     # 商品列表
│   │   └── DraggableItem.tsx # 可拖拽商品
│   ├── BoxSelector/         # 箱型选择
│   └── ExportPanel/         # 导出面板
├── stores/
│   └── packingStore.ts      # 全局状态
├── utils/
│   ├── excelParser.ts       # Excel解析
│   ├── pdfGenerator.ts      # PDF生成
│   └── packingCalculator.ts # 装箱计算
└── types/
    └── index.ts
```

## 核心数据模型

```typescript
interface Product {
  id: string;
  name: string;
  length: number;  // cm
  width: number;
  height: number;
  weight: number;
  quantity: number;
  fragile?: boolean;
}

interface BoxType {
  id: string;
  name: string;
  length: number;
  width: number;
  height: number;
  maxWeight: number;
}

interface PackedBox {
  boxType: BoxType;
  items: PackedItem[];
  utilization: number; // 0-100
}

interface PackedItem extends Product {
  position: { x: number; y: number; z: number };
  rotation: 'xyz' | 'xzy' | 'yxz' | 'yzx' | 'zxy' | 'zyx';
}
```

## 技术栈

- **框架**: React 18 + TypeScript
- **构建**: Vite
- **样式**: Tailwind CSS
- **拖拽**: @dnd-kit/core
- **状态**: Zustand
- **PDF**: jsPDF
- **Excel**: xlsx (sheetjs)
- **图标**: Lucide React

## 2D 视图设计

```
┌─────────────────────────────────────────┐
│  箱子 60×40×40cm  俯视图               │
│  ┌────────────────────────────────┐    │
│  │                                │    │
│  │    📦A        📦B             │    │
│  │   15×8        20×10           │    │
│  │                                │    │
│  │         📦C                   │    │
│  │        30×20                  │    │
│  │                                │    │
│  └────────────────────────────────┘    │
│  利用率: 78%  剩余空间: ████░░░░░░      │
└─────────────────────────────────────────┘
```

## 关键交互

1. **从列表拖入箱子**: 商品从左侧列表拖到右侧箱子区域
2. **箱内调整**: 在箱子区域内拖拽调整位置
3. **自动排列**: 点击"智能排列"触发算法优化
4. **实时反馈**: 显示利用率、运费估算

## 与后端对接

```typescript
// 调用现有 Python 算法
async function calculatePacking(products: Product[]): Promise<PackedBox[]> {
  const response = await fetch('/api/packing/calculate', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ products })
  });
  return response.json();
}
```

## 第一优先级（必须完成）

1. 商品列表展示
2. 单个箱子2D俯视图
3. 拖拽放入/移出
4. 基础导出（JSON/Excel）

## 第二优先级（时间允许）

1. 多箱子管理
2. PDF打印清单
3. 3D切换按钮（预留接口）
4. 箱型智能推荐
