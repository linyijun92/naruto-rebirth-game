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

    // Create player
    const { data: player, error } = await supabase
      .from('players')
      .insert([{
        username,
        email,
        password_hash: passwordHash,
        level: 1,
        experience: 0,
        experience_to_next_level: 100,
        currency: 0
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
        { method: 'GET', path: '/player/:id' }
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
      'GET /player/:id'
    ]
  });
};
