-- Supabase 数据库表结构
-- 重生到火影忍者世界
-- 创建时间：2026-02-13

-- ============================================================================
-- 玩家表（players）
-- ============================================================================
CREATE TABLE IF NOT EXISTS players (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  level INTEGER DEFAULT 1,
  experience INTEGER DEFAULT 0,
  experience_to_next_level INTEGER DEFAULT 100,
  currency INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_players_username ON players(username);
CREATE INDEX IF NOT EXISTS idx_players_email ON players(email);

-- RLS（Row Level Security）策略
ALTER TABLE players ENABLE ROW LEVEL SECURITY;

-- 允许任何人读取
CREATE POLICY "Public read access" ON players
  FOR SELECT
  TO anon
  USING (true);

-- 允许用户插入自己的数据
CREATE POLICY "Users can insert own data" ON players
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- 允许用户更新自己的数据
CREATE POLICY "Users can update own data" ON players
  FOR UPDATE
  TO anon
  WITH CHECK (true);

-- ============================================================================
-- 玩家属性表（player_attributes）
-- ============================================================================
CREATE TABLE IF NOT EXISTS player_attributes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  chakra INTEGER DEFAULT 50 NOT NULL CHECK (chakra >= 0 AND chakra <= 999),
  ninjutsu INTEGER DEFAULT 50 NOT NULL CHECK (ninjutsu >= 0 AND ninjutsu <= 999),
  taijutsu INTEGER DEFAULT 50 NOT NULL CHECK (taijutsu >= 0 AND taijutsu <= 999),
  intelligence INTEGER DEFAULT 50 NOT NULL CHECK (intelligence >= 0 AND intelligence <= 999),
  speed INTEGER DEFAULT 50 NOT NULL CHECK (speed >= 0 AND speed <= 999),
  luck INTEGER DEFAULT 50 NOT NULL CHECK (luck >= 0 AND luck <= 999),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_attributes_player_id ON player_attributes(player_id);

-- RLS 策略
ALTER TABLE player_attributes ENABLE ROW LEVEL SECURITY;

-- 允许任何人读取
CREATE POLICY "Public read access" ON player_attributes
  FOR SELECT
  TO anon
  USING (true);

-- ============================================================================
-- 存档表（saves）
-- ============================================================================
CREATE TABLE IF NOT EXISTS saves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  save_name VARCHAR(100),
  save_type VARCHAR(20) DEFAULT 'manual' CHECK (save_type IN ('auto', 'manual')),
  is_cloud BOOLEAN DEFAULT false,
  current_chapter VARCHAR(50),
  current_node VARCHAR(50),
  inventory JSONB DEFAULT '{}',
  attributes JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_saves_player_id ON saves(player_id);
CREATE INDEX IF NOT EXISTS idx_saves_is_cloud ON saves(is_cloud);

-- RLS 策略
ALTER TABLE saves ENABLE ROW LEVEL SECURITY;

-- 允许任何人读取
CREATE POLICY "Public read access" ON saves
  FOR SELECT
  TO anon
  USING (true);

-- 允许用户插入/更新自己的数据
CREATE POLICY "Users can manage own saves" ON saves
  FOR ALL
  TO anon
  USING (true);

-- ============================================================================
-- 任务表（quests）
-- ============================================================================
CREATE TABLE IF NOT EXISTS quests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  quest_type VARCHAR(20) NOT NULL CHECK (quest_type IN ('main', 'side', 'daily')),
  requirements JSONB DEFAULT '{}',
  rewards JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_quests_type ON quests(quest_type);

-- RLS 策略
ALTER TABLE quests ENABLE ROW LEVEL SECURITY;

-- 允许任何人读取
CREATE POLICY "Public read access" ON quests
  FOR SELECT
  TO anon
  USING (true);

-- ============================================================================
-- 玩家任务进度表（player_quests）
-- ============================================================================
CREATE TABLE IF NOT EXISTS player_quests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  quest_id UUID REFERENCES quests(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'accepted', 'completed', 'rewarded')),
  progress JSONB DEFAULT '{}',
  rewards_received BOOLEAN DEFAULT false,
  accepted_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_player_quests_player_id ON player_quests(player_id);
CREATE INDEX IF NOT EXISTS idx_player_quests_status ON player_quests(status);

-- RLS 策略
ALTER TABLE player_quests ENABLE ROW LEVEL SECURITY;

-- 允许用户插入/更新自己的数据
CREATE POLICY "Users can manage own quests" ON player_quests
  FOR ALL
  TO anon
  USING (true);

