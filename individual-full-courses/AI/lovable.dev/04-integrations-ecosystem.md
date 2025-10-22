# Chapter 4: Integrations & Ecosystem - Extending Lovable

## Introduction

Lovable.dev isn't a walled garden—it's designed to integrate with the tools and services you already use. From GitHub for version control to Figma for design import, from Stripe for payments to custom third-party APIs, Lovable connects seamlessly with the broader development ecosystem. In this chapter, we'll explore how to extend your applications through integrations and why Lovable's open approach matters.

**Documentation**: [Integrations Overview](https://docs.lovable.dev/integrations)

## GitHub Integration: Version Control & Collaboration

### Overview

Every Lovable project can be connected to a **GitHub repository**, providing full version control and code ownership.

**Key Benefit**: Your entire codebase is backed up automatically, and you can collaborate using standard Git workflows.

**Documentation**: [GitHub Integration Guide](https://docs.lovable.dev/integrations/github)

### How It Works

**Behind the Scenes**:
- Lovable automatically creates a Git repository for every project
- When you connect GitHub, it pushes your code to your repository
- **Two-way sync**: Changes in Lovable → GitHub, Changes in GitHub → Lovable

**What Gets Synced**:
- All source code (React components, TypeScript, CSS)
- Configuration files
- Database schema (as code)
- Edge Functions
- Package dependencies (package.json)

### Setting Up GitHub Integration

**Steps**:
1. Open project settings in Lovable
2. Click "Connect to GitHub"
3. Authorize Lovable GitHub app
4. Choose organization (personal or team)
5. Create new repo or select existing
6. Lovable pushes your code

**Result**: Your project appears in GitHub with full commit history

### Benefits of GitHub Integration

#### 1. **Version Control**

**See Every Change**:
```
Commit History:
- "Add user authentication" (2 hours ago)
- "Update homepage design" (5 hours ago)
- "Fix form validation bug" (yesterday)
```

**Revert Mistakes**:
- Review diffs of AI-generated changes
- Roll back to previous versions
- Branch for experiments

#### 2. **Collaboration**

**Standard Git Workflows**:
- Team members clone repository
- Create branches for features
- Open pull requests
- Review code before merging

**Example**:
```
Developer workflow:
1. Clone Lovable project from GitHub
2. Create feature branch: git checkout -b add-payment
3. Make changes in local IDE
4. Push to GitHub
5. Changes sync back to Lovable automatically
```

#### 3. **Code Ownership**

**You Own Everything**:
- Complete source code in your GitHub account
- Not locked into Lovable platform
- Can deploy anywhere (Vercel, Netlify, own servers)
- Export and continue development externally if needed

#### 4. **CI/CD Integration**

**Continuous Integration**:
- Connect GitHub Actions
- Run tests on every commit
- Automated deployment pipelines
- Quality checks and linting

#### 5. **Transparency**

**Review AI-Generated Code**:
- See exactly what the AI changed
- Compare before/after in diffs
- Understand implementation details
- Learn from generated patterns

### Viewing Diffs and Changes

**In GitHub**:
```
Commit: "Add authentication system"

Files changed:
+ src/components/LoginForm.tsx (new)
+ src/components/SignupForm.tsx (new)
+ src/lib/auth.ts (new)
M src/App.tsx (modified)
+ supabase/migrations/create_users_table.sql (new)
```

**Review each file's changes**:
- Green lines = added
- Red lines = removed
- See AI's implementation choices

### External Development

**Work in Your IDE**:
1. Clone repo: `git clone github.com/yourname/project`
2. Open in VS Code, WebStorm, etc.
3. Make changes locally
4. Push to GitHub
5. Changes appear in Lovable

**Hybrid Workflow**:
- Use Lovable AI for big features
- Fine-tune in your IDE
- Let AI handle boilerplate
- You handle complex logic

## Figma to Lovable: Design Import

### Overview

**Figma to Lovable** integration (powered by Builder.io) transforms static designs into working applications.

**Workflow**: Design in Figma → Export to Lovable → Add functionality with AI

**Resources**:
- [Figma to Lovable Tutorial](https://docs.lovable.dev/features/figma-to-lovable)
- [Figma](https://figma.com) - Design tool
- [Builder.io](https://builder.io) - Design-to-code platform

### How It Works

**Step 1: Design in Figma**
- Create high-fidelity designs
- Use Figma best practices (Auto Layout, proper naming)
- Organize layers and components

**Step 2: Builder.io Plugin**
- Install Builder.io Figma plugin
- Select frames to export
- Click "Open in Lovable"

**Step 3: Code Generation**
- Design converts to clean React code
- Maintains pixel-perfect accuracy
- Responsive breakpoints preserved
- Tailwind CSS for styling

**Step 4: Add Functionality**
- Use Lovable AI to add interactivity
- Connect to backend/database
- Implement business logic

### Best Practices for Figma Designs

**For Best Conversion**:

1. **Use Auto Layout**
   - Proper spacing and constraints
   - Responsive behavior

2. **Name Layers Clearly**
   - "header-logo" not "Rectangle 42"
   - Descriptive component names

3. **Component Organization**
   - Use Figma components for reusable elements
   - Consistent naming conventions

4. **Responsive Design**
   - Design mobile and desktop variants
   - Use constraints properly

**What Works Well**:
- Landing pages
- Marketing sites
- Dashboard layouts
- Form designs
- Navigation menus

**What Needs Manual Work**:
- Complex interactions
- Animations (can be added with AI after)
- Dynamic data (add with AI)

### Example Workflow

**Scenario**: Designer creates landing page in Figma

1. **Design Phase**:
   - Hero section with image and CTA
   - Features grid (3 columns)
   - Pricing table
   - Contact form
   - Footer

2. **Export**:
   - Use Builder.io plugin
   - Select all frames
   - Export to Lovable

3. **Add Functionality**:
```
"Make the contact form functional:
- Validate email format
- Store submissions in database
- Send confirmation email
- Show success message"

"Connect pricing table to Stripe:
- Add 'Subscribe' buttons
- Implement checkout flow"
```

**Result**: Pixel-perfect design + working functionality in minutes

### Alternative: Screenshot Import

Can't access Figma files? Lovable can work from screenshots:

**Prompt**:
```
"Recreate this design from the screenshot:
[Upload image]
- Match colors and fonts as closely as possible
- Responsive layout
- Modern, clean styling"
```

Works surprisingly well for:
- Competitor analysis
- Quick prototypes
- Legacy designs

## Stripe Integration: Payments

### Overview

Accept payments and manage subscriptions with **Stripe** integration.

**Resources**:
- [Stripe Integration Guide](https://docs.lovable.dev/integrations/stripe)
- [Stripe Documentation](https://stripe.com/docs)
- [Stripe Dashboard](https://dashboard.stripe.com)

**What You Can Build**:
- One-time payments
- Subscription billing
- Payment processing
- Customer portals
- Invoice management

### Setting Up Stripe

**Prompt**:
```
"Integrate Stripe payments:
- Connect to my Stripe account
- Implement checkout flow
- Handle webhooks for payment confirmation"
```

**Lovable Asks**:
```
"I need your Stripe secret key. Please add it to Secrets:
- STRIPE_SECRET_KEY
- STRIPE_PUBLISHABLE_KEY"
```

**Steps**:
1. Get API keys from dashboard.stripe.com
2. Add to Lovable Secrets vault
3. Lovable configures integration automatically

### Example: Subscription Product

**Prompt**:
```
"Create subscription tiers:

Basic: $9/month
- Feature A
- Feature B

Pro: $29/month
- All Basic features
- Feature C
- Feature D
- Priority support

Pricing page with:
- 3-column layout
- Feature comparison
- 'Subscribe' buttons
- Monthly/Annual toggle

Implementation:
- Stripe Checkout for payment
- Store subscription status in database
- Check subscription on login
- Restrict features based on plan"
```

**What Lovable Creates**:
- Pricing page UI
- Stripe Checkout integration
- Webhook handler (payment success → update database)
- Subscription status checks
- Customer portal (manage subscription)

### Webhook Handling

**Webhooks** notify your app of Stripe events:

**Events**:
- `payment_succeeded`: Payment completed
- `subscription_canceled`: User canceled
- `invoice_payment_failed`: Payment failed

**Automatic Setup**:
Lovable creates Edge Function to handle webhooks:
```
When Stripe sends payment_succeeded:
1. Verify webhook signature (security)
2. Extract customer ID and subscription
3. Update user's subscription status in database
4. Send confirmation email
```

### Security Best Practices

**Secrets Vault**:
- Never expose secret keys in frontend
- All payment processing happens on backend (Edge Functions)

**Webhook Verification**:
- Lovable automatically verifies webhook signatures
- Prevents fraudulent requests

**PCI Compliance**:
- Stripe handles sensitive card data
- You never touch raw credit card numbers

## Shopify Integration

### Overview

Build custom storefronts powered by Shopify's e-commerce backend.

**Use Case**: Custom shopping experience while Shopify handles inventory, orders, fulfillment.

**Resources**:
- [Shopify](https://shopify.com) - E-commerce platform
- [Shopify API Docs](https://shopify.dev/docs)

**Prompt Example**:
```
"Create Shopify storefront:
- Connect to my Shopify store
- Display products with images and prices
- Add to cart functionality
- Checkout redirects to Shopify
- Show order history for logged-in customers"
```

**What You Need**:
- Shopify store
- Shopify API credentials (added to Secrets)

**Result**: Custom-branded shopping experience with Shopify's robust backend

## Email Integration: Resend & SendGrid

### Overview

Send transactional and marketing emails from your application.

**Supported Services**:
- **Resend**: Modern, developer-friendly (recommended) - [resend.com](https://resend.com)
- **SendGrid**: Established, feature-rich - [sendgrid.com](https://sendgrid.com)

### Email Use Cases

**Transactional**:
- Welcome emails on signup
- Order confirmations
- Password resets
- Payment receipts
- Notifications

**Marketing** (with proper consent):
- Newsletters
- Product announcements
- Promotional campaigns

### Example: Welcome Email

**Prompt**:
```
"Send welcome email when user signs up:

Email Service: Resend
From: welcome@myapp.com
Subject: 'Welcome to {AppName}!'

Content:
- Greeting with user's first name
- Brief intro to product
- Quick start guide link
- Support contact

Trigger: Automatically on user.created event"
```

**Implementation**:
- Lovable creates Edge Function
- Triggers on new user signup
- Sends via Resend API
- Logs success/failure

**What You Need**:
- Resend account (free tier available)
- API key added to Secrets
- Verified sending domain

### Email Templates

**Prompt**:
```
"Create email template system:
- Store templates in database
- Support variables: {{user.name}}, {{order.total}}
- Preview before sending
- Track open rates and clicks"
```

## Authentication Alternatives: Clerk

### Overview

While Lovable Cloud includes authentication, you can use **Clerk** for advanced auth needs.

**Resources**:
- [Clerk](https://clerk.com) - Authentication platform
- [Clerk Documentation](https://clerk.com/docs)

**Why Clerk**:
- More social providers (Apple, LinkedIn, etc.)
- Advanced security features
- Custom authentication flows
- Enterprise SSO

**Prompt Example**:
```
"Integrate Clerk for authentication:
- Replace built-in auth with Clerk
- Support email, Google, and GitHub login
- Show user profile from Clerk
- Sync Clerk user ID to database"
```

**Setup**:
- Clerk account
- API keys in Secrets
- Lovable scaffolds integration code

## External Database: Custom Supabase

### Overview

Instead of Lovable Cloud, you can bring your own Supabase instance.

**Why You Might**:
- Company data residency requirements
- Specific Supabase features needed
- Existing Supabase project to connect

**How It Works**:
1. Create Supabase project at supabase.com
2. Get connection URL and anon key
3. Provide to Lovable
4. AI generates code using your Supabase

**Trade-offs**:
- **Pro**: Full control over database
- **Con**: Manual Supabase management
- **Pro**: Transparent billing
- **Con**: No Lovable-managed scaling

## Custom API Integrations

### Overview

Connect to any third-party API by describing what you need.

**Examples**:
- **Weather Data**: OpenWeatherMap, WeatherAPI
- **Maps**: Google Maps, Mapbox
- **CRM**: Salesforce, HubSpot
- **Messaging**: Twilio (SMS), SendGrid
- **Analytics**: Google Analytics
- **AI Services**: Replicate, OpenAI (bring your own key)

### Example: Weather API

**Prompt**:
```
"Integrate OpenWeatherMap API:
- User searches for city name
- Fetch current weather and 5-day forecast
- Display temperature, conditions, humidity
- Show weather icons
- Store recent searches in database

API Key: Store in Secrets as OPENWEATHER_API_KEY
Endpoint: api.openweathermap.org/data/2.5/"
```

**Implementation**:
- Edge Function calls API (hides key)
- Caches responses (reduce API calls)
- Error handling (invalid city, rate limits)

### Example: SMS Notifications (Twilio)

**Prompt**:
```
"Add SMS notifications via Twilio:
- When order ships, text customer tracking number
- Store phone numbers in user profiles
- Verify phone with OTP before sending
- Log all sent messages

Twilio credentials in Secrets:
- TWILIO_ACCOUNT_SID
- TWILIO_AUTH_TOKEN
- TWILIO_PHONE_NUMBER"
```

## Make.com: No-Code Automation

### Overview

**Make (formerly Integromat)** connects Lovable to thousands of services via visual workflows.

**Resources**:
- [Make.com](https://make.com) - No-code automation platform
- [Make Templates](https://make.com/en/templates) - Pre-built workflows

**Use Case**: Lovable handles frontend/UI, Make handles complex backend workflows.

**Example**:
```
Lovable → Make → Google Sheets + Slack

When user submits form in Lovable:
1. Send webhook to Make
2. Make adds row to Google Sheet
3. Make posts to Slack channel
4. Make creates Asana task
```

**Setup**:
1. Create Make scenario (workflow)
2. Get Make webhook URL
3. Lovable sends events to webhook
4. Make handles automation

**Benefits**:
- Connect to 1000+ services
- Visual workflow builder
- No code required for integrations

## Replicate: Custom AI Models

### Overview

Access specialized AI models on **Replicate** for advanced use cases.

**Resources**:
- [Replicate](https://replicate.com) - AI model platform
- [Replicate Models](https://replicate.com/explore) - Browse available models
- [Replicate Documentation](https://replicate.com/docs)

**What Replicate Offers**:
- Image generation (Stable Diffusion variants)
- Video processing
- Audio transcription
- Custom ML models

**Prompt Example**:
```
"Integrate Replicate for image generation:
- User describes desired image
- Generate using Stable Diffusion XL
- Display result in gallery
- Options to regenerate or tweak prompt

Replicate API key in Secrets"
```

**Use Cases**:
- AI-generated product images
- Custom art creation tools
- Style transfer applications
- Voice cloning or generation

## Build with URL: Lovable API

### Overview

**Build with URL** lets you trigger Lovable project creation via special URLs.

**URL Format**:
```
https://lovable.dev/?autosubmit=true#prompt=YOUR_PROMPT_HERE
```

**Use Cases**:

#### 1. **Template Gallery**

Create "starter templates" as shareable links:
```
Clickable links on your site:
- "Blog Starter" → Opens Lovable with blog template
- "E-commerce Starter" → Opens with shop template
- "Dashboard Starter" → Opens with admin panel template
```

#### 2. **Social Sharing**

```
Tweet: "Built this todo app in 5 minutes with Lovable!
Try it yourself: [Lovable URL with todo app prompt]"

Others click → Instant todo app in their Lovable account
```

#### 3. **Educational Content**

```
Tutorial: "Building a Weather App"

Each step has "Try in Lovable" button
Students click → Pre-filled prompt creates example
```

#### 4. **Internal Tooling**

```
Company library of app starters:
- "Customer Dashboard"
- "Report Generator"
- "Feedback Form"

One-click starts project with company standards
```

### Link Generator Tool

Lovable provides a **Link Generator** to create these URLs easily:
- Enter your prompt
- Add optional image references (up to 10)
- Copy generated URL
- Share anywhere

### Image References in URLs

**Include reference images**:
```
https://lovable.dev/?autosubmit=true&images=URL1,URL2#prompt=PROMPT
```

**Use for**:
- Design inspiration
- Logo references
- Example layouts
- Color schemes

## Deployment Options Beyond Lovable

### Overview

While Lovable provides one-click hosting, you can deploy anywhere.

### Netlify Deployment

**Steps**:
1. Connect GitHub repository
2. Link to Netlify
3. Configure build:
   ```
   Build command: npm run build
   Publish directory: dist
   ```
4. Auto-deploy on Git push

**Why Netlify**:
- Custom domains
- Form handling
- Split testing
- CDN optimization

### Vercel Deployment

**Steps**:
1. Import GitHub repository
2. Vercel detects framework (React/Next.js)
3. Auto-configures build
4. Deploy

**Workflow**:
- Lovable edits `dev` branch
- You merge to `main` for production
- Vercel auto-deploys `main`

### Self-Hosting

**Export & Deploy**:
1. Clone from GitHub
2. Build locally: `npm run build`
3. Deploy static files to:
   - AWS S3 + CloudFront
   - DigitalOcean Spaces
   - Your own servers

**Backend (Lovable Cloud)**:
- Continues running on Lovable's infrastructure
- Or: Migrate to your own Supabase instance

## Mobile Apps: Capacitor Conversion

### Overview

Convert Lovable web apps to **native mobile apps** (iOS/Android) using Capacitor.

**What is Capacitor**:
- Wraps web app in native container
- Access native device features (camera, GPS, etc.)
- Deploy to App Store and Google Play

**Steps** (community guide available):
1. Build web app in Lovable
2. Export code from GitHub
3. Add Capacitor: `npx cap init`
4. Add platforms: `npx cap add ios android`
5. Build and test
6. Submit to app stores

**Best For**:
- Prototype mobile app quickly
- Cross-platform with single codebase
- Web-first apps that need mobile presence

## Community Ecosystem

### bolt.diy Compatibility

Some **bolt.diy** (Bolt.new open-source fork) patterns and approaches are transferable to Lovable workflows.

### Community Resources

**Learning**:
- YouTube tutorials
- Blog posts and guides
- Reddit discussions (r/Lovable, etc.)
- Discord community

**Templates & Examples**:
- Public project gallery
- Remixable starter templates
- "Launched" showcase

**Tools**:
- Link generators
- Conversion utilities (Next.js, Capacitor)
- Integration helpers

## Best Practices for Integrations

### 1. Use Secrets for All API Keys

**Never** expose keys in:
- Chat prompts
- Frontend code
- Public GitHub repos

**Always** store in Secrets vault.

### 2. Handle Rate Limits

**Prompt**:
```
"Add rate limiting:
- Max 10 API calls per user per minute
- Show friendly error if limit exceeded
- Cache results to reduce calls"
```

### 3. Error Handling

**Graceful Failures**:
```
"If Stripe payment fails:
- Show user-friendly error message
- Log error details
- Offer retry button
- Provide support contact"
```

### 4. Test Webhooks Locally

Use tools like **ngrok** or **Stripe CLI** to test webhook handlers before deploying.

### 5. Monitor Integration Health

**Prompt**:
```
"Add integration monitoring:
- Log all external API calls
- Track success/failure rates
- Alert if API goes down
- Display status page for users"
```

## Summary

Lovable's integration ecosystem ensures you're never locked in and can connect to the tools you need:

- **GitHub**: Version control, collaboration, code ownership
- **Figma**: Design-to-code workflow
- **Stripe**: Payment processing
- **Shopify**: E-commerce backend
- **Email Services**: Transactional and marketing emails
- **Authentication**: Clerk and others
- **Custom APIs**: Any third-party service
- **Make.com**: No-code automation
- **Replicate**: Specialized AI models
- **Build with URL**: Programmatic project creation
- **Multiple Deployment Options**: Netlify, Vercel, self-hosting
- **Mobile**: Capacitor for iOS/Android

This open, extensible approach means Lovable fits into your workflow—not the other way around. You maintain full code ownership, can deploy anywhere, and integrate with any service.

In the next chapter, we'll explore **Collaboration & Deployment**—working in teams, publishing applications, and managing custom domains.

---

**Key Takeaways**:
1. GitHub integration provides version control and code ownership
2. Figma designs convert to pixel-perfect code via Builder.io
3. Stripe enables payments with automatic webhook handling
4. Email services (Resend/SendGrid) for transactional messages
5. Custom API integrations for any third-party service
6. Build with URL for programmatic project creation
7. Deploy to Netlify, Vercel, or self-host from GitHub
8. Secrets vault protects API keys and credentials
9. Mobile apps possible via Capacitor conversion
10. Open ecosystem prevents vendor lock-in
