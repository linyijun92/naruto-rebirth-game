import { Request, Response } from 'express';
import { supabase } from '../config/database';
import { ApiResponse } from '../../types/database';

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

    // 检查用户名和邮箱是否已存在（使用 Supabase）
    const { data: existingUsers, error: checkError } = await supabase
      .from('players')
      .select('username, email')
      .or('username.eq.' + username)
      .or('email.eq.' + email);

    if (checkError) {
      console.error('Check existing user error:', checkError);
      return res.status(500).json({
        success: false,
        error: 'Database error while checking existing user',
      } as ApiResponse<null>);
    }

    if (existingUsers && existingUsers.length > 0) {
      return res.status(409).json({
        success: false,
        error: 'Username or email already exists',
      } as ApiResponse<null>);
    }

    // 创建新玩家（使用 Supabase）
    const { data, error: insertError } = await supabase
      .from('players')
      .insert({
        username,
        email,
        password_hash: password, // 实际中应该使用 bcrypt 哈希
        level: 1,
        experience: 0,
        experience_to_next_level: 100,
        currency: 0,
      })
      .select();

    if (insertError) {
      console.error('Register player error:', insertError);
      return res.status(500).json({
        success: false,
        error: 'Failed to create player',
      } as ApiResponse<null>);
    }

    const player = data;

    // 获取玩家属性
    const { data: attributes, error: attrError } = await supabase
      .from('player_attributes')
      .select('*')
      .eq('player_id', player.id);

    if (attrError) {
      console.error('Get attributes error:', attrError);
      // 属性由触发器自动创建，这里只是获取
    }

    // 返回结果（不返回密码）
    const { password_hash, ...playerWithoutPassword } = player;

    res.status(201).json({
      success: true,
      data: {
        ...playerWithoutPassword,
        attributes: attributes ? attributes[0] : null,
      },
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
    const { data: players, error: queryError } = await supabase
      .from('v_players_full')
      .select('*')
      .eq('username', username);

    if (queryError) {
      console.error('Login query error:', queryError);
      return res.status(500).json({
        success: false,
        error: 'Database error while querying player',
      } as ApiResponse<null>);
    }

    if (!players || players.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Player not found',
      } as ApiResponse<null>);
    }

    const player = players[0];

    // 验证密码（实际中应该使用 bcrypt.compare）
    if (player.password_hash !== password) {
      return res.status(401).json({
        success: false,
        error: 'Invalid password',
      } as ApiResponse<null>);
    }

    // 生成 JWT Token（实际中应该使用 jsonwebtoken）
    const token = `mock-jwt-token-${player.id}`;

    res.status(200).json({
      success: true,
      data: {
        player,
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
    const { data: players, error: queryError } = await supabase
      .from('v_players_full')
      .select('*')
      .eq('id', id);

    if (queryError) {
      console.error('Get player query error:', queryError);
      return res.status(500).json({
        success: false,
        error: 'Database error while querying player',
      } as ApiResponse<null>);
    }

    if (!players || players.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Player not found',
      } as ApiResponse<null>);
    }

    res.status(200).json({
      success: true,
      data: players[0],
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
    const { data, error: updateError } = await supabase
      .from('players')
      .update(updates)
      .eq('id', id)
      .select();

    if (updateError) {
      console.error('Update player error:', updateError);
      return res.status(500).json({
        success: false,
        error: 'Failed to update player',
      } as ApiResponse<null>);
    }

    if (!data || data.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Player not found',
      } as ApiResponse<null>);
    }

    const updatedPlayer = data[0];

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
    const { data: players, error: queryError } = await supabase
      .from('v_players_full')
      .select('*')
      .eq('id', id);

    if (queryError) {
      console.error('Level up query error:', queryError);
      return res.status(500).json({
        success: false,
        error: 'Database error while querying player',
      } as ApiResponse<null>);
    }

    if (!players || players.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Player not found',
      } as ApiResponse<null>);
    }

    const player = players[0];

    // 检查是否有足够经验
    if (player.experience < player.experience_to_next_level) {
      return res.status(400).json({
        success: false,
        error: 'Insufficient experience to level up',
        currentLevel: player.level,
        requiredExperience: player.experience_to_next_level,
      } as ApiResponse<null>);
    }

    // 升级
    const previousLevel = player.level;
    const newLevel = previousLevel + 1;
    const updatedPlayer = {
      level: newLevel,
      experience_to_next_level: Math.floor(player.experience_to_next_level * 1.2),
      updated_at: new Date().toISOString(),
    };

    // 更新数据库（使用 Supabase）
    const { data, error: updateError } = await supabase
      .from('players')
      .update(updatedPlayer)
      .eq('id', id)
      .select();

    if (updateError) {
      console.error('Level up update error:', updateError);
      return res.status(500).json({
        success: false,
        error: 'Failed to update player',
      } as ApiResponse<null>);
    }

    res.status(200).json({
      success: true,
      data: {
        previousLevel,
        newLevel,
        experience: player.experience,
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
    const { data: players, error: queryError } = await supabase
      .from('v_players_full')
      .select('*')
      .eq('id', id);

    if (queryError) {
      console.error('Add experience query error:', queryError);
      return res.status(500).json({
        success: false,
        error: 'Database error while querying player',
      } as ApiResponse<null>);
    }

    if (!players || players.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Player not found',
      } as ApiResponse<null>);
    }

    const player = players[0];

    // 添加经验
    const newExperience = player.experience + experienceAmount;
    const levelUp = newExperience >= player.experience_to_next_level;

    const updatedPlayer = {
      experience: newExperience,
      updated_at: new Date().toISOString(),
    };

    // 如果升级，更新等级
    if (levelUp) {
      updatedPlayer.level = player.level + 1;
      updatedPlayer.experience_to_next_level = Math.floor(player.experience_to_next_level * 1.2);
    }

    // 更新数据库（使用 Supabase）
    const { data, error: updateError } = await supabase
      .from('players')
      .update(updatedPlayer)
      .eq('id', id)
      .select();

    if (updateError) {
      console.error('Add experience update error:', updateError);
      return res.status(500).json({
        success: false,
        error: 'Failed to update player',
      } as ApiResponse<null>);
    }

    res.status(200).json({
      success: true,
      data: {
        previousExperience: player.experience,
        addedExperience: experienceAmount,
        newExperience: newExperience,
        previousLevel: player.level,
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
