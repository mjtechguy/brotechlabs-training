# Chapter 5: Collaboration & Deployment - Teams and Publishing

## Introduction

Building applications is often a team effort, and getting your app in front of users is the ultimate goal. Lovable.dev provides comprehensive collaboration features for teams of any size, along with one-click deployment to make your applications publicly accessible. In this chapter, we'll explore workspaces, role-based permissions, publishing workflows, and custom domain setup.

**Documentation**: [Collaboration Features](https://docs.lovable.dev/features/collaboration)

## Workspaces: Organizing Projects and Teams

### What is a Workspace?

A **workspace** is like an organization or team account that contains:
- Multiple projects
- Multiple collaborators
- Shared billing and credits
- Unified settings

**Think of it as**: Your company's Lovable account where all team members and projects live.

### Workspace vs. Personal

**Personal Account**:
- Individual user
- Personal projects
- Own billing

**Workspace**:
- Team environment
- Multiple members
- Shared resources
- Centralized management

### Creating and Managing Workspaces

**Create New Workspace**:
1. Click workspace dropdown
2. "+ New Workspace"
3. Name it (e.g., "Acme Inc" or "Design Team")
4. Choose plan (Free/Pro/Business)

**Multiple Workspaces**:
- You can create/join multiple workspaces
- Switch between them easily
- Each has separate projects and billing

**Use Cases**:
- **Company Workspace**: Main business projects
- **Client Workspace**: Projects for specific client
- **Personal Workspace**: Side projects
- **Open Source Workspace**: Community projects

## Collaboration Features

### Unlimited Collaborators

**Key Benefit**: Lovable allows **unlimited team members** even on the free tier.

**No Per-Seat Pricing**:
- Add as many people as needed
- No extra charges for more users
- Great for:
  - Large teams
  - Classrooms
  - Open source projects
  - Hackathons

### Inviting Collaborators

#### Workspace-Level Invites

**Grant Access to All Projects**:

**Steps**:
1. Workspace Settings
2. Members tab
3. "Invite Member"
4. Enter email address
5. Select role (Admin/Editor/Viewer)
6. Send invitation

**When to Use**:
- Permanent team members
- Need access to multiple projects
- Ongoing collaboration

#### Project-Level Invites

**Grant Access to Single Project**:

**Steps**:
1. Open project
2. Click "Invite" button
3. Enter email
4. Person gets access only to that project

**When to Use**:
- External consultants
- Contractors for specific project
- One-time collaborators
- Don't want them seeing other projects

### Role-Based Permissions

Lovable supports four roles with different capabilities:

#### **Viewer**

**Can**:
- View project and content
- See code in Code Mode
- Browse project settings
- View analytics

**Cannot**:
- Edit or modify project
- Use AI to make changes
- Publish updates
- Invite others

**Use For**:
- Stakeholders reviewing progress
- Clients checking on projects
- Read-only access for audits

#### **Editor**

**Can**:
- Everything Viewers can do
- Use AI to edit project (Agent/Chat modes)
- Make visual edits
- Edit code in Code Mode
- Publish updates

**Cannot**:
- Invite/remove members
- Delete project
- Manage billing
- Transfer ownership

**Use For**:
- Developers building features
- Designers making UI changes
- Primary team members

#### **Admin**

**Can**:
- Everything Editors can do
- Invite and remove members (except Owner)
- Manage project settings
- Configure custom domains
- Set up integrations
- Delete or transfer projects

**Cannot**:
- Remove the Owner
- Transfer ownership

**Use For**:
- Tech leads
- Project managers
- Senior team members

**Availability**: Pro and Business plans only (Free tier doesn't have Admin role)

#### **Owner**

**Can**:
- Everything Admins can do
- Transfer ownership
- Delete workspace
- Full control over everything

**Note**: Every workspace/project has exactly one Owner

### Permissions Matrix

| Action | Viewer | Editor | Admin | Owner |
|--------|--------|--------|-------|-------|
| View project | ✅ | ✅ | ✅ | ✅ |
| View code | ✅ | ✅ | ✅ | ✅ |
| Edit with AI | ❌ | ✅ | ✅ | ✅ |
| Visual edits | ❌ | ✅ | ✅ | ✅ |
| Publish | ❌ | ✅ | ✅ | ✅ |
| Invite members | ❌ | ❌ | ✅ | ✅ |
| Manage settings | ❌ | ❌ | ✅ | ✅ |
| Custom domains | ❌ | ❌ | ✅ | ✅ |
| Delete project | ❌ | ❌ | ✅ | ✅ |
| Transfer ownership | ❌ | ❌ | ❌ | ✅ |

## Real-Time Collaboration

### Concurrent Editing

**Multiple people can work simultaneously**:
- See changes as they happen
- Real-time preview updates
- Collaborative development

**How It Works**:
```
Developer A: "Add user authentication"
Developer B: Sees AI implementing auth in real-time

Developer B: "Add profile page"
Developer A: Sees profile page appear immediately
```

**Combined with GitHub**:
- Changes sync to GitHub automatically
- Full commit history preserved
- Can review diffs and merges

### Credit Sharing

**Important**: When collaborators use AI, they consume **workspace owner's credits**.

**How It Works**:
- Team members don't need their own paid plan
- All AI usage draws from workspace credit pool
- Workspace owner sees combined usage

**Example**:
```
Your Pro plan: 200 credits/month

Team usage:
- You: 50 credits
- Designer: 30 credits
- Developer: 40 credits
Total: 120 credits used of 200
```

**Best Practice**: Higher tiers for active teams
- Pro 200 or 400 for small teams
- Business plans for larger organizations

## Project Visibility

### Public Projects

**Characteristics**:
- Visible in community gallery
- Shareable via link
- Anyone can view
- Can be remixed by others

**Free Tier Limitation**:
- All projects must be public
- Cannot make private projects

**Use For**:
- Open source projects
- Learning and sharing
- Portfolio pieces
- Community templates

**Remixing**:
```
Anyone can "Remix" your public project:
- Creates a copy in their workspace
- They can modify their copy
- Your original is unchanged
```

**Security Note**: Projects connected to databases (Lovable Cloud) **cannot be remixed** for security reasons.

### Private Projects

**Characteristics**:
- Visible only to workspace members
- Not in community gallery
- Cannot be remixed publicly
- Invitation required to access

**Requirements**: Pro or Business plan

**Use For**:
- Client work
- Proprietary applications
- Internal tools
- Commercial projects

**Workspace Visibility**:
- All workspace members can see private projects by default
- Use project-level invites for restricted access

### Personal Projects

**Characteristics** (Business plan only):
- Visible only to creator
- Not even workspace members can see
- Maximum privacy

**Use For**:
- Personal experiments within company workspace
- Sandbox for testing
- Confidential prototypes

## Publishing Your Application

### One-Click Publish

**Documentation**: [Publishing Guide](https://docs.lovable.dev/features/publish)

**How It Works**:

**Steps**:
1. Click "Publish" button in project
2. Lovable performs security scan
3. Review any findings
4. Confirm publication
5. App goes live immediately

**What You Get**:
- Live URL: `yourproject.lovable.app`
- HTTPS/SSL automatically
- Global CDN delivery
- Auto-scaling infrastructure

### Pre-Publish Security Scan

**AI-Powered Security Check**:

**Learn More**: [Security Features](https://docs.lovable.dev/features/security)

Before publishing, Lovable scans your code for:
- **Exposed API keys or secrets**
- **XSS vulnerabilities**
- **SQL injection risks**
- **Missing input validation**
- **Open database rules**
- **Insecure authentication**

**Severity Levels**:
- 🔴 **Errors** (critical): Must fix before publishing
- 🟡 **Warnings**: Recommended to fix
- 🔵 **Info**: Best practice suggestions

**AI Auto-Fix**:
```
Finding: "API key exposed in frontend code"

Options:
[Try to Fix] - AI attempts to move key to Secrets vault
[Fix Manually] - You handle it
[Ignore] - Publish anyway (not recommended)
```

**Example Output**:
```
Security Scan Results:

🔴 ERRORS (3)
- API key exposed in HomePage.tsx line 42
- Database rule allows public write access
- Password stored in plain text

🟡 WARNINGS (2)
- No rate limiting on API endpoints
- Missing CSRF protection on forms

🔵 INFO (1)
- Consider adding input sanitization
```

### Publishing Workflow

**1. Development**:
- Build features with AI
- Test in preview mode
- Iterate and refine

**2. Review**:
- Check for bugs
- Test all functionality
- Review generated code

**3. Security Scan**:
- Click "Publish"
- AI scans codebase
- Fix any errors

**4. Publish**:
- Confirm publication
- App goes live
- URL becomes accessible

**5. Monitor**:
- Check analytics
- Monitor logs
- Gather user feedback

### Unpublishing

**Need to take app offline?**

**Steps**:
1. Project settings
2. Click "Unpublish"
3. Confirm

**Result**:
- URL shows "Project not found"
- Code remains in workspace
- Can republish anytime

**Use Cases**:
- Emergency maintenance
- Major bugs discovered
- Temporary suspension

## Custom Domains

### Overview

Instead of `yourproject.lovable.app`, use your own domain like `www.yoursite.com`.

**Requirements**: Pro or Business plan

**Documentation**: [Custom Domain Setup](https://docs.lovable.dev/features/custom-domain)

### Setting Up Custom Domain

**High-Level Process**:
1. Purchase domain (Namecheap, Google Domains, etc.)
2. Add domain in Lovable
3. Configure DNS records
4. Verify connection
5. SSL certificate issued automatically

### Step-by-Step

**In Lovable**:
1. Project settings
2. "Custom Domain" tab
3. Enter your domain (e.g., `app.mycompany.com`)
4. Lovable provides DNS instructions

**DNS Configuration**:

**Option A: Subdomain** (`app.mycompany.com`):
```
Type: CNAME
Name: app
Value: yourproject.lovable.app
```

**Option B: Root Domain** (`mycompany.com`):
```
Type: A Record
Name: @
Value: [IP address provided by Lovable]
```

**At Your DNS Provider**:
1. Log into domain registrar
2. Find DNS management
3. Add records as instructed
4. Save changes

**Back in Lovable**:
1. Click "Verify"
2. Lovable checks DNS propagation
3. Issues SSL certificate (automatic)
4. Domain becomes active

**Timeline**:
- DNS propagation: 5 minutes to 48 hours (usually <1 hour)
- SSL certificate: Automatic once DNS verified

### Entri Integration

**Simplified DNS Setup**:

Lovable partners with **Entri** to automate DNS configuration:

**If Your Provider Supports Entri**:
1. Click "Auto-Configure DNS"
2. Authorize Entri to access your domain
3. DNS records added automatically
4. Verification happens instantly

**Benefits**:
- No manual DNS editing
- Faster setup
- Fewer errors

**Supported Registrars**: Check Entri documentation

### Multiple Domains

You can connect multiple domains to one project:
- `www.mysite.com` (primary)
- `mysite.com` (root, redirects to www)
- `app.mysite.com` (alternative)

### SSL/HTTPS

**Automatic SSL Certificates**:
- Free SSL via Let's Encrypt
- Auto-renewal every 90 days
- HTTPS enforced
- No manual configuration

**Result**: 🔒 Secure connection for all users

## Project Analytics

### Built-In Analytics

Every published project includes **analytics dashboard**:

**Documentation**: [Analytics Guide](https://docs.lovable.dev/features/analytics)

**Metrics Tracked**:
- **Visitors**: Unique and total
- **Page Views**: How many pages viewed
- **Session Duration**: Average time on site
- **Bounce Rate**: % leaving after one page
- **Traffic Sources**: Where visitors come from
- **Devices**: Desktop, mobile, tablet breakdown
- **Locations**: Geographic distribution

**Real-Time Data**:
- See current active users
- Live page view updates
- Recent visitor activity

**No Setup Required**:
- Built into Lovable
- Starts tracking on publish
- Privacy-friendly (no cookies for basic analytics)

### Accessing Analytics

**Steps**:
1. Open published project
2. Click "Analytics" tab
3. View dashboard

**Date Ranges**:
- Last 24 hours
- Last 7 days
- Last 30 days
- Custom range

### Use Cases

**Monitoring Success**:
```
Launched marketing campaign:
- 500 visitors in 24 hours
- 65% from social media
- 3.5 minute average session
- 40% bounce rate
```

**Identifying Issues**:
```
High bounce rate on pricing page:
- 80% leaving immediately
- Investigation needed
- A/B test new design
```

**Growth Tracking**:
```
Month-over-month growth:
- January: 1,000 visitors
- February: 2,500 visitors
- March: 4,200 visitors
```

### External Analytics

You can also add:
- **Google Analytics** (advanced tracking)
- **Plausible** (privacy-focused)
- **Mixpanel** (product analytics)

**Prompt**:
```
"Add Google Analytics:
- Tracking ID: G-XXXXXXXXXX
- Track page views and events
- Privacy-compliant cookie consent"
```

## Team Workflows

### Recommended Workflow for Teams

#### Small Teams (2-5 people)

**Approach: Direct Collaboration**

1. **Everyone edits in Lovable**
   - Real-time collaboration
   - See changes immediately
   - AI-assisted development

2. **GitHub for backup**
   - Automatic sync enabled
   - Version history preserved

3. **Publish from Lovable**
   - Security scan
   - One team member publishes

**Benefits**:
- Fast iteration
- Minimal process overhead
- Great for startups and prototypes

#### Medium Teams (5-20 people)

**Approach: Branch-Based**

1. **Lovable development branch**
   - All Lovable edits go to `dev` branch
   - Continuous GitHub sync

2. **Review in GitHub**
   - Create pull requests from `dev` to `main`
   - Code review process
   - Run tests (CI/CD)

3. **Deploy `main` branch**
   - Merge approved PRs
   - `main` deploys to production
   - Lovable or external hosting (Netlify/Vercel)

**Benefits**:
- Code review process
- Quality control
- Separation of dev/production

#### Large Teams (20+ people)

**Approach: Hybrid Development**

1. **Lovable for rapid prototyping**
   - Product managers and designers build prototypes
   - Validate ideas quickly

2. **Developers refine externally**
   - Clone from GitHub
   - Work in traditional IDEs
   - Add complex logic
   - Maintain code quality standards

3. **CI/CD pipeline**
   - Automated testing
   - Staging environments
   - Production deployment

**Benefits**:
- Best of both worlds
- Leverage Lovable for speed
- Maintain engineering standards

### Example Team Roles

**Scenario: Building a SaaS Product**

**Product Manager (Admin)**:
- Creates initial project structure
- Defines features with AI
- Reviews progress
- Manages releases

**Designer (Editor)**:
- Imports Figma designs
- Refines UI with Visual Editor
- Ensures brand consistency

**Frontend Developer (Editor)**:
- Adds interactivity
- Implements complex UI logic
- Optimizes performance

**Backend Developer (Editor)**:
- Configures Lovable Cloud
- Creates Edge Functions
- Manages integrations

**QA Tester (Viewer)**:
- Reviews preview
- Reports bugs
- Validates features

**Stakeholder (Viewer)**:
- Checks progress
- Provides feedback
- Approves for launch

## Best Practices

### 1. Use Workspaces for Organization

**Don't**:
- Mix personal and client projects in one workspace

**Do**:
- Separate workspace per client or project type
- Clear naming conventions

### 2. Assign Appropriate Roles

**Principle of Least Privilege**:
- Give Viewer access by default
- Editor for active contributors
- Admin only for leads
- One Owner per workspace

### 3. Enable GitHub from Start

**Why**:
- Automatic backup
- Version history
- Team code review
- External deployment options

**When**:
- Set up GitHub integration at project creation
- Don't wait until later

### 4. Review Security Scans

**Don't Ignore Warnings**:
- AI can miss edge cases
- Manual review important
- Fix critical issues before publish

### 5. Test Before Publishing

**Checklist**:
- ✅ All features work in preview
- ✅ Mobile responsive
- ✅ Forms validate properly
- ✅ Database connections secure
- ✅ No exposed secrets
- ✅ Error handling implemented

### 6. Monitor After Launch

**Post-Launch**:
- Check analytics daily (first week)
- Monitor logs for errors
- Gather user feedback
- Iterate based on usage

### 7. Use Custom Domains for Production

**Benefit**: Professional appearance

**Free Subdomain OK for**:
- Personal projects
- Internal tools
- Testing/staging

**Custom Domain for**:
- Client-facing apps
- Commercial products
- Branded experiences

## Community Features

### "Launched" Portal

**Showcase Your Work**:

**What It Is**:
- Gallery of public projects built with Lovable
- Community voting and feedback
- Inspiration for others

**How to Submit**:
1. Publish your project
2. Submit to "Launched" page
3. Include description and screenshots
4. Share on social media

**Weekly Competitions**:
- Best projects win free credits
- Categories: Most Creative, Best Design, Most Useful
- Community voting

### Remixing Projects

**Learn from Others**:

**Public Project = Template**:
- Find interesting project in gallery
- Click "Remix"
- Creates copy in your workspace
- Modify freely

**Use Cases**:
- Learn new techniques
- Start from example
- Customize templates
- Teaching and education

**Attribution**: Give credit to original creators

### Sharing & Embedding

**Share Preview Links**:
- Send preview URL to stakeholders
- They see live version
- No Lovable account needed

**Embed** (if public):
- Potentially embed in iframe
- Showcase in portfolio
- Demo on your website

## Summary

Lovable's collaboration and deployment features make it suitable for solo developers and large teams alike:

**Collaboration**:
- **Workspaces** organize teams and projects
- **Unlimited collaborators** even on free tier
- **Role-based permissions** (Viewer/Editor/Admin/Owner)
- **Real-time collaboration** with live preview
- **Credit sharing** from workspace pool

**Project Visibility**:
- **Public** for open source and sharing
- **Private** for commercial work (Pro/Business)
- **Personal** for individual sandboxes (Business)

**Publishing**:
- **One-click publish** to lovable.app subdomain
- **AI security scan** before going live
- **Auto-fix suggestions** for vulnerabilities
- **Unpublish** option for maintenance

**Custom Domains**:
- **Connect your domain** (Pro/Business)
- **Automated DNS** setup via Entri
- **Free SSL certificates** automatically
- **Multiple domains** per project

**Analytics**:
- **Built-in analytics dashboard**
- **Real-time visitor tracking**
- **Traffic sources and device data**
- **Integration with external analytics tools**

Whether you're a solo founder launching an MVP, a design team building client projects, or an enterprise with complex workflows, Lovable scales to fit your collaboration and deployment needs.

In the final chapter, we'll dive into **Technical Architecture & Best Practices**—understanding the underlying technology stack, security considerations, performance optimization, and advanced patterns.

---

**Key Takeaways**:
1. Workspaces organize multiple projects and unlimited team members
2. Four roles: Viewer, Editor, Admin, Owner with increasing permissions
3. Real-time collaboration with shared preview and credit pooling
4. Public/private/personal visibility options based on plan tier
5. One-click publishing with AI security scanning
6. Custom domain support with automated DNS and free SSL
7. Built-in analytics for monitoring app performance
8. GitHub integration provides version control and backup
9. Team workflows scale from small startups to large organizations
10. "Launched" portal for community showcase and competitions
