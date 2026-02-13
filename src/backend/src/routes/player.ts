import { Request, Response } from 'express';
import { ApiResponse } from '../../types/database';

// Supabase 客户端（从 config/database.ts 导入）
// const { supabase } = require('../../config/database');

// 暂时使用模拟数据，直到 Supabase 连接配置
const mockPlayers = new Map<string, any>();

// 注册玩家
export const register = async (req: Request, res: Response) => {
  try {
    const { username, email, password } = req.body;

    // 验证输入
    if (!username || !email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Username, email, and password are required',
      } as ApiResponse<null>);
    }

    // 检查用户名和邮箱是否已存在
    // const { data: existingUsers } = await supabase
    //   .from('players')
    //   .select('username, email')
    //   .or('username.eq.' + username)
    //   .or('email.eq.' + email);

    // if (existingUsers && existingUsers.length > 0) {
    //   return res.status(409).json({
    //     success: false,
    //     error: 'Username or email already exists',
    //   } as ApiResponse<null>);
    // }

    // 创建新玩家（使用 Supabase）
    // const { data, error } = await supabase
    //   .from('players')
    //   .insert({
    //     username,
    //     email,
    //     password_hash: password, // 实际中应该使用 bcrypt 哈希
    //     level: 1,
    //     experience: 0,
    //     experience_to_next_level: 100,
    //     currency: 0,
    //   })
    //   .select();

    // const player = data;

    // 创建玩家属性
    // await supabase.from('player_attributes').insert({
    //   player_id: player.id,
    //   chakra: 50,
    //   ninjutsu: 50,
    //   taijutsu: 50,
    //   intelligence: 50,
    //   speed: 50,
    //   luck: 50,
    // });

    // 临时模拟实现
    const playerId = `player_${Date.now()}`;
    const mockPlayer = {
      id: playerId,
      username,
      email,
      level: 1,
      experience: 0,
      experience_to_next_level: 100,
      currency: 0,
    };

    mockPlayers.set(playerId, mockPlayer);

    // 返回结果（不返回密码）
    const { password_hash, ...playerWithoutPassword } = mockPlayer;

    res.status(201).json({
      success: true,
      data: playerWithoutPassword,
    } as ApiResponse<any>);
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    } as ApiResponse<null>);
  }
};

// 登录玩家
export const login = async (req: Request, res: Response) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        error: 'Username and password are required',
      } as ApiResponse<null>);
    }

    // 查询玩家（使用 Supabase）
    // const { data, error } = await supabase
    //   .from('players')
    //   .select('*')
    //   .eq('username', username);

    // if (error || !data || data.length === 0) {
    //   return res.status(404).json({
    //     success: false,
    //     error: 'Player not found',
    //   } as ApiResponse<null>);
    // }

    // const player = data[0];

    // 验证密码（实际中应该使用 bcrypt.compare）
    // if (player.password_hash !== password) {
    //   return res.status(401).json({
    //     success: false,
    //     error: 'Invalid password',
    //   } as ApiResponse<null>);
    // }

    // 临时模拟实现
    const mockPlayer = Array.from(mockPlayers.values()).find(p => p.username === username);
    
    if (!mockPlayer) {
      return res.status(404).json({
        success: false,
        error: 'Player not found',
      } as ApiResponse<null>);
    }

    // 获取玩家属性
    // const { data: attributes } = await supabase
    //   .from('player_attributes')
    //   .select('*')
    //   .eq('player_id', mockPlayer.id);

    const playerWithAttributes = {
      ...mockPlayer,
      attributes: {
        chakra: 50,
        ninjutsu: 50,
        taijutsu: 50,
        intelligence: 50,
        speed: 50,
        luck: 50,
      },
    };

    // 生成 JWT Token（实际中应该使用 jsonwebtoken）
    const token = `mock-jwt-token-${mockPlayer.id}`;

    res.status(200).json({
      success: true,
      data: {
        player: playerWithAttributes,
        token,
      },
    } as ApiResponse<any>);
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    } as ApiResponse<null>);
  }
};

// 获取玩家信息
export const getPlayer = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({
        success: false,
        error: 'Player ID is required',
      } as ApiResponse<null>);
    }

    // 查询玩家（使用 Supabase）
    // const { data, error } = await supabase
    //   .from('v_players_full')
    //   .select('*')
    //   .eq('id', id);

    // if (error || !data || data.length === 0) {
    //   return res.status(404).json({
    //     success: false,
    //     error: 'Player not found',
    //   } as ApiResponse<null>);
    // }

    // const player = data[0];

    // 临时模拟实现
    const mockPlayer = mockPlayers.get(id);

    if (!mockPlayer) {
      return res.status(404).json({
        success: false,
        error: 'Player not found',
      } as ApiResponse<null>);
    }

    res.status(200).json({
      success: true,
      data: mockPlayer,
    } as ApiResponse<any>);
  } catch (error) {
    console.error('Get player error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    } as ApiResponse<null>);
  }
};

