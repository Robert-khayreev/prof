-- Initialize additional databases for Rails multi-database setup
-- This script creates the cache, queue, and cable databases

-- Create cache database
CREATE DATABASE prof_production_cache;
GRANT ALL PRIVILEGES ON DATABASE prof_production_cache TO prof;

-- Create queue database
CREATE DATABASE prof_production_queue;
GRANT ALL PRIVILEGES ON DATABASE prof_production_queue TO prof;

-- Create cable database
CREATE DATABASE prof_production_cable;
GRANT ALL PRIVILEGES ON DATABASE prof_production_cable TO prof;