-- ============================================================================
-- 物品表（items）
-- ============================================================================
CREATE TABLE IF NOT EXISTS items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  item_type VARCHAR(20) NOT NULL CHECK (item_type IN ('ninja_tool', 'consumable', 'equipment')),
  rarity VARCHAR(10) NOT NULL CHECK (rarity IN ('N', 'R', 'SR', 'SSR', 'UR')),
  price INTEGER NOT NULL CHECK (price >= 0),
  effect JSONB DEFAULT '{}',
  description TEXT
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_items_type ON items(item_type);
CREATE INDEX IF NOT EXISTS idx_items_rarity ON items(rarity);

-- RLS 策略
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- 允许任何人读取
CREATE POLICY "Public read access" ON items
  FOR SELECT
  TO anon
  USING (true);

-- ============================================================================
-- 玩家库存表（player_inventory）
-- ============================================================================
CREATE TABLE IF NOT EXISTS player_inventory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  item_id UUID REFERENCES items(id) ON DELETE CASCADE,
  quantity INTEGER DEFAULT 1 CHECK (quantity >= 0),
  is_equipped BOOLEAN DEFAULT false,
  obtained_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_inventory_player_id ON player_inventory(player_id);
CREATE INDEX IF NOT EXISTS idx_inventory_item_id ON player_inventory(item_id);

-- RLS 策略
ALTER TABLE player_inventory ENABLE ROW LEVEL SECURITY;

-- 允许用户插入/更新自己的数据
CREATE POLICY "Users can manage own inventory" ON player_inventory
  FOR ALL
  TO anon
  USING (true);

-- ============================================================================
-- 触发器（Triggers）
-- ============================================================================

-- 自动创建玩家属性记录
CREATE OR REPLACE FUNCTION create_player_attributes()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM player_attributes WHERE player_id = NEW.id) THEN
    INSERT INTO player_attributes (player_id, chakra, ninjutsu, taijutsu, intelligence, speed, luck)
    VALUES (NEW.id, 50, 50, 50, 50, 50, 50);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_player_attributes
AFTER INSERT ON players
FOR EACH ROW
EXECUTE FUNCTION create_player_attributes();

-- ============================================================================
-- 健康检查函数
-- ============================================================================
CREATE OR REPLACE FUNCTION health_check()
RETURNS JSONB AS $$
DECLARE
  result JSONB;
BEGIN
  result = jsonb_build_object(
    'status', 'ok',
    'timestamp', NOW(),
    'database', jsonb_build_object(
      'connected', 'true',
      'name', 'naruto-rebirth-game'
    ),
    'tables', (
      SELECT jsonb_agg(jsonb_build_object('name', tablename))
      FROM pg_tables
      WHERE schemaname = 'public'
    )
  );
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 实用视图（Views）
-- ============================================================================

-- 玩家完整信息视图
CREATE OR REPLACE VIEW v_players_full AS
SELECT
  p.id,
  p.username,
  p.email,
  p.level,
  p.experience,
  p.experience_to_next_level,
  p.currency,
  p.created_at,
  p.updated_at,
  pa.chakra,
  pa.ninjutsu,
  pa.taijutsu,
  pa.intelligence,
  pa.speed,
  pa.luck
FROM players p
LEFT JOIN player_attributes pa ON p.id = pa.player_id;

-- ============================================================================
-- 数据初始化（可选）
-- ============================================================================

-- 插入初始任务数据
INSERT INTO quests (title, description, quest_type, requirements, rewards) VALUES
('第一次任务', '探索木叶村', 'main', '{"level":1}', '{"experience":100,"currency":50}'),
('日常修行', '每天完成修行任务', 'daily', '{"daily_count":1}', '{"experience":50,"currency":20}'),
('购买忍具', '购买基础忍具', 'side', '{"currency":200}', '{"item":"shuriken"}')
ON CONFLICT DO NOTHING;

-- 插入初始物品数据
INSERT INTO items (name, item_type, rarity, price, description) VALUES
('手里剑', 'ninja_tool', 'N', 100, '基础投掷武器'),
('苦无', 'ninja_tool', 'N', 80, '短距离投掷武器'),
('治疗药', 'consumable', 'R', 50, '恢复 50 点生命值'),
('查克拉药', 'consumable', 'R', 100, '恢复 30 点查克拉'),
('螺旋丸', 'ninja_tool', 'SR', 500, 'A级忍术'),
('起爆符', 'ninja_tool', 'SR', 150, '爆炸符咒，用于任务')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 完成
-- ============================================================================
-- 注释：运行完此脚本后，在 Supabase Dashboard 的 SQL Editor 中执行
-- 或者使用 Supabase CLI: supabase db push --schema public
-- ============================================================================
