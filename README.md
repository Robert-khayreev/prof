# Dating Profile Performance Analyzer

A Tinder-style application for analyzing dating profile performance based on real user interactions. Test multiple profiles and gather detailed metrics like swipes, scroll depth, time spent, and more.

## Features

### 🎯 Core Features

- **User Authentication**: Secure sign up and login system with encrypted passwords
- **Multi-User Support**: Each user has their own account and private profile collection
- **Convenient Navigation**: Sticky navigation bar with easy access to all features across the app
- **Profile Management**: Create and manage multiple dating profiles with photos, bio, name, age, gender identity, height, and income level
- **Image Upload**: Support for unlimited photos per profile using ActiveStorage
- **Tinder-style Image Navigation**: Tap left/right sides of images to browse photos, with progress bars at top
- **Spectator Mode**: Anonymous profile viewing mode for gathering interaction data (no login required)
- **Real-time Analytics**: Comprehensive analytics dashboard with key performance metrics
- **Tinder-style Swipe Interface**: Swipe left/right functionality with smooth animations
- **Interaction Tracking**: Automatic tracking of:
  - Profile views
  - Right swipes (likes)
  - Left swipes (passes)
  - Time spent viewing each profile
  - Scroll depth percentage
  - Photo position when swiping (which image the viewer was on)
  - Session tracking

### 📊 Analytics Metrics

- **Total profile views** (= right swipes + left swipes, since every view results in a decision)
- **Right swipe count** (likes)
- **Left swipe count** (passes)
- **Success rate** (right swipe percentage)
- **Average time spent** per view (in seconds)
- **Average scroll depth** (0-100%, how much of the profile was viewed)
- **Average photos viewed** before swiping
- **Photo performance analysis**:
  - Which photo position gets right swipes (e.g., "Photo #2")
  - Which photo position gets left swipes
  - Swipe distribution by photo with percentages
- **Detailed interaction history** with timestamps and photo position data

All metrics include complete data (time spent and scroll depth) for accurate analysis.

## Getting Started

### Prerequisites

- Ruby 3.2+
- Rails 8.0+
- SQLite3
- Bundler

### Installation

1. **Install dependencies**:
   ```bash
   bundle install
   ```

2. **Setup the database**:
   ```bash
   bin/rails db:migrate
   ```

3. **Seed sample data** (optional but recommended):
   ```bash
   bin/rails db:seed
   ```
   This creates two demo accounts:
   - **Email**: `demo@example.com` / **Password**: `password` (Profiles: Alex, Jordan, Sam)
   - **Email**: `test@example.com` / **Password**: `password` (Profiles: Taylor, Morgan, Casey)
   
   When you log in as one user and visit spectator mode, you'll see the other user's profiles.

4. **Start the server**:
   ```bash
   bin/rails server
   ```

5. **Visit the application**:
   Open your browser and navigate to `http://localhost:3000`

6. **Sign up or login**:
   - Create a new account by clicking "Sign Up"
   - Or login with one of the demo accounts above

## Usage Guide

### Home Page

The landing page provides different options based on login status:

**When logged out:**
- **Sign Up**: Create a new account
- **Log In**: Access your existing account
- **Spectator Mode**: Browse profiles anonymously (no account needed)

**When logged in:**
- **Manage My Profiles**: Create and analyze your own profiles
- **Spectator Mode**: Browse and interact with active profiles

### Creating a Profile

1. **Sign up or log in** to your account
2. Click "Manage My Profiles" from the home page
3. Click "Create New Profile"
4. Fill in the information:
   - **Name** (required)
   - **Age** (required, must be 18+)
   - **Gender Identity** (optional: Male, Female, Non-binary, Genderqueer, Agender, Other)
   - **Height** (optional, in centimeters)
   - **Income Level** (optional, select from ranges)
   - **Bio/Description** (optional, max 500 characters)
   - **Upload photos** (multiple images supported)
   - Toggle **"Active"** status to make profile visible in spectator mode
5. Click "Create Profile"

### Managing Profiles

From the profiles dashboard, you can:
- View all your profiles
- See quick stats (views, swipes, success rate)
- Edit profile details
- View detailed analytics
- Delete profiles
- Toggle active/inactive status

### Viewing Analytics

1. Navigate to your profiles list
2. Click "Analytics" on any profile
3. View comprehensive metrics including:
   - Total views
   - Right/left swipes
   - Success rate percentage
   - Average time spent
   - Average scroll depth
   - Average photos viewed
   - Photo performance breakdown (which photos get right/left swipes)
   - Swipe distribution by photo position with percentages
   - Recent interaction history with photo position data table

### Spectator Mode

Spectator mode provides a true Tinder-style experience - one profile at a time:

1. Click "Spectator Mode" from the home page
2. **Instantly see a profile** - no browsing, just start swiping!
3. View one profile at a time with full details
4. **Navigate through profile photos** (Tinder-style):
   - Tap the **left side** of the image to go to previous photo
   - Tap the **right side** of the image to go to next photo
   - See **progress bars at the top** showing which photo you're viewing
   - Smooth fade transitions between images
5. Use the swipe interface:
   - Swipe left (✕) to pass
   - Swipe right (♥) to like
   - View profile bio and details
6. **Automatic progression** - after swiping, the next unseen profile loads automatically
7. See how many profiles remain in your session

**Smart Session Tracking**:
- Never see the same profile twice in one session
- **Privacy protection**: Logged-in users won't see their own profiles
- "Start Over" button when you've seen all profiles
- Timer shows elapsed viewing time per profile
- Automatic scroll depth tracking
- All interactions are recorded for analytics
- Touch swipe support on mobile devices
- Keyboard shortcuts (← for left, → for right)
- Remaining profiles counter

## Technical Architecture

### Models

- **User**: Manages user sessions and profile ownership
- **Profile**: Stores profile information and relationships
- **ProfileInteraction**: Records all user interactions with profiles

### Controllers

- **HomeController**: Landing page with conditional navigation
- **SessionsController**: User login and logout
- **RegistrationsController**: User sign up
- **ProfilesController**: CRUD operations and analytics for profiles (requires authentication)
- **SpectatorController**: Anonymous profile viewing and interaction tracking (public)
- **ApplicationController**: Base controller with authentication helpers

### Key Technologies

- **Ruby on Rails 8.0**: Backend framework
- **BCrypt**: Secure password encryption
- **has_secure_password**: Rails authentication system
- **ActiveStorage**: Image upload and management
- **SQLite3**: Database
- **Vanilla JavaScript**: Frontend interactivity and tracking
- **CSS3**: Modern, responsive UI with Tinder-style animations

### Database Schema

```ruby
# users
- email (string, unique)
- password_digest (string, encrypted)
- session_token (string, unique)
- timestamps

# profiles
- name (string)
- age (integer)
- gender_identity (string, optional: male, female, non-binary, genderqueer, agender, other)
- height (integer, cm, optional)
- income_level (string, optional: 0-30k, 30k-50k, 50k-75k, 75k-100k, 100k-150k, 150k-200k, 200k+)
- description (text)
- user_id (integer, indexed)
- active (boolean)
- timestamps

# profile_interactions
- profile_id (integer, indexed)
- viewer_session (string)
- action (string: 'right_swipe', 'left_swipe')
- time_spent (integer, seconds, required)
- scroll_depth (integer, 0-100 percentage, required)
- image_index (integer, 0-based index of photo being viewed when swiped)
- timestamps
```

### How Analytics Work

The application uses a **single-record-per-view** system for accurate analytics:

1. **When a user views a profile**: Page loads, timer starts, scroll tracking begins, image navigation tracking starts
2. **When user swipes (left or right)**: 
   - Creates ONE ProfileInteraction record with:
     - Action type (right_swipe or left_swipe)
     - Time spent viewing (in seconds)
     - Scroll depth (0-100%, how much they scrolled)
     - Image index (which photo they were viewing when they swiped)
3. **Metrics calculation**:
   - **Views** = Total swipe actions (right + left)
   - **Success Rate** = (Right Swipes / Total Views) × 100
   - **Averages** = Mean of time_spent, scroll_depth, and photos viewed across all interactions
   - **Photo Performance** = Distribution analysis of swipe actions by image position

This ensures:
- ✅ No duplicate records
- ✅ Every interaction has complete data
- ✅ Accurate, reliable analytics
- ✅ Views always equal right_swipes + left_swipes

## Features Breakdown

### Profile Creation & Management
- Upload multiple images per profile
- Edit profile information anytime
- Toggle visibility (active/inactive)
- Delete profiles with all associated data

### Analytics Dashboard
- Real-time metric calculations
- Visual stat cards with icons
- Interaction history table
- Filterable and sortable data

### Spectator Mode
- True Tinder-style one-profile-at-a-time interface
- Automatic progression to next unseen profile
- Smart session tracking (no duplicate profiles)
- Remaining profiles counter
- **Tinder-style image navigation:**
  - Tap left/right sides of image to change photos
  - Progress bars at top (just like Tinder)
  - Smooth fade transitions
  - Works with unlimited photos per profile
- Swipe animations (left/right)
- Touch gesture support
- Keyboard navigation
- Automatic time and scroll tracking
- Session-based anonymous tracking
- "Start Over" functionality when all profiles viewed

## UI/UX Features

- **Modern Design**: Clean, gradient-based color scheme
- **Responsive Layout**: Works on desktop, tablet, and mobile
- **Smooth Animations**: Card swipes, hover effects, transitions
- **Intuitive Navigation**: Clear call-to-action buttons
- **Accessibility**: Keyboard shortcuts and semantic HTML
- **Empty States**: Helpful messages when no data exists

## Development

### Running Tests
```bash
bin/rails test
```

### Code Style
```bash
bin/rubocop
```

### Security Scan
```bash
bin/brakeman
```

## Future Enhancements

Potential features for future development:
- User authentication system
- A/B testing capabilities
- Export analytics to PDF/CSV
- Profile comparison tools
- Heat maps for scroll depth
- Geographic data tracking
- Device/browser analytics
- Social sharing capabilities
- Multi-language support
- Advanced filtering in spectator mode

## License

This project is available for educational and personal use.

## Support

For issues or questions, please open an issue on the repository.

---

Built with ❤️ using Ruby on Rails
