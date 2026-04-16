import { create } from 'zustand';
import type { Product, BoxType, PlacedItem } from '../types';

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
