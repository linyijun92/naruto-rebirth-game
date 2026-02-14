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

module.exports = { supabase, checkDatabaseConnection };
