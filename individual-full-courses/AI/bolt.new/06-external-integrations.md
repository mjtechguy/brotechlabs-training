# Chapter 6: External Integrations and Production Readiness

## Introduction

While Bolt Cloud provides comprehensive backend infrastructure, many applications benefit from additional external services. In this chapter, we'll explore how to integrate Supabase as an alternative backend, build mobile apps with Expo, import designs from Figma, and connect various APIs for extended functionality.

## Supabase Integration: Alternative Backend as a Service

**Supabase** is an open-source alternative to Firebase that provides backend infrastructure for your applications. Think of it as a complete backend (server, database, authentication) in a box.

**Official Site**: [supabase.com](https://supabase.com) | **Documentation**: [supabase.com/docs](https://supabase.com/docs) | **Bolt Guide**: [Supabase with Bolt.new](https://support.bolt.new/integrations/supabase)

### What is Supabase?

Supabase provides three core services:

#### **1. Database (PostgreSQL)**
A powerful, professional-grade database for storing application data.

**Key Term**: *Database* - An organized collection of data stored electronically. Think of it as an extremely organized filing system for your application's information.

**Key Term**: *PostgreSQL* - A robust, open-source relational database system known for reliability and features.

#### **2. Authentication**
User management and login functionality built-in.

**Key Term**: *Authentication* - The process of verifying who a user is (usually with username/password, but can include social logins, magic links, etc.).

#### **3. Storage**
File upload and storage capabilities.

### Why Use Supabase with Bolt.new?

Most applications need:
- A way to store data permanently
- User accounts and login
- File upload capabilities

Building these from scratch is complex and time-consuming. Supabase provides them as ready-to-use services.

**Note**: Bolt Cloud includes similar capabilities automatically. Supabase is useful when you need:
- More control over your database
- Specific Supabase features
- Integration with existing Supabase projects
- Self-hosting options

### Supabase Database Features

#### **Tables and Data**

**What You Can Store**:
- User profiles
- Blog posts
- Product catalogs
- Order history
- Comments and reviews
- Any structured data

**Example Use Case**: E-commerce Site

```
Products Table:
- id: 1
- name: "Wireless Headphones"
- price: 79.99
- description: "Premium sound quality"
- in_stock: true

Orders Table:
- id: 1
- user_id: 42
- product_id: 1
- quantity: 2
- order_date: "2025-10-21"
```

#### **Real-Time Updates**

Supabase supports **real-time subscriptions**—changes to the database instantly appear in your application.

**Key Term**: *Real-time* - Instant updates without refreshing the page.

**Use Cases**:
- Chat applications (see new messages instantly)
- Collaborative tools (see others' changes live)
- Live dashboards (data updates automatically)
- Notifications (instant alerts)

**Example**: In a chat app, when User A sends a message, User B sees it immediately without refreshing.

#### **Row Level Security (RLS)**

Supabase allows you to set security rules at the data level:

**Examples**:
- Users can only see their own profile
- Only admins can delete posts
- Authors can edit their own articles
- Public data is readable by everyone

**Key Term**: *Row Level Security* - Database-level security rules that determine who can read, insert, update, or delete specific rows of data.

### Supabase Authentication

Pre-built authentication supporting multiple methods:

#### **Email/Password**
Traditional login system:
- User registration
- Login
- Password reset
- Email verification

#### **Social Logins**
One-click login with:
- Google
- GitHub
- Facebook
- Twitter
- Apple
- Many others

**Key Term**: *OAuth* - A standard that allows users to log into your app using their accounts from other services (like "Sign in with Google").

#### **Magic Links**
Passwordless authentication:
- User enters email
- Receives login link
- Clicks link to authenticate
- No password needed

#### **Phone Authentication**
SMS-based login:
- User enters phone number
- Receives verification code
- Enters code to authenticate

### Supabase Storage

Upload and manage files:

**File Types Supported**:
- Images (JPG, PNG, GIF, WebP)
- Documents (PDF, DOCX, TXT)
- Videos (MP4, WebM)
- Audio (MP3, WAV)
- Any other file type

**Features**:
- Organized in buckets (like folders)
- Access control (public or private files)
- Automatic URL generation
- Image transformations (resize, crop, etc.)

**Example Use Case**: User Profile Pictures
1. User uploads photo
2. Stored in Supabase Storage
3. URL generated automatically
4. Image displayed in application
5. Can be resized/cropped on the fly

### How to Use Supabase with Bolt.new

#### Step 1: Create Supabase Project
1. Sign up at supabase.com
2. Create new project
3. Get your project credentials

#### Step 2: Tell Bolt.new What You Need
"Add user authentication using Supabase with email/password login"

#### Step 3: AI Generates Integration
The AI automatically:
- Installs Supabase client library
- Configures connection
- Creates login/signup components
- Implements authentication logic
- Handles user sessions

#### Step 4: Configure in Supabase
- Set up authentication providers
- Create database tables
- Configure security rules
- Set up storage buckets

### Real-World Example: Blog with Supabase

**Prompt to Bolt.new**:
"Create a blog where users can sign up, write posts, and comment on others' posts. Use Supabase for the database and authentication."

**What Gets Built**:

**Database Tables**:
```
users (managed by Supabase Auth)
├── id
├── email
└── created_at

posts
├── id
├── author_id (references users)
├── title
├── content
├── created_at
└── updated_at

comments
├── id
├── post_id (references posts)
├── user_id (references users)
├── content
└── created_at
```

**Features**:
- User registration and login
- Create/edit/delete own posts
- Comment on any post
- Real-time comment updates
- User profile pages
- Security rules ensuring users can only edit their own content

**Time to Build**: 5-10 minutes with Bolt.new

## Expo Integration: Build Mobile Apps

**Expo** is a framework for building native mobile applications (iOS and Android) using React Native and JavaScript.

**Official Site**: [expo.dev](https://expo.dev) | **Documentation**: [docs.expo.dev](https://docs.expo.dev) | **Bolt Guide**: [Expo for Mobile Apps](https://support.bolt.new/integrations/expo)

**Key Term**: *React Native* - A framework that lets you build mobile apps using JavaScript/React that run natively on iOS and Android devices.

**Key Term**: *Native App* - An application built specifically for a mobile platform that can be downloaded from app stores and installed on devices.

### Why Expo?

**Traditional Mobile Development**:
- Learn Swift for iOS
- Learn Kotlin/Java for Android
- Build two separate applications
- Maintain two codebases

**With Expo**:
- Write JavaScript/React once
- Works on both iOS and Android
- Use same skills as web development
- Access device features (camera, location, etc.)

### What You Can Build with Expo + Bolt.new

**Application Types**:
- Social media apps
- E-commerce apps
- Fitness trackers
- News readers
- Chat applications
- Productivity tools
- Games
- Almost anything!

### Key Mobile Features Expo Provides

#### **Device Access**
- **Camera**: Take photos and videos
- **Location**: GPS and maps
- **Accelerometer**: Detect device movement
- **Push Notifications**: Send alerts to users
- **Contacts**: Access phone contacts
- **Calendar**: Integrate with device calendar
- **File System**: Store and retrieve files

#### **Native Components**
- Touch gestures (swipe, pinch, zoom)
- Native navigation
- Status bars
- Tab bars
- Modal screens

#### **Cross-Platform Compatibility**
Write once, run on:
- iOS (iPhone, iPad)
- Android phones and tablets
- Even web browsers (Expo supports web too!)

### How to Use Expo with Bolt.new

#### Prompt Example
"Create a mobile app for tracking daily water intake with push notifications to remind users to drink water."

**What Gets Generated**:
- Mobile-optimized UI components
- Data persistence (local storage)
- Notification scheduling
- Charts/graphs for tracking
- Settings screen

### Testing Your Mobile App

#### **Expo Go App**
1. Download "Expo Go" app on your phone (free in app stores)
2. Scan QR code from Bolt.new
3. App loads on your actual device
4. Test real mobile experience
5. See changes in real-time as you develop

**No need for**:
- Xcode (iOS development software)
- Android Studio (Android development software)
- Physical device cables
- Complex setup

#### **Emulators**
Can also test on:
- iOS Simulator (Mac only)
- Android Emulator
- Browser preview

### Publishing Your Mobile App

When ready to distribute:

#### **Expo Build Service**
1. Configure app details (name, icon, splash screen)
2. Build for iOS and/or Android
3. Expo creates app bundles
4. Submit to app stores

#### **App Stores**
- **Apple App Store** (iOS): Requires Apple Developer account ($99/year)
- **Google Play Store** (Android): Requires Google Play Developer account ($25 one-time)

#### **Over-the-Air Updates**
With Expo, push updates without app store approval:
- Fix bugs instantly
- Add features
- Update content
- Users get updates automatically

**Limitation**: Only works for JavaScript changes, not native code changes.

## Figma Integration: Design to Code

**What is Figma?**
A collaborative design tool for creating user interfaces.

**Official Site**: [figma.com](https://www.figma.com) | **Bolt Guide**: [Figma for Design](https://support.bolt.new/integrations/figma)

### How Integration Works

1. Designer creates UI in Figma
2. Import into Bolt.new
3. AI converts design to code
4. Developer adds functionality

### What Gets Imported

- Layout and positioning
- Colors and typography
- Spacing and sizing
- Component structure
- Basic interactions

### Benefits

- Design-to-development handoff is instant
- Reduces miscommunication
- Accurate implementation
- Faster development

## Environment Variables and Secrets

### What Are Environment Variables?

**Environment Variable**: A configuration value stored outside your code that can be different in development vs. production.

### Why They Matter

**Never Hard-Code Secrets**:

❌ **Bad**:
```javascript
const API_KEY = "sk_live_abc123xyz789";  // Visible in code!
```

✅ **Good**:
```javascript
const API_KEY = process.env.SUPABASE_KEY;  // Loaded from secure storage
```

### Types of Information to Store as Environment Variables

**API Keys**:
- Supabase credentials
- Stripe payment keys
- SendGrid email keys
- OpenAI API keys

**Database Credentials**:
- Connection strings
- Usernames and passwords

**Service URLs**:
- API endpoints
- Webhook URLs

**Feature Flags**:
- Enable/disable features
- A/B testing configurations

### How to Use Environment Variables in Bolt.new

#### Development
Create a `.env` file (automatically ignored by Git):

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key-here
STRIPE_PUBLIC_KEY=pk_test_abc123
```

#### Production (Netlify)
1. Go to Netlify dashboard
2. Navigate to Site Settings
3. Build & Deploy → Environment
4. Add each variable
5. Redeploy site

**Security**: These values are encrypted and never exposed to users.

## API Integrations

Bolt.new makes it easy to integrate with external services:

### Common API Integrations

#### **Payment Processing**
- **Stripe**: Credit card payments, subscriptions
- **PayPal**: Alternative payment method
- **Square**: In-person and online payments

#### **Communication**
- **Twilio**: SMS messaging
- **SendGrid**: Email delivery
- **Mailchimp**: Email marketing

#### **Maps and Location**
- **Google Maps**: Interactive maps, directions
- **Mapbox**: Customizable maps
- **OpenStreetMap**: Free, open-source maps

#### **AI and Machine Learning**
- **OpenAI**: ChatGPT, DALL-E, text generation
- **Google Cloud AI**: Vision, translation, speech
- **Hugging Face**: Pre-trained models

#### **Social Media**
- **Twitter API**: Post tweets, read timeline
- **Instagram API**: Share photos
- **Facebook API**: Social integration

### Example: Adding Stripe Payments

**Prompt to Bolt.new**:
"Add Stripe payment integration with a checkout form for a $29 product"

**AI Generates**:
- Stripe client setup
- Checkout form component
- Payment confirmation page
- Error handling
- Webhook endpoint for payment events

**You Provide**:
- Stripe API keys (in environment variables)
- Product details
- Thank you page content

## Analytics and Monitoring

### Google Analytics
Track user behavior:
- Page views
- User demographics
- Traffic sources
- Conversion tracking

### Sentry
Error monitoring:
- Catch and log errors
- Get notified of issues
- See error context
- Track error frequency

### LogRocket
Session replay:
- Watch how users interact
- See what led to errors
- Identify UX issues
- Improve user experience

## Cost Considerations

### Free Tiers (Good for Learning and Small Projects)

**Netlify Free**:
- 100GB bandwidth/month
- 300 build minutes/month
- Perfect for personal projects

**Supabase Free**:
- 500MB database
- 1GB file storage
- 50,000 monthly active users
- Excellent for MVPs and prototypes

**Expo**:
- Free to develop
- Pay only for build services or when publishing

### Paid Plans (For Production Applications)

**Netlify Pro** (~$19/month):
- 400GB bandwidth
- More build minutes
- Better support
- Advanced features

**Supabase Pro** (~$25/month):
- 8GB database
- 100GB file storage
- Daily backups
- Point-in-time recovery

**Mobile App Stores**:
- Apple Developer: $99/year
- Google Play: $25 one-time

### Estimating Costs

**Small Project** (personal site, small app):
- Netlify: Free
- Supabase: Free
- Total: $0/month

**Medium Project** (small business, moderate traffic):
- Netlify Pro: $19/month
- Supabase Pro: $25/month
- Domain: $12/year (~$1/month)
- Total: ~$45/month

**Large Project** (significant traffic, many users):
- Netlify Business: $99/month
- Supabase Team: $599/month
- Additional services vary
- Total: $700+/month

## Real-World Deployment Scenario

Let's walk through a complete deployment:

### Project: Recipe Sharing Platform

**Requirements**:
- Users can create accounts
- Post recipes with photos
- Comment on recipes
- Search and filter recipes
- Mobile-friendly

**Architecture**:
- **Frontend**: React app (built with Bolt.new)
- **Deployment**: Netlify
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **File Storage**: Supabase Storage (for recipe photos)

**Development Process**:

1. **Build in Bolt.new** (2-3 hours)
   - Prompt AI to create recipe platform
   - Implement user authentication
   - Create recipe upload form
   - Build recipe display and search
   - Test locally

2. **Set Up Supabase** (30 minutes)
   - Create project
   - Design database schema
   - Configure authentication
   - Set up storage bucket for images
   - Configure security rules

3. **Connect Services** (15 minutes)
   - Add Supabase credentials to Bolt.new
   - Test database connection
   - Verify authentication works
   - Test file uploads

4. **Deploy to Netlify** (5 minutes)
   - Click deploy in Bolt.new
   - Add environment variables in Netlify
   - Verify deployment successful
   - Test live application

5. **Configure Domain** (15 minutes)
   - Purchase domain (recipehub.com)
   - Configure DNS
   - Add to Netlify
   - Wait for HTTPS certificate

6. **Final Testing** (30 minutes)
   - Test all features on live site
   - Check mobile responsiveness
   - Verify images load correctly
   - Test user registration and login

**Total Time**: ~4 hours from idea to live application

**Ongoing Maintenance**:
- Monitor errors and analytics
- Respond to user feedback
- Add new features as needed
- Keep dependencies updated

## Production Readiness Checklist

Before launching to real users:

### Performance
- [ ] Images optimized
- [ ] Unnecessary packages removed
- [ ] Code minified (automatic with Netlify)
- [ ] Loading time under 3 seconds
- [ ] Mobile performance tested

### Security
- [ ] No API keys in code
- [ ] HTTPS enabled (automatic)
- [ ] Input validation implemented
- [ ] Authentication tested
- [ ] User data encrypted
- [ ] CORS configured properly
- [ ] SQL injection prevented
- [ ] XSS attacks prevented

### Functionality
- [ ] All features tested
- [ ] Forms work correctly
- [ ] Links navigate properly
- [ ] Error handling present
- [ ] Mobile responsive
- [ ] Cross-browser tested

### SEO
- [ ] Page titles descriptive
- [ ] Meta descriptions added
- [ ] Images have alt text
- [ ] URLs clean and readable
- [ ] Site map created
- [ ] robots.txt configured

### Legal & Compliance
- [ ] Privacy policy (if collecting data)
- [ ] Terms of service
- [ ] Cookie consent (if using cookies)
- [ ] GDPR compliant (if serving EU)
- [ ] Accessibility standards (WCAG)

### Monitoring
- [ ] Error tracking set up
- [ ] Analytics configured
- [ ] Performance monitoring active
- [ ] Uptime monitoring enabled

## Summary

Bolt.new's external integrations extend capabilities beyond the built-in Bolt Cloud infrastructure:

**Supabase**:
- Alternative backend with more control
- Professional PostgreSQL database
- Real-time subscriptions
- Row-level security
- Multiple authentication methods

**Expo**:
- Build native mobile apps
- Test on real devices easily
- Publish to app stores
- Over-the-air updates

**Figma**:
- Import designs directly
- Instant design-to-code
- Accurate implementation
- Faster development

**APIs & Services**:
- Payment processing (Stripe, PayPal)
- Communication (Twilio, SendGrid)
- Maps and location services
- AI and machine learning
- Social media integration

**Production Tools**:
- Environment variables for security
- Analytics for insights
- Error monitoring for reliability
- Performance tracking

With these integrations, Bolt.new supports building enterprise-grade applications that can scale to millions of users while maintaining professional standards for security, performance, and user experience.

---

**Key Takeaways**:
1. Supabase provides alternative backend with more control
2. Expo enables native mobile app development
3. Figma integration speeds design-to-code workflow
4. Environment variables keep secrets secure
5. API integrations extend functionality infinitely
6. Free tiers support learning and small projects
7. Production checklist ensures quality launches
8. Complete stack from development to monitoring

**Congratulations! You've completed the full Bolt.new course and now understand how to build, deploy, and scale professional applications using AI assistance.**
