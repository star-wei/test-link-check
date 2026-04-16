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
