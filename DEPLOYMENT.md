# Deployment Configuration Guide

This guide covers the necessary steps to configure and deploy the application to production using Kamal.

## Prerequisites

1. Docker installed locally
2. SSH access to your production server(s)
3. A container registry account (Docker Hub, GitHub Container Registry, etc.)
4. A domain name configured to point to your server

## Configuration Steps

### 1. Update `config/deploy.yml` Placeholders

Before deploying, you need to update the following values in `config/deploy.yml`:

#### Image Registry (lines 5, 28)
```yaml
# Line 5: Name of the container image
image: your-user/prof
# Replace 'your-user' with your Docker Hub username or registry path
# Example: johndoe/prof or ghcr.io/johndoe/prof

# Line 28: Registry username
username: your-user
# Replace with the same username
```

#### Server Configuration (line 10)
```yaml
servers:
  web:
    - 192.168.0.1
# Replace with your actual production server IP address(es)
# Example: 
#   - 203.0.113.42
# Or for multiple servers:
#   - 203.0.113.42
#   - 203.0.113.43
```

#### Domain Name (line 22)
```yaml
proxy:
  ssl: true
  host: app.example.com
# Replace with your actual domain name
# Example: myapp.com or app.mydomain.com
```

#### Database Server Host (line 104 - Optional)
```yaml
host: <%= ENV.fetch("DB_SERVER_HOST") { "192.168.0.1" } %>
# By default, the database will run on the same server as the web app
# If you want a separate database server, set DB_SERVER_HOST env variable
# or update the default IP address
```

### 2. Set Up Environment Secrets

Create or update environment variables for sensitive data:

```bash
# Registry password (Docker Hub access token or registry password)
export KAMAL_REGISTRY_PASSWORD="your-registry-access-token"

# PostgreSQL password (use a strong, random password)
export POSTGRES_PASSWORD="your-secure-database-password"

# Rails master key is read from config/master.key automatically
```

**Important:** Never commit actual passwords or tokens to git!

### 3. Install Dependencies

```bash
# Install the pg gem for production
bundle install
```

### 4. First-Time Deployment

```bash
# Set up the server (installs Docker, etc.)
bin/kamal setup

# This will:
# - Install Docker on your server
# - Start the PostgreSQL database
# - Build and push your Docker image
# - Deploy the application
# - Set up SSL certificates via Let's Encrypt
```

### 5. Database Setup

After the first deployment, create and migrate the databases:

```bash
# Run migrations on all databases
bin/kamal app exec 'bin/rails db:create db:migrate'
```

### 6. Subsequent Deployments

```bash
# Deploy updated code
bin/kamal deploy

# Or for a specific environment
bin/kamal deploy -d production
```

## Database Configuration

The production environment uses PostgreSQL with four separate databases:

- **prof_production**: Main application database
- **prof_production_cache**: Solid Cache database
- **prof_production_queue**: Solid Queue (background jobs) database
- **prof_production_cable**: Solid Cable (WebSockets) database

All databases are automatically created via the initialization script at `db/init-databases.sql`.

## Common Commands

```bash
# View application logs
bin/kamal app logs -f

# Open Rails console
bin/kamal console

# Open database console
bin/kamal dbc

# SSH into the server
bin/kamal app exec --interactive --reuse "bash"

# Restart the application
bin/kamal app restart

# Stop all services
bin/kamal app stop

# Start all services
bin/kamal app start

# Rollback to previous version
bin/kamal app rollback
```

## SSL/TLS Configuration

SSL certificates are automatically obtained and renewed via Let's Encrypt. Ensure:

1. Your domain's DNS A record points to your server IP
2. Port 80 and 443 are open on your server firewall
3. If using Cloudflare, set SSL/TLS encryption mode to "Full"

## Database Backups

**Important:** Set up regular backups for your PostgreSQL database!

The database files are stored in a Docker volume. Consider:

1. Using your hosting provider's backup service
2. Setting up automated pg_dump backups
3. Storing backups off-server (S3, etc.)

Example backup command:
```bash
bin/kamal accessory exec db "pg_dump -U prof prof_production" > backup.sql
```

## Environment Variables

All environment variables are configured in `config/deploy.yml`:

### Secret Variables (from .kamal/secrets)
- `RAILS_MASTER_KEY`: Rails credentials encryption key
- `POSTGRES_PASSWORD`: Database password

### Clear Variables (non-sensitive)
- `DB_HOST`: Database host (default: prof-db)
- `DB_PORT`: Database port (default: 5432)
- `DB_USER`: Database username (default: prof)
- `DB_NAME`: Primary database name
- `DB_NAME_CACHE`, `DB_NAME_QUEUE`, `DB_NAME_CABLE`: Additional database names
- `SOLID_QUEUE_IN_PUMA`: Run background jobs in web server
- `WEB_CONCURRENCY`: Number of Puma workers
- `JOB_CONCURRENCY`: Number of Solid Queue workers

## Troubleshooting

### Database connection issues
```bash
# Check if database is running
bin/kamal accessory details db

# Check database logs
bin/kamal accessory logs db

# Restart database
bin/kamal accessory restart db
```

### Application issues
```bash
# Check application logs
bin/kamal app logs -f

# Check application status
bin/kamal app details

# Restart application
bin/kamal app restart
```

### SSL certificate issues
```bash
# Check proxy logs
bin/kamal proxy logs

# Restart proxy
bin/kamal proxy restart
```

## Security Checklist

- [ ] Update all placeholder values in `config/deploy.yml`
- [ ] Set strong, unique `POSTGRES_PASSWORD`
- [ ] Keep `config/master.key` secure and never commit it
- [ ] Use SSH keys for server access
- [ ] Enable firewall on production server (ports 22, 80, 443)
- [ ] Set up database backups
- [ ] Use access tokens instead of passwords for registry
- [ ] Keep dependencies updated
- [ ] Monitor application logs regularly

## Additional Resources

- [Kamal Documentation](https://kamal-deploy.org/)
- [Rails on Docker](https://guides.rubyonrails.org/action_cable_overview.html)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

