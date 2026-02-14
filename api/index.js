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
        currency: 100,  // 初始货币
        attribute_points: 10  // 初始属性点数
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

// ==================== 新增的 API 端点函数 ====================

// 加载存档
const loadSave = async (req, res) => {
  try {
    const { query } = req;
    const saveId = query.id || query.saveId;

    if (!saveId) {
      return sendJson(res, 400, {
        success: false,
        error: 'Save ID is required'
      });
    }

    // 从数据库加载存档数据
    const { data: save, error } = await supabase
      .from('saves')
      .select('*')
      .eq('id', saveId)
      .single();

    if (error || !save) {
      return sendJson(res, 404, {
        success: false,
        error: 'Save not found'
      });
    }

    // 验证存档所有权
    if (save.player_id !== gameState.player?.id) {
      return sendJson(res, 403, {
        success: false,
        error: 'You do not have permission to load this save'
      });
    }

    // 构建返回数据
    const saveData = {
      saveName: save.save_name,
      playerData: gameState.player,
      saveData: save.save_data,
      createdAt: save.created_at,
      updatedAt: save.updated_at
    };

    sendJson(res, 200, {
      success: true,
      data: {
        save: saveData,
        message: '存档加载成功'
      }
    });
  } catch (error) {
    console.error('Load save error:', error);
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

    if (!saveName || !saveData) {
      return sendJson(res, 400, {
        success: false,
        error: 'Save name and save data are required'
      });
    }

    // 验证玩家身份
    const playerId = gameState.player?.id;
    if (!playerId) {
      return sendJson(res, 401, {
        success: false,
        error: 'Unauthorized'
      });
    }

    // 创建存档记录
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

    if (error) throw error;

    sendJson(res, 201, {
      success: true,
      data: save,
      message: '存档创建成功'
    });
  } catch (error) {
    console.error('Create save error:', error);
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

    if (!saveId) {
      return sendJson(res, 400, {
        success: false,
        error: 'Save ID is required'
      });
    }

    // 获取存档信息以验证所有权
    const { data: save, error } = await supabase
      .from('saves')
      .select('*')
      .eq('id', saveId)
      .single();

    if (error || !save) {
      return sendJson(res, 404, {
        success: false,
        error: 'Save not found'
      });
    }

    // 验证所有权
    if (save.player_id !== gameState.player?.id) {
      return sendJson(res, 403, {
        success: false,
        error: 'You do not have permission to delete this save'
      });
    }

    // 删除存档
    const { error: deleteError } = await supabase
      .from('saves')
      .delete()
      .eq('id', saveId);

    if (deleteError) throw deleteError;

    sendJson(res, 200, {
      success: true,
      message: '存档删除成功'
    });
  } catch (error) {
    console.error('Delete save error:', error);
    sendJson(res, 500, {
      success: false,
      error: 'Failed to delete save'
    });
  }
};

