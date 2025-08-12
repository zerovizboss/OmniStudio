# OmniStudio Training Platform - Development Environment Setup

## Document Information
- **Version**: 1.0
- **Date**: 2025-08-12
- **User Story**: #11 - Development Environment Setup
- **Status**: Complete

## Prerequisites

### System Requirements
- **Node.js**: >= 18.0.0
- **npm**: >= 8.0.0
- **Git**: Latest version
- **Salesforce CLI**: Latest version
- **Visual Studio Code**: Recommended IDE

### Salesforce Requirements
- **Salesforce Developer Hub**: Access to Dev Hub org
- **OmniStudio Package**: Installed in target org
- **API Access**: API version 64.0 support

## Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/zerovizboss/OmniStudio.git
cd OmniStudio
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Authorize Dev Hub
```bash
# Authorize your Dev Hub org
sf org login web --set-default-dev-hub --alias devhub

# Verify authorization
sf org list
```

### 4. Create Scratch Org
```bash
# Create new scratch org with OmniStudio
npm run scratch:create

# Open scratch org
npm run scratch:open
```

### 5. Deploy Source Code
```bash
# Push source to scratch org
npm run scratch:push
```

### 6. Setup Sample Data
```bash
# Execute sample data script
sf apex run --file scripts/apex/sample-data-setup.apex
```

## Development Workflow

### Daily Development Process
1. **Start Development**: `npm run scratch:open`
2. **Pull Changes**: `npm run scratch:pull` 
3. **Make Changes**: Edit code in VS Code
4. **Push Changes**: `npm run scratch:push`
5. **Run Tests**: `npm run test`
6. **Commit Changes**: `git add . && git commit -m "Your message"`

### Code Quality Checks
```bash
# Run all linting
npm run lint

# Check code formatting
npm run prettier:verify

# Fix formatting
npm run prettier

# Run Apex tests with coverage
npm run test:unit:code-coverage
```

## Project Structure

```
OmniStudio/
├── force-app/main/default/        # Salesforce source code
│   ├── classes/                   # Apex classes
│   ├── objects/                   # Custom objects
│   ├── lwc/                       # Lightning Web Components
│   └── ...
├── config/                        # Org configuration
│   └── project-scratch-def.json   # Scratch org definition
├── scripts/                       # Utility scripts
│   └── apex/                      # Anonymous Apex scripts
├── docs/                          # Project documentation
├── .github/workflows/             # CI/CD pipelines
├── package.json                   # Node.js configuration
├── sfdx-project.json             # Salesforce DX configuration
└── README.md                     # Project overview
```

## Configuration Files

### Salesforce DX Configuration
- **sfdx-project.json**: Project configuration with API version 64.0
- **config/project-scratch-def.json**: Scratch org definition with OmniStudio features
- **.forceignore**: Files to ignore during deployment

### Code Quality Configuration
- **.eslintrc.json**: ESLint configuration for LWC
- **.prettierrc**: Code formatting rules
- **jest.config.js**: JavaScript testing configuration
- **.husky/pre-commit**: Git pre-commit hooks

## Scratch Org Management

### Create New Scratch Org
```bash
# Create org with 30-day duration
sf org create scratch --definition-file config/project-scratch-def.json --duration-days 30 --alias myorg --set-default

# Install OmniStudio (if not in org definition)
sf package install --package 04t6A000002zgKSQAY --wait 10
```

### Scratch Org Commands
```bash
# List all orgs
sf org list

# Open specific org
sf org open --target-org myorg

# Delete scratch org
sf org delete scratch --target-org myorg
```

## Testing Strategy

### Apex Testing
- **Minimum Coverage**: 90% (exceeds Salesforce 75% requirement)
- **Test Classes**: Every Apex class has corresponding test class
- **Test Data**: Uses @TestSetup for consistent test data
- **Assertions**: Meaningful assertions beyond just coverage

