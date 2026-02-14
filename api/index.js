const { supabase, checkDatabaseConnection } = require('./database');

// Helper function to parse request body
const parseBody = (req) => {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', (chunk) => {
      body += chunk.toString();
    });
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (error) {
        reject(error);
      }
    });
    req.on('error', reject);
  });
};

// Helper function to send JSON response
const sendJson = (res, statusCode, data) => {
  res.statusCode = statusCode;
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify(data));
};

// Helper function to extract player ID from Authorization header
const getPlayerIdFromToken = (req) => {
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }

  const token = authHeader.substring(7); // Remove "Bearer " prefix

  console.log('[getPlayerIdFromToken] Full token:', token);
  console.log('[getPlayerIdFromToken] Token length:', token.length);

  // Mock token format: "mock-jwt-token-<player_id>"
  if (token.startsWith('mock-jwt-token-')) {
    const playerId = token.substring(16); // Extract player_id from "mock-jwt-token-"
    console.log('[getPlayerIdFromToken] Extracted player ID:', playerId);
    console.log('[getPlayerIdFromToken] Player ID length:', playerId.length);
    return playerId;
  }

  // If using real JWT, you would decode the token here
  // For now, we'll just return null
  return null;
};

// Player registration
const registerPlayer = async (req, res) => {
  try {
    const body = await parseBody(req);
    const { username, email, password } = body;

    if (!username || !email || !password) {
      return sendJson(res, 400, {
        success: false,
        error: 'Username, email, and password are required'
      });
    }

    // Check if player already exists
    const { data: existingPlayer } = await supabase
      .from('players')
      .select('id')
      .or(`username.eq.${username},email.eq.${email}`)
      .single();

    if (existingPlayer) {
      return sendJson(res, 409, {
        success: false,
        error: 'Player already exists'
      });
    }

    // Create password hash (simplified - use bcrypt in production)
    const passwordHash = `hash_${password}`;

    // Create player with attribute_points
    const { data: player, error } = await supabase
      .from('players')
      .insert([{
        username,
        email,
        password_hash: passwordHash,
        level: 1,
        experience: 0,
        experience_to_next_level: 100,
        currency: 100,  // Initial currency
        attribute_points: 10  // Initial attribute points
      }])
      .select()
      .single();

    if (error) throw error;

    // Create player attributes
    const { error: attrError } = await supabase
      .from('player_attributes')
      .insert([{
        player_id: player.id,
        chakra: 50,
        ninjutsu: 50,
        taijutsu: 50,
        intelligence: 50,
        speed: 50,
        luck: 50
      }]);

    if (attrError) throw attrError;

    sendJson(res, 201, {
      success: true,
      data: player
    });
  } catch (error) {
    console.error('Registration error:', error);
    sendJson(res, 500, {
      success: false,
      error: 'Failed to register player'
    });
  }
};

