# Chapter 5: GitHub Collaboration - Version Control and Teamwork

## Introduction

Modern software development is rarely a solo endeavor. Bolt v2 includes powerful collaboration features through GitHub integration, Codeflow for instant PR reviews, project forking, and team workspaces. In this chapter, we'll explore how to leverage these features for effective teamwork and code management.

## GitHub Integration

**GitHub** is the world's largest code hosting platform, used by millions of developers for version control and collaboration.

**Official Site**: [github.com](https://github.com) | **GitHub Learning Resources**: [skills.github.com](https://skills.github.com)

### Why GitHub Integration Matters

**Version Control**:
- Track every change to your project
- See complete history of modifications
- Revert to previous versions if needed
- Understand who changed what and when

**Backup**:
- Your code is safely stored in the cloud
- Recover from mistakes
- Access projects from anywhere

**Collaboration**:
- Work with team members
- Review code changes
- Manage contributions
- Coordinate development

### How Bolt + GitHub Works

**Automatic Syncing**:
1. Create or import project in Bolt
2. Connect to GitHub
3. Bolt automatically syncs your code
4. Every change is tracked
5. Complete version history maintained

**Key Features**:
- **Push Changes**: Send your Bolt project updates to GitHub
- **Pull Changes**: Get updates from team members
- **Branch Management**: Work on features in isolation
- **Merge**: Combine changes from multiple developers
- **Pull Requests**: Review code before merging

**Key Terms**:
- *Repository (Repo)*: A project folder containing all your code and its history
- *Commit*: A saved snapshot of your project at a specific point in time
- *Branch*: A separate version of your code where you can experiment
- *Pull Request*: A request to merge your changes into the main codebase

## Codeflow: Instant Pull Request Environments (pr.new)

**Codeflow** is Bolt's revolutionary feature for reviewing GitHub pull requests instantly in a live environment.

**Try it**: Simply add `pr.new/` before any GitHub URL (e.g., `https://pr.new/github.com/owner/repo/pull/123`)

### What is Codeflow?

**Codeflow** lets you open any GitHub repository or pull request directly in Bolt.new with a special URL format.

**Magic URL Format**:
```
https://pr.new/github.com/owner/repo/pull/123
```

**What Happens**:
1. Bolt loads the PR code into a WebContainer
2. Installs dependencies automatically
3. Starts the dev server
4. Shows you a working preview of the changes
5. **All in under 10 seconds**

**Key Term**: *Pull Request (PR)* - A proposal to merge code changes from one branch into another, typically used for code review before adding features to the main codebase.

### Why Codeflow Matters

**Traditional PR Review Problems**:
- Download/clone the repository
- Check out the PR branch
- Install dependencies (can take minutes)
- Start dev server
- Test the changes
- **Total Time**: 10-30 minutes per PR

**With Codeflow**:
1. Click pr.new link
2. See working code in seconds
3. Test immediately
4. **Total Time**: Under 1 minute

### Practical Use Cases

#### **Scenario 1: Code Review**
Your teammate opens a PR adding a new feature:

**Old Way**:
```bash
git fetch origin
git checkout pr-branch
npm install
npm run dev
# Wait, test, provide feedback
```

**Codeflow Way**:
- Click `https://pr.new/github.com/yourorg/project/pull/456`
- Immediately see the new feature working
- Test it interactively
- Leave informed feedback

#### **Scenario 2: Bug Reports**
Someone reports a bug with a PR that supposedly fixes it:

**With Codeflow**:
- Open the PR in Bolt using pr.new
- Reproduce the original bug (check if still there)
- Verify the fix works
- Suggest improvements if needed
- All without touching your local environment

#### **Scenario 3: Learning from Open Source**
You find an interesting feature in a public repo's PR:

- Use pr.new to open it
- See the code running
- Experiment with modifications
- Learn by doing (changes don't affect the original)

### GitHub App Integration

Bolt provides a **Codeflow GitHub App** that adds convenience features:

**What It Does**:
- Adds a "Review in Bolt.new" button directly on GitHub PRs
- Automatically posts Bolt.new preview links in PR comments
- Updates links when PR code changes

**Installation** (for repository owners):
1. Install the Codeflow GitHub App from the GitHub Marketplace
2. Grant permissions to your repositories
3. PRs automatically get Bolt.new preview links

**Benefits for Teams**:
- Reviewers can test PRs without local setup
- Faster feedback cycles
- More thorough testing (easier to test means more people will)
- Non-developers (PMs, designers) can see changes live

### Codeflow vs Traditional Cloud Previews

| Feature | Codeflow (Bolt.new) | Traditional Preview Deploys |
|---------|---------------------|----------------------------|
| **Speed** | Instant (seconds) | 2-10 minutes build time |
| **Cost** | Free (Bolt handles it) | Often requires paid CI/CD |
| **Full Stack** | Front+back working | Often just frontend |
| **Editing** | Can modify and test | Read-only usually |
| **Dependencies** | Auto-installed | Must be pre-configured |

## Fork Projects

**Forking** allows you to copy and modify existing Bolt projects.

### How Forking Works

1. **Find a Project**: Browse Bolt templates or community projects
2. **Fork It**: Create your own copy with one click
3. **Customize**: Modify it for your needs
4. **Deploy**: Launch your customized version

### Use Cases

- Start with proven templates
- Learn from others' code
- Create variations of existing projects
- Build on community work
- Experiment with pr.new previews (fork to save changes)

### Example Workflow

**Starting from a Template**:
- Find a restaurant website template
- Fork it to your account
- Customize colors, content, images
- Deploy your unique version
- Original remains unchanged

**Codeflow + Fork Workflow**:
1. Use pr.new to open someone's PR
2. Test their changes
3. Fork the project if you want to build on it
4. Make your modifications
5. Deploy your version

## Bolt Teams and Shared Workspaces

**Bolt Teams** enables professional collaboration for product teams and agencies.

### Team Features

#### **Shared Workspaces**
- Multiple team members work on same project
- Real-time collaboration
- Shared Bolt Cloud resources
- Unified billing

#### **Access Control**
- Assign roles (admin, developer, viewer)
- Manage permissions
- Control who can deploy
- Audit team activity

#### **Project Management**
- Organize projects by client or product
- Share templates across team
- Centralized billing and usage
- Team analytics

### Collaboration Workflows

#### **Agency Use Case**
1. Create client workspace
2. Add team members
3. Build project collaboratively
4. Client can view progress
5. Deploy when approved
6. Hand off or maintain

#### **Product Team Use Case**
1. Create product workspace
2. Designers, developers, and product managers collaborate
3. Rapid iteration on features
4. Shared infrastructure (database, auth)
5. Coordinated deployments

### Role-Based Access

**Admin Role**:
- Full access to all projects
- Manage team members
- Configure billing
- Deploy to production
- Access all settings

**Developer Role**:
- Create and edit projects
- Push to GitHub
- Deploy to staging
- Limited production access
- View team resources

**Viewer Role**:
- View projects and code
- Comment on changes
- No editing permissions
- No deployment access
- Read-only analytics

## Bring Your Own Design System

Bolt v2 allows teams to bring their own **design system**—ensuring brand consistency across projects.

**Key Term**: *Design System* - A collection of reusable components, styles, and guidelines that ensure consistent design across applications.

### How It Works

- Import your component library
- Define brand colors, fonts, spacing
- Create reusable components
- AI agents use your design system
- All projects maintain brand consistency

### Benefits

**Brand Consistency**: Every project follows your guidelines
**Speed**: Reuse components instead of rebuilding
**Collaboration**: Designers and developers share common language
**Quality**: Pre-approved, tested components

### Example

A company with specific branding can import their design system, and when they ask Bolt to build new features, the AI automatically uses their brand colors, fonts, and components.

## Best Practices for Team Collaboration

### 1. **Use Meaningful Commit Messages**

**Bad**: "Fixed stuff"
**Good**: "Fixed authentication bug preventing password resets"

**Format**:
- Brief summary (under 50 characters)
- Detailed explanation if needed
- Reference issue numbers

### 2. **Create Feature Branches**

**Workflow**:
- `main` branch: Always production-ready
- `develop` branch: Integration branch
- `feature/user-auth` branch: Specific feature
- `bugfix/login-error` branch: Bug fixes

### 3. **Write Clear Pull Request Descriptions**

**Include**:
- What changed and why
- Screenshots of UI changes
- Testing instructions
- Related issue numbers
- Breaking changes (if any)

### 4. **Review Code Thoroughly**

**Use Codeflow to**:
- Test functionality
- Check code quality
- Verify edge cases
- Ensure consistency
- Leave constructive feedback

### 5. **Communicate Actively**

- Comment on PRs promptly
- Use GitHub discussions
- Tag team members
- Document decisions
- Share knowledge

## Version Control Best Practices

### Branching Strategy

**GitFlow**:
- `main`: Production code
- `develop`: Next release
- `feature/*`: New features
- `hotfix/*`: Critical fixes
- `release/*`: Release preparation

**Trunk-Based**:
- Short-lived feature branches
- Frequent merges to main
- Feature flags for incomplete work
- Continuous integration

### Commit Frequency

**Good Practice**:
- Commit after completing a logical unit of work
- Multiple commits per day
- Each commit should be coherent
- Atomic commits (one purpose per commit)

**Avoid**:
- Committing broken code
- Giant commits with many changes
- Inconsistent commit messages
- Committing sensitive data

## Collaborative Development Scenarios

### Scenario 1: Building a Feature Together

**Team**: Designer (Sarah), Frontend Dev (Marcus), Backend Dev (Jennifer)

**Workflow**:
1. **Sarah**: Creates designs in Figma
2. **Sarah**: Shares Figma link with team
3. **Marcus**: Uses Bolt to import Figma designs
4. **Marcus**: Generates frontend components
5. **Jennifer**: Reviews in Codeflow
6. **Jennifer**: Adds backend integration
7. **Team**: Reviews complete PR
8. **Marcus**: Deploys to staging
9. **Sarah**: Tests and approves
10. **Jennifer**: Merges and deploys

**Time**: 1-2 days (vs. 1-2 weeks traditional)

### Scenario 2: Open Source Contribution

**Contributor Workflow**:
1. Find project on GitHub
2. Use pr.new to explore codebase
3. Identify improvement opportunity
4. Fork the repository
5. Make changes in Bolt
6. Test with Bolt Cloud
7. Push to GitHub fork
8. Create pull request
9. Maintainers review in Codeflow
10. Iterate based on feedback
11. PR merged!

### Scenario 3: Client Project Handoff

**Agency Workflow**:
1. Build client project in Bolt Teams
2. Connect to GitHub repository
3. Document code and setup
4. Add client as team viewer
5. Demo project via Codeflow
6. Transfer GitHub repository
7. Provide Bolt export
8. Client takes ownership

## Troubleshooting Common Issues

### Issue: Merge Conflicts

**What**: Two people edited the same code

**Solution**:
1. Pull latest changes
2. Review conflicts
3. Choose correct version
4. Test thoroughly
5. Commit resolution

### Issue: Lost Changes

**Prevention**:
- Commit frequently
- Push to GitHub regularly
- Use Bolt's auto-save
- Enable GitHub sync

### Issue: Accidental Deployment

**Recovery**:
- Use Netlify rollback
- Revert Git commit
- Redeploy previous version
- Review permissions

### Issue: Permission Denied

**Check**:
- Your role in Bolt Teams
- GitHub repository access
- Organization settings
- Team admin approval

## Summary

Bolt's collaboration features transform team development:

**GitHub Integration**:
- Automatic syncing with version control
- Complete project history
- Branch management
- Professional workflows

**Codeflow (pr.new)**:
- Instant PR environments
- Under 10 seconds to review
- Full-stack testing
- No local setup needed

**Project Forking**:
- Copy and customize templates
- Learn from community
- Build on others' work
- Rapid prototyping

**Bolt Teams**:
- Shared workspaces
- Role-based access
- Unified billing
- Team analytics

**Design Systems**:
- Brand consistency
- Reusable components
- Designer-developer collaboration
- Quality assurance

These features enable modern, efficient collaboration whether you're:
- Working solo with version control
- Collaborating with a small team
- Contributing to open source
- Running an agency
- Building in a large organization

In the next chapter, we'll explore external integrations with Supabase, Expo, Figma, and other services that extend Bolt's capabilities even further.

---

**Key Takeaways**:
1. GitHub integration provides version control and backup
2. Codeflow enables instant PR review (10-30 min → under 1 min)
3. Forking allows copying and customizing projects
4. Bolt Teams supports professional collaboration
5. Design systems ensure brand consistency
6. Role-based access controls permissions
7. Best practices improve team efficiency
8. Multiple workflows supported (GitFlow, trunk-based)
