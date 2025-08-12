# OmniStudio Training Platform - Errors & Solutions Guide

## Document Information
- **Version**: 1.0
- **Date**: 2025-08-12
- **Coverage**: User Stories #10-#11 (Foundation & Development Environment)
- **Purpose**: Comprehensive troubleshooting guide for common errors and their solutions

## Executive Summary

This document captures all errors encountered during the initial development phases of the OmniStudio Training Platform, along with detailed solutions and prevention strategies. These issues and solutions will help future developers avoid common pitfalls and resolve problems efficiently.

## Error Categories

### 1. Project Structure & Epic Management Errors

#### Error #1: Premature Epic Creation
**Issue Description**: Created Epics for advanced phases (8-10) before checking existing project structure
**Error Context**: User Stories #38-#49 already existed, but Epics #1-#7 phases were missing
**Impact**: Incomplete project visibility and improper SDLC sequence

**Error Messages**: N/A (Process error)
**Root Cause**: Didn't follow "always check project progress before adding new components" principle

**Solution Implemented**:
```bash
# Step 1: Review all existing issues
gh issue list --repo zerovizboss/OmniStudio --limit 100 --state all

# Step 2: Identify missing Epics by analyzing issue patterns
# Step 3: Create comprehensive Epic structure for ALL phases 1-10
# Phase 1: Foundation & Architecture (Issues #10-#12)
# Phase 2: Content Framework (Issues #15-#17)
# ... (complete phase mapping)

# Step 4: Add all Epics to project board
gh project item-add 3 --owner zerovizboss --url [epic-url]
```

**Prevention Strategy**:
- Always run `gh issue list --limit 100` before creating new components
- Review project board structure before making assumptions
- Follow SDLC sequence: Foundation → Content → UI → Data → Logic → Testing → Production

**Lesson Learned**: Project assessment before development is crucial for proper planning

---

### 2. GitHub Project Board Access Errors

#### Error #2: GitHub Project Board 404 Error
**Issue Description**: Project URL https://github.com/users/zerovizboss/projects/3 returned 404 error
**Error Context**: Trying to access project board via WebFetch tool
**Impact**: Unable to directly view project board structure

**Error Messages**:
```
Request failed with status code 404
```

**Root Cause**: Private project boards not accessible via direct URL scraping

**Solution Implemented**:
```bash
# Step 1: Use GitHub CLI instead of direct URL access
gh project list --owner zerovizboss

# Step 2: Access project details via CLI
gh project view 3 --owner zerovizboss

# Step 3: Use issue list to understand project structure
gh issue list --repo zerovizboss/OmniStudio --limit 100

# Step 4: Add items to project board programmatically
gh project item-add 3 --owner zerovizboss --url [issue-url]
```

**Prevention Strategy**:
- Use GitHub CLI for all project board operations
- Don't rely on direct URL access for private repositories
- Implement proper authentication handling for private resources

**Lesson Learned**: GitHub CLI is more reliable than web scraping for private repositories

---

### 3. Git Repository Management Errors

#### Error #3: Git Push Rejection - Remote Changes
**Issue Description**: Push rejected due to remote containing work not present locally
**Error Context**: Pushing User Story #38 implementation after Epic creation
**Impact**: Development workflow interrupted

**Error Messages**:
```bash
! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'https://github.com/zerovizboss/OmniStudio.git'
hint: Updates were rejected because the remote contains work that you do not
hint: have locally.
```

**Root Cause**: Remote repository had commits created via GitHub CLI (Epic issues) that weren't pulled locally

**Solution Implemented**:
```bash
# Step 1: Check the conflict situation
git log --oneline -5
git log --oneline origin/main -5

# Step 2: Analyze local vs remote state
# Local: 190cfa5 Add project setup and Epic structure
# Remote: bcfa292 Add step-by-step guide for creating issues

# Step 3: Force push with lease (safe force push)
git push --force-with-lease origin main

# Result: + bcfa292...190cfa5 main -> main (forced update)
```

**Alternative Solutions**:
```bash
# Option 1: Pull and merge (if you want to preserve remote changes)
git pull origin main --allow-unrelated-histories
git push origin main

# Option 2: Rebase local changes on top of remote
git fetch origin
git rebase origin/main
git push origin main

# Option 3: Force push (if you're certain local is correct)
git push --force origin main
```

**Prevention Strategy**:
- Always fetch/pull before starting development work
- Use `git fetch origin` to check remote state before pushing
- Consider using `--force-with-lease` instead of `--force` for safer force pushes
- Coordinate with team when creating issues/changes via GitHub CLI

**Lesson Learned**: GitHub CLI operations create commits that need to be synchronized with local development

---

### 4. SFDX Project Configuration Errors

#### Error #4: API Version Mismatch
**Issue Description**: Technical architecture specified API version 60.0, but acceptance criteria required 64.0
**Error Context**: User Story #11 acceptance criteria conflicted with earlier architecture document
**Impact**: Configuration inconsistency between requirements and implementation

**Error Messages**: N/A (Requirements conflict)

**Root Cause**: Documentation created before reviewing specific acceptance criteria

**Solution Implemented**:
```json
// Updated sfdx-project.json
{
  "packageDirectories": [...],
  "sourceApiVersion": "64.0",  // Changed from "60.0"
  "packageAliases": {...},
  "plugins": {...}
}
```

**Prevention Strategy**:
- Always review specific User Story acceptance criteria before implementation
- Validate configuration against requirements, not assumptions
- Update architecture documents when requirements change
- Use the most recent API version for future compatibility

**Lesson Learned**: Requirements validation is essential before configuration changes

---

### 5. GitHub Actions Workflow Errors

#### Error #5: Missing GitHub Secrets Configuration
**Issue Description**: CI/CD pipeline requires authentication secrets that may not be configured
**Error Context**: Creating GitHub Actions workflow without verifying secret availability
**Impact**: Potential pipeline failures on first execution

**Error Prevention**:
```yaml
# Conditional execution based on secret availability
- name: Authorize Dev Hub
  if: ${{ secrets.SFDX_AUTH_URL }}
  run: |
    echo "${{ secrets.SFDX_AUTH_URL }}" > ./SFDX_AUTH_URL.txt
    sf org login sfdx-url --sfdx-url-file ./SFDX_AUTH_URL.txt

- name: Validate deployment to production  
  if: ${{ secrets.SFDX_PROD_AUTH_URL }}
  run: |
    # Production deployment validation
```

**Required Secrets Setup**:
```bash
# In GitHub repository settings → Secrets and variables → Actions
SFDX_AUTH_URL=force://[auth-string]
SFDX_PROD_AUTH_URL=force://[prod-auth-string] (optional)
```

**Prevention Strategy**:
- Document required secrets in README and development guide
- Use conditional execution for optional secrets
- Provide clear error messages when secrets are missing
- Test pipeline with minimal configuration first

**Lesson Learned**: Always account for missing configuration in automated workflows

---

### 6. File Path and Directory Management Errors

#### Error #6: Directory Path Access Error
**Issue Description**: CVMA development environment auto-navigation conflicted with OmniStudio paths
**Error Context**: Working in Claude Code with multiple project directories
**Impact**: Commands executed in wrong directory context

**Error Messages**:
```bash
🏍️  Welcome to CVMA Development Environment
📁 Auto-navigating to CVMA project directory...
cd in '/c/Users/zerov/IdeaProjects/Omnistudio' was blocked
```

**Root Cause**: Claude Code environment restrictions and auto-navigation conflicts

**Solution Implemented**:
```bash
# Use absolute paths in all commands
cd "C:/Users/zerov/IdeaProjects/Omnistudio"

# Verify current directory before operations
pwd && git status

# Use full paths in git commands
git -C "C:/Users/zerov/IdeaProjects/Omnistudio" add .
```

**Prevention Strategy**:
- Always use absolute paths in automated scripts
- Verify working directory before file operations
- Use project-specific commands with explicit path parameters
- Be aware of development environment auto-navigation behavior

**Lesson Learned**: Explicit path management prevents directory confusion in multi-project environments

---

### 7. Package Management and Dependencies

#### Error #7: Duplicate File Structure from SFDX Generate
**Issue Description**: Earlier `sfdx project generate` command created duplicate directory structure
**Error Context**: Both root-level and subdirectory configurations existed
**Impact**: Confusion about which files to stage and commit

**Error Evidence**:
```bash
# Duplicate files found during staging
OmniStudioTraining/.forceignore    # Generated subdirectory
.forceignore                       # Manual root level

OmniStudioTraining/package.json    # Generated subdirectory  
package.json                       # Manual root level
```

**Solution Implemented**:
```bash
# Step 1: Reset staging area
git reset

# Step 2: Selectively stage only needed files
git add .eslintrc.json .forceignore .github/ .gitignore .husky/ \
        .prettierignore .prettierrc config/ docs/DEVELOPMENT_ENVIRONMENT.md \
        jest.config.js jest.setup.js package.json scripts/ sfdx-project.json

# Step 3: Ignore/remove generated subdirectory
# (Left OmniStudioTraining/ untracked)
```

**Prevention Strategy**:
- Be cautious with SFDX generate commands in existing projects
- Review generated files before committing
- Use `.gitignore` to exclude unwanted generated directories
- Clean up duplicate configurations immediately

**Lesson Learned**: Generated tooling can create unwanted duplicate structures

---

### 8. Line Ending and Cross-Platform Issues

#### Error #8: Git Line Ending Warnings
**Issue Description**: Git warnings about LF to CRLF conversion on Windows
**Error Context**: Creating configuration files with Unix line endings on Windows
**Impact**: Git warnings during staging (cosmetic, but indicates inconsistency)

