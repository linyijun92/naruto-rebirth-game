import mongoose, { Document, Schema } from 'mongoose';

export interface IItemEffect {
  type: 'attribute' | 'recover' | 'special';
  target: string;
  value: number;
}

export interface IItem extends Document {
  itemId: string;
  name: string;
  description: string;
  type: 'tool' | 'medicine' | 'equipment' | 'material';
  category: string;
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary';
  effect?: IItemEffect;
  price: number;
  sellPrice: number;
  maxStack: number;
  icon?: string;
  createdAt: Date;
  updatedAt: Date;
}

const ItemEffectSchema: Schema = new Schema({
  type: {
    type: String,
    enum: ['attribute', 'recover', 'special'],
    required: true,
  },
  target: { type: String, required: true },
  value: { type: Number, required: true },
});

const ItemSchema: Schema = new Schema(
  {
    itemId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    name: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      enum: ['tool', 'medicine', 'equipment', 'material'],
      required: true,
      index: true,
    },
    category: {
      type: String,
      required: true,
      index: true,
    },
    rarity: {
      type: String,
      enum: ['common', 'uncommon', 'rare', 'epic', 'legendary'],
      default: 'common',
      index: true,
    },
    effect: {
      type: ItemEffectSchema,
    },
    price: {
      type: Number,
      required: true,
      min: 0,
    },
    sellPrice: {
      type: Number,
      required: true,
      min: 0,
    },
    maxStack: {
      type: Number,
      default: 99,
    },
    icon: {
      type: String,
    },
  },
  {
    timestamps: true,
  },
);

// 创建索引
ItemSchema.index({ type: 1, category: 1 });
ItemSchema.index({ rarity: 1 });

export default mongoose.model<IItem>('Item', ItemSchema);