// Player login
const loginPlayer = async (req, res) => {
  try {
    const body = await parseBody(req);
    const { username, password } = body;

    if (!username || !password) {
      return sendJson(res, 400, {
        success: false,
        error: 'Username and password are required'
      });
    }

    const passwordHash = `hash_${password}`;

    const { data: player, error } = await supabase
      .from('players')
      .select('*, player_attributes(*)')
      .eq('username', username)
      .eq('password_hash', passwordHash)
      .single();

    if (error || !player) {
      return sendJson(res, 401, {
        success: false,
        error: 'Invalid credentials'
      });
    }

    sendJson(res, 200, {
      success: true,
      data: {
        player,
        token: 'mock-jwt-token-' + player.id
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    sendJson(res, 500, {
      success: false,
      error: 'Failed to login'
    });
  }
};

// Get player
const getPlayer = async (req, res) => {
  try {
    const { query } = req;
    const playerId = query.id || query.player_id;

    if (!playerId) {
      return sendJson(res, 400, {
        success: false,
        error: 'Player ID is required'
      });
    }

    const { data: player, error } = await supabase
      .from('players')
      .select('*, player_attributes(*)')
      .eq('id', playerId)
      .single();

    if (error || !player) {
      return sendJson(res, 404, {
        success: false,
        error: 'Player not found'
      });
    }

    sendJson(res, 200, {
      success: true,
      data: player
    });
  } catch (error) {
    console.error('Get player error:', error);
    sendJson(res, 500, {
      success: false,
      error: 'Failed to get player'
    });
  }
};

// ==================== 新增的 API 端点函数（已修复 UUID 问题） ====================

// 加载存档
const loadSave = async (req, res) => {
  try {
    const { query } = req;
    const saveId = query.id || query.saveId;

    console.log('[loadSave] Starting loadSave, saveId:', saveId);

    if (!saveId) {
      return sendJson(res, 400, {
        success: false,
        error: 'Save ID is required'
      });
    }

    // Extract player ID from token
    const playerId = getPlayerIdFromToken(req);
    console.log('[loadSave] Player ID from token:', playerId);

    if (!playerId) {
      return sendJson(res, 401, {
        success: false,
        error: 'Unauthorized'
      });
    }

    // 从数据库加载存档数据
    console.log('[loadSave] Querying saves table for saveId:', saveId);
    const { data: save, error } = await supabase
      .from('saves')
      .select('*')
      .filter('id', 'eq', saveId)
      .single();

    if (error) {
      console.error('[loadSave] Database query error:', error);
      throw error;
    }

    if (!save) {
      console.log('[loadSave] Save not found');
      return sendJson(res, 404, {
        success: false,
        error: 'Save not found'
      });
    }

    // 验证存档所有权
    console.log('[loadSave] Save player_id:', save.player_id, 'Player ID:', playerId);
    if (save.player_id !== playerId) {
      console.log('[loadSave] Permission denied');
      return sendJson(res, 403, {
        success: false,
        error: 'You do not have permission to load this save'
      });
    }

    // 构建返回数据
    const saveData = {
      saveName: save.save_name,
      saveData: save.save_data,
      createdAt: save.created_at,
      updatedAt: save.updated_at
    };

    console.log('[loadSave] Save loaded successfully:', saveData);
    sendJson(res, 200, {
      success: true,
      data: {
        save: saveData,
        message: '存档加载成功'
      }
    });
  } catch (error) {
    console.error('[loadSave] Error:', error);
    console.error('[loadSave] Error stack:', error.stack);
    sendJson(res, 500, {
      success: false,
      error: 'Failed to load save'
    });
  }
};

// 创建存档
const createSave = async (req, res) => {
  try {
    const body = await parseBody(req);
    const { saveName, saveData } = body;

    console.log('[createSave] Starting createSave, saveName:', saveName);

    if (!saveName || !saveData) {
      return sendJson(res, 400, {
        success: false,
        error: 'Save name and save data are required'
      });
    }

    // Extract player ID from token
    const playerId = getPlayerIdFromToken(req);
    console.log('[createSave] Player ID from token:', playerId);

    if (!playerId) {
      return sendJson(res, 401, {
        success: false,
        error: 'Unauthorized'
      });
    }

    // 创建存档记录
    console.log('[createSave] Inserting save record');
    const { data: save, error } = await supabase
      .from('saves')
      .insert([{
        player_id: playerId,
        save_name: saveName,
        save_data: saveData,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }])
      .select()
      .single();

    if (error) {
      console.error('[createSave] Database insert error:', error);
      throw error;
    }

    console.log('[createSave] Save created successfully:', save);
    sendJson(res, 201, {
      success: true,
      data: save,
      message: '存档创建成功'
    });
  } catch (error) {
    console.error('[createSave] Error:', error);
    console.error('[createSave] Error stack:', error.stack);
    sendJson(res, 500, {
      success: false,
      error: 'Failed to create save'
    });
  }
};

// 删除存档
const deleteSave = async (req, res) => {
  try {
    const { query } = req;
    const saveId = query.id || query.saveId;

    console.log('[deleteSave] Starting deleteSave, saveId:', saveId);

    if (!saveId) {
      return sendJson(res, 400, {
        success: false,
        error: 'Save ID is required'
      });
    }

    // Extract player ID from token
    const playerId = getPlayerIdFromToken(req);
    console.log('[deleteSave] Player ID from token:', playerId);

    if (!playerId) {
      return sendJson(res, 401, {
        success: false,
        error: 'Unauthorized'
      });
    }

    // 获取存档信息以验证所有权
    console.log('[deleteSave] Fetching save info');
    const { data: save, error } = await supabase
      .from('saves')
      .select('*')
      .filter('id', 'eq', saveId)
      .single();

    if (error || !save) {
      console.log('[deleteSave] Save not found');
      return sendJson(res, 404, {
        success: false,
        error: 'Save not found'
      });
    }

    // 验证所有权
    console.log('[deleteSave] Save player_id:', save.player_id, 'Player ID:', playerId);
    if (save.player_id !== playerId) {
      console.log('[deleteSave] Permission denied');
      return sendJson(res, 403, {
        success: false,
        error: 'You do not have permission to delete this save'
      });
    }

    // 删除存档
    console.log('[deleteSave] Deleting save');
    const { error: deleteError } = await supabase
      .from('saves')
      .delete()
      .filter('id', 'eq', saveId);

    if (deleteError) {
      console.error('[deleteSave] Database delete error:', deleteError);
      throw deleteError;
    }

    console.log('[deleteSave] Save deleted successfully');
    sendJson(res, 200, {
      success: true,
      message: '存档删除成功'
    });
  } catch (error) {
    console.error('[deleteSave] Error:', error);
    console.error('[deleteSave] Error stack:', error.stack);
    sendJson(res, 500, {
      success: false,
      error: 'Failed to delete save'
    });
  }
};

// 获取存档列表
const getSaves = async (req, res) => {
  try {
    console.log('[getSaves] Starting getSaves');

    // Extract player ID from token
    const playerId = getPlayerIdFromToken(req);
    console.log('[getSaves] Player ID from token:', playerId);

    if (!playerId) {
      return sendJson(res, 401, {
        success: false,
        error: 'Unauthorized'
      });
    }

    // 查询存档列表
    console.log('[getSaves] Querying saves table for playerId:', playerId);
    const { data: saves, error } = await supabase
      .from('saves')
      .select('*')
      .filter('player_id', 'eq', playerId)
      .order('updated_at', { ascending: false })
      .limit(10);

    if (error) {
      console.error('[getSaves] Database query error:', error);
      throw error;
    }

    console.log('[getSaves] Saves fetched successfully, count:', saves ? saves.length : 0);
    sendJson(res, 200, {
      success: true,
      data: {
        saves: saves || []
      }
    });
  } catch (error) {
    console.error('[getSaves] Error:', error);
    console.error('[getSaves] Error stack:', error.stack);
    sendJson(res, 500, {
      success: false,
      error: 'Failed to get saves'
    });
  }
};

// 完成任务
const completeQuest = async (req, res) => {
  try {
    const { query } = req;
    const questId = query.id || query.questId;

    console.log('[completeQuest] Starting completeQuest, questId:', questId);

    if (!questId) {
      return sendJson(res, 400, {
        success: false,
        error: 'Quest ID is required'
      });
    }

    // Extract player ID from token
    const playerId = getPlayerIdFromToken(req);
    console.log('[completeQuest] Player ID from token:', playerId);

    if (!playerId) {
      return sendJson(res, 401, {
        success: false,
        error: 'Unauthorized'
      });
    }

    // 获取任务信息
    console.log('[completeQuest] Fetching quest info');
    const { data: quest, error } = await supabase
      .from('quests')
      .select('*')
      .filter('id', 'eq', questId)
      .single();

    if (error || !quest) {
      console.log('[completeQuest] Quest not found');
      return sendJson(res, 404, {
        success: false,
        error: 'Quest not found'
      });
    }

    // 检查任务是否可以完成
    console.log('[completeQuest] Quest status:', quest.status);
    if (quest.status !== 'available' && quest.status !== 'in_progress') {
      return sendJson(res, 400, {
        success: false,
        error: 'Quest cannot be completed'
      });
    }

    // 更新任务状态为 completed
    console.log('[completeQuest] Updating quest status');
    const { error: updateError } = await supabase
      .from('quests')
      .update({
        status: 'completed',
        completed_at: new Date().toISOString()
      })
      .filter('id', 'eq', questId);

    if (updateError) {
      console.error('[completeQuest] Database update error:', updateError);
      throw updateError;
    }

    // 解析奖励
    const rewards = {
      currency: quest.currency_reward || 0,
      experience: quest.experience_reward || 0,
      attributeIncreases: {
        chakra: quest.chakra_reward || 0,
        ninjutsu: quest.ninjutsu_reward || 0,
        taijutsu: quest.taijutsu_reward || 0,
        intelligence: quest.intelligence_reward || 0,
        speed: quest.speed_reward || 0,
        luck: quest.luck_reward || 0
      }
    };

    // 更新玩家数据
    if (rewards.currency > 0) {
      await supabase
        .from('players')
        .update({
          currency: supabase.raw(`currency + ${rewards.currency}`)
        })
        .filter('id', 'eq', playerId);
    }

    if (rewards.experience > 0) {
      await supabase
        .from('players')
        .update({
          experience: supabase.raw(`experience + ${rewards.experience}`)
        })
        .filter('id', 'eq', playerId);
    }

    // 更新属性
    const { error: attrError } = await supabase
      .from('player_attributes')
      .select('*')
      .filter('player_id', 'eq', playerId)
      .single();

    if (!attrError) {
      const updates = {};
      if (rewards.attributeIncreases.chakra > 0) {
        updates.chakra = supabase.raw(`chakra + ${rewards.attributeIncreases.chakra}`);
      }
      if (rewards.attributeIncreases.ninjutsu > 0) {
        updates.ninjutsu = supabase.raw(`ninjutsu + ${rewards.attributeIncreases.ninjutsu}`);
      }
      if (rewards.attributeIncreases.taijutsu > 0) {
        updates.taijutsu = supabase.raw(`taijutsu + ${rewards.attributeIncreases.taijutsu}`);
      }
      if (rewards.attributeIncreases.intelligence > 0) {
        updates.intelligence = supabase.raw(`intelligence + ${rewards.attributeIncreases.intelligence}`);
      }
      if (rewards.attributeIncreases.speed > 0) {
        updates.speed = supabase.raw(`speed + ${rewards.attributeIncreases.speed}`);
      }
      if (rewards.attributeIncreases.luck > 0) {
        updates.luck = supabase.raw(`luck + ${rewards.attributeIncreases.luck}`);
      }

      if (Object.keys(updates).length > 0) {
        await supabase
          .from('player_attributes')
          .update(updates)
          .filter('player_id', 'eq', playerId);
      }
    }

    console.log('[completeQuest] Quest completed successfully');
    sendJson(res, 200, {
      success: true,
      data: {
        rewards: {
          currency: rewards.currency,
          experience: rewards.experience,
          description: `获得 ${rewards.currency} 货币和 ${rewards.experience} 经验值`
        }
      },
      message: '任务完成'
    });
  } catch (error) {
    console.error('[completeQuest] Error:', error);
    console.error('[completeQuest] Error stack:', error.stack);
    sendJson(res, 500, {
      success: false,
      error: 'Failed to complete quest'
    });
  }
};

// 领取任务奖励
const claimQuestReward = async (req, res) => {
  try {
    const { query } = req;
    const questId = query.id || query.questId;

    console.log('[claimQuestReward] Starting claimQuestReward, questId:', questId);

    if (!questId) {
      return sendJson(res, 400, {
        success: false,
        error: 'Quest ID is required'
      });
    }

    // Extract player ID from token
    const playerId = getPlayerIdFromToken(req);
    console.log('[claimQuestReward] Player ID from token:', playerId);

    if (!playerId) {
      return sendJson(res, 401, {
        success: false,
        error: 'Unauthorized'
      });
    }

    // 获取任务信息
    console.log('[claimQuestReward] Fetching quest info');
    const { data: quest, error } = await supabase
      .from('quests')
      .select('*')
      .filter('id', 'eq', questId)
      .single();

    if (error || !quest) {
      console.log('[claimQuestReward] Quest not found');
      return sendJson(res, 404, {
        success: false,
        error: 'Quest not found'
      });
    }

    // 检查任务是否已完成且未领取
    console.log('[claimQuestReward] Quest status:', quest.status, 'claimed:', quest.claimed);
    if (quest.status !== 'completed' || quest.claimed) {
      return sendJson(res, 400, {
        success: false,
        error: 'Reward cannot be claimed'
      });
    }

    // 标记为已领取
    console.log('[claimQuestReward] Marking quest as claimed');
    const { error: updateError } = await supabase
      .from('quests')
      .update({
        claimed: true,
        claimed_at: new Date().toISOString()
      })
      .filter('id', 'eq', questId);

    if (updateError) {
      console.error('[claimQuestReward] Database update error:', updateError);
      throw updateError;
    }

    // 解析奖励
    const rewards = {
      currency: quest.currency_reward || 0,
      description: `奖励：${quest.currency_reward || 0} 货币`
    };

    // 更新玩家货币
    if (rewards.currency > 0) {
      await supabase
        .from('players')
        .update({
          currency: supabase.raw(`currency + ${rewards.currency}`)
        })
        .filter('id', 'eq', playerId);
    }

    console.log('[claimQuestReward] Reward claimed successfully');
    sendJson(res, 200, {
      success: true,
      data: {
        rewards,
        message: '奖励领取成功'
      }
    });
  } catch (error) {
    console.error('[claimQuestReward] Error:', error);
    console.error('[claimQuestReward] Error stack:', error.stack);
    sendJson(res, 500, {
      success: false,
      error: 'Failed to claim quest reward'
    });
  }
};

// 获取任务列表
const getQuests = async (req, res) => {
  try {
    const { query } = req;
    const questType = query.type || 'all'; // all, main, side, daily

    console.log('[getQuests] Starting getQuests, type:', questType);

    let queryBuilder = supabase.from('quests');

    if (questType !== 'all') {
      queryBuilder = queryBuilder.eq('quest_type', questType);
    }

    const { data: quests, error } = await queryBuilder
      .select('*')
      .order('created_at', { ascending: false })
      .limit(20);

    if (error) {
      console.error('[getQuests] Database query error:', error);
      throw error;
    }

    console.log('[getQuests] Quests fetched successfully, count:', quests ? quests.length : 0);
    sendJson(res, 200, {
      success: true,
      data: {
        quests: quests || []
      }
    });
  } catch (error) {
    console.error('[getQuests] Error:', error);
    console.error('[getQuests] Error stack:', error.stack);
    sendJson(res, 500, {
      success: false,
      error: 'Failed to get quests'
    });
  }
};

// 升级属性
const upgradeAttribute = async (req, res) => {
  try {
    const body = await parseBody(req);
    const { attribute, amount } = body;

    console.log('[upgradeAttribute] Starting upgradeAttribute, attribute:', attribute, 'amount:', amount);

    if (!attribute) {
      return sendJson(res, 400, {
        success: false,
        error: 'Attribute is required'
      });
    }

    if (!amount || amount < 1) {
      return sendJson(res, 400, {
        success: false,
        error: 'Amount must be at least 1'
      });
    }

    // Extract player ID from token
    const playerId = getPlayerIdFromToken(req);
    console.log('[upgradeAttribute] Player ID from token:', playerId);

    if (!playerId) {
      return sendJson(res, 401, {
        success: false,
        error: 'Unauthorized'
      });
    }

    // 获取玩家属性点数
    console.log('[upgradeAttribute] Fetching player attribute points');
    const { data: player, error: playerError } = await supabase
      .from('players')
      .select('attribute_points')
      .filter('id', 'eq', playerId)
      .single();

    if (playerError || !player) {
      console.log('[upgradeAttribute] Player not found');
      return sendJson(res, 404, {
        success: false,
        error: 'Player not found'
      });
    }

    const attributePoints = player.attribute_points || 0;
    const requiredPoints = amount * 1; // 每次升级 1 点

    console.log('[upgradeAttribute] Current attribute points:', attributePoints, 'Required:', requiredPoints);

    if (attributePoints < requiredPoints) {
      return sendJson(res, 400, {
        success: false,
        error: 'Not enough attribute points'
      });
    }

    // 获取当前属性值
    console.log('[upgradeAttribute] Fetching player attributes');
    const { data: attributes, error: attrError } = await supabase
      .from('player_attributes')
      .select('*')
      .filter('player_id', 'eq', playerId)
      .single();

    if (attrError || !attributes) {
      console.log('[upgradeAttribute] Attributes not found');
      return sendJson(res, 404, {
        success: false,
        error: 'Attributes not found'
      });
    }

    // 检查属性是否已满级
    const currentValue = attributes[attribute] || 0;
    console.log('[upgradeAttribute] Current attribute value:', currentValue);

    if (currentValue >= 100) {
      return sendJson(res, 400, {
        success: false,
        error: 'Attribute already at max level'
      });
    }

    // 计算新属性值
    const newValue = Math.min(currentValue + (amount * 10), 100);
    console.log('[upgradeAttribute] New attribute value:', newValue);

    // 更新属性
    console.log('[upgradeAttribute] Updating attribute');
    const { error: updateAttrError } = await supabase
      .from('player_attributes')
      .update({
        [attribute]: newValue
      })
      .filter('player_id', 'eq', playerId);

    if (updateAttrError) {
      console.error('[upgradeAttribute] Database update error:', updateAttrError);
      throw updateAttrError;
    }

    // 扣除属性点数
    console.log('[upgradeAttribute] Updating player attribute points');
    const { error: updatePlayerError } = await supabase
      .from('players')
      .update({
        attribute_points: attributePoints - requiredPoints
      })
      .filter('id', 'eq', playerId);

    if (updatePlayerError) {
      console.error('[upgradeAttribute] Database update error:', updatePlayerError);
      throw updatePlayerError;
    }

    // 返回更新后的数据
    const { data: updatedPlayer } = await supabase
      .from('players')
      .select('*')
      .filter('id', 'eq', playerId)
      .single();

    console.log('[upgradeAttribute] Attribute upgraded successfully');
    sendJson(res, 200, {
      success: true,
      data: {
        upgrade: {
          attribute,
          old_value: currentValue,
          new_value: newValue,
          increase: newValue - currentValue,
          attribute_points_used: requiredPoints,
          new_attribute_points: updatedPlayer.attribute_points
        },
        player: updatedPlayer
      },
      message: `属性 ${attribute} 从 ${currentValue} 提升到 ${newValue}`
    });
  } catch (error) {
    console.error('[upgradeAttribute] Error:', error);
    console.error('[upgradeAttribute] Error stack:', error.stack);
    sendJson(res, 500, {
      success: false,
      error: 'Failed to upgrade attribute'
    });
  }
};

// ==================== 主路由处理函数 ====================

// Health check
const healthCheck = async (req, res) => {
  try {
    const isConnected = await checkDatabaseConnection();

    const health = {
      status: isConnected ? 'ok' : 'error',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV || 'development',
      database: {
        state: isConnected ? 'connected' : 'disconnected',
        name: 'naruto-rebirth-game',
        type: 'supabase'
      },
      memory: {
        used: process.memoryUsage().heapUsed,
        total: process.memoryUsage().heapTotal,
        rss: process.memoryUsage().rss
      },
      cpu: process.cpuUsage()
    };

    sendJson(res, isConnected ? 200 : 503, health);
  } catch (error) {
    console.error('[healthCheck] Error:', error);
    console.error('[healthCheck] Error stack:', error.stack);
    sendJson(res, 500, {
      status: 'error',
      timestamp: new Date().toISOString(),
      error: error.message
    });
  }
};

// Main handler
module.exports = async (req, res) => {
  const { url, method, query } = req;
  const rawPath = query.path || url.replace('/api', '').split('?')[0] || '';
  const path = rawPath.startsWith('/') ? rawPath : '/' + rawPath;

  console.log(`[${new Date().toISOString()}] ${method} ${path}`, { query, body: req.body });

  // Health check
  if (path === '/health' && method === 'GET') {
    return healthCheck(req, res);
  }

  // Player registration
  if (path === '/player/register' && method === 'POST') {
    return registerPlayer(req, res);
  }

  // Player login
  if (path === '/player/login' && method === 'POST') {
    return loginPlayer(req, res);
  }

  // Get player
  if (path.startsWith('/player/') && method === 'GET') {
    const playerId = path.split('/')[2];
    req.query.id = playerId;
    return getPlayer(req, res);
  }

  // ==================== 新增的路由处理（已修复 UUID 问题） ====================

  // Load save
  if (path.startsWith('/saves/') && path.endsWith('/load') && method === 'POST') {
    const saveId = path.split('/')[2];
    req.query.id = saveId;
    return loadSave(req, res);
  }

  // Create save
  if (path === '/saves' && method === 'POST') {
    return createSave(req, res);
  }

  // Delete save
  if (path.startsWith('/saves/') && method === 'DELETE') {
    const saveId = path.split('/')[2];
    req.query.id = saveId;
    return deleteSave(req, res);
  }

  // Get saves
  if (path === '/saves' && method === 'GET') {
    return getSaves(req, res);
  }

  // Complete quest
  if (path.startsWith('/quest/') && path.endsWith('/complete') && method === 'POST') {
    const questId = path.split('/')[2];
    req.query.id = questId;
    return completeQuest(req, res);
  }

  // Claim quest reward
  if (path.startsWith('/quest/') && path.endsWith('/claim') && method === 'POST') {
    const questId = path.split('/')[2];
    req.query.id = questId;
    return claimQuestReward(req, res);
  }

  // Get quests
  if (path === '/quests' && method === 'GET') {
    return getQuests(req, res);
  }

  // Upgrade attribute
  if (path === '/player/upgrade' && method === 'POST') {
    return upgradeAttribute(req, res);
  }

  // Root endpoint
  if (path === '/' || path === '') {
    return sendJson(res, 200, {
      message: 'Naruto Rebirth Game API',
      version: '1.0.1', // Updated version
      timestamp: new Date().toISOString(),
      endpoints: [
        { method: 'GET', path: '/health' },
        { method: 'POST', path: '/player/register' },
        { method: 'POST', path: '/player/login' },
        { method: 'GET', path: '/player/:id' },
        { method: 'GET', path: '/saves' },
        { method: 'POST', path: '/saves' },
        { method: 'POST', path: '/saves/:saveId/load' },
        { method: 'DELETE', path: '/saves/:saveId' },
        { method: 'GET', path: '/quests' },
        { method: 'POST', path: '/quest/:questId/complete' },
        { method: 'POST', path: '/quest/:questId/claim' },
        { method: 'POST', path: '/player/upgrade' }
      ]
    });
  }

  // 404 Not Found
  sendJson(res, 404, {
    success: false,
    error: 'Endpoint not found',
    path: path,
    method: method,
    availableEndpoints: [
      'GET /health',
      'POST /player/register',
      'POST /player/login',
      'GET /player/:id',
      'GET /saves',
      'POST /saves',
      'POST /saves/:saveId/load',
      'DELETE /saves/:saveId',
      'GET /quests',
      'POST /quest/:questId/complete',
      'POST /quest/:questId/claim',
      'POST /player/upgrade'
    ]
  });
};
