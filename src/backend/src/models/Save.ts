import mongoose, { Document, Schema } from 'mongoose';

export interface ISave extends Document {
  saveId: string;
  playerId: string;
  saveName: string;
  gameTime: string;
  playerLevel: number;
  attributes: {
    chakra: number;
    ninjutsu: number;
    taijutsu: number;
    intelligence: number;
    speed: number;
    luck: number;
  };
  currentChapter: string;
  inventory: any[];
  quests: any[];
  achievements: any[];
  playTime: number;
  isCloud: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const SaveSchema: Schema = new Schema(
  {
    saveId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    playerId: {
      type: String,
      required: true,
      index: true,
    },
    saveName: {
      type: String,
      required: true,
      maxlength: 50,
    },
    gameTime: {
      type: String,
      required: true,
    },
    playerLevel: {
      type: Number,
      default: 1,
    },
    attributes: {
      chakra: { type: Number, default: 100 },
      ninjutsu: { type: Number, default: 50 },
      taijutsu: { type: Number, default: 50 },
      intelligence: { type: Number, default: 50 },
      speed: { type: Number, default: 50 },
      luck: { type: Number, default: 50 },
    },
    currentChapter: {
      type: String,
      required: true,
    },
    inventory: {
      type: [Schema.Types.Mixed],
      default: [],
    },
    quests: {
      type: [Schema.Types.Mixed],
      default: [],
    },
    achievements: {
      type: [Schema.Types.Mixed],
      default: [],
    },
    playTime: {
      type: Number,
      default: 0,
    },
    isCloud: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  },
);

// 创建索引
SaveSchema.index({ playerId: 1, updatedAt: -1 });
SaveSchema.index({ isCloud: 1 });

export default mongoose.model<ISave>('Save', SaveSchema);
