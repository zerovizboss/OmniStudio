/**
 * @description Learning Path Manager for OmniStudio Training Platform
 * @author Claude Code Assistant
 * @since User Story #16 - Differentiated Study Paths
 * @version 1.0
 * 
 * This class manages differentiated learning paths for Consultant and Developer
 * certification tracks, providing personalized study recommendations and
 * progress tracking based on individual learner profiles.
 */
public with sharing class LearningPathManager {
    
    /**
     * @description Learning path definition with metadata
     */
    public class LearningPath {
        public String certificationTrack {get; set;}
        public String pathName {get; set;}
        public String description {get; set;}
        public List<String> prerequisites {get; set;}
        public Integer recommendedExperienceMonths {get; set;}
        public Integer totalEstimatedHours {get; set;}
        public List<StudyModule> modules {get; set;}
        public Map<String, String> crossCertificationMapping {get; set;}
        
        public LearningPath() {
            this.prerequisites = new List<String>();
            this.modules = new List<StudyModule>();
            this.crossCertificationMapping = new Map<String, String>();
        }
    }
    
    /**
     * @description Study module within a learning path
     */
    public class StudyModule {
        public String moduleId {get; set;}
        public String moduleName {get; set;}
        public String topic {get; set;}
        public String description {get; set;}
        public Integer estimatedHours {get; set;}
        public Integer sequenceOrder {get; set;}
        public List<String> learningObjectives {get; set;}
        public List<String> prerequisites {get; set;}
        public List<StudyUnit> units {get; set;}
        public String difficultyProgression {get; set;}
        
        public StudyModule() {
            this.learningObjectives = new List<String>();
            this.prerequisites = new List<String>();
            this.units = new List<StudyUnit>();
        }
    }
    
    /**
     * @description Individual study unit within a module
     */
    public class StudyUnit {
        public String unitId {get; set;}
        public String unitName {get; set;}
        public String unitType {get; set;} // Theory, Practice, Assessment, Project
        public Integer estimatedMinutes {get; set;}
        public String difficultyLevel {get; set;}
        public List<String> contentTags {get; set;}
        public String scenario {get; set;}
        public Boolean isRequired {get; set;}
        
        public StudyUnit() {
            this.contentTags = new List<String>();
            this.isRequired = true;
        }
    }
    
    /**
     * @description User learning progress tracking
     */
    public class LearningProgress {
        public String userId {get; set;}
        public String certificationTrack {get; set;}
        public String currentModuleId {get; set;}
        public String currentUnitId {get; set;}
        public Decimal overallProgressPercent {get; set;}
        public Map<String, Decimal> moduleProgress {get; set;}
        public Integer totalStudyHours {get; set;}
        public DateTime lastActivity {get; set;}
        public List<String> completedUnits {get; set;}
        public List<String> recommendedNext {get; set;}
        
        public LearningProgress() {
            this.moduleProgress = new Map<String, Decimal>();
            this.completedUnits = new List<String>();
            this.recommendedNext = new List<String>();
        }
    }
    
    /**
     * @description Get complete learning path for a certification track
     * @param certificationTrack Either 'Consultant' or 'Developer'
     * @return LearningPath configured learning path
     */
    public static LearningPath getLearningPath(String certificationTrack) {
        if (certificationTrack == 'Consultant') {
            return getConsultantLearningPath();
        } else if (certificationTrack == 'Developer') {
            return getDeveloperLearningPath();
        } else {
            throw new IllegalArgumentException('Invalid certification track: ' + certificationTrack);
        }
    }
    
    /**
     * @description Create Consultant-specific learning path
     * @return LearningPath for Consultant track
     */
    private static LearningPath getConsultantLearningPath() {
        LearningPath consultantPath = new LearningPath();
        consultantPath.certificationTrack = 'Consultant';
        consultantPath.pathName = 'OmniStudio Consultant Certification Path';
        consultantPath.description = 'Role-focused learning path emphasizing business scenarios, solution design, and user experience optimization for OmniStudio implementations.';
        consultantPath.recommendedExperienceMonths = 6;
        consultantPath.totalEstimatedHours = 120;
        
        // Prerequisites
        consultantPath.prerequisites.addAll(new List<String>{
            'Salesforce Administrator Certification (recommended)',
            'Basic understanding of Salesforce platform',
            'Experience with business process analysis',
            'Familiarity with web technologies (HTML, CSS, JavaScript basics)'
        });
        
        // Cross-certification mapping
        consultantPath.crossCertificationMapping.put('FlexCards', 'Developer.FlexCards.Advanced');
        consultantPath.crossCertificationMapping.put('OmniScripts', 'Developer.OmniScripts.Implementation');
        consultantPath.crossCertificationMapping.put('DataTools', 'Developer.DataRaptors.Business');
        consultantPath.crossCertificationMapping.put('Solutioning', 'Developer.IntegrationProcedures.Architecture');
        
        // Module 1: OmniStudio Foundation & Business Context
        StudyModule foundationModule = new StudyModule();
        foundationModule.moduleId = 'CONS_M01';
        foundationModule.moduleName = 'OmniStudio Foundation & Business Context';
        foundationModule.topic = 'Foundation';
        foundationModule.description = 'Understanding OmniStudio ecosystem and business applications';
        foundationModule.estimatedHours = 15;
        foundationModule.sequenceOrder = 1;
        foundationModule.difficultyProgression = 'Beginner → Intermediate';
        
        foundationModule.learningObjectives.addAll(new List<String>{
            'Understand OmniStudio ecosystem and components',
            'Identify business use cases for each OmniStudio tool',
            'Evaluate solution fit for business requirements',
            'Navigate OmniStudio Designer interfaces'
        });
        
        // Foundation units
        foundationModule.units.add(createStudyUnit('CONS_U01_01', 'OmniStudio Overview', 'Theory', 90, 'Beginner', 
            new List<String>{'omnistudio-overview', 'business-context'}, 
            'Understanding the complete OmniStudio suite and its business applications'));
        foundationModule.units.add(createStudyUnit('CONS_U01_02', 'Business Use Cases Analysis', 'Practice', 120, 'Intermediate', 
            new List<String>{'business-requirements', 'use-cases'}, 
            'Analyzing customer scenarios to determine appropriate OmniStudio solutions'));
        foundationModule.units.add(createStudyUnit('CONS_U01_03', 'Designer Navigation', 'Practice', 60, 'Beginner', 
            new List<String>{'designer-interface', 'navigation'}, 
            'Hands-on practice with OmniStudio Designer tools'));
        foundationModule.units.add(createStudyUnit('CONS_U01_04', 'Foundation Assessment', 'Assessment', 45, 'Intermediate', 
            new List<String>{'assessment', 'foundation'}, 
            'Comprehensive assessment of OmniStudio foundation knowledge'));
        
        consultantPath.modules.add(foundationModule);
        
        // Module 2: FlexCards for Business Solutions (23% weight)
        StudyModule flexCardsModule = new StudyModule();
        flexCardsModule.moduleId = 'CONS_M02';
        flexCardsModule.moduleName = 'FlexCards for Business Solutions';
        flexCardsModule.topic = 'FlexCards';
        flexCardsModule.description = 'Creating responsive data displays and interactive business dashboards';
        flexCardsModule.estimatedHours = 28; // 23% of 120 hours
        flexCardsModule.sequenceOrder = 2;
        flexCardsModule.difficultyProgression = 'Beginner → Advanced';
        
        flexCardsModule.learningObjectives.addAll(new List<String>{
            'Design FlexCards for various business scenarios',
            'Implement conditional visibility for dynamic user experiences',
            'Configure data sources for real-time business data',
            'Optimize FlexCard performance for business users'
        });
        
        flexCardsModule.prerequisites.add('CONS_M01');
        
        // FlexCards units with business focus
        flexCardsModule.units.add(createStudyUnit('CONS_U02_01', 'FlexCard Business Applications', 'Theory', 75, 'Beginner', 
            new List<String>{'flexcard-basics', 'business-applications'}, 
            'Customer dashboard showing account summary, recent activities, and action items'));
        flexCardsModule.units.add(createStudyUnit('CONS_U02_02', 'Data Source Configuration', 'Practice', 90, 'Intermediate', 
            new List<String>{'flexcard-datasource', 'configuration'}, 
            'Sales rep viewing opportunity pipeline with real-time updates'));
        flexCardsModule.units.add(createStudyUnit('CONS_U02_03', 'Conditional Business Logic', 'Practice', 105, 'Intermediate', 
            new List<String>{'flexcard-conditional-visibility', 'business-logic'}, 
            'Service agent dashboard adapting based on case priority and customer tier'));
        flexCardsModule.units.add(createStudyUnit('CONS_U02_04', 'FlexCard Actions & Navigation', 'Practice', 90, 'Intermediate', 
            new List<String>{'flexcard-actions', 'navigation'}, 
            'Interactive customer portal with self-service actions'));
        flexCardsModule.units.add(createStudyUnit('CONS_U02_05', 'Business Dashboard Project', 'Project', 180, 'Advanced', 
            new List<String>{'flexcard-project', 'business-dashboard'}, 
            'Executive dashboard combining multiple business metrics with drill-down capabilities'));
        flexCardsModule.units.add(createStudyUnit('CONS_U02_06', 'FlexCards Assessment', 'Assessment', 60, 'Advanced', 
            new List<String>{'assessment', 'flexcards'}, 
            'Comprehensive FlexCards assessment with business scenarios'));
        
        consultantPath.modules.add(flexCardsModule);
        
        // Module 3: OmniScripts for Process Automation (27% weight)
        StudyModule omniScriptsModule = new StudyModule();
        omniScriptsModule.moduleId = 'CONS_M03';
        omniScriptsModule.moduleName = 'OmniScripts for Process Automation';
        omniScriptsModule.topic = 'OmniScripts';
        omniScriptsModule.description = 'Building guided business processes and user workflows';
        omniScriptsModule.estimatedHours = 32; // 27% of 120 hours
        omniScriptsModule.sequenceOrder = 3;
        omniScriptsModule.difficultyProgression = 'Intermediate → Advanced';
        
        omniScriptsModule.learningObjectives.addAll(new List<String>{
            'Design multi-step business processes',
            'Implement conditional logic for process branching',
            'Configure data collection and validation',
            'Optimize user experience for business workflows'
        });
        
        omniScriptsModule.prerequisites.addAll(new List<String>{'CONS_M01', 'CONS_M02'});
        
        // OmniScript units with process focus
        omniScriptsModule.units.add(createStudyUnit('CONS_U03_01', 'Business Process Mapping', 'Theory', 90, 'Intermediate', 
            new List<String>{'omniscript-elements', 'process-mapping'}, 
            'Customer onboarding process with document collection and approval workflow'));
        omniScriptsModule.units.add(createStudyUnit('CONS_U03_02', 'Data Collection Workflows', 'Practice', 120, 'Intermediate', 
            new List<String>{'omniscript-data-json', 'data-collection'}, 
            'Insurance claim submission with dynamic form fields based on claim type'));
        omniScriptsModule.units.add(createStudyUnit('CONS_U03_03', 'Conditional Process Logic', 'Practice', 135, 'Advanced', 
            new List<String>{'omniscript-conditional-logic', 'process-branching'}, 
            'Loan application process with credit score-based routing and approval paths'));
        omniScriptsModule.units.add(createStudyUnit('CONS_U03_04', 'Integration with Business Systems', 'Practice', 120, 'Advanced', 
            new List<String>{'omniscript-integration', 'external-systems'}, 
            'Employee onboarding connecting HR systems, IT provisioning, and facility access'));
        omniScriptsModule.units.add(createStudyUnit('CONS_U03_05', 'Process Optimization & UX', 'Theory', 75, 'Advanced', 
            new List<String>{'omniscript-performance', 'user-experience'}, 
            'Optimizing customer service workflows for reduced handling time'));
        omniScriptsModule.units.add(createStudyUnit('CONS_U03_06', 'End-to-End Process Project', 'Project', 210, 'Advanced', 
            new List<String>{'omniscript-project', 'end-to-end-process'}, 
            'Complete customer service case resolution workflow with escalation paths'));
        omniScriptsModule.units.add(createStudyUnit('CONS_U03_07', 'OmniScripts Assessment', 'Assessment', 75, 'Advanced', 
            new List<String>{'assessment', 'omniscripts'}, 
            'Complex process scenarios assessment'));
        
        consultantPath.modules.add(omniScriptsModule);
        
        // Module 4: Data Tools for Business Intelligence (23% weight)
        StudyModule dataToolsModule = new StudyModule();
        dataToolsModule.moduleId = 'CONS_M04';
        dataToolsModule.moduleName = 'Data Tools for Business Intelligence';
        dataToolsModule.topic = 'DataTools';
        dataToolsModule.description = 'Leveraging data transformation for business insights and reporting';
        dataToolsModule.estimatedHours = 28; // 23% of 120 hours
        dataToolsModule.sequenceOrder = 4;
        dataToolsModule.difficultyProgression = 'Intermediate → Advanced';
        
        dataToolsModule.learningObjectives.addAll(new List<String>{
            'Design data transformations for business reporting',
            'Configure data extraction for analytics',
            'Implement business intelligence workflows',
            'Optimize data operations for business performance'
        });
        
        dataToolsModule.prerequisites.addAll(new List<String>{'CONS_M01'});
        
        // DataTools units with BI focus
        dataToolsModule.units.add(createStudyUnit('CONS_U04_01', 'Business Data Requirements', 'Theory', 75, 'Intermediate', 
            new List<String>{'dataraptor-extract', 'business-requirements'}, 
            'Sales performance reporting with territory and product analysis'));
        dataToolsModule.units.add(createStudyUnit('CONS_U04_02', 'Data Extraction for Analytics', 'Practice', 105, 'Intermediate', 
            new List<String>{'dataraptor-extract', 'analytics'}, 
            'Customer satisfaction dashboard with survey data aggregation'));
        dataToolsModule.units.add(createStudyUnit('CONS_U04_03', 'Business Data Transformation', 'Practice', 120, 'Advanced', 
            new List<String>{'dataraptor-transform', 'business-transformation'}, 
            'Financial reporting with currency conversion and period calculations'));
        dataToolsModule.units.add(createStudyUnit('CONS_U04_04', 'Automated Data Loading', 'Practice', 90, 'Advanced', 
            new List<String>{'dataraptor-load', 'automation'}, 
            'Automated lead scoring and assignment based on business criteria'));
        dataToolsModule.units.add(createStudyUnit('CONS_U04_05', 'Performance Optimization', 'Theory', 60, 'Advanced', 
            new List<String>{'dataraptor-turbo', 'performance'}, 
            'Large-scale data processing for enterprise reporting requirements'));
        dataToolsModule.units.add(createStudyUnit('CONS_U04_06', 'Business Intelligence Project', 'Project', 180, 'Advanced', 
            new List<String>{'datatools-project', 'business-intelligence'}, 
            'Executive KPI dashboard with automated data refresh and alert system'));
        dataToolsModule.units.add(createStudyUnit('CONS_U04_07', 'DataTools Assessment', 'Assessment', 60, 'Advanced', 
            new List<String>{'assessment', 'datatools'}, 
            'Complex data scenarios assessment'));
        
        consultantPath.modules.add(dataToolsModule);
        
        // Module 5: Solution Architecture & Best Practices (27% weight)
        StudyModule solutioningModule = new StudyModule();
        solutioningModule.moduleId = 'CONS_M05';
        solutioningModule.moduleName = 'Solution Architecture & Best Practices';
        solutioningModule.topic = 'Solutioning';
        solutioningModule.description = 'Enterprise solution design, governance, and optimization strategies';
        solutioningModule.estimatedHours = 32; // 27% of 120 hours
        solutioningModule.sequenceOrder = 5;
        solutioningModule.difficultyProgression = 'Advanced';
        
        solutioningModule.learningObjectives.addAll(new List<String>{
            'Architect enterprise OmniStudio solutions',
            'Apply governance and best practices',
            'Design for scalability and performance',
            'Implement security and compliance requirements'
        });
        
        solutioningModule.prerequisites.addAll(new List<String>{'CONS_M01', 'CONS_M02', 'CONS_M03', 'CONS_M04'});
        
        // Solutioning units with architecture focus
        solutioningModule.units.add(createStudyUnit('CONS_U05_01', 'Enterprise Solution Architecture', 'Theory', 120, 'Advanced', 
            new List<String>{'solution-architecture', 'enterprise'}, 
            'Multi-org OmniStudio deployment for global insurance company'));
        solutioningModule.units.add(createStudyUnit('CONS_U05_02', 'Governance & Standards', 'Theory', 90, 'Advanced', 
            new List<String>{'best-practices', 'governance'}, 
            'Establishing development standards and approval processes for large teams'));
        solutioningModule.units.add(createStudyUnit('CONS_U05_03', 'Performance & Scalability', 'Practice', 105, 'Advanced', 
            new List<String>{'performance-optimization', 'scalability'}, 
            'Optimizing OmniStudio solutions for 100,000+ user deployment'));
        solutioningModule.units.add(createStudyUnit('CONS_U05_04', 'Security & Compliance', 'Practice', 90, 'Advanced', 
            new List<String>{'security-considerations', 'compliance'}, 
            'Healthcare solution with HIPAA compliance and data privacy controls'));
        solutioningModule.units.add(createStudyUnit('CONS_U05_05', 'Change Management', 'Theory', 75, 'Advanced', 
            new List<String>{'change-management', 'adoption'}, 
            'User adoption strategies for enterprise OmniStudio rollouts'));
        solutioningModule.units.add(createStudyUnit('CONS_U05_06', 'Capstone Architecture Project', 'Project', 240, 'Advanced', 
            new List<String>{'capstone-project', 'solution-architecture'}, 
            'Complete enterprise solution design with all OmniStudio components'));
        solutioningModule.units.add(createStudyUnit('CONS_U05_07', 'Final Certification Prep', 'Assessment', 90, 'Advanced', 
            new List<String>{'certification-prep', 'final-assessment'}, 
            'Comprehensive certification preparation and practice exam'));
        
        consultantPath.modules.add(solutioningModule);
        
        return consultantPath;
    }
    
    /**
     * @description Create Developer-specific learning path
     * @return LearningPath for Developer track
     */
    private static LearningPath getDeveloperLearningPath() {
        LearningPath developerPath = new LearningPath();
        developerPath.certificationTrack = 'Developer';
        developerPath.pathName = 'OmniStudio Developer Certification Path';
        developerPath.description = 'Technical implementation-focused learning path emphasizing coding, integration, and advanced OmniStudio development techniques.';
        developerPath.recommendedExperienceMonths = 12;
        developerPath.totalEstimatedHours = 150;
        
        // Prerequisites
        developerPath.prerequisites.addAll(new List<String>{
            'Salesforce Platform Developer I Certification (required)',
            'Strong JavaScript, HTML, CSS experience',
            'Apex programming proficiency',
            'REST/SOAP API integration experience',
            'Lightning Web Components knowledge (recommended)'
        });
        
        // Cross-certification mapping
        developerPath.crossCertificationMapping.put('FlexCards', 'Consultant.FlexCards.Business');
        developerPath.crossCertificationMapping.put('OmniScripts', 'Consultant.OmniScripts.Process');
        developerPath.crossCertificationMapping.put('DataRaptors', 'Consultant.DataTools.BI');
        developerPath.crossCertificationMapping.put('IntegrationProcedures', 'Consultant.Solutioning.Integration');
        developerPath.crossCertificationMapping.put('Expressions', 'Consultant.Solutioning.Logic');
        
        // Module 1: OmniStudio Development Foundation
        StudyModule foundationModule = new StudyModule();
        foundationModule.moduleId = 'DEV_M01';
        foundationModule.moduleName = 'OmniStudio Development Foundation';
        foundationModule.topic = 'Foundation';
        foundationModule.description = 'Technical foundation for OmniStudio development and architecture';
        foundationModule.estimatedHours = 20;
        foundationModule.sequenceOrder = 1;
        foundationModule.difficultyProgression = 'Intermediate → Advanced';
        
        foundationModule.learningObjectives.addAll(new List<String>{
            'Understand OmniStudio technical architecture',
            'Set up development environments and tools',
            'Master OmniStudio APIs and integration patterns',
            'Implement version control and deployment strategies'
        });
        
        // Foundation units
        foundationModule.units.add(createStudyUnit('DEV_U01_01', 'OmniStudio Architecture Deep-Dive', 'Theory', 120, 'Intermediate', 
            new List<String>{'architecture', 'technical-foundation'}, 
            'Understanding OmniStudio technical stack and integration points'));
        foundationModule.units.add(createStudyUnit('DEV_U01_02', 'Development Environment Setup', 'Practice', 90, 'Intermediate', 
            new List<String>{'development-setup', 'tools'}, 
            'Configuring Salesforce DX, VS Code, and OmniStudio development tools'));
        foundationModule.units.add(createStudyUnit('DEV_U01_03', 'API Integration Fundamentals', 'Practice', 105, 'Advanced', 
            new List<String>{'api-integration', 'technical-integration'}, 
            'Implementing REST and SOAP integrations with OmniStudio components'));
        foundationModule.units.add(createStudyUnit('DEV_U01_04', 'DevOps & Deployment', 'Practice', 120, 'Advanced', 
            new List<String>{'devops', 'deployment'}, 
            'CI/CD pipelines and automated deployment strategies'));
        foundationModule.units.add(createStudyUnit('DEV_U01_05', 'Foundation Assessment', 'Assessment', 60, 'Advanced', 
            new List<String>{'assessment', 'foundation'}, 
            'Technical foundation assessment with hands-on coding exercises'));
        
        developerPath.modules.add(foundationModule);
        
        // Module 2: Advanced FlexCards Development (20% weight)
        StudyModule flexCardsModule = new StudyModule();
        flexCardsModule.moduleId = 'DEV_M02';
        flexCardsModule.moduleName = 'Advanced FlexCards Development';
        flexCardsModule.topic = 'FlexCards';
        flexCardsModule.description = 'Custom FlexCard development with JavaScript, CSS, and advanced integrations';
        flexCardsModule.estimatedHours = 30; // 20% of 150 hours
        flexCardsModule.sequenceOrder = 2;
        flexCardsModule.difficultyProgression = 'Intermediate → Advanced';
        
        flexCardsModule.learningObjectives.addAll(new List<String>{
            'Develop custom FlexCard components',
            'Implement advanced JavaScript functionality',
            'Create responsive CSS layouts',
            'Build real-time data integrations'
        });
        
        flexCardsModule.prerequisites.add('DEV_M01');
        
        // Advanced FlexCards units
        flexCardsModule.units.add(createStudyUnit('DEV_U02_01', 'Custom JavaScript in FlexCards', 'Practice', 135, 'Intermediate', 
            new List<String>{'flexcard-javascript', 'custom-development'}, 
            'Building interactive charts and data visualizations within FlexCards'));
        flexCardsModule.units.add(createStudyUnit('DEV_U02_02', 'Advanced CSS Styling', 'Practice', 105, 'Intermediate', 
            new List<String>{'flexcard-styling', 'css-advanced'}, 
            'Creating responsive designs with custom animations and themes'));
        flexCardsModule.units.add(createStudyUnit('DEV_U02_03', 'Real-time Data Integration', 'Practice', 150, 'Advanced', 
            new List<String>{'flexcard-datasource', 'real-time-integration'}, 
            'Implementing WebSocket connections for live data updates'));
        flexCardsModule.units.add(createStudyUnit('DEV_U02_04', 'Custom Actions & Events', 'Practice', 120, 'Advanced', 
            new List<String>{'flexcard-actions', 'event-handling'}, 
            'Building complex user interactions with custom event handlers'));
        flexCardsModule.units.add(createStudyUnit('DEV_U02_05', 'Performance Optimization', 'Theory', 75, 'Advanced', 
            new List<String>{'flexcard-performance', 'optimization'}, 
            'Optimizing FlexCard rendering and data loading performance'));
        flexCardsModule.units.add(createStudyUnit('DEV_U02_06', 'FlexCards Coding Challenge', 'Project', 180, 'Advanced', 
            new List<String>{'flexcard-project', 'coding-challenge'}, 
            'Building a complete dashboard with custom components and integrations'));
        flexCardsModule.units.add(createStudyUnit('DEV_U02_07', 'FlexCards Technical Assessment', 'Assessment', 75, 'Advanced', 
            new List<String>{'assessment', 'flexcards-technical'}, 
            'Hands-on coding assessment with debugging scenarios'));
        
        developerPath.modules.add(flexCardsModule);
        
        return developerPath;
    }
    
    /**
     * @description Create a study unit with specified parameters
     * @param unitId Unique identifier for the unit
     * @param unitName Display name of the unit
     * @param unitType Type of learning unit
     * @param estimatedMinutes Time estimate in minutes
     * @param difficultyLevel Difficulty level
     * @param contentTags List of content tags
     * @param scenario Business/technical scenario description
     * @return StudyUnit configured unit
     */
    private static StudyUnit createStudyUnit(String unitId, String unitName, String unitType, 
                                           Integer estimatedMinutes, String difficultyLevel, 
                                           List<String> contentTags, String scenario) {
        StudyUnit unit = new StudyUnit();
        unit.unitId = unitId;
        unit.unitName = unitName;
        unit.unitType = unitType;
        unit.estimatedMinutes = estimatedMinutes;
        unit.difficultyLevel = difficultyLevel;
        unit.contentTags = contentTags;
        unit.scenario = scenario;
        return unit;
    }
    
    /**
     * @description Get personalized learning recommendations for a user
     * @param userId The user ID
     * @param certificationTrack The certification track
     * @return LearningProgress with recommendations
     */
    public static LearningProgress getPersonalizedRecommendations(String userId, String certificationTrack) {
        // This would typically query user performance data
        // For now, return a basic structure
        LearningProgress progress = new LearningProgress();
        progress.userId = userId;
        progress.certificationTrack = certificationTrack;
        progress.overallProgressPercent = 0;
        progress.totalStudyHours = 0;
        progress.lastActivity = DateTime.now();
        
        // Get first module as starting point
        LearningPath path = getLearningPath(certificationTrack);
        if (!path.modules.isEmpty()) {
            StudyModule firstModule = path.modules[0];
            progress.currentModuleId = firstModule.moduleId;
            if (!firstModule.units.isEmpty()) {
                progress.currentUnitId = firstModule.units[0].unitId;
                progress.recommendedNext.add(firstModule.units[0].unitId);
            }
        }
        
        return progress;
    }
    
    /**
     * @description Get study time estimates for all topics in a certification track
     * @param certificationTrack The certification track
     * @return Map<String, Integer> topic to hours mapping
     */
    public static Map<String, Integer> getStudyTimeEstimates(String certificationTrack) {
        Map<String, Integer> estimates = new Map<String, Integer>();
        
        LearningPath path = getLearningPath(certificationTrack);
        for (StudyModule module : path.modules) {
            if (module.topic != 'Foundation') {
                estimates.put(module.topic, module.estimatedHours);
            }
        }
        
        return estimates;
    }
    
    /**
     * @description Get cross-certification mappings between tracks
     * @param fromTrack Source certification track
     * @param toTrack Target certification track
     * @return Map<String, String> topic mappings
     */
    public static Map<String, String> getCrossCertificationMappings(String fromTrack, String toTrack) {
        LearningPath sourcePath = getLearningPath(fromTrack);
        Map<String, String> mappings = new Map<String, String>();
        
        for (String topic : sourcePath.crossCertificationMapping.keySet()) {
            String mappedContent = sourcePath.crossCertificationMapping.get(topic);
            if (mappedContent.startsWith(toTrack)) {
                mappings.put(topic, mappedContent);
            }
        }
        
        return mappings;
    }
    
    /**
     * @description Calculate prerequisite completion for a specific module
     * @param userId The user ID
     * @param moduleId The module to check prerequisites for
     * @param completedUnits List of completed unit IDs
     * @return Boolean whether prerequisites are met
     */
    public static Boolean checkPrerequisites(String userId, String moduleId, List<String> completedUnits) {
        // This would typically check against user progress records
        // For now, return basic logic
        if (moduleId.contains('M01')) {
            return true; // Foundation modules have no prerequisites
        }
        
        // Check if foundation module is completed
        Boolean foundationCompleted = false;
        for (String unitId : completedUnits) {
            if (unitId.contains('M01')) {
                foundationCompleted = true;
                break;
            }
        }
        
        return foundationCompleted;
    }
}