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

**Important:** Get your `RAILS_MASTER_KEY` from `config/master.key` - never commit this file!

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

### Manual Database Setup (if needed)

Railway's PostgreSQL automatically creates the main database. For the additional databases (cache, queue, cable):

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Link to your project
railway link

# Connect to database
railway run rails dbconsole

# Then in PostgreSQL console:
CREATE DATABASE <your_db_name>_cache;
CREATE DATABASE <your_db_name>_queue;
CREATE DATABASE <your_db_name>_cable;
\q
```

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

### Build Fails

**Error: "frozen mode" or "Gemfile.lock"**
- Solution: Run `bundle install` locally and commit `Gemfile.lock`

**Error: "pg gem installation failed"**
- Solution: Already fixed! Dockerfile includes `libpq-dev`

### Database Connection Issues

**Error: "could not connect to server"**
- Check that PostgreSQL service is running in Railway dashboard
- Verify `DATABASE_URL` is set in environment variables

### Application Crashes

**Check logs:**
```bash
railway logs
```

**Common issues:**
- Missing `RAILS_MASTER_KEY`
- Database not migrated (should auto-run via Procfile)
- Port binding issues (Rails should auto-detect `PORT` from Railway)

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