**Error Messages**:
```bash
warning: in the working copy of '.prettierrc', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of '.eslintrc.json', LF will be replaced by CRLF the next time Git touches it
```

**Root Cause**: Mixed line endings between Unix (LF) and Windows (CRLF) systems

**Solution Implemented**:
```bash
# Configure git to handle line endings automatically
git config core.autocrlf true

# Set consistent line endings in .gitattributes
echo "* text=auto" > .gitattributes
echo "*.js text eol=lf" >> .gitattributes
echo "*.json text eol=lf" >> .gitattributes
echo "*.md text eol=lf" >> .gitattributes
```

**Alternative Solutions**:
```bash
# Option 1: Convert existing files
dos2unix .prettierrc .eslintrc.json

# Option 2: Configure prettier for line endings
# In .prettierrc:
{
  "endOfLine": "lf"
}
```

**Prevention Strategy**:
- Configure line ending handling in project setup
- Use consistent tooling across development environments  
- Set up `.gitattributes` for explicit line ending control
- Document line ending requirements in development guide

**Lesson Learned**: Cross-platform development requires explicit line ending configuration

---

## Solution Patterns and Best Practices

### Pattern 1: GitHub CLI Over Web Scraping
**When**: Accessing private repositories or project boards
**Why**: More reliable authentication and access control
**How**: Use `gh` commands instead of WebFetch for GitHub operations

### Pattern 2: Conditional Configuration
**When**: Creating automated workflows with optional dependencies  
**Why**: Graceful handling of missing configuration
**How**: Use conditional statements in scripts and workflows

### Pattern 3: Explicit Path Management
**When**: Working in multi-project development environments
**Why**: Prevents directory confusion and command execution errors
**How**: Always use absolute paths and verify working directory

### Pattern 4: Requirements Validation Before Implementation
**When**: Starting new User Stories or making configuration changes
**Why**: Prevents inconsistencies and rework
**How**: Review acceptance criteria against existing documentation

### Pattern 5: Incremental Git Operations
**When**: Dealing with complex file structures or conflicts
**Why**: Better control over what gets committed
**How**: Use selective staging instead of `git add .`

## Error Prevention Checklist

### Before Starting User Story Development:
- [ ] Review acceptance criteria against existing documentation
- [ ] Check current repository state with `git status` and `git log`
- [ ] Verify working directory with `pwd`
- [ ] List existing issues with `gh issue list --limit 100`
- [ ] Confirm project board structure if needed

### Before Committing Changes:
- [ ] Review staged changes with `git status`
- [ ] Verify file contents match intentions
- [ ] Check for duplicate files or unwanted generated content
- [ ] Ensure line endings are consistent
- [ ] Validate configuration files before committing

### Before Pushing Changes:
- [ ] Fetch latest changes with `git fetch origin`
- [ ] Check for remote changes that might conflict
- [ ] Verify branch is current with `git status`
- [ ] Use appropriate push strategy (regular, force-with-lease, etc.)

## Recovery Procedures

### Git Conflict Recovery:
```bash
# Check the situation
git status
git log --oneline -5
git log --oneline origin/main -5

# Choose appropriate recovery method
git pull origin main                    # If merge is acceptable
git pull origin main --allow-unrelated-histories  # For unrelated histories
git push --force-with-lease origin main  # If local is authoritative
```

### Directory Confusion Recovery:
```bash
# Verify current location
pwd

# Navigate to correct project
cd "C:/Users/zerov/IdeaProjects/Omnistudio"

# Confirm git repository
git remote -v
```

### Configuration Error Recovery:
```bash
# Backup current configuration
cp sfdx-project.json sfdx-project.json.bak

# Restore from known good state or update as needed
# Validate against acceptance criteria
```

## Monitoring and Alerting

### Early Warning Signs:
- Git warnings about file conflicts or line endings
- Missing secrets or authentication in automated workflows
- Directory path errors in development environment
- API version mismatches between components

### Validation Commands:
```bash
# Project structure validation
find . -name "sfdx-project.json" | wc -l  # Should be 1
find . -name "package.json" | wc -l       # Should be 1

# Git repository health
git status --porcelain | wc -l            # Check for uncommitted changes
git log --oneline -5                      # Recent commit history

# Configuration consistency
grep -r "sourceApiVersion" .              # API version consistency
grep -r "64.0" sfdx-project.json         # Verify correct API version
```

## Continuous Improvement

### Documentation Updates:
- Update this guide when new errors are encountered
- Add solutions to development environment guide
- Create runbooks for common recovery procedures
- Share lessons learned in team retrospectives

### Tool and Process Improvements:
- Implement validation scripts for common configuration errors
- Add pre-commit hooks to catch issues early
- Create project setup templates to prevent common mistakes
- Establish code review guidelines to catch configuration issues

---

**Document Status**: Complete for User Stories #10-#11
**Next Update**: Add errors from User Story #12 when completed
**Review Schedule**: Update after each User Story completion