import mongoose, { Document, Schema } from 'mongoose';

export interface IStoryChoice {
  id: string;
  text: string;
  nextNode: string;
  requirements?: any;
}

export interface IStoryNode extends Document {
  nodeId: string;
  chapterId: string;
  type: 'dialogue' | 'choice' | 'event';
  content: string;
  speaker?: string;
  choices?: IStoryChoice[];
  backgroundMusic?: string;
  soundEffect?: string;
  requirements?: any;
  createdAt: Date;
}

const StoryChoiceSchema: Schema = new Schema({
  id: { type: String, required: true },
  text: { type: String, required: true },
  nextNode: { type: String, required: true },
  requirements: { type: Schema.Types.Mixed },
});

const StoryNodeSchema: Schema = new Schema(
  {
    nodeId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    chapterId: {
      type: String,
      required: true,
      index: true,
    },
    type: {
      type: String,
      enum: ['dialogue', 'choice', 'event'],
      required: true,
    },
    content: {
      type: String,
      required: true,
    },
    speaker: {
      type: String,
    },
    choices: {
      type: [StoryChoiceSchema],
      default: [],
    },
    backgroundMusic: {
      type: String,
    },
    soundEffect: {
      type: String,
    },
    requirements: {
      type: Schema.Types.Mixed,
    },
  },
  {
    timestamps: { createdAt: true, updatedAt: false },
  },
);

// 创建索引
StoryNodeSchema.index({ chapterId: 1, nodeId: 1 });

export default mongoose.model<IStoryNode>('StoryNode', StoryNodeSchema);