### LWC Testing
- **Jest Framework**: Lightning Web Component testing
- **Coverage**: 80% minimum for JavaScript components
- **Accessibility**: Basic accessibility testing included

### Integration Testing
- **End-to-End**: Complete user journey testing
- **Performance**: Response time validation (< 2 seconds)
- **Cross-Browser**: Chrome, Firefox, Safari, Edge

## CI/CD Pipeline

### Pipeline Stages
1. **Code Quality**: ESLint, Prettier, SFDX Scanner
2. **Unit Tests**: Apex tests with 90% coverage requirement
3. **Security Scan**: Security vulnerability analysis
4. **Deploy Validation**: Production deployment validation (main branch)
5. **Performance Test**: Load testing for critical components

### Pipeline Triggers
- **Push to main/develop**: Full pipeline execution
- **Pull Requests**: Code quality and unit tests
- **Manual Trigger**: On-demand pipeline execution

### Required Secrets
Set these in GitHub repository settings:
- **SFDX_AUTH_URL**: Dev Hub authentication URL
- **SFDX_PROD_AUTH_URL**: Production org authentication URL (optional)

## OmniStudio Package Installation

### Manual Installation
1. Navigate to Setup → Apps → Packaging → Installed Packages
2. Install OmniStudio package (04t6A000002zgKSQAY)
3. Assign permissions to users
4. Configure OmniStudio settings

### Automated Installation (Scratch Org)
```bash
# Install via CLI
sf package install --package 04t6A000002zgKSQAY --target-org myorg --wait 15

# Verify installation
sf package installed list --target-org myorg
```

## Troubleshooting

### Common Issues

#### Authentication Issues
```bash
# Re-authenticate Dev Hub
sf auth web login --setdefaultdevhubusername --alias devhub

# Clear authentication cache
sf auth logout --all
```

#### Deployment Failures
```bash
# Check org limits
sf limits api display

# Force push (destructive)
sf project deploy start --source-dir force-app --ignore-conflicts
```

#### Permission Errors
```bash
# Check user permissions
sf user display --target-org myorg

# Assign permission set
sf permset assign --name OmniStudioUser --target-org myorg
```

### Performance Issues
- **Slow Deploys**: Check `.forceignore` file
- **Test Timeouts**: Increase test wait times
- **Apex Limits**: Implement bulkification patterns

## Development Best Practices

### Code Standards
- **Naming Conventions**: Use descriptive, consistent names
- **Error Handling**: Comprehensive try-catch blocks
- **Bulkification**: Handle collections, not single records
- **Security**: Field-level security and sharing rules

### Git Workflow
- **Feature Branches**: Create branch per feature/user story
- **Commit Messages**: Use conventional commit format
- **Pull Requests**: Required for main branch changes
- **Code Reviews**: Mandatory peer review process

### Testing Standards
- **Test Coverage**: Aim for 90%+ meaningful coverage
- **Test Data**: Use @TestSetup for reusable test data
- **Assertions**: Test behavior, not just coverage
- **Edge Cases**: Test boundary conditions and error scenarios

## Support & Resources

### Internal Resources
- **Technical Architecture**: `docs/TECHNICAL_ARCHITECTURE.md`
- **Project Charter**: `docs/PROJECT_CHARTER.md`
- **Success Metrics**: `docs/SUCCESS_METRICS_KPI.md`

### Salesforce Resources
- **OmniStudio Documentation**: https://help.salesforce.com/s/articleView?id=sf.omnistudio_overview.htm
- **Salesforce DX Guide**: https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/
- **Lightning Web Components**: https://lwc.dev/

### Community Resources
- **Trailhead**: OmniStudio modules and projects
- **Developer Forums**: Salesforce Stack Exchange
- **GitHub Issues**: Project-specific questions and bug reports

---

**Development Environment Setup Complete** ✅
**Next Step**: Proceed to User Story #12 - Wireframes & UX Design