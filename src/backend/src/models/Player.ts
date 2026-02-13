import mongoose, { Document, Schema } from 'mongoose';

export interface IPlayerStats {
  totalPlayTime: number; // 总游戏时间（秒）
  missionsCompleted: number; // 完成的任务数
  enemiesDefeated: number; // 击败的敌人数
  itemsCollected: number; // 收集的物品数
}

export interface IPlayerInventoryItem {
  itemId: string;
  quantity: number;
  equipped?: boolean;
}

export interface IPlayerAttributes {
  strength: number; // 力量
  agility: number; // 敏捷
  intelligence: number; // 智力
  chakra: number; // 查克拉控制
}

export interface IPlayer extends Document {
  playerId: string;
  userId: string;
  level: number;
  experience: number;
  gold: number;
  chakra: number;
  maxChakra: number;
  health: number;
  maxHealth: number;
  inventory: IPlayerInventoryItem[];
  equipment: Record<string, string>; // { category: itemId }
  attributes: IPlayerAttributes;
  currentChapter: string;
  flags: Record<string, any>; // 游戏标记
  stats: IPlayerStats;
  createdAt: Date;
  updatedAt: Date;
}

const PlayerStatsSchema: Schema = new Schema({
  totalPlayTime: { type: Number, default: 0 },
  missionsCompleted: { type: Number, default: 0 },
  enemiesDefeated: { type: Number, default: 0 },
  itemsCollected: { type: Number, default: 0 },
});

const PlayerInventoryItemSchema: Schema = new Schema({
  itemId: { type: String, required: true },
  quantity: { type: Number, required: true, min: 0 },
  equipped: { type: Boolean, default: false },
});

const PlayerAttributesSchema: Schema = new Schema({
  strength: { type: Number, default: 10 },
  agility: { type: Number, default: 10 },
  intelligence: { type: Number, default: 10 },
  chakra: { type: Number, default: 10 },
});

const PlayerSchema: Schema = new Schema(
  {
    playerId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    userId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    level: {
      type: Number,
      required: true,
      default: 1,
      min: 1,
    },
    experience: {
      type: Number,
      required: true,
      default: 0,
      min: 0,
    },
    gold: {
      type: Number,
      required: true,
      default: 0,
      min: 0,
    },
    chakra: {
      type: Number,
      required: true,
      default: 100,
      min: 0,
    },
    maxChakra: {
      type: Number,
      required: true,
      default: 100,
      min: 0,
    },
    health: {
      type: Number,
      required: true,
      default: 100,
      min: 0,
    },
    maxHealth: {
      type: Number,
      required: true,
      default: 100,
      min: 0,
    },
    inventory: {
      type: [PlayerInventoryItemSchema],
      default: [],
    },
    equipment: {
      type: Map,
      of: String,
      default: {},
    },
    attributes: {
      type: PlayerAttributesSchema,
      default: {
        strength: 10,
        agility: 10,
        intelligence: 10,
        chakra: 10,
      },
    },
    currentChapter: {
      type: String,
      default: 'chapter_1',
    },
    flags: {
      type: Map,
      of: mongoose.Schema.Types.Mixed,
      default: {},
    },
    stats: {
      type: PlayerStatsSchema,
      default: {
        totalPlayTime: 0,
        missionsCompleted: 0,
        enemiesDefeated: 0,
        itemsCollected: 0,
      },
    },
  },
  {
    timestamps: true,
  },
);

// 创建索引
PlayerSchema.index({ userId: 1 });
PlayerSchema.index({ level: -1 });
PlayerSchema.index({ experience: -1 });

export default mongoose.model<IPlayer>('Player', PlayerSchema);
