# Fail fast if database connection is not available
# This prevents waiting through health check retries with unclear errors

Rails.application.config.after_initialize do
  # Only check in production environment
  next unless Rails.env.production?

  begin
    # Debug: Show all database-related env vars
    Rails.logger.info "=" * 80
    Rails.logger.info "DATABASE ENVIRONMENT CHECK"
    Rails.logger.info "=" * 80
    Rails.logger.info "Checking for database configuration..."
    Rails.logger.info "  DATABASE_URL: #{ENV['DATABASE_URL'].present? ? '[SET]' : '[NOT SET]'}"
    Rails.logger.info "  DB_HOST: #{ENV['DB_HOST'].present? ? "[SET: #{ENV['DB_HOST']}]" : '[NOT SET]'}"
    Rails.logger.info "  RAILS_ENV: #{Rails.env}"
    
    # Print all environment variables
    Rails.logger.info ""
    Rails.logger.info "ALL ENVIRONMENT VARIABLES:"
    Rails.logger.info "-" * 80
    ENV.keys.sort.each do |key|
      Rails.logger.info "  #{key}: #{ENV[key]}"
    end
    Rails.logger.info "-" * 80
    
    # Check if DATABASE_URL is present for Railway/Heroku deployments
    # We need EITHER DATABASE_URL (Railway/Heroku) OR DB_HOST (Kamal), not both
    if ENV["DATABASE_URL"].blank? && ENV["DB_HOST"].blank?
      Rails.logger.error ""
      Rails.logger.error "⚠️  DATABASE CONFIGURATION MISSING"
      Rails.logger.error "=" * 80
      Rails.logger.error ""
      Rails.logger.error "NEITHER DATABASE_URL NOR DB_HOST environment variable is set."
      Rails.logger.error "You need AT LEAST ONE of these variables configured."
      Rails.logger.error ""
      Rails.logger.error "If deploying to Railway:"
      Rails.logger.error "  1. Add PostgreSQL: Click '+ New' → 'Database' → 'Add PostgreSQL'"
      Rails.logger.error "  2. Wait for PostgreSQL to finish provisioning (green status)"
      Rails.logger.error "  3. Verify DATABASE_URL appears in your web service Variables tab"
      Rails.logger.error "  4. IMPORTANT: Redeploy your web service after adding database!"
      Rails.logger.error ""
      Rails.logger.error "If you already added PostgreSQL but still see this error:"
      Rails.logger.error "  • You may have set variables but NOT redeployed"
      Rails.logger.error "  • Trigger a manual redeploy from Railway dashboard"
      Rails.logger.error "  • Or push a new commit to trigger auto-deploy"
      Rails.logger.error ""
      Rails.logger.error "If deploying with Kamal:"
      Rails.logger.error "  1. Set DB_HOST in your config/deploy.yml"
      Rails.logger.error "  2. Ensure all DB_* environment variables are configured"
      Rails.logger.error ""
      Rails.logger.error "If testing locally:"
      Rails.logger.error "  export DATABASE_URL='postgresql://localhost/prof_production'"
      Rails.logger.error "=" * 80
      
      raise "FATAL: DATABASE_URL or DB_HOST environment variable is required. See logs above for setup instructions."
    end

    # Attempt to establish connection early
    Rails.logger.info "✓ Database configuration found, attempting connection..."
    
    # Try to connect with a short timeout
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      connection.execute("SELECT 1")
      Rails.logger.info "✓ Database connection successful!"
      Rails.logger.info "=" * 80
    end

  rescue PG::ConnectionBad, ActiveRecord::ConnectionNotEstablished => e
    # Log the full error for debugging
    Rails.logger.error "=" * 80
    Rails.logger.error "DATABASE CONNECTION FAILED"
    Rails.logger.error "=" * 80
    Rails.logger.error "Error: #{e.class} - #{e.message}"
    Rails.logger.error ""
    Rails.logger.error "The database environment variable is SET, but the database is NOT accessible."
    Rails.logger.error ""
    Rails.logger.error "Environment variables:"
    Rails.logger.error "  DATABASE_URL: #{ENV['DATABASE_URL'].present? ? '[SET]' : '[NOT SET]'}"
    Rails.logger.error "  DB_HOST: #{ENV['DB_HOST'] || '[NOT SET]'}"
    Rails.logger.error "  RAILS_ENV: #{Rails.env}"
    Rails.logger.error ""
    Rails.logger.error "If deploying to Railway:"
    Rails.logger.error "  1. Check that your PostgreSQL service is RUNNING (green status)"
    Rails.logger.error "  2. Go to PostgreSQL service → click 'Restart' if needed"
    Rails.logger.error "  3. Verify both services are in the SAME Railway project"
    Rails.logger.error "  4. Check PostgreSQL service logs for errors"
    Rails.logger.error "  5. Wait 30-60 seconds after starting PostgreSQL before deploying web service"
    Rails.logger.error ""
    Rails.logger.error "Other possible causes:"
    Rails.logger.error "  • DATABASE_URL format is incorrect"
    Rails.logger.error "  • Database credentials are invalid"
    Rails.logger.error "  • Network connectivity issues between services"
    Rails.logger.error "  • PostgreSQL hasn't finished starting up yet"
    Rails.logger.error "=" * 80

    # Raise the exception to stop the application from starting
    raise "FATAL: Cannot connect to database. Configuration is present but database is not accessible. See logs above for troubleshooting steps."

  rescue ActiveRecord::NoDatabaseError => e
    Rails.logger.error "=" * 80
    Rails.logger.error "DATABASE DOES NOT EXIST"
    Rails.logger.error "=" * 80
    Rails.logger.error "Error: #{e.message}"
    Rails.logger.error ""
    Rails.logger.error "The database connection is working, but the database doesn't exist."
    Rails.logger.error "This should be handled by the 'release' command in Procfile."
    Rails.logger.error ""
    Rails.logger.error "If deploying to Railway:"
    Rails.logger.error "  - Ensure the 'release' command ran successfully"
    Rails.logger.error "  - Check Railway logs for migration errors"
    Rails.logger.error "  - Try manually running: railway run rails db:prepare"
    Rails.logger.error "=" * 80

    raise "FATAL: Database does not exist. Run migrations first. See logs above for details."

  rescue StandardError => e
    # Catch any other database-related errors
    Rails.logger.error "=" * 80
    Rails.logger.error "UNEXPECTED DATABASE ERROR"
    Rails.logger.error "=" * 80
    Rails.logger.error "Error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.first(10).join("\n")
    Rails.logger.error "=" * 80

    raise "FATAL: Database connection check failed. See logs above for details."
  end
end