// 获取存档列表
const getSaves = async (req, res) => {
  try {
    const playerId = gameState.player?.id;
    if (!playerId) {
      return sendJson(res, 401, {
        success: false,
        error: 'Unauthorized'
      });
    }

    const { data: saves, error } = await supabase
      .from('saves')
      .select('*')
      .eq('player_id', playerId)
      .order('updated_at', { ascending: false })
      .limit(10);

    if (error) throw error;

    sendJson(res, 200, {
      success: true,
      data: {
        saves: saves || []
      }
    });
  } catch (error) {
    console.error('Get saves error:', error);
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

    if (!questId) {
      return sendJson(res, 400, {
        success: false,
        error: 'Quest ID is required'
      });
    }

    // 获取任务信息
    const { data: quest, error } = await supabase
      .from('quests')
      .select('*')
      .eq('id', questId)
      .single();

    if (error || !quest) {
      return sendJson(res, 404, {
        success: false,
        error: 'Quest not found'
      });
    }

    // 检查任务是否可以完成
    if (quest.status !== 'available' && quest.status !== 'in_progress') {
      return sendJson(res, 400, {
        success: false,
        error: 'Quest cannot be completed'
      });
    }

    // 更新任务状态为 completed
    const { error: updateError } = await supabase
      .from('quests')
      .update({
        status: 'completed',
        completed_at: new Date().toISOString()
      })
      .eq('id', questId);

    if (updateError) throw updateError;

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
    const playerId = gameState.player?.id;
    if (!playerId) {
      return sendJson(res, 401, {
        success: false,
        error: 'Unauthorized'
      });
    }

    // 更新货币
    if (rewards.currency > 0) {
      await supabase
        .from('players')
        .update({
          currency: supabase.raw(`currency + ${rewards.currency}`)
        })
        .eq('id', playerId);
    }

    // 更新经验值
    if (rewards.experience > 0) {
      await supabase
        .from('players')
        .update({
          experience: supabase.raw(`experience + ${rewards.experience}`)
        })
        .eq('id', playerId);
    }

    // 更新属性
    const { error: attrError } = await supabase
      .from('player_attributes')
      .select('*')
      .eq('player_id', playerId)
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
          .eq('player_id', playerId);
      }
    }

    sendJson(res, 200, {
      success: true,
      data: {
        rewards: {
          currency: rewards.currency,
          experience: rewards.experience,
          description: `获得 ${rewards.currency} 货币和 ${rewards.experience} 经验值`
        },
        player: {
          currency: gameState.player.currency + rewards.currency,
          experience: gameState.player.experience + rewards.experience
        }
      },
      message: '任务完成'
    });
  } catch (error) {
    console.error('Complete quest error:', error);
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

    if (!questId) {
      return sendJson(res, 400, {
        success: false,
        error: 'Quest ID is required'
      });
    }

    // 获取任务信息
    const { data: quest, error } = await supabase
      .from('quests')
      .select('*')
      .eq('id', questId)
      .single();

    if (error || !quest) {
      return sendJson(res, 404, {
        success: false,
        error: 'Quest not found'
      });
    }

    // 检查任务是否已完成且未领取
    if (quest.status !== 'completed' || quest.claimed) {
      return sendJson(res, 400, {
        success: false,
        error: 'Reward cannot be claimed'
      });
    }

    // 标记为已领取
    const { error: updateError } = await supabase
      .from('quests')
      .update({
        claimed: true,
        claimed_at: new Date().toISOString()
      })
      .eq('id', questId);

    if (updateError) throw updateError;

    // 解析奖励
    const rewards = {
      currency: quest.currency_reward || 0,
      description: `奖励：${quest.currency_reward || 0} 货币`
    };

    // 更新玩家货币
    const playerId = gameState.player?.id;
    if (!playerId) {
      return sendJson(res, 401, {
        success: false,
        error: 'Unauthorized'
      });
    }

    if (rewards.currency > 0) {
      await supabase
        .from('players')
        .update({
          currency: supabase.raw(`currency + ${rewards.currency}`)
        })
        .eq('id', playerId);
    }

    sendJson(res, 200, {
      success: true,
      data: {
        rewards,
        player: {
          currency: gameState.player.currency + rewards.currency
        }
      },
      message: '奖励领取成功'
    });
  } catch (error) {
    console.error('Claim quest reward error:', error);
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

    let queryBuilder = supabase.from('quests');

    if (questType !== 'all') {
      queryBuilder = queryBuilder.eq('quest_type', questType);
    }

    const { data: quests, error } = await queryBuilder
      .select('*')
      .order('created_at', { ascending: false })
      .limit(20);

    if (error) throw error;

    sendJson(res, 200, {
      success: true,
      data: {
        quests: quests || []
      }
    });
  } catch (error) {
    console.error('Get quests error:', error);
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

    const playerId = gameState.player?.id;
    if (!playerId) {
      return sendJson(res, 401, {
        success: false,
        error: 'Unauthorized'
      });
    }

    // 获取玩家属性点数
    const { data: player, error: playerError } = await supabase
      .from('players')
      .select('attribute_points')
      .eq('id', playerId)
      .single();

    if (playerError || !player) {
      return sendJson(res, 404, {
        success: false,
        error: 'Player not found'
      });
    }

    const attributePoints = player.attribute_points || 0;
    const requiredPoints = amount * 1; // 每次升级 1 点

    if (attributePoints < requiredPoints) {
      return sendJson(res, 400, {
        success: false,
        error: 'Not enough attribute points'
      });
    }

    // 获取当前属性值
    const { data: attributes, error: attrError } = await supabase
      .from('player_attributes')
      .select('*')
      .eq('player_id', playerId)
      .single();

    if (attrError || !attributes) {
      return sendJson(res, 404, {
        success: false,
        error: 'Attributes not found'
      });
    }

    // 检查属性是否已满级
    const currentValue = attributes[attribute] || 0;
    if (currentValue >= 100) {
      return sendJson(res, 400, {
        success: false,
        error: 'Attribute already at max level'
      });
    }

    // 计算新属性值
    const newValue = Math.min(currentValue + (amount * 10), 100);

    // 更新属性
    const { error: updateAttrError } = await supabase
      .from('player_attributes')
      .update({
        [attribute]: newValue
      })
      .eq('player_id', playerId);

    if (updateAttrError) throw updateAttrError;

    // 扣除属性点数
    const { error: updatePlayerError } = await supabase
      .from('players')
      .update({
        attribute_points: attributePoints - requiredPoints
      })
      .eq('id', playerId);

    if (updatePlayerError) throw updatePlayerError;

    // 返回更新后的数据
    const { data: updatedPlayer } = await supabase
      .from('players')
      .select('*')
      .eq('id', playerId)
      .single();

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
    console.error('Upgrade attribute error:', error);
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
    console.error('Health check error:', error);
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

  console.log(`${method} ${path}`, { query, body: req.body });

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

  // ==================== 新增的路由处理 ====================

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
      version: '1.0.0',
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
