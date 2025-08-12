/**
 * @description Test class for UserOnboardingController
 * @author Claude Code Assistant
 * @since User Story #22 - User Onboarding OmniScript
 * @version 1.0
 */
@isTest
private class UserOnboardingControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test user profile for existing user test
        UserProfile__c existingProfile = new UserProfile__c();
        existingProfile.User__c = UserInfo.getUserId();
        existingProfile.CertificationGoals__c = 'Developer';
        existingProfile.CurrentExperience__c = 'Intermediate';
        existingProfile.JobRole__c = 'Software Developer';
        existingProfile.IndustryBackground__c = 'Technology';
        existingProfile.SalesforceExperience__c = 'Advanced';
        existingProfile.PreviousCertifications__c = 'Platform Developer I;Administrator';
        existingProfile.MotivationLevel__c = 'High';
        existingProfile.AvailableTimeCommitment__c = '10-15 hours/week';
        existingProfile.TargetCertificationDate__c = Date.today().addMonths(3);
        existingProfile.PreferredLearningStyle__c = 'Visual';
        existingProfile.ContentDeliveryPreference__c = 'Interactive';
        existingProfile.DifficultyProgression__c = 'Moderate';
        existingProfile.PracticeFrequency__c = 'Daily';
        existingProfile.EnableReminders__c = true;
        existingProfile.ReminderTime__c = 'Morning';
        existingProfile.LearningGoals__c = 'Pass Certification;Career Advancement';
        existingProfile.AssessmentScore__c = 'High';
        existingProfile.StudyHoursPerWeek__c = 12;
        existingProfile.PreferredStudyDays__c = 'Monday;Tuesday;Wednesday;Thursday;Friday';
        existingProfile.PreferredStudyTime__c = 'Morning';
        existingProfile.WeeklyQuestionTarget__c = 100;
        existingProfile.StudyPlan__c = 'Structured';
        existingProfile.EnableProgressTracking__c = true;
        existingProfile.EnableWeakAreaFocus__c = true;
        existingProfile.StudyStartDate__c = Date.today();
        existingProfile.TargetCompletionWeeks__c = 12;
        existingProfile.PersonalMotivation__c = 'Career growth and technical advancement';
        existingProfile.OnboardingCompleted__c = true;
        existingProfile.OnboardingCompletedDate__c = DateTime.now();
        
        insert existingProfile;
    }
    
    @isTest
    static void testInitializeOnboardingNewUser() {
        // Create a fresh user context (simulate new user)
        System.runAs(createTestUser()) {
            Test.startTest();
            UserOnboardingController.OnboardingData result = UserOnboardingController.initializeOnboarding();
            Test.stopTest();
            
            // Assertions for new user
            Assert.isNotNull(result, 'Onboarding data should not be null');
            Assert.isFalse(result.isExistingUser, 'Should identify as new user');
            Assert.areEqual(UserInfo.getUserId(), result.userId, 'User ID should match current user');
            Assert.areEqual(UserInfo.getName(), result.userName, 'User name should match current user');
            Assert.areEqual(0, result.currentStepIndex, 'New user should start at step 0');
            Assert.isNotNull(result.profileData, 'Profile data should be initialized');
            Assert.isNotNull(result.assessment, 'Assessment should be initialized');
            Assert.isNotNull(result.studyGoals, 'Study goals should be initialized');
            Assert.isTrue(result.studyGoals.enableProgressTracking, 'Progress tracking should be enabled by default');
            Assert.isTrue(result.studyGoals.enableWeakAreaFocus, 'Weak area focus should be enabled by default');
            Assert.isTrue(result.assessment.enableReminders, 'Reminders should be enabled by default');
            Assert.areEqual(5, result.onboardingSteps.size(), 'Should have 5 onboarding steps for new user');
            
            // Verify step structure
            Assert.areEqual('welcome', result.onboardingSteps[0].stepId, 'First step should be welcome');
            Assert.areEqual('profile', result.onboardingSteps[1].stepId, 'Second step should be profile');
            Assert.areEqual('assessment', result.onboardingSteps[2].stepId, 'Third step should be assessment');
            Assert.areEqual('goals', result.onboardingSteps[3].stepId, 'Fourth step should be goals');
            Assert.areEqual('complete', result.onboardingSteps[4].stepId, 'Fifth step should be complete');
            
            // Verify current step marking
            Assert.isTrue(result.onboardingSteps[0].isCurrentStep, 'First step should be current');
            Assert.isFalse(result.onboardingSteps[1].isCurrentStep, 'Other steps should not be current');
        }
    }
    
    @isTest
    static void testInitializeOnboardingExistingUser() {
        Test.startTest();
        UserOnboardingController.OnboardingData result = UserOnboardingController.initializeOnboarding();
        Test.stopTest();
        
        // Assertions for existing user
        Assert.isNotNull(result, 'Onboarding data should not be null');
        Assert.isTrue(result.isExistingUser, 'Should identify as existing user');
        Assert.areEqual(4, result.currentStepIndex, 'Existing user should skip to completion step');
        
        // Verify loaded data
        Assert.areEqual('Developer', result.profileData.certificationGoals, 'Should load existing certification goal');
        Assert.areEqual('Intermediate', result.profileData.currentExperience, 'Should load existing experience');
        Assert.areEqual('Software Developer', result.profileData.jobRole, 'Should load existing job role');
        Assert.areEqual('Visual', result.assessment.preferredLearningStyle, 'Should load existing learning style');
        Assert.areEqual(12, result.studyGoals.studyHoursPerWeek, 'Should load existing study hours');
        
        // Verify previous certifications parsing
        Assert.areEqual(2, result.profileData.previousCertifications.size(), 'Should parse previous certifications');
        Assert.isTrue(result.profileData.previousCertifications.contains('Platform Developer I'), 'Should include Platform Developer I');
        Assert.isTrue(result.profileData.previousCertifications.contains('Administrator'), 'Should include Administrator');
    }
    
    @isTest
    static void testSaveProfileData() {
        System.runAs(createTestUser()) {
            UserOnboardingController.UserProfileData profileData = new UserOnboardingController.UserProfileData();
            profileData.certificationGoals = 'Consultant';
            profileData.currentExperience = 'Beginner';
            profileData.jobRole = 'Business Analyst';
            profileData.industryBackground = 'Healthcare';
            profileData.salesforceExperience = 'Beginner';
            profileData.previousCertifications = new List<String>{'Administrator'};
            profileData.motivationLevel = 'High';
            profileData.availableTimeCommitment = '5-10 hours/week';
            profileData.targetCertificationDate = Date.today().addMonths(6);
            
            String profileJson = JSON.serialize(profileData);
            
            Test.startTest();
            Boolean result = UserOnboardingController.saveProfileData(profileJson);
            Test.stopTest();
            
            Assert.isTrue(result, 'Profile save should be successful');
            
            // Verify data was saved
            List<UserProfile__c> savedProfiles = [
                SELECT CertificationGoals__c, CurrentExperience__c, JobRole__c, IndustryBackground__c,
                       SalesforceExperience__c, PreviousCertifications__c, MotivationLevel__c,
                       AvailableTimeCommitment__c, TargetCertificationDate__c
                FROM UserProfile__c 
                WHERE User__c = :UserInfo.getUserId()
            ];
            
            Assert.areEqual(1, savedProfiles.size(), 'Should create one profile record');
            
            UserProfile__c savedProfile = savedProfiles[0];
            Assert.areEqual('Consultant', savedProfile.CertificationGoals__c, 'Should save certification goal');
            Assert.areEqual('Beginner', savedProfile.CurrentExperience__c, 'Should save experience level');
            Assert.areEqual('Business Analyst', savedProfile.JobRole__c, 'Should save job role');
            Assert.areEqual('Healthcare', savedProfile.IndustryBackground__c, 'Should save industry');
            Assert.areEqual('Administrator', savedProfile.PreviousCertifications__c, 'Should save certifications');
        }
    }
    
    @isTest
    static void testSaveLearningAssessment() {
        System.runAs(createTestUser()) {
            // First create a profile
            UserProfile__c profile = new UserProfile__c();
            profile.User__c = UserInfo.getUserId();
            profile.CertificationGoals__c = 'Developer';
            insert profile;
            
            UserOnboardingController.LearningAssessment assessment = new UserOnboardingController.LearningAssessment();
            assessment.preferredLearningStyle = 'Kinesthetic';
            assessment.contentDeliveryPreference = 'Videos';
            assessment.difficultyProgression = 'Intensive';
            assessment.practiceFrequency = 'Alternate Days';
            assessment.enableReminders = true;
            assessment.reminderTime = 'Evening';
            assessment.learningGoals = new List<String>{'Pass Certification', 'Skill Development'};
            assessment.assessmentScore = 'Medium';
            
            String assessmentJson = JSON.serialize(assessment);
            
            Test.startTest();
            Boolean result = UserOnboardingController.saveLearningAssessment(assessmentJson);
            Test.stopTest();
            
            Assert.isTrue(result, 'Assessment save should be successful');
            
            // Verify data was saved
            UserProfile__c updatedProfile = [
                SELECT PreferredLearningStyle__c, ContentDeliveryPreference__c, DifficultyProgression__c,
                       PracticeFrequency__c, EnableReminders__c, ReminderTime__c, LearningGoals__c, AssessmentScore__c
                FROM UserProfile__c 
                WHERE User__c = :UserInfo.getUserId()
                LIMIT 1
            ];
            
            Assert.areEqual('Kinesthetic', updatedProfile.PreferredLearningStyle__c, 'Should save learning style');
            Assert.areEqual('Videos', updatedProfile.ContentDeliveryPreference__c, 'Should save content preference');
            Assert.areEqual('Intensive', updatedProfile.DifficultyProgression__c, 'Should save difficulty progression');
            Assert.areEqual('Pass Certification;Skill Development', updatedProfile.LearningGoals__c, 'Should save learning goals');
            Assert.isTrue(updatedProfile.EnableReminders__c, 'Should save reminder preference');
        }
    }
    
    @isTest
    static void testSaveStudyGoals() {
        System.runAs(createTestUser()) {
            // First create a profile
            UserProfile__c profile = new UserProfile__c();
            profile.User__c = UserInfo.getUserId();
            profile.CertificationGoals__c = 'Consultant';
            insert profile;
            
            UserOnboardingController.StudyGoalConfiguration studyGoals = new UserOnboardingController.StudyGoalConfiguration();
            studyGoals.studyHoursPerWeek = 8;
            studyGoals.preferredStudyDays = new List<String>{'Monday', 'Wednesday', 'Friday'};
            studyGoals.preferredStudyTime = 'Evening';
            studyGoals.weeklyQuestionTarget = 50;
            studyGoals.studyPlan = 'Flexible';
            studyGoals.enableProgressTracking = true;
            studyGoals.enableWeakAreaFocus = false;
            studyGoals.studyStartDate = Date.today().addDays(7);
            studyGoals.targetCompletionWeeks = 16;
            studyGoals.personalMotivation = 'Professional development and career growth';
            
            String studyGoalsJson = JSON.serialize(studyGoals);
            
            Test.startTest();
            Boolean result = UserOnboardingController.saveStudyGoals(studyGoalsJson);
            Test.stopTest();
            
            Assert.isTrue(result, 'Study goals save should be successful');
            
            // Verify data was saved
            UserProfile__c updatedProfile = [
                SELECT StudyHoursPerWeek__c, PreferredStudyDays__c, PreferredStudyTime__c, WeeklyQuestionTarget__c,
                       StudyPlan__c, EnableProgressTracking__c, EnableWeakAreaFocus__c, StudyStartDate__c,
                       TargetCompletionWeeks__c, PersonalMotivation__c
                FROM UserProfile__c 
                WHERE User__c = :UserInfo.getUserId()
                LIMIT 1
            ];
            
            Assert.areEqual(8, updatedProfile.StudyHoursPerWeek__c, 'Should save study hours per week');
            Assert.areEqual('Monday;Wednesday;Friday', updatedProfile.PreferredStudyDays__c, 'Should save study days');
            Assert.areEqual('Evening', updatedProfile.PreferredStudyTime__c, 'Should save study time');
            Assert.areEqual(50, updatedProfile.WeeklyQuestionTarget__c, 'Should save question target');
            Assert.areEqual('Flexible', updatedProfile.StudyPlan__c, 'Should save study plan');
            Assert.isTrue(updatedProfile.EnableProgressTracking__c, 'Should save progress tracking preference');
            Assert.isFalse(updatedProfile.EnableWeakAreaFocus__c, 'Should save weak area focus preference');
        }
    }
    
    @isTest
    static void testCompleteOnboarding() {
        System.runAs(createTestUser()) {
            // First create a profile
            UserProfile__c profile = new UserProfile__c();
            profile.User__c = UserInfo.getUserId();
            profile.CertificationGoals__c = 'Developer';
            insert profile;
            
            Test.startTest();
            Boolean result = UserOnboardingController.completeOnboarding();
            Test.stopTest();
            
            Assert.isTrue(result, 'Onboarding completion should be successful');
            
            // Verify profile was updated
            UserProfile__c updatedProfile = [
                SELECT OnboardingCompleted__c, OnboardingCompletedDate__c
                FROM UserProfile__c 
                WHERE User__c = :UserInfo.getUserId()
                LIMIT 1
            ];
            
            Assert.isTrue(updatedProfile.OnboardingCompleted__c, 'Onboarding should be marked as completed');
            Assert.isNotNull(updatedProfile.OnboardingCompletedDate__c, 'Completion date should be set');
        }
    }
    
    @isTest
    static void testGetRecommendedTrackDeveloper() {
        UserOnboardingController.UserProfileData profileData = new UserOnboardingController.UserProfileData();
        profileData.jobRole = 'Senior Software Developer';
        profileData.salesforceExperience = 'Advanced';
        profileData.previousCertifications = new List<String>{'Platform Developer I', 'Integration Architecture Designer'};
        
        String profileJson = JSON.serialize(profileData);
        
        Test.startTest();
        String recommendedTrack = UserOnboardingController.getRecommendedTrack(profileJson);
        Test.stopTest();
        
        Assert.areEqual('Developer', recommendedTrack, 'Should recommend Developer track for technical profile');
    }
    
    @isTest
    static void testGetRecommendedTrackConsultant() {
        UserOnboardingController.UserProfileData profileData = new UserOnboardingController.UserProfileData();
        profileData.jobRole = 'Business Analyst';
        profileData.salesforceExperience = 'Intermediate';
        profileData.previousCertifications = new List<String>{'Administrator', 'Sales Cloud Consultant'};
        
        String profileJson = JSON.serialize(profileData);
        
        Test.startTest();
        String recommendedTrack = UserOnboardingController.getRecommendedTrack(profileJson);
        Test.stopTest();
        
        Assert.areEqual('Consultant', recommendedTrack, 'Should recommend Consultant track for business profile');
    }
    
    @isTest
    static void testGetRecommendedTrackDefault() {
        UserOnboardingController.UserProfileData profileData = new UserOnboardingController.UserProfileData();
        // Leave fields empty to test default behavior
        
        String profileJson = JSON.serialize(profileData);
        
        Test.startTest();
        String recommendedTrack = UserOnboardingController.getRecommendedTrack(profileJson);
        Test.stopTest();
        
        Assert.areEqual('Consultant', recommendedTrack, 'Should default to Consultant track for new users');
    }
    
    @isTest
    static void testRecordOnboardingAnalytics() {
        Test.startTest();
        Boolean result = UserOnboardingController.recordOnboardingAnalytics('profile', 'step_completed');
        Test.stopTest();
        
        Assert.isTrue(result, 'Analytics recording should be successful');
    }
    
    @isTest
    static void testErrorHandling() {
        // Test with invalid JSON to trigger error handling
        Test.startTest();
        try {
            UserOnboardingController.saveProfileData('invalid json');
            Assert.fail('Should have thrown an exception for invalid JSON');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Unable to save profile'), 'Should throw appropriate error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateExistingProfile() {
        // Test updating an existing profile instead of creating a new one
        UserOnboardingController.UserProfileData profileData = new UserOnboardingController.UserProfileData();
        profileData.certificationGoals = 'Updated Consultant';
        profileData.currentExperience = 'Updated Intermediate';
        profileData.jobRole = 'Updated Business Analyst';
        
        String profileJson = JSON.serialize(profileData);
        
        Test.startTest();
        Boolean result = UserOnboardingController.saveProfileData(profileJson);
        Test.stopTest();
        
        Assert.isTrue(result, 'Profile update should be successful');
        
        // Verify existing profile was updated, not a new one created
        List<UserProfile__c> profiles = [
            SELECT CertificationGoals__c, CurrentExperience__c, JobRole__c
            FROM UserProfile__c 
            WHERE User__c = :UserInfo.getUserId()
        ];
        
        Assert.areEqual(1, profiles.size(), 'Should still have only one profile record');
        Assert.areEqual('Updated Consultant', profiles[0].CertificationGoals__c, 'Should update certification goal');
        Assert.areEqual('Updated Intermediate', profiles[0].CurrentExperience__c, 'Should update experience');
        Assert.areEqual('Updated Business Analyst', profiles[0].JobRole__c, 'Should update job role');
    }
    
    @isTest
    static void testOnboardingStepsContent() {
        System.runAs(createTestUser()) {
            Test.startTest();
            UserOnboardingController.OnboardingData result = UserOnboardingController.initializeOnboarding();
            Test.stopTest();
            
            // Verify welcome step has content
            UserOnboardingController.OnboardingStep welcomeStep = result.onboardingSteps[0];
            Assert.areEqual(1, welcomeStep.stepContent.size(), 'Welcome step should have content');
            Assert.areEqual('Video', welcomeStep.stepContent[0].contentType, 'Welcome content should be video');
            Assert.isTrue(welcomeStep.stepContent[0].isRequired, 'Welcome video should be required');
            
            // Verify profile step has multiple content items
            UserOnboardingController.OnboardingStep profileStep = result.onboardingSteps[1];
            Assert.areEqual(2, profileStep.stepContent.size(), 'Profile step should have multiple content items');
            Assert.areEqual('Form', profileStep.stepContent[0].contentType, 'Profile content should be form');
            
            // Verify completion step
            UserOnboardingController.OnboardingStep completionStep = result.onboardingSteps[4];
            Assert.areEqual('complete', completionStep.stepId, 'Last step should be completion');
            Assert.areEqual(2, completionStep.stepContent.size(), 'Completion step should have content');
        }
    }
    
    // Helper method to create a test user
    private static User createTestUser() {
        return new User(
            Id = UserInfo.getUserId(),
            Username = 'testuser@omnistudio.test',
            Email = 'testuser@omnistudio.test',
            FirstName = 'Test',
            LastName = 'User'
        );
    }
}