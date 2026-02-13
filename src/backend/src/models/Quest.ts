import mongoose, { Document, Schema } from 'mongoose';

export interface IQuestObjective {
  id: string;
  description: string;
  target: string;
  current: number;
  required: number;
  completed: boolean;
}

export interface IQuestReward {
  experience?: number;
  currency?: number;
  items?: any[];
  attributes?: any;
}

export interface IQuest extends Document {
  questId: string;
  name: string;
  description: string;
  type: 'main' | 'side' | 'daily';
  objectives: IQuestObjective[];
  rewards: IQuestReward;
  prerequisites?: any;
  isRepeatable: boolean;
  cooldownHours?: number;
  createdAt: Date;
  updatedAt: Date;
}

const QuestObjectiveSchema: Schema = new Schema({
  id: { type: String, required: true },
  description: { type: String, required: true },
  target: { type: String, required: true },
  current: { type: Number, default: 0 },
  required: { type: Number, required: true },
  completed: { type: Boolean, default: false },
});

const QuestSchema: Schema = new Schema(
  {
    questId: {
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
      enum: ['main', 'side', 'daily'],
      required: true,
      index: true,
    },
    objectives: {
      type: [QuestObjectiveSchema],
      required: true,
    },
    rewards: {
      type: Schema.Types.Mixed,
      required: true,
    },
    prerequisites: {
      type: Schema.Types.Mixed,
    },
    isRepeatable: {
      type: Boolean,
      default: false,
    },
    cooldownHours: {
      type: Number,
    },
  },
  {
    timestamps: true,
  },
);

export default mongoose.model<IQuest>('Quest', QuestSchema);
