// Database configuration for Vercel
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL || '';
const supabaseKey = process.env.SUPABASE_SERVICE_KEY || '';

// Create Supabase client
const supabase = createClient(supabaseUrl, supabaseKey);

// Health check function
const checkDatabaseConnection = async () => {
  try {
    const { data, error } = await supabase
      .from('players')
      .select('id')
      .limit(1);

    return !error;
  } catch (error) {
    console.error('Database connection failed:', error);
    return false;
  }
};

// Initialize database tables (run once)
const initializeDatabase = async () => {
  try {
    // Create saves table (if not exists)
    console.log('Initializing database tables...');

    // Note: In Supabase, you should create tables using the Supabase Dashboard
    // But we can use SQL to create tables if needed
    const { error: savesError } = await supabase.rpc('create_saves_table');
    if (savesError) {
      console.warn('Failed to create saves table (may already exist):', savesError.message);
    }

    const { error: questsError } = await supabase.rpc('create_quests_table');
    if (questsError) {
      console.warn('Failed to create quests table (may already exist):', questsError.message);
    }

    console.log('Database initialization complete');
    return true;
  } catch (error) {
    console.error('Database initialization failed:', error);
    return false;
  }
};

module.exports = { supabase, checkDatabaseConnection, initializeDatabase };
