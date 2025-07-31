# Create Issues in OmniStudio Repository

Now that your "OmniStudio Training" project is linked to the OmniStudio repository, follow these steps:

## Step 1: Go to OmniStudio Issues
**URL:** https://github.com/zerovizboss/OmniStudio/issues

## Step 2: Create Labels First
**URL:** https://github.com/zerovizboss/OmniStudio/labels

Click "New label" for each of these:

### Epic Labels
- **Name:** `epic:foundation` **Color:** `#0052CC` (blue)
- **Name:** `epic:content` **Color:** `#FF8B00` (orange)
- **Name:** `epic:flexcards` **Color:** `#36B37E` (green)
- **Name:** `epic:omniscripts` **Color:** `#6554C0` (purple)
- **Name:** `epic:dataraptors` **Color:** `#FF5630` (red)

### Sprint Labels
- **Name:** `sprint-1` **Color:** `#F4F5F7` (light gray)
- **Name:** `sprint-2` **Color:** `#F4F5F7` (light gray)
- **Name:** `sprint-3` **Color:** `#F4F5F7` (light gray)
- **Name:** `sprint-4` **Color:** `#F4F5F7` (light gray)

### Story Point Labels
- **Name:** `story-points:5` **Color:** `#C1C7D0` (gray)
- **Name:** `story-points:8` **Color:** `#C1C7D0` (gray)
- **Name:** `story-points:13` **Color:** `#C1C7D0` (gray)

### Certification Labels
- **Name:** `consultant-exam` **Color:** `#0747A6` (dark blue)
- **Name:** `developer-exam` **Color:** `#0747A6` (dark blue)

## Step 3: Create Your First Issue

**URL:** https://github.com/zerovizboss/OmniStudio/issues/new

### Issue 1: Project Foundation

**Title:**
```
Define project charter and technical architecture
```

**Description:**
```
**As a** project manager
**I want** project charter and technical architecture defined
**So that** the development team has clear technical guidance and project scope

**Acceptance Criteria:**
- [ ] Technical architecture document created with OmniStudio component usage strategy
- [ ] Development environment requirements documented
- [ ] Project timeline and resource allocation planned
- [ ] Success metrics and KPIs defined
- [ ] Risk assessment and mitigation plan created

**Epic:** Project Foundation
**Sprint:** 1
**Story Points:** 8
```

**Labels to add:**
- `epic:foundation`
- `sprint-1`
- `story-points:8`

**Projects:**
- Select "OmniStudio Training" from the projects dropdown

## Step 4: Create Issue 2

**Title:**
```
Setup development environment with OmniStudio components
```

**Description:**
```
**As a** developer
**I want** development environment setup with OmniStudio components
**So that** I can begin building the training application

**Acceptance Criteria:**
- [ ] Salesforce DX project configured with API version 64.0
- [ ] OmniStudio package installed and configured
- [ ] Development org prepared with sample data
- [ ] CI/CD pipeline established with GitHub Actions
- [ ] Code quality tools configured (ESLint, Prettier)

**Epic:** Project Foundation
**Sprint:** 1
**Story Points:** 5
```

**Labels to add:**
- `epic:foundation`
- `sprint-1`
- `story-points:5`

**Projects:**
- Select "OmniStudio Training"

## Step 5: Continue with Priority Issues

After creating the first 2 issues, continue with these high-priority ones:

### Issue 3: Create wireframes and user experience design
- **Epic:** Project Foundation
- **Sprint:** 1
- **Story Points:** 8
- **Labels:** `epic:foundation`, `sprint-1`, `story-points:8`

### Issue 4: Build dashboard FlexCard with progress tracking
- **Epic:** FlexCard Implementation
- **Sprint:** 3
- **Story Points:** 8
- **Labels:** `epic:flexcards`, `sprint-3`, `story-points:8`

### Issue 5: Create exam selection FlexCards for Consultant vs Developer
- **Epic:** FlexCard Implementation
- **Sprint:** 3
- **Story Points:** 5
- **Labels:** `epic:flexcards`, `sprint-3`, `consultant-exam`, `developer-exam`, `story-points:5`

## Step 6: Check Your Project Board

After creating each issue:
1. Go to: https://github.com/users/zerovizboss/projects/3/views/1
2. You should see your issues automatically appearing in the project
3. Drag them to appropriate columns (Backlog, Sprint 1, etc.)

## Complete Issue List

For all 40 user stories, refer to the detailed descriptions in:
- `docs/GITHUB_USER_STORIES_BACKLOG.md`
- `docs/MANUAL_ISSUE_CREATION_GUIDE.md`

## Quick Verification

After creating your first issue:
1. ✅ Issue appears at: https://github.com/zerovizboss/OmniStudio/issues
2. ✅ Issue has proper labels applied
3. ✅ Issue appears in your project: https://github.com/users/zerovizboss/projects/3/views/1
4. ✅ You can move it between project columns

Start with the first 2 issues above, then let me know how it goes!