# Fail fast if database connection is not available
# This prevents waiting through health check retries with unclear errors

Rails.application.config.after_initialize do
  # Only check in production environment
  next unless Rails.env.production?

  begin
    # Check if DATABASE_URL is present for Railway/Heroku deployments
    if ENV["DATABASE_URL"].blank? && ENV["DB_HOST"].blank?
      raise "DATABASE_URL or DB_HOST environment variable is required for production deployment. " \
            "Please ensure your database service is properly configured and environment variables are set."
    end

    # Attempt to establish connection early
    ActiveRecord::Base.logger.info "Checking database connection..."
    
    # Try to connect with a short timeout
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      connection.execute("SELECT 1")
      ActiveRecord::Base.logger.info "Database connection successful!"
    end

  rescue PG::ConnectionBad, ActiveRecord::ConnectionNotEstablished => e
    # Log the full error for debugging
    Rails.logger.error "=" * 80
    Rails.logger.error "DATABASE CONNECTION FAILED"
    Rails.logger.error "=" * 80
    Rails.logger.error "Error: #{e.class} - #{e.message}"
    Rails.logger.error ""
    Rails.logger.error "Environment variables:"
    Rails.logger.error "  DATABASE_URL: #{ENV['DATABASE_URL'].present? ? '[SET]' : '[NOT SET]'}"
    Rails.logger.error "  DB_HOST: #{ENV['DB_HOST'] || '[NOT SET]'}"
    Rails.logger.error "  RAILS_ENV: #{Rails.env}"
    Rails.logger.error ""
    Rails.logger.error "Possible causes:"
    Rails.logger.error "  1. PostgreSQL service is not running"
    Rails.logger.error "  2. DATABASE_URL environment variable is incorrect"
    Rails.logger.error "  3. Database credentials are invalid"
    Rails.logger.error "  4. Network connectivity issues"
    Rails.logger.error "  5. Database host is not accessible"
    Rails.logger.error "=" * 80

    # Raise the exception to stop the application from starting
    raise "FATAL: Cannot connect to database. Application startup aborted. See logs above for details."

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

