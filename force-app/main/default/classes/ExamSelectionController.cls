/**
 * @description Exam Selection FlexCards Controller for OmniStudio Training Platform
 * @author Claude Code Assistant
 * @since User Story #19 - Exam Selection FlexCards
 * @version 1.0
 * 
 * This class provides backend data for exam selection FlexCards, displaying
 * comprehensive information about Consultant vs Developer certification paths
 * to help users make informed decisions about their certification journey.
 */
public with sharing class ExamSelectionController {
    
    /**
     * @description Exam selection data structure
     */
    public class ExamSelectionData {
        @AuraEnabled public List<ExamInfo> availableExams {get; set;}
        @AuraEnabled public UserRecommendation userRecommendation {get; set;}
        @AuraEnabled public String currentUserId {get; set;}
        @AuraEnabled public Boolean hasExistingProgress {get; set;}
        @AuraEnabled public DateTime lastUpdated {get; set;}
        
        public ExamSelectionData() {
            this.availableExams = new List<ExamInfo>();
        }
    }
    
    /**
     * @description Comprehensive exam information
     */
    public class ExamInfo {
        @AuraEnabled public String examId {get; set;}
        @AuraEnabled public String examName {get; set;}
        @AuraEnabled public String examDisplayName {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public String targetAudience {get; set;}
        @AuraEnabled public ExamDetails examDetails {get; set;}
        @AuraEnabled public List<String> prerequisites {get; set;}
        @AuraEnabled public ExperienceLevel experienceLevel {get; set;}
        @AuraEnabled public VisualStyling styling {get; set;}
        @AuraEnabled public List<CallToAction> callToActions {get; set;}
        @AuraEnabled public List<String> keyTopics {get; set;}
        @AuraEnabled public CareerOutcome careerOutcome {get; set;}
        @AuraEnabled public String studyPathUrl {get; set;}
        @AuraEnabled public String practiceExamUrl {get; set;}
        @AuraEnabled public Boolean isRecommended {get; set;}
        
        public ExamInfo() {
            this.prerequisites = new List<String>();
            this.callToActions = new List<CallToAction>();
            this.keyTopics = new List<String>();
        }
    }
    
    /**
     * @description Official exam details
     */
    public class ExamDetails {
        @AuraEnabled public Integer questionCount {get; set;}
        @AuraEnabled public Integer durationMinutes {get; set;}
        @AuraEnabled public Decimal passingScore {get; set;}
        @AuraEnabled public String passingScoreDisplay {get; set;}
        @AuraEnabled public Decimal examCost {get; set;}
        @AuraEnabled public String examCostDisplay {get; set;}
        @AuraEnabled public String examFormat {get; set;}
        @AuraEnabled public Integer validityPeriodYears {get; set;}
        @AuraEnabled public String schedulingInfo {get; set;}
        @AuraEnabled public String retakePolicy {get; set;}
    }
    
    /**
     * @description Experience level requirements
     */
    public class ExperienceLevel {
        @AuraEnabled public Integer minimumMonths {get; set;}
        @AuraEnabled public Integer recommendedMonths {get; set;}
        @AuraEnabled public String experienceDescription {get; set;}
        @AuraEnabled public List<String> requiredSkills {get; set;}
        @AuraEnabled public List<String> recommendedCertifications {get; set;}
        
        public ExperienceLevel() {
            this.requiredSkills = new List<String>();
            this.recommendedCertifications = new List<String>();
        }
    }
    
    /**
     * @description Visual styling information for FlexCard
     */
    public class VisualStyling {
        @AuraEnabled public String primaryColor {get; set;}
        @AuraEnabled public String secondaryColor {get; set;}
        @AuraEnabled public String accentColor {get; set;}
        @AuraEnabled public String gradientClass {get; set;}
        @AuraEnabled public String iconName {get; set;}
        @AuraEnabled public String cardClass {get; set;}
        @AuraEnabled public String badgeClass {get; set;}
        @AuraEnabled public String headerImage {get; set;}
    }
    
    /**
     * @description Call to action button configuration
     */
    public class CallToAction {
        @AuraEnabled public String actionId {get; set;}
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public String actionUrl {get; set;}
        @AuraEnabled public String buttonClass {get; set;}
        @AuraEnabled public String iconName {get; set;}
        @AuraEnabled public Boolean isPrimary {get; set;}
        @AuraEnabled public String analyticsEvent {get; set;}
    }
    
    /**
     * @description Career outcome information
     */
    public class CareerOutcome {
        @AuraEnabled public String primaryRole {get; set;}
        @AuraEnabled public List<String> careerPaths {get; set;}
        @AuraEnabled public String salaryRange {get; set;}
        @AuraEnabled public String marketDemand {get; set;}
        @AuraEnabled public List<String> nextCertifications {get; set;}
        @AuraEnabled public String growthProjection {get; set;}
        
        public CareerOutcome() {
            this.careerPaths = new List<String>();
            this.nextCertifications = new List<String>();
        }
    }
    
    /**
     * @description User-specific recommendation
     */
    public class UserRecommendation {
        @AuraEnabled public String recommendedExam {get; set;}
        @AuraEnabled public String reasonForRecommendation {get; set;}
        @AuraEnabled public List<String> matchingFactors {get; set;}
        @AuraEnabled public String confidenceLevel {get; set;}
        @AuraEnabled public String alternativeOption {get; set;}
        
        public UserRecommendation() {
            this.matchingFactors = new List<String>();
        }
    }
    
    /**
     * @description Get comprehensive exam selection data
     * @return ExamSelectionData complete exam information
     */
    @AuraEnabled(cacheable=true)
    public static ExamSelectionData getExamSelectionData() {
        try {
            ExamSelectionData selectionData = new ExamSelectionData();
            selectionData.currentUserId = UserInfo.getUserId();
            selectionData.lastUpdated = DateTime.now();
            
            // Create exam information for both tracks
            selectionData.availableExams.add(createConsultantExamInfo());
            selectionData.availableExams.add(createDeveloperExamInfo());
            
            // Check for existing user progress
            selectionData.hasExistingProgress = checkExistingUserProgress(selectionData.currentUserId);
            
            // Generate user recommendation
            selectionData.userRecommendation = generateUserRecommendation(selectionData.currentUserId);
            
            // Set recommendation flags on exams
            for (ExamInfo exam : selectionData.availableExams) {
                exam.isRecommended = (exam.examId == selectionData.userRecommendation.recommendedExam);
            }
            
            return selectionData;
            
        } catch (Exception e) {
            System.debug('Error in getExamSelectionData: ' + e.getMessage());
            throw new AuraHandledException('Unable to load exam selection data: ' + e.getMessage());
        }
    }
    
    /**
     * @description Create Consultant exam information
     * @return ExamInfo Consultant exam details
     */
    private static ExamInfo createConsultantExamInfo() {
        ExamInfo consultantExam = new ExamInfo();
        
        // Basic information
        consultantExam.examId = 'Consultant';
        consultantExam.examName = 'Salesforce OmniStudio Consultant';
        consultantExam.examDisplayName = 'OmniStudio Consultant';
        consultantExam.description = 'Designed for professionals who implement OmniStudio solutions to meet business requirements and optimize user experiences.';
        consultantExam.targetAudience = 'Business analysts, solution architects, consultants, and technical leads who design and implement OmniStudio solutions.';
        
        // Exam details
        consultantExam.examDetails = new ExamDetails();
        consultantExam.examDetails.questionCount = 60;
        consultantExam.examDetails.durationMinutes = 105;
        consultantExam.examDetails.passingScore = 63.0;
        consultantExam.examDetails.passingScoreDisplay = '63%';
        consultantExam.examDetails.examCost = 200.0;
        consultantExam.examDetails.examCostDisplay = '$200 USD';
        consultantExam.examDetails.examFormat = 'Multiple choice and multiple select';
        consultantExam.examDetails.validityPeriodYears = 3;
        consultantExam.examDetails.schedulingInfo = 'Available at Pearson VUE testing centers and online proctoring';
        consultantExam.examDetails.retakePolicy = 'Wait 24 hours after first attempt, then 14 days between subsequent attempts';
        
        // Prerequisites
        consultantExam.prerequisites.addAll(new List<String>{
            'Salesforce Administrator certification (recommended)',
            '6+ months hands-on Salesforce experience',
            'Basic understanding of business process analysis',
            'Familiarity with web technologies (HTML, CSS, JavaScript basics)'
        });
        
        // Experience level
        consultantExam.experienceLevel = new ExperienceLevel();
        consultantExam.experienceLevel.minimumMonths = 6;
        consultantExam.experienceLevel.recommendedMonths = 12;
        consultantExam.experienceLevel.experienceDescription = 'Business-focused role requiring solution design and user experience optimization skills';
        
        consultantExam.experienceLevel.requiredSkills.addAll(new List<String>{
            'Business requirements analysis',
            'Solution design and architecture',
            'User experience design principles',
            'Salesforce platform knowledge',
            'Process optimization techniques'
        });
        
        consultantExam.experienceLevel.recommendedCertifications.addAll(new List<String>{
            'Salesforce Certified Administrator',
            'Salesforce Certified Platform App Builder (helpful)',
            'Business Analysis certifications (beneficial)'
        });
        
        // Visual styling - Blue theme for Consultant
        consultantExam.styling = new VisualStyling();
        consultantExam.styling.primaryColor = '#0176D3'; // Salesforce Blue
        consultantExam.styling.secondaryColor = '#E3F3FD'; // Light Blue
        consultantExam.styling.accentColor = '#014A94'; // Dark Blue
        consultantExam.styling.gradientClass = 'consultant-gradient';
        consultantExam.styling.iconName = 'utility:solution';
        consultantExam.styling.cardClass = 'consultant-card';
        consultantExam.styling.badgeClass = 'consultant-badge';
        consultantExam.styling.headerImage = '/assets/consultant-header.jpg';
        
        // Key topics
        consultantExam.keyTopics.addAll(new List<String>{
            'FlexCards (23%): Responsive data displays and dashboards',
            'OmniScripts (27%): Guided business processes and workflows',
            'Data Tools (23%): Business intelligence and analytics',
            'Solution Architecture (27%): Enterprise design and best practices'
        });
        
        // Career outcomes
        consultantExam.careerOutcome = new CareerOutcome();
        consultantExam.careerOutcome.primaryRole = 'OmniStudio Solution Consultant';
        consultantExam.careerOutcome.careerPaths.addAll(new List<String>{
            'Senior Business Analyst',
            'Solution Architect',
            'Technical Consultant',
            'Customer Success Manager',
            'Project Manager'
        });
        consultantExam.careerOutcome.salaryRange = '$85,000 - $130,000 annually';
        consultantExam.careerOutcome.marketDemand = 'High demand - Growing 25% year-over-year';
        consultantExam.careerOutcome.nextCertifications.addAll(new List<String>{
            'Salesforce Certified Technical Architect',
            'Salesforce Certified Application Architect',
            'Industry Cloud Consultant certifications'
        });
        consultantExam.careerOutcome.growthProjection = 'Excellent growth potential with OmniStudio adoption increasing across industries';
        
        // Call to actions
        CallToAction beginStudyPath = new CallToAction();
        beginStudyPath.actionId = 'begin-consultant-study';
        beginStudyPath.label = 'Begin Study Path';
        beginStudyPath.description = 'Start your Consultant certification journey';
        beginStudyPath.actionUrl = '/study/consultant/onboarding';
        beginStudyPath.buttonClass = 'slds-button_brand consultant-primary-btn';
        beginStudyPath.iconName = 'utility:bookmark';
        beginStudyPath.isPrimary = true;
        beginStudyPath.analyticsEvent = 'consultant_study_path_selected';
        
        CallToAction practiceExam = new CallToAction();
        practiceExam.actionId = 'practice-consultant-exam';
        practiceExam.label = 'Take Practice Exam';
        practiceExam.description = 'Test your readiness with sample questions';
        practiceExam.actionUrl = '/practice/consultant/exam';
        practiceExam.buttonClass = 'slds-button_outline-brand consultant-secondary-btn';
        practiceExam.iconName = 'utility:quiz';
        practiceExam.isPrimary = false;
        practiceExam.analyticsEvent = 'consultant_practice_exam_started';
        
        consultantExam.callToActions.add(beginStudyPath);
        consultantExam.callToActions.add(practiceExam);
        
        // URLs
        consultantExam.studyPathUrl = '/study/consultant/onboarding';
        consultantExam.practiceExamUrl = '/practice/consultant/exam';
        
        return consultantExam;
    }
    
    /**
     * @description Create Developer exam information
     * @return ExamInfo Developer exam details
     */
    private static ExamInfo createDeveloperExamInfo() {
        ExamInfo developerExam = new ExamInfo();
        
        // Basic information
        developerExam.examId = 'Developer';
        developerExam.examName = 'Salesforce OmniStudio Developer';
        developerExam.examDisplayName = 'OmniStudio Developer';
        developerExam.description = 'Designed for developers who build advanced OmniStudio solutions with custom code, integrations, and complex business logic.';
        developerExam.targetAudience = 'Software developers, technical architects, and engineers who implement advanced OmniStudio solutions with custom development.';
        
        // Exam details
        developerExam.examDetails = new ExamDetails();
        developerExam.examDetails.questionCount = 60;
        developerExam.examDetails.durationMinutes = 105;
        developerExam.examDetails.passingScore = 63.0;
        developerExam.examDetails.passingScoreDisplay = '63%';
        developerExam.examDetails.examCost = 200.0;
        developerExam.examDetails.examCostDisplay = '$200 USD';
        developerExam.examDetails.examFormat = 'Multiple choice, multiple select, and hands-on scenarios';
        developerExam.examDetails.validityPeriodYears = 3;
        developerExam.examDetails.schedulingInfo = 'Available at Pearson VUE testing centers and online proctoring';
        developerExam.examDetails.retakePolicy = 'Wait 24 hours after first attempt, then 14 days between subsequent attempts';
        
        // Prerequisites
        developerExam.prerequisites.addAll(new List<String>{
            'Salesforce Platform Developer I certification (required)',
            '12+ months Salesforce development experience',
            'Strong JavaScript, HTML, CSS proficiency',
            'Apex programming experience',
            'REST/SOAP API integration experience'
        });
        
        // Experience level
        developerExam.experienceLevel = new ExperienceLevel();
        developerExam.experienceLevel.minimumMonths = 12;
        developerExam.experienceLevel.recommendedMonths = 18;
        developerExam.experienceLevel.experienceDescription = 'Technical role requiring advanced development and integration skills';
        
        developerExam.experienceLevel.requiredSkills.addAll(new List<String>{
            'Advanced JavaScript (ES6+)',
            'Salesforce Apex programming',
            'Lightning Web Components (LWC)',
            'REST/SOAP API development',
            'JSON data manipulation',
            'Performance optimization techniques'
        });
        
        developerExam.experienceLevel.recommendedCertifications.addAll(new List<String>{
            'Salesforce Certified Platform Developer I (required)',
            'Salesforce Certified Platform Developer II (recommended)',
            'JavaScript Developer Certification (beneficial)',
            'Integration Architecture Designer (advanced)'
        });
        
        // Visual styling - Green theme for Developer
        developerExam.styling = new VisualStyling();
        developerExam.styling.primaryColor = '#4BCE2F'; // Success Green
        developerExam.styling.secondaryColor = '#E8F5E8'; // Light Green
        developerExam.styling.accentColor = '#2E7D32'; // Dark Green
        developerExam.styling.gradientClass = 'developer-gradient';
        developerExam.styling.iconName = 'utility:code';
        developerExam.styling.cardClass = 'developer-card';
        developerExam.styling.badgeClass = 'developer-badge';
        developerExam.styling.headerImage = '/assets/developer-header.jpg';
        
        // Key topics
        developerExam.keyTopics.addAll(new List<String>{
            'Advanced FlexCards (20%): Custom JavaScript and complex integrations',
            'OmniScript Development (20%): Custom elements and advanced logic',
            'Integration Procedures (20%): Server-side processing and APIs',
            'DataRaptors (20%): Advanced data operations and transformations',
            'Expression Functions (20%): Custom formulas and decision logic'
        });
        
        // Career outcomes
        developerExam.careerOutcome = new CareerOutcome();
        developerExam.careerOutcome.primaryRole = 'OmniStudio Technical Developer';
        developerExam.careerOutcome.careerPaths.addAll(new List<String>{
            'Senior Salesforce Developer',
            'Technical Architect',
            'Integration Specialist',
            'Full-Stack Developer',
            'Development Team Lead'
        });
        developerExam.careerOutcome.salaryRange = '$95,000 - $150,000 annually';
        developerExam.careerOutcome.marketDemand = 'Very high demand - Critical skill shortage in market';
        developerExam.careerOutcome.nextCertifications.addAll(new List<String>{
            'Salesforce Certified Technical Architect',
            'Integration Architecture Designer',
            'Platform Developer II',
            'Industries certifications with development focus'
        });
        developerExam.careerOutcome.growthProjection = 'Exceptional growth potential - highest paid OmniStudio specialization';
        
        // Call to actions
        CallToAction beginStudyPath = new CallToAction();
        beginStudyPath.actionId = 'begin-developer-study';
        beginStudyPath.label = 'Begin Study Path';
        beginStudyPath.description = 'Start your Developer certification journey';
        beginStudyPath.actionUrl = '/study/developer/onboarding';
        beginStudyPath.buttonClass = 'slds-button_brand developer-primary-btn';
        beginStudyPath.iconName = 'utility:bookmark';
        beginStudyPath.isPrimary = true;
        beginStudyPath.analyticsEvent = 'developer_study_path_selected';
        
        CallToAction practiceExam = new CallToAction();
        practiceExam.actionId = 'practice-developer-exam';
        practiceExam.label = 'Take Practice Exam';
        practiceExam.description = 'Test your technical skills with sample questions';
        practiceExam.actionUrl = '/practice/developer/exam';
        practiceExam.buttonClass = 'slds-button_outline-brand developer-secondary-btn';
        practiceExam.iconName = 'utility:quiz';
        practiceExam.isPrimary = false;
        practiceExam.analyticsEvent = 'developer_practice_exam_started';
        
        developerExam.callToActions.add(beginStudyPath);
        developerExam.callToActions.add(practiceExam);
        
        // URLs
        developerExam.studyPathUrl = '/study/developer/onboarding';
        developerExam.practiceExamUrl = '/practice/developer/exam';
        
        return developerExam;
    }
    
    /**
     * @description Check if user has existing progress in any track
     * @param userId User ID to check
     * @return Boolean true if user has existing progress
     */
    private static Boolean checkExistingUserProgress(String userId) {
        // Check for user profile
        Integer profileCount = [
            SELECT COUNT()
            FROM UserProfile__c 
            WHERE User__c = :userId
        ];
        
        // Check for answered questions
        Integer answerCount = [
            SELECT COUNT()
            FROM UserAnswer__c 
            WHERE User__c = :userId
        ];
        
        return profileCount > 0 || answerCount > 0;
    }
    
    /**
     * @description Generate user recommendation based on profile and experience
     * @param userId User ID
     * @return UserRecommendation recommendation details
     */
    private static UserRecommendation generateUserRecommendation(String userId) {
        UserRecommendation recommendation = new UserRecommendation();
        
        // Get user profile if it exists
        List<UserProfile__c> profiles = [
            SELECT CertificationGoals__c, CurrentDifficulty__c, PreferredLearningStyle__c
            FROM UserProfile__c 
            WHERE User__c = :userId 
            LIMIT 1
        ];
        
        if (!profiles.isEmpty()) {
            UserProfile__c profile = profiles[0];
            
            if (profile.CertificationGoals__c == 'Developer') {
                recommendation.recommendedExam = 'Developer';
                recommendation.reasonForRecommendation = 'Based on your profile preference for Developer certification';
                recommendation.matchingFactors.add('Profile indicates Developer track preference');
                recommendation.alternativeOption = 'Consultant';
            } else {
                recommendation.recommendedExam = 'Consultant';
                recommendation.reasonForRecommendation = 'Based on your profile preference for Consultant certification';
                recommendation.matchingFactors.add('Profile indicates Consultant track preference');
                recommendation.alternativeOption = 'Developer';
            }
            
            recommendation.confidenceLevel = 'High';
        } else {
            // Default recommendation for new users
            recommendation.recommendedExam = 'Consultant';
            recommendation.reasonForRecommendation = 'Consultant track is ideal for getting started with OmniStudio';
            recommendation.matchingFactors.addAll(new List<String>{
                'Great starting point for OmniStudio learning',
                'Business-focused approach with practical scenarios',
                'Lower technical prerequisites than Developer track'
            });
            recommendation.alternativeOption = 'Developer';
            recommendation.confidenceLevel = 'Medium';
        }
        
        return recommendation;
    }
    
    /**
     * @description Record user's exam selection for analytics
     * @param examId Selected exam ID
     * @param actionType Type of action taken
     * @return Boolean success status
     */
    @AuraEnabled
    public static Boolean recordExamSelection(String examId, String actionType) {
        try {
            // In a real implementation, this would record analytics data
            System.debug('User selected exam: ' + examId + ' with action: ' + actionType);
            
            // Could create custom object record for analytics
            // ExamSelectionEvent__c event = new ExamSelectionEvent__c(...);
            // insert event;
            
            return true;
            
        } catch (Exception e) {
            System.debug('Error recording exam selection: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Get exam comparison data for side-by-side view
     * @return Map<String, Object> comparison data
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getExamComparison() {
        try {
            ExamSelectionData selectionData = getExamSelectionData();
            Map<String, Object> comparison = new Map<String, Object>();
            
            if (selectionData.availableExams.size() >= 2) {
                ExamInfo consultant = selectionData.availableExams[0];
                ExamInfo developer = selectionData.availableExams[1];
                
                comparison.put('consultant', consultant);
                comparison.put('developer', developer);
                comparison.put('sideBySideFeatures', new List<String>{
                    'Experience Level',
                    'Prerequisites',
                    'Key Topics',
                    'Career Outcomes',
                    'Salary Range'
                });
            }
            
            return comparison;
            
        } catch (Exception e) {
            throw new AuraHandledException('Unable to load exam comparison: ' + e.getMessage());
        }
    }
}