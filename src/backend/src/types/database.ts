// Supabase 数据类型定义
// 基于 Supabase 自动生成的 PostgreSQL 类型

export type Player = {
  id: string;
  username: string;
  email: string;
  password_hash: string;
  level: number;
  experience: number;
  experience_to_next_level: number;
  currency: number;
  created_at: string;
  updated_at: string;
};

export type PlayerAttribute = {
  id: string;
  player_id: string;
  chakra: number;
  ninjutsu: number;
  taijutsu: number;
  intelligence: number;
  speed: number;
  luck: number;
  updated_at: string;
};

export type Save = {
  id: string;
  player_id: string;
  save_name: string;
  save_type: 'auto' | 'manual';
  is_cloud: boolean;
  current_chapter: string;
  current_node: string;
  inventory: Record<string, any>;
  attributes: Record<string, any>;
  created_at: string;
  updated_at: string;
};

export type Quest = {
  id: string;
  title: string;
  description: string;
  quest_type: 'main' | 'side' | 'daily';
  requirements: Record<string, any>;
  rewards: Record<string, any>;
  created_at: string;
};

export type PlayerQuest = {
  id: string;
  player_id: string;
  quest_id: string;
  status: 'available' | 'accepted' | 'completed' | 'rewarded';
  progress: Record<string, any>;
  rewards_received: boolean;
  accepted_at: string | null;
  completed_at: string | null;
};

export type Item = {
  id: string;
  name: string;
  item_type: 'ninja_tool' | 'consumable' | 'equipment';
  rarity: 'N' | 'R' | 'SR' | 'SSR' | 'UR';
  price: number;
  effect: Record<string, any>;
  description: string;
};

export type PlayerInventory = {
  id: string;
  player_id: string;
  item_id: string;
  quantity: number;
  is_equipped: boolean;
  obtained_at: string;
};

export type HealthResponse = {
  status: 'ok' | 'error';
  timestamp: string;
  database: {
    connected: boolean;
    name: string;
  };
  uptime: number;
};

// 查询参数类型
export type CreatePlayerRequest = {
  username: string;
  email: string;
  password: string;
};

export type UpdatePlayerRequest = {
  level?: number;
  experience?: number;
  currency?: number;
  attributes?: {
    chakra?: number;
    ninjutsu?: number;
    taijutsu?: number;
    intelligence?: number;
    speed?: number;
    luck?: number;
  };
};

export type CreateSaveRequest = {
  player_id: string;
  save_name: string;
  save_type?: 'auto' | 'manual';
  current_chapter: string;
  current_node: string;
  inventory?: Record<string, any>;
  attributes?: Record<string, any>;
};

export type UpdateSaveRequest = Partial<CreateSaveRequest> & {
  id: string;
};

export type LoginRequest = {
  username: string;
  password: string;
};

export type RegisterRequest = CreatePlayerRequest;

export type AcceptQuestRequest = {
  player_id: string;
  quest_id: string;
};

export type CompleteQuestRequest = {
  player_id: string;
  quest_id: string;
};

export type PurchaseItemRequest = {
  player_id: string;
  item_id: string;
  quantity?: number;
};

// 工具类型
export type QueryOptions = {
  columns?: string;
  eq?: string;
  neq?: string;
  gt?: string;
  lt?: string;
  like?: string;
  limit?: number;
  offset?: number;
  order?: string;
};

export type ApiResponse<T = {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
};
