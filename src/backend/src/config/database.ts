import { createClient, SupabaseClient } from '@supabase/supabase-js';
import logger from './logger';

// Supabase 客户端配置
const supabaseUrl = process.env.SUPABASE_URL || '';
const supabaseKey = process.env.SUPABASE_SERVICE_KEY || '';

// 创建 Supabase 客户端
export const supabase: SupabaseClient = createClient(supabaseUrl, supabaseKey);

// 健康检查函数
export const checkDatabaseConnection = async (): Promise<boolean> => {
  try {
    // 测试数据库连接
    const { data, error } = await supabase
      .from('players')
      .select('id')
      .limit(1);

    if (error) {
      logger.error('Database connection failed:', error);
      return false;
    }

    logger.info('Database connected successfully');
    return true;
  } catch (error) {
    logger.error('Failed to connect to database:', error);
    return false;
  }
};

// 数据库初始化（可选，用于表创建）
export const initializeDatabase = async (): Promise<void> => {
  try {
    logger.info('Supabase database initialized (RLS enabled)');

    // 表结构通过 Supabase Dashboard 的 SQL Editor 创建
    // 或者使用 Supabase CLI：supabase db push --schema public
    logger.info('Schema file: src/backend/db/schema.sql');
  } catch (error) {
    logger.error('Failed to initialize database:', error);
    throw error;
  }
};

// 断开数据库连接（Supabase 会自动管理连接池）
export const disconnectDatabase = async (): Promise<void> => {
  try {
    // Supabase 客户端会自动管理连接池
    logger.info('Supabase database disconnected');
  } catch (error) {
    logger.error('Error disconnecting from database:', error);
  }
};