// 更新玩家信息
export const updatePlayer = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    if (!id) {
      return res.status(400).json({
        success: false,
        error: 'Player ID is required',
      } as ApiResponse<null>);
    }

    // 更新玩家（使用 Supabase）
    // const { data, error } = await supabase
    //   .from('players')
    //   .update(updates)
    //   .eq('id', id)
    //   .select();

    // if (error) {
    //   return res.status(500).json({
    //     success: false,
    //     error: 'Failed to update player',
    //   } as ApiResponse<null>);
    // }

    // 临时模拟实现
    const mockPlayer = mockPlayers.get(id);

    if (!mockPlayer) {
      return res.status(404).json({
        success: false,
        error: 'Player not found',
      } as ApiResponse<null>);
    }

    // 更新属性
    const updatedPlayer = {
      ...mockPlayer,
      ...updates,
      updated_at: new Date().toISOString(),
    };

    mockPlayers.set(id, updatedPlayer);

    res.status(200).json({
      success: true,
      data: updatedPlayer,
    } as ApiResponse<any>);
  } catch (error) {
    console.error('Update player error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    } as ApiResponse<null>);
  }
};

// 升级
export const levelUp = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({
        success: false,
        error: 'Player ID is required',
      } as ApiResponse<null>);
    }

    // 获取玩家信息
    // const { data, error } = await supabase
    //   .from('v_players_full')
    //   .select('*')
    //   .eq('id', id);

    // if (error || !data || data.length === 0) {
    //   return res.status(404).json({
    //     success: false,
    //     error: 'Player not found',
    //   } as ApiResponse<null>);
    // }

    // const player = data[0];
    const mockPlayer = mockPlayers.get(id);

    if (!mockPlayer) {
      return res.status(404).json({
        success: false,
        error: 'Player not found',
      } as ApiResponse<null>);
    }

    // 检查是否有足够经验
    if (mockPlayer.experience < mockPlayer.experience_to_next_level) {
      return res.status(400).json({
        success: false,
        error: 'Insufficient experience to level up',
        currentLevel: mockPlayer.level,
        requiredExperience: mockPlayer.experience_to_next_level,
      } as ApiResponse<null>);
    }

    // 升级
    const previousLevel = mockPlayer.level;
    const newLevel = previousLevel + 1;
    const updatedPlayer = {
      ...mockPlayer,
      level: newLevel,
      experience_to_next_level: mockPlayer.experience_to_next_level * 1.2,
      updated_at: new Date().toISOString(),
    };

    // 更新数据库
    // await supabase
    //   .from('players')
    //   .update({
    //     level: newLevel,
    //     experience_to_next_level: updatedPlayer.experience_to_next_level,
    //   })
    //   .eq('id', id);

    mockPlayers.set(id, updatedPlayer);

    res.status(200).json({
      success: true,
      data: {
        previousLevel,
        newLevel,
        experience: mockPlayer.experience,
        experienceToNextLevel: updatedPlayer.experience_to_next_level,
      },
    } as ApiResponse<any>);
  } catch (error) {
    console.error('Level up error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    } as ApiResponse<null>);
  }
};

// 添加经验
export const addExperience = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { experienceAmount } = req.body;

    if (!id || !experienceAmount) {
      return res.status(400).json({
        success: false,
        error: 'Player ID and experience amount are required',
      } as ApiResponse<null>);
    }

    // 获取玩家信息
    // const { data, error } = await supabase
    //   .from('v_players_full')
    //   .select('*')
    //   .eq('id', id);

    // if (error || !data || data.length === 0) {
    //   return res.status(404).json({
    //     success: false,
      //     error: 'Player not found',
    //   } as ApiResponse<null>);
    // }

    // const player = data[0];
    const mockPlayer = mockPlayers.get(id);

    if (!mockPlayer) {
      return res.status(404).json({
        success: false,
        error: 'Player not found',
      } as ApiResponse<null>);
    }

    // 添加经验
    const newExperience = mockPlayer.experience + experienceAmount;
    const levelUp = newExperience >= mockPlayer.experience_to_next_level;

    const updatedPlayer = {
      ...mockPlayer,
      experience: newExperience,
      updated_at: new Date().toISOString(),
    };

    // 如果升级，更新等级
    if (levelUp) {
      updatedPlayer.level += 1;
      updatedPlayer.experience_to_next_level = mockPlayer.experience_to_next_level * 1.2;
    }

    // 更新数据库
    // await supabase
    //   .from('players')
    //   .update({
    //     experience: updatedPlayer.experience,
    //     level: updatedPlayer.level,
    //     experience_to_next_level: updatedPlayer.experience_to_next_level,
    //   })
    //   .eq('id', id);

    mockPlayers.set(id, updatedPlayer);

    res.status(200).json({
      success: true,
      data: {
        previousExperience: mockPlayer.experience,
        addedExperience: experienceAmount,
        newExperience: updatedPlayer.experience,
        previousLevel: mockPlayer.level,
        newLevel: updatedPlayer.level,
        levelUp,
      },
    } as ApiResponse<any>);
  } catch (error) {
    console.error('Add experience error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
    } as ApiResponse<null>);
  }
};
