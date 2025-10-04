# Railway Deployment Guide

This guide covers deploying your Rails application to Railway.

## Quick Start

Railway is a Platform-as-a-Service (PaaS) that makes deployment simple. No server management required!

### Prerequisites

1. [Railway account](https://railway.app/) (free tier available)
2. Git repository (GitHub, GitLab, or Bitbucket)
3. Railway CLI (optional, for local testing)

## Deployment Steps

### 1. Create a New Railway Project

1. Go to [railway.app](https://railway.app/) and sign in
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Authorize Railway to access your repository
5. Select your `prof` repository

### 2. Add PostgreSQL Database

1. In your Railway project, click "+ New"
2. Select "Database" → "PostgreSQL"
3. Railway will automatically provision a PostgreSQL database
4. The `DATABASE_URL` environment variable will be automatically set

### 3. Configure Environment Variables

Railway automatically provides `DATABASE_URL`, but you need to add:

1. Click on your web service
2. Go to "Variables" tab
3. Add these variables:

```
RAILS_MASTER_KEY=<paste your config/master.key content>
RAILS_ENV=production
```

**Important:** 
- Get your `RAILS_MASTER_KEY` from `config/master.key` - never commit this file!
- **After adding/changing variables, you MUST redeploy** for changes to take effect
- Railway does NOT automatically restart your app when variables change

### 4. Deploy

Railway will automatically deploy when you:
- Push to your main/master branch
- Manually trigger a deploy from the Railway dashboard

#### First Deployment

1. Push your code to GitHub:
```bash
git add .
git commit -m "Configure for Railway deployment"
git push origin main
```

2. Railway will automatically:
   - Build your Docker image
   - Run database migrations (via `release` command in Procfile)
   - Start your web server
   - Assign a public URL

### 5. Access Your Application

1. In Railway dashboard, click on your web service
2. Go to "Settings" tab
3. Under "Networking", you'll see your public URL
4. Click it to open your deployed application!

### 6. Custom Domain (Optional)

1. In your web service settings, go to "Networking"
2. Click "Add Custom Domain"
3. Enter your domain name
4. Follow Railway's DNS configuration instructions

## Database Management

### Database Configuration

Railway provides a single PostgreSQL database. This application uses that one database for all Rails services (primary, cache, queue, cable) with separate table prefixes. **No additional database setup is needed.**

The configuration automatically:
- Uses the `DATABASE_URL` environment variable from Railway
- Shares the same database for cache/queue/cable (more efficient for single-DB setups)
- Runs all migrations via `db:prepare` in the release command

### Run Migrations

Migrations run automatically on each deployment via the `release` command in `Procfile`.

To run manually:
```bash
railway run rails db:migrate
```

### Access Rails Console

```bash
railway run rails console
```

## Configuration Files

Your project includes these Railway-specific files:

### `Procfile`
Defines how Railway runs your app:
- `web`: Starts the web server using Thruster + Puma
- `release`: Runs before each deployment (creates DBs and runs migrations)

### `railway.toml` (Optional)
Additional Railway configuration:
- Dockerfile path
- Health check settings
- Restart policies

### `Dockerfile`
Built with PostgreSQL support:
- `libpq5` and `postgresql-client` for PostgreSQL runtime
- `libpq-dev` for building the `pg` gem
- Multi-stage build for smaller images

### `config/initializers/database_connection_check.rb`
Fail-fast database validation:
- Checks database connectivity immediately on startup
- Prevents waiting through health check timeouts
- Provides clear error messages if database is unavailable
- Only runs in production environment

## Environment Variables

Railway automatically provides:
- `DATABASE_URL`: PostgreSQL connection string
- `PORT`: Port to bind to (handled by Rails)

You need to set:
- `RAILS_MASTER_KEY`: Your encryption key from `config/master.key`
- `RAILS_ENV`: Set to `production`

## Scaling

### Vertical Scaling (Upgrade Resources)
1. Go to your web service settings
2. Click "Resources" tab
3. Upgrade your plan for more CPU/RAM

### Horizontal Scaling (Multiple Instances)
Edit `railway.toml`:
```toml
[deploy]
numReplicas = 2  # Run 2 instances
```

**Note:** With multiple instances, consider:
- Using Railway's Redis for cache (instead of Solid Cache)
- External job queue service (instead of Solid Queue)

## Monitoring & Logs

### View Logs
1. Click on your web service
2. Go to "Deployments" tab
3. Click on a deployment to see logs
4. Or use CLI: `railway logs`

### Metrics
Railway provides basic metrics:
- CPU usage
- Memory usage
- Network traffic
- Response times

## Troubleshooting

### Deployment Fails with Database Connection Errors

The application now **fails fast** with clear error messages instead of retrying indefinitely. You'll see one of these errors in the logs:

#### **Error: "DATABASE CONFIGURATION MISSING"**

This means neither `DATABASE_URL` nor `DB_HOST` environment variable is set.

```
DATABASE CONFIGURATION MISSING
Neither DATABASE_URL nor DB_HOST environment variable is set.
```

**How to fix:**

1. **Add PostgreSQL Database to Railway**
   - In Railway dashboard, click **"+ New"** → **"Database"** → **"Add PostgreSQL"**
   - Railway will automatically provision it and set `DATABASE_URL`
   
2. **Verify Environment Variables**
   - Click on your web service → Variables tab
   - Confirm `DATABASE_URL` is present (auto-set by Railway)
   - Add `RAILS_MASTER_KEY` from your local `config/master.key`
   - Add `RAILS_ENV=production`

3. **IMPORTANT: Redeploy After Setting Variables**
   - Railway does **NOT** automatically restart when you change variables
   - You **MUST** trigger a redeploy manually:
     - Option 1: Go to your web service → click "⋮" menu → "Redeploy"
     - Option 2: Push a new commit to trigger auto-deploy
     - Option 3: Use Railway CLI: `railway up --detach`

#### **Error: "DATABASE CONNECTION FAILED"**

This means the database environment variable IS set, but the database is NOT accessible.

```
DATABASE CONNECTION FAILED
The database environment variable is SET, but the database is NOT accessible.
Error: PG::ConnectionBad - ...
```

**How to fix:**

1. **Check PostgreSQL Service Status**
   - In Railway dashboard, verify your PostgreSQL service is **RUNNING** (green status)
   - If stopped or errored, click on it and restart it

2. **Wait for PostgreSQL to Start**
   - PostgreSQL may take 30-60 seconds to fully start up
   - Don't deploy the web service until PostgreSQL shows green/active status

3. **Verify Services Are in Same Project**
   - Both PostgreSQL and web service must be in the **same Railway project**
   - If not, remove and re-add PostgreSQL to the correct project

4. **Check PostgreSQL Logs**
   - Click on PostgreSQL service → Logs tab
   - Look for startup errors or crashes

5. **Restart Services in Order**
   ```
   1. Ensure PostgreSQL is running and stable (wait 60 seconds after start)
   2. Stop web service if it's running
   3. Redeploy web service
   ```

#### **Error: "DATABASE DOES NOT EXIST"**

The database connection works, but the database hasn't been created yet. This should be handled automatically by the `release` command in `Procfile`, but if it fails:

```bash
# Install Railway CLI if you haven't
npm i -g @railway/cli

# Login and link to your project
railway login
railway link

# Manually create and migrate the database
railway run rails db:prepare
```

Then redeploy your application.

### Build Fails

**Error: "frozen mode" or "Gemfile.lock"**
- Solution: Run `bundle install` locally and commit `Gemfile.lock`

**Error: "pg gem installation failed"**
- Solution: Already fixed! Dockerfile includes `libpq-dev`

### Database Connection Issues

**Error: "could not connect to server"**
- Check that PostgreSQL service is running in Railway dashboard
- Verify `DATABASE_URL` is set in environment variables
- Ensure web service and database are in the same Railway project

### Application Crashes

**Check logs:**
```bash
railway logs
```

**Common issues:**
- Missing `RAILS_MASTER_KEY`
- Database not migrated (should auto-run via Procfile)
- Port binding issues (Rails should auto-detect `PORT` from Railway)
- Database connection timeout (increase Railway's timeout settings)

## Backups

Railway Pro plans include automatic daily backups. For manual backups:

```bash
# Create backup
railway run pg_dump $DATABASE_URL > backup.sql

# Restore backup
railway run psql $DATABASE_URL < backup.sql
```

## Cost Optimization

### Free Tier
Railway's free tier includes:
- $5 of usage per month
- Suitable for small apps and testing

### Tips to Reduce Costs
1. Use single replica for staging environments
2. Enable sleep mode for non-production services
3. Monitor usage in Railway dashboard
4. Consider upgrading to Pro ($20/month) for better pricing

## Comparison: Railway vs Kamal

| Feature | Railway | Kamal |
|---------|---------|-------|
| Setup Time | 5 minutes | 30-60 minutes |
| Server Management | None (managed) | Full control |
| Scaling | Click a button | Manual |
| Database | Managed PostgreSQL | Self-hosted |
| SSL/HTTPS | Automatic | Let's Encrypt (auto) |
| Monitoring | Built-in | DIY |
| Cost | ~$20-50/month | VPS cost ($5-20/month) |
| Best For | Quick deployment, startups | Cost control, custom needs |

## Production Checklist

- [ ] `RAILS_MASTER_KEY` environment variable set
- [ ] PostgreSQL database added to project
- [ ] Custom domain configured (optional)
- [ ] Backups enabled (Pro plan)
- [ ] Monitoring alerts configured
- [ ] Force SSL enabled (automatic on Railway)
- [ ] Database connection pooling configured
- [ ] Static assets precompiled (automatic via Dockerfile)

## Additional Resources

- [Railway Documentation](https://docs.railway.app/)
- [Railway CLI](https://docs.railway.app/develop/cli)
- [Railway Templates](https://railway.app/templates)
- [Railway Status](https://status.railway.app/)

## Support

- Railway Discord: https://discord.gg/railway
- Railway Help Center: https://help.railway.app/
- Project Issues: Create issues in your GitHub repo

