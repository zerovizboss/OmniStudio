/**
 * @description User Onboarding OmniScript Controller for OmniStudio Training Platform
 * @author Claude Code Assistant
 * @since User Story #22 - User Onboarding OmniScript
 * @version 1.0
 * 
 * This class provides backend logic for the user onboarding OmniScript flow,
 * handling profile creation, learning style assessment, and study goal configuration
 * with comprehensive data validation and user experience optimization.
 */
public with sharing class UserOnboardingController {
    
    /**
     * @description Complete onboarding data structure
     */
    public class OnboardingData {
        @AuraEnabled public String userId {get; set;}
        @AuraEnabled public String userName {get; set;}
        @AuraEnabled public String userEmail {get; set;}
        @AuraEnabled public UserProfileData profileData {get; set;}
        @AuraEnabled public LearningAssessment assessment {get; set;}
        @AuraEnabled public StudyGoalConfiguration studyGoals {get; set;}
        @AuraEnabled public List<OnboardingStep> onboardingSteps {get; set;}
        @AuraEnabled public Integer currentStepIndex {get; set;}
        @AuraEnabled public Boolean isExistingUser {get; set;}
        @AuraEnabled public DateTime onboardingStartedAt {get; set;}
        @AuraEnabled public DateTime onboardingCompletedAt {get; set;}
        
        public OnboardingData() {
            this.onboardingSteps = new List<OnboardingStep>();
        }
    }
    
    /**
     * @description User profile information collected during onboarding
     */
    public class UserProfileData {
        @AuraEnabled public String certificationGoals {get; set;}
        @AuraEnabled public String currentExperience {get; set;}
        @AuraEnabled public String jobRole {get; set;}
        @AuraEnabled public String industryBackground {get; set;}
        @AuraEnabled public String salesforceExperience {get; set;}
        @AuraEnabled public List<String> previousCertifications {get; set;}
        @AuraEnabled public String motivationLevel {get; set;}
        @AuraEnabled public String availableTimeCommitment {get; set;}
        @AuraEnabled public Date targetCertificationDate {get; set;}
        
        public UserProfileData() {
            this.previousCertifications = new List<String>();
        }
    }
    
    /**
     * @description Learning style and preference assessment
     */
    public class LearningAssessment {
        @AuraEnabled public String preferredLearningStyle {get; set;} // Visual, Auditory, Kinesthetic, Mixed
        @AuraEnabled public String contentDeliveryPreference {get; set;} // Videos, Reading, Interactive, Mixed
        @AuraEnabled public String difficultyProgression {get; set;} // Gradual, Moderate, Intensive
        @AuraEnabled public String practiceFrequency {get; set;} // Daily, Alternate Days, Weekends, Flexible
        @AuraEnabled public Boolean enableReminders {get; set;}
        @AuraEnabled public String reminderTime {get; set;} // Morning, Afternoon, Evening
        @AuraEnabled public List<String> learningGoals {get; set;}
        @AuraEnabled public String assessmentScore {get; set;} // Calculated recommendation strength
        
        public LearningAssessment() {
            this.learningGoals = new List<String>();
        }
    }
    
    /**
     * @description Study goal configuration and planning
     */
    public class StudyGoalConfiguration {
        @AuraEnabled public Integer studyHoursPerWeek {get; set;}
        @AuraEnabled public List<String> preferredStudyDays {get; set;}
        @AuraEnabled public String preferredStudyTime {get; set;} // Morning, Afternoon, Evening, Flexible
        @AuraEnabled public Integer weeklyQuestionTarget {get; set;}
        @AuraEnabled public String studyPlan {get; set;} // Structured, Flexible, Self-Paced
        @AuraEnabled public Boolean enableProgressTracking {get; set;}
        @AuraEnabled public Boolean enableWeakAreaFocus {get; set;}
        @AuraEnabled public Date studyStartDate {get; set;}
        @AuraEnabled public Integer targetCompletionWeeks {get; set;}
        @AuraEnabled public String personalMotivation {get; set;}
        
        public StudyGoalConfiguration() {
            this.preferredStudyDays = new List<String>();
        }
    }
    
    /**
     * @description Individual onboarding step information
     */
    public class OnboardingStep {
        @AuraEnabled public String stepId {get; set;}
        @AuraEnabled public String stepTitle {get; set;}
        @AuraEnabled public String stepDescription {get; set;}
        @AuraEnabled public String stepIcon {get; set;}
        @AuraEnabled public Boolean isCompleted {get; set;}
        @AuraEnabled public Boolean isCurrentStep {get; set;}
        @AuraEnabled public Integer estimatedMinutes {get; set;}
        @AuraEnabled public List<StepContent> stepContent {get; set;}
        
        public OnboardingStep() {
            this.stepContent = new List<StepContent>();
        }
    }
    
    /**
     * @description Content within each onboarding step
     */
    public class StepContent {
        @AuraEnabled public String contentType {get; set;} // Text, Video, Interactive, Form
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public String contentUrl {get; set;}
        @AuraEnabled public String iconName {get; set;}
        @AuraEnabled public Boolean isRequired {get; set;}
    }
    
    /**
     * @description Initialize onboarding process for current user
     * @return OnboardingData initial onboarding information
     */
    @AuraEnabled(cacheable=false)
    public static OnboardingData initializeOnboarding() {
        try {
            String userId = UserInfo.getUserId();
            OnboardingData onboardingData = new OnboardingData();
            
            onboardingData.userId = userId;
            onboardingData.userName = UserInfo.getName();
            onboardingData.userEmail = UserInfo.getUserEmail();
            onboardingData.onboardingStartedAt = DateTime.now();
            onboardingData.currentStepIndex = 0;
            
            // Check if user already has a profile (returning user)
            onboardingData.isExistingUser = checkExistingUserProfile(userId);
            
            if (onboardingData.isExistingUser) {
                // Load existing profile data
                onboardingData.profileData = loadExistingProfileData(userId);
                onboardingData.assessment = loadExistingAssessment(userId);
                onboardingData.studyGoals = loadExistingStudyGoals(userId);
                onboardingData.currentStepIndex = 4; // Skip to completion step
            } else {
                // Initialize empty data for new user
                onboardingData.profileData = new UserProfileData();
                onboardingData.assessment = new LearningAssessment();
                onboardingData.studyGoals = new StudyGoalConfiguration();
                // Set defaults
                onboardingData.studyGoals.enableProgressTracking = true;
                onboardingData.studyGoals.enableWeakAreaFocus = true;
                onboardingData.assessment.enableReminders = true;
            }
            
            // Generate onboarding steps
            onboardingData.onboardingSteps = generateOnboardingSteps(onboardingData.isExistingUser);
            
            return onboardingData;
            
        } catch (Exception e) {
            System.debug('Error in initializeOnboarding: ' + e.getMessage());
            throw new AuraHandledException('Unable to initialize onboarding: ' + e.getMessage());
        }
    }
    
    /**
     * @description Save user profile data during onboarding
     * @param profileDataJson JSON string of profile data
     * @return Boolean success status
     */
    @AuraEnabled
    public static Boolean saveProfileData(String profileDataJson) {
        try {
            UserProfileData profileData = (UserProfileData) JSON.deserialize(profileDataJson, UserProfileData.class);
            String userId = UserInfo.getUserId();
            
            // Create or update user profile record
            List<UserProfile__c> existingProfiles = [
                SELECT Id FROM UserProfile__c WHERE User__c = :userId LIMIT 1
            ];
            
            UserProfile__c profile = existingProfiles.isEmpty() ? new UserProfile__c() : existingProfiles[0];
            
            profile.User__c = userId;
            profile.CertificationGoals__c = profileData.certificationGoals;
            profile.CurrentExperience__c = profileData.currentExperience;
            profile.JobRole__c = profileData.jobRole;
            profile.IndustryBackground__c = profileData.industryBackground;
            profile.SalesforceExperience__c = profileData.salesforceExperience;
            profile.PreviousCertifications__c = String.join(profileData.previousCertifications, ';');
            profile.MotivationLevel__c = profileData.motivationLevel;
            profile.AvailableTimeCommitment__c = profileData.availableTimeCommitment;
            profile.TargetCertificationDate__c = profileData.targetCertificationDate;
            profile.ProfileCompletedDate__c = DateTime.now();
            
            if (existingProfiles.isEmpty()) {
                insert profile;
            } else {
                update profile;
            }
            
            return true;
            
        } catch (Exception e) {
            System.debug('Error saving profile data: ' + e.getMessage());
            throw new AuraHandledException('Unable to save profile: ' + e.getMessage());
        }
    }
    
    /**
     * @description Save learning assessment results
     * @param assessmentDataJson JSON string of assessment data
     * @return Boolean success status
     */
    @AuraEnabled
    public static Boolean saveLearningAssessment(String assessmentDataJson) {
        try {
            LearningAssessment assessment = (LearningAssessment) JSON.deserialize(assessmentDataJson, LearningAssessment.class);
            String userId = UserInfo.getUserId();
            
            // Update user profile with learning assessment
            List<UserProfile__c> profiles = [
                SELECT Id FROM UserProfile__c WHERE User__c = :userId LIMIT 1
            ];
            
            if (!profiles.isEmpty()) {
                UserProfile__c profile = profiles[0];
                profile.PreferredLearningStyle__c = assessment.preferredLearningStyle;
                profile.ContentDeliveryPreference__c = assessment.contentDeliveryPreference;
                profile.DifficultyProgression__c = assessment.difficultyProgression;
                profile.PracticeFrequency__c = assessment.practiceFrequency;
                profile.EnableReminders__c = assessment.enableReminders;
                profile.ReminderTime__c = assessment.reminderTime;
                profile.LearningGoals__c = String.join(assessment.learningGoals, ';');
                profile.AssessmentScore__c = assessment.assessmentScore;
                profile.AssessmentCompletedDate__c = DateTime.now();
                
                update profile;
            }
            
            return true;
            
        } catch (Exception e) {
            System.debug('Error saving assessment data: ' + e.getMessage());
            throw new AuraHandledException('Unable to save assessment: ' + e.getMessage());
        }
    }
    
    /**
     * @description Save study goal configuration
     * @param studyGoalJson JSON string of study goals
     * @return Boolean success status
     */
    @AuraEnabled
    public static Boolean saveStudyGoals(String studyGoalJson) {
        try {
            StudyGoalConfiguration studyGoals = (StudyGoalConfiguration) JSON.deserialize(studyGoalJson, StudyGoalConfiguration.class);
            String userId = UserInfo.getUserId();
            
            // Update user profile with study goals
            List<UserProfile__c> profiles = [
                SELECT Id FROM UserProfile__c WHERE User__c = :userId LIMIT 1
            ];
            
            if (!profiles.isEmpty()) {
                UserProfile__c profile = profiles[0];
                profile.StudyHoursPerWeek__c = studyGoals.studyHoursPerWeek;
                profile.PreferredStudyDays__c = String.join(studyGoals.preferredStudyDays, ';');
                profile.PreferredStudyTime__c = studyGoals.preferredStudyTime;
                profile.WeeklyQuestionTarget__c = studyGoals.weeklyQuestionTarget;
                profile.StudyPlan__c = studyGoals.studyPlan;
                profile.EnableProgressTracking__c = studyGoals.enableProgressTracking;
                profile.EnableWeakAreaFocus__c = studyGoals.enableWeakAreaFocus;
                profile.StudyStartDate__c = studyGoals.studyStartDate;
                profile.TargetCompletionWeeks__c = studyGoals.targetCompletionWeeks;
                profile.PersonalMotivation__c = studyGoals.personalMotivation;
                profile.StudyGoalsCompletedDate__c = DateTime.now();
                
                update profile;
            }
            
            return true;
            
        } catch (Exception e) {
            System.debug('Error saving study goals: ' + e.getMessage());
            throw new AuraHandledException('Unable to save study goals: ' + e.getMessage());
        }
    }
    
    /**
     * @description Complete onboarding process
     * @return Boolean success status
     */
    @AuraEnabled
    public static Boolean completeOnboarding() {
        try {
            String userId = UserInfo.getUserId();
            
            // Update user profile to mark onboarding as complete
            List<UserProfile__c> profiles = [
                SELECT Id FROM UserProfile__c WHERE User__c = :userId LIMIT 1
            ];
            
            if (!profiles.isEmpty()) {
                UserProfile__c profile = profiles[0];
                profile.OnboardingCompleted__c = true;
                profile.OnboardingCompletedDate__c = DateTime.now();
                
                update profile;
                
                // Generate initial learning path recommendation
                generateInitialLearningPath(userId, profile);
            }
            
            return true;
            
        } catch (Exception e) {
            System.debug('Error completing onboarding: ' + e.getMessage());
            throw new AuraHandledException('Unable to complete onboarding: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get recommended certification track based on profile
     * @param profileDataJson JSON string of profile data
     * @return String recommended track
     */
    @AuraEnabled
    public static String getRecommendedTrack(String profileDataJson) {
        try {
            UserProfileData profileData = (UserProfileData) JSON.deserialize(profileDataJson, UserProfileData.class);
            
            // Logic for track recommendation
            Integer developerScore = 0;
            Integer consultantScore = 0;
            
            // Job role scoring
            if (profileData.jobRole != null) {
                String role = profileData.jobRole.toLowerCase();
                if (role.contains('developer') || role.contains('architect') || role.contains('engineer')) {
                    developerScore += 3;
                } else if (role.contains('consultant') || role.contains('analyst') || role.contains('manager')) {
                    consultantScore += 3;
                }
            }
            
            // Experience scoring
            if (profileData.salesforceExperience != null) {
                if (profileData.salesforceExperience.contains('Advanced') || profileData.salesforceExperience.contains('Expert')) {
                    developerScore += 2;
                } else if (profileData.salesforceExperience.contains('Beginner') || profileData.salesforceExperience.contains('Intermediate')) {
                    consultantScore += 2;
                }
            }
            
            // Previous certifications scoring
            for (String cert : profileData.previousCertifications) {
                if (cert != null) {
                    String certLower = cert.toLowerCase();
                    if (certLower.contains('developer') || certLower.contains('architect')) {
                        developerScore += 1;
                    } else if (certLower.contains('admin') || certLower.contains('consultant')) {
                        consultantScore += 1;
                    }
                }
            }
            
            return developerScore > consultantScore ? 'Developer' : 'Consultant';
            
        } catch (Exception e) {
            System.debug('Error getting recommended track: ' + e.getMessage());
            return 'Consultant'; // Default recommendation
        }
    }
    
    /**
     * @description Record onboarding analytics and user interaction
     * @param stepId Current step
     * @param actionTaken Action performed
     * @return Boolean success status
     */
    @AuraEnabled
    public static Boolean recordOnboardingAnalytics(String stepId, String actionTaken) {
        try {
            // In a real implementation, this would create analytics records
            System.debug('Onboarding analytics: Step ' + stepId + ', Action: ' + actionTaken);
            
            // Could create custom analytics object
            // OnboardingAnalytics__c analytics = new OnboardingAnalytics__c(...);
            // insert analytics;
            
            return true;
            
        } catch (Exception e) {
            System.debug('Error recording analytics: ' + e.getMessage());
            return false;
        }
    }
    
    // Helper methods
    
    private static Boolean checkExistingUserProfile(String userId) {
        return [SELECT COUNT() FROM UserProfile__c WHERE User__c = :userId AND OnboardingCompleted__c = true] > 0;
    }
    
    private static UserProfileData loadExistingProfileData(String userId) {
        List<UserProfile__c> profiles = [
            SELECT CertificationGoals__c, CurrentExperience__c, JobRole__c, IndustryBackground__c,
                   SalesforceExperience__c, PreviousCertifications__c, MotivationLevel__c,
                   AvailableTimeCommitment__c, TargetCertificationDate__c
            FROM UserProfile__c 
            WHERE User__c = :userId 
            LIMIT 1
        ];
        
        UserProfileData profileData = new UserProfileData();
        if (!profiles.isEmpty()) {
            UserProfile__c profile = profiles[0];
            profileData.certificationGoals = profile.CertificationGoals__c;
            profileData.currentExperience = profile.CurrentExperience__c;
            profileData.jobRole = profile.JobRole__c;
            profileData.industryBackground = profile.IndustryBackground__c;
            profileData.salesforceExperience = profile.SalesforceExperience__c;
            profileData.motivationLevel = profile.MotivationLevel__c;
            profileData.availableTimeCommitment = profile.AvailableTimeCommitment__c;
            profileData.targetCertificationDate = profile.TargetCertificationDate__c;
            
            if (profile.PreviousCertifications__c != null) {
                profileData.previousCertifications = profile.PreviousCertifications__c.split(';');
            }
        }
        
        return profileData;
    }
    
    private static LearningAssessment loadExistingAssessment(String userId) {
        List<UserProfile__c> profiles = [
            SELECT PreferredLearningStyle__c, ContentDeliveryPreference__c, DifficultyProgression__c,
                   PracticeFrequency__c, EnableReminders__c, ReminderTime__c, LearningGoals__c, AssessmentScore__c
            FROM UserProfile__c 
            WHERE User__c = :userId 
            LIMIT 1
        ];
        
        LearningAssessment assessment = new LearningAssessment();
        if (!profiles.isEmpty()) {
            UserProfile__c profile = profiles[0];
            assessment.preferredLearningStyle = profile.PreferredLearningStyle__c;
            assessment.contentDeliveryPreference = profile.ContentDeliveryPreference__c;
            assessment.difficultyProgression = profile.DifficultyProgression__c;
            assessment.practiceFrequency = profile.PracticeFrequency__c;
            assessment.enableReminders = profile.EnableReminders__c;
            assessment.reminderTime = profile.ReminderTime__c;
            assessment.assessmentScore = profile.AssessmentScore__c;
            
            if (profile.LearningGoals__c != null) {
                assessment.learningGoals = profile.LearningGoals__c.split(';');
            }
        }
        
        return assessment;
    }
    
    private static StudyGoalConfiguration loadExistingStudyGoals(String userId) {
        List<UserProfile__c> profiles = [
            SELECT StudyHoursPerWeek__c, PreferredStudyDays__c, PreferredStudyTime__c, WeeklyQuestionTarget__c,
                   StudyPlan__c, EnableProgressTracking__c, EnableWeakAreaFocus__c, StudyStartDate__c,
                   TargetCompletionWeeks__c, PersonalMotivation__c
            FROM UserProfile__c 
            WHERE User__c = :userId 
            LIMIT 1
        ];
        
        StudyGoalConfiguration studyGoals = new StudyGoalConfiguration();
        if (!profiles.isEmpty()) {
            UserProfile__c profile = profiles[0];
            studyGoals.studyHoursPerWeek = Integer.valueOf(profile.StudyHoursPerWeek__c != null ? profile.StudyHoursPerWeek__c : 0);
            studyGoals.preferredStudyTime = profile.PreferredStudyTime__c;
            studyGoals.weeklyQuestionTarget = Integer.valueOf(profile.WeeklyQuestionTarget__c != null ? profile.WeeklyQuestionTarget__c : 0);
            studyGoals.studyPlan = profile.StudyPlan__c;
            studyGoals.enableProgressTracking = profile.EnableProgressTracking__c;
            studyGoals.enableWeakAreaFocus = profile.EnableWeakAreaFocus__c;
            studyGoals.studyStartDate = profile.StudyStartDate__c;
            studyGoals.targetCompletionWeeks = Integer.valueOf(profile.TargetCompletionWeeks__c != null ? profile.TargetCompletionWeeks__c : 0);
            studyGoals.personalMotivation = profile.PersonalMotivation__c;
            
            if (profile.PreferredStudyDays__c != null) {
                studyGoals.preferredStudyDays = profile.PreferredStudyDays__c.split(';');
            }
        }
        
        return studyGoals;
    }
    
    private static List<OnboardingStep> generateOnboardingSteps(Boolean isExistingUser) {
        List<OnboardingStep> steps = new List<OnboardingStep>();
        
        if (!isExistingUser) {
            // Step 1: Welcome
            OnboardingStep welcomeStep = new OnboardingStep();
            welcomeStep.stepId = 'welcome';
            welcomeStep.stepTitle = 'Welcome to OmniStudio Training';
            welcomeStep.stepDescription = 'Get started with your certification journey';
            welcomeStep.stepIcon = 'utility:connected_apps';
            welcomeStep.isCurrentStep = true;
            welcomeStep.estimatedMinutes = 2;
            welcomeStep.stepContent.add(createStepContent('Video', 'Platform Overview', 'Learn about OmniStudio Training features', '/videos/platform-intro', 'utility:video', true));
            steps.add(welcomeStep);
            
            // Step 2: Profile Setup
            OnboardingStep profileStep = new OnboardingStep();
            profileStep.stepId = 'profile';
            profileStep.stepTitle = 'Create Your Profile';
            profileStep.stepDescription = 'Tell us about your background and goals';
            profileStep.stepIcon = 'utility:user';
            profileStep.estimatedMinutes = 5;
            profileStep.stepContent.add(createStepContent('Form', 'Personal Information', 'Basic profile details', null, 'utility:edit_form', true));
            profileStep.stepContent.add(createStepContent('Form', 'Experience Level', 'Your current Salesforce experience', null, 'utility:trending', true));
            steps.add(profileStep);
            
            // Step 3: Learning Assessment
            OnboardingStep assessmentStep = new OnboardingStep();
            assessmentStep.stepId = 'assessment';
            assessmentStep.stepTitle = 'Learning Style Assessment';
            assessmentStep.stepDescription = 'Personalize your learning experience';
            assessmentStep.stepIcon = 'utility:quiz';
            assessmentStep.estimatedMinutes = 8;
            assessmentStep.stepContent.add(createStepContent('Interactive', 'Learning Preferences', 'Discover your optimal learning style', null, 'utility:knowledge_base', true));
            steps.add(assessmentStep);
            
            // Step 4: Study Goals
            OnboardingStep goalsStep = new OnboardingStep();
            goalsStep.stepId = 'goals';
            goalsStep.stepTitle = 'Set Study Goals';
            goalsStep.stepDescription = 'Configure your study schedule and targets';
            goalsStep.stepIcon = 'utility:goals';
            goalsStep.estimatedMinutes = 5;
            goalsStep.stepContent.add(createStepContent('Form', 'Study Schedule', 'When and how often you want to study', null, 'utility:event', true));
            goalsStep.stepContent.add(createStepContent('Form', 'Success Metrics', 'Define your progress goals', null, 'utility:graph', true));
            steps.add(goalsStep);
        }
        
        // Step 5: Completion (for all users)
        OnboardingStep completionStep = new OnboardingStep();
        completionStep.stepId = 'complete';
        completionStep.stepTitle = 'Ready to Start Learning!';
        completionStep.stepDescription = 'Your personalized learning path is ready';
        completionStep.stepIcon = 'utility:success';
        completionStep.estimatedMinutes = 2;
        completionStep.stepContent.add(createStepContent('Text', 'Congratulations!', 'Your onboarding is complete', null, 'utility:party', false));
        completionStep.stepContent.add(createStepContent('Interactive', 'Next Steps', 'Explore your personalized dashboard', '/dashboard', 'utility:forward', false));
        steps.add(completionStep);
        
        return steps;
    }
    
    private static StepContent createStepContent(String contentType, String title, String description, 
                                                 String contentUrl, String iconName, Boolean isRequired) {
        StepContent content = new StepContent();
        content.contentType = contentType;
        content.title = title;
        content.description = description;
        content.contentUrl = contentUrl;
        content.iconName = iconName;
        content.isRequired = isRequired;
        return content;
    }
    
    private static void generateInitialLearningPath(String userId, UserProfile__c profile) {
        // This would integrate with LearningPathManager to create initial recommendations
        // Based on user profile, certification goals, and learning assessment
        System.debug('Generating initial learning path for user: ' + userId + 
                     ' with certification goal: ' + profile.CertificationGoals__c);
    }
}