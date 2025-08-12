/**
 * @description Test class for ExamSelectionController
 * @author Claude Code Assistant
 * @since User Story #19 - Exam Selection FlexCards
 * @version 1.0
 * 
 * Comprehensive test coverage for exam selection FlexCards controller,
 * exam information display, user recommendations, and analytics tracking.
 */
@IsTest
private class ExamSelectionControllerTest {
    
    /**
     * @description Test data setup with user profiles and progress
     */
    @TestSetup
    static void setupTestData() {
        // Create user profiles with different preferences
        List<UserProfile__c> userProfiles = new List<UserProfile__c>();
        
        // Consultant-focused user
        UserProfile__c consultantUser = new UserProfile__c();
        consultantUser.User__c = UserInfo.getUserId();
        consultantUser.CertificationGoals__c = 'Consultant';
        consultantUser.CurrentDifficulty__c = 2;
        consultantUser.PreferredLearningStyle__c = 'Visual';
        consultantUser.StudyHoursPerWeek__c = 12;
        consultantUser.StudyGoalDate__c = Date.today().addDays(90);
        userProfiles.add(consultantUser);
        
        insert userProfiles;
        
        // Create sample questions for progress tracking
        List<Question__c> questions = new List<Question__c>();
        
        // Consultant questions
        questions.addAll(createExamQuestions('Consultant', 'FlexCards', 15));
        questions.addAll(createExamQuestions('Consultant', 'OmniScripts', 15));
        questions.addAll(createExamQuestions('Consultant', 'DataTools', 10));
        questions.addAll(createExamQuestions('Consultant', 'Solutioning', 10));
        
        // Developer questions  
        questions.addAll(createExamQuestions('Developer', 'FlexCards', 10));
        questions.addAll(createExamQuestions('Developer', 'OmniScripts', 10));
        questions.addAll(createExamQuestions('Developer', 'DataRaptors', 10));
        questions.addAll(createExamQuestions('Developer', 'IntegrationProcedures', 10));
        
        insert questions;
        
        // Create user answers to establish some progress
        createUserAnswers(questions);
        
        // Create performance summary
        UserPerformanceSummary__c summary = new UserPerformanceSummary__c();
        summary.User__c = UserInfo.getUserId();
        summary.RecentAccuracyRate__c = 68.0;
        summary.TotalQuestionsAnswered__c = 45;
        summary.AverageResponseTime__c = 38;
        summary.TotalStudyHours__c = 15;
        summary.LastUpdated__c = DateTime.now();
        insert summary;
    }
    
    /**
     * @description Create test questions for exam topics
     */
    private static List<Question__c> createExamQuestions(String track, String topic, Integer count) {
        List<Question__c> questions = new List<Question__c>();
        
        for (Integer i = 0; i < count; i++) {
            Question__c q = new Question__c();
            q.CertificationTrack__c = track;
            q.Topic__c = topic;
            q.Active__c = true;
            q.QuestionText__c = 'Test question ' + i + ' for ' + track + ' ' + topic;
            q.QuestionType__c = 'Multiple Choice';
            q.Difficulty__c = 1 + Math.mod(i, 3);
            q.CorrectAnswer__c = 'A';
            q.OptionA__c = 'Correct answer for ' + topic;
            q.OptionB__c = 'Wrong answer 1';
            q.OptionC__c = 'Wrong answer 2';
            q.OptionD__c = 'Wrong answer 3';
            q.Explanation__c = 'Explanation for ' + topic + ' question';
            q.UsageCount__c = i + 5;
            
            questions.add(q);
        }
        
        return questions;
    }
    
    /**
     * @description Create user answers with varied performance
     */
    private static void createUserAnswers(List<Question__c> questions) {
        List<UserAnswer__c> answers = new List<UserAnswer__c>();
        String userId = UserInfo.getUserId();
        
        // Answer subset of questions with moderate success rate
        Integer questionCount = 0;
        for (Question__c q : questions) {
            if (questionCount >= 50) { // Limit to avoid governor limits
                break;
            }
            
            UserAnswer__c answer = new UserAnswer__c();
            answer.User__c = userId;
            answer.Question__c = q.Id;
            answer.IsCorrect__c = Math.random() < 0.68; // 68% success rate
            answer.ResponseTime__c = 25 + Integer.valueOf(Math.random() * 60);
            answer.AnsweredDate__c = DateTime.now().addDays(-Integer.valueOf(Math.random() * 14));
            
            answers.add(answer);
            questionCount++;
        }
        
        insert answers;
    }
    
    /**
     * @description Test basic exam selection data retrieval
     */
    @IsTest
    static void testGetExamSelectionData() {
        Test.startTest();
        ExamSelectionController.ExamSelectionData examData = 
            ExamSelectionController.getExamSelectionData();
        Test.stopTest();
        
        // Verify basic data structure
        Assert.isNotNull(examData, 'Exam selection data should not be null');
        Assert.areEqual(UserInfo.getUserId(), examData.currentUserId, 
            'Current user ID should be set');
        Assert.isNotNull(examData.lastUpdated, 
            'Last updated timestamp should be set');
        
        // Verify available exams
        Assert.isNotNull(examData.availableExams, 
            'Available exams list should be initialized');
        Assert.areEqual(2, examData.availableExams.size(), 
            'Should have both Consultant and Developer exams');
        
        // Verify exam details
        ExamSelectionController.ExamInfo consultantExam = null;
        ExamSelectionController.ExamInfo developerExam = null;
        
        for (ExamSelectionController.ExamInfo exam : examData.availableExams) {
            if (exam.examId == 'Consultant') {
                consultantExam = exam;
            } else if (exam.examId == 'Developer') {
                developerExam = exam;
            }
        }
        
        Assert.isNotNull(consultantExam, 'Should find Consultant exam');
        Assert.isNotNull(developerExam, 'Should find Developer exam');
        
        // Verify user recommendation
        Assert.isNotNull(examData.userRecommendation, 
            'User recommendation should be provided');
        Assert.isNotNull(examData.userRecommendation.recommendedExam, 
            'Should recommend an exam');
        Assert.isTrue(examData.hasExistingProgress, 
            'Should detect existing user progress from setup data');
    }
    
    /**
     * @description Test Consultant exam information details
     */
    @IsTest
    static void testConsultantExamDetails() {
        Test.startTest();
        ExamSelectionController.ExamSelectionData examData = 
            ExamSelectionController.getExamSelectionData();
        Test.stopTest();
        
        ExamSelectionController.ExamInfo consultantExam = null;
        for (ExamSelectionController.ExamInfo exam : examData.availableExams) {
            if (exam.examId == 'Consultant') {
                consultantExam = exam;
                break;
            }
        }
        
        Assert.isNotNull(consultantExam, 'Should find Consultant exam');
        
        // Verify basic information
        Assert.areEqual('Consultant', consultantExam.examId, 
            'Exam ID should be Consultant');
        Assert.areEqual('Salesforce OmniStudio Consultant', consultantExam.examName, 
            'Exam name should be correct');
        Assert.isNotNull(consultantExam.description, 
            'Description should be provided');
        Assert.isNotNull(consultantExam.targetAudience, 
            'Target audience should be specified');
        
        // Verify exam details
        Assert.isNotNull(consultantExam.examDetails, 
            'Exam details should be provided');
        Assert.areEqual(60, consultantExam.examDetails.questionCount, 
            'Should have 60 questions');
        Assert.areEqual(105, consultantExam.examDetails.durationMinutes, 
            'Should be 105 minutes');
        Assert.areEqual(63.0, consultantExam.examDetails.passingScore, 
            'Should require 63% passing score');
        Assert.areEqual('63%', consultantExam.examDetails.passingScoreDisplay, 
            'Passing score display should be formatted');
        Assert.areEqual(200.0, consultantExam.examDetails.examCost, 
            'Should cost $200');
        Assert.areEqual('$200 USD', consultantExam.examDetails.examCostDisplay, 
            'Cost display should be formatted');
        
        // Verify prerequisites
        Assert.isNotNull(consultantExam.prerequisites, 
            'Prerequisites should be listed');
        Assert.isTrue(consultantExam.prerequisites.size() > 0, 
            'Should have prerequisites');
        
        // Verify experience level
        Assert.isNotNull(consultantExam.experienceLevel, 
            'Experience level should be specified');
        Assert.areEqual(6, consultantExam.experienceLevel.minimumMonths, 
            'Should require minimum 6 months experience');
        Assert.areEqual(12, consultantExam.experienceLevel.recommendedMonths, 
            'Should recommend 12 months experience');
        Assert.isNotNull(consultantExam.experienceLevel.requiredSkills, 
            'Required skills should be listed');
        Assert.isTrue(consultantExam.experienceLevel.requiredSkills.size() > 0, 
            'Should have required skills');
        
        // Verify visual styling (Blue theme)
        Assert.isNotNull(consultantExam.styling, 
            'Visual styling should be provided');
        Assert.areEqual('#0176D3', consultantExam.styling.primaryColor, 
            'Should use Salesforce blue as primary color');
        Assert.areEqual('utility:solution', consultantExam.styling.iconName, 
            'Should use solution icon');
        Assert.areEqual('consultant-gradient', consultantExam.styling.gradientClass, 
            'Should use consultant gradient class');
        
        // Verify call to actions
        Assert.isNotNull(consultantExam.callToActions, 
            'Call to actions should be provided');
        Assert.areEqual(2, consultantExam.callToActions.size(), 
            'Should have 2 call to action buttons');
        
        Boolean hasBeginStudyPath = false;
        Boolean hasPracticeExam = false;
        for (ExamSelectionController.CallToAction cta : consultantExam.callToActions) {
            if (cta.actionId == 'begin-consultant-study') {
                hasBeginStudyPath = true;
                Assert.areEqual('Begin Study Path', cta.label, 
                    'Begin study path label should be correct');
                Assert.isTrue(cta.isPrimary, 
                    'Begin study path should be primary action');
            } else if (cta.actionId == 'practice-consultant-exam') {
                hasPracticeExam = true;
                Assert.areEqual('Take Practice Exam', cta.label, 
                    'Practice exam label should be correct');
                Assert.isFalse(cta.isPrimary, 
                    'Practice exam should be secondary action');
            }
        }
        Assert.isTrue(hasBeginStudyPath, 'Should have begin study path action');
        Assert.isTrue(hasPracticeExam, 'Should have practice exam action');
        
        // Verify career outcomes
        Assert.isNotNull(consultantExam.careerOutcome, 
            'Career outcome should be provided');
        Assert.areEqual('OmniStudio Solution Consultant', consultantExam.careerOutcome.primaryRole, 
            'Primary role should be specified');
        Assert.isNotNull(consultantExam.careerOutcome.careerPaths, 
            'Career paths should be listed');
        Assert.isTrue(consultantExam.careerOutcome.careerPaths.size() > 0, 
            'Should have career paths');
        Assert.areEqual('$85,000 - $130,000 annually', consultantExam.careerOutcome.salaryRange, 
            'Salary range should be specified');
        
        // Verify key topics
        Assert.isNotNull(consultantExam.keyTopics, 
            'Key topics should be listed');
        Assert.areEqual(4, consultantExam.keyTopics.size(), 
            'Should have 4 key topics for Consultant track');
    }
    
    /**
     * @description Test Developer exam information details
     */
    @IsTest
    static void testDeveloperExamDetails() {
        Test.startTest();
        ExamSelectionController.ExamSelectionData examData = 
            ExamSelectionController.getExamSelectionData();
        Test.stopTest();
        
        ExamSelectionController.ExamInfo developerExam = null;
        for (ExamSelectionController.ExamInfo exam : examData.availableExams) {
            if (exam.examId == 'Developer') {
                developerExam = exam;
                break;
            }
        }
        
        Assert.isNotNull(developerExam, 'Should find Developer exam');
        
        // Verify basic information
        Assert.areEqual('Developer', developerExam.examId, 
            'Exam ID should be Developer');
        Assert.areEqual('Salesforce OmniStudio Developer', developerExam.examName, 
            'Exam name should be correct');
        Assert.isTrue(developerExam.description.contains('advanced'), 
            'Description should mention advanced development');
        Assert.isTrue(developerExam.targetAudience.contains('developers'), 
            'Target audience should mention developers');
        
        // Verify higher experience requirements than Consultant
        Assert.areEqual(12, developerExam.experienceLevel.minimumMonths, 
            'Should require minimum 12 months (more than Consultant)');
        Assert.areEqual(18, developerExam.experienceLevel.recommendedMonths, 
            'Should recommend 18 months experience');
        
        // Verify technical prerequisites
        Assert.isTrue(developerExam.prerequisites.contains('Salesforce Platform Developer I certification (required)'), 
            'Should require Platform Developer I certification');
        Assert.isTrue(developerExam.prerequisites.size() >= 4, 
            'Should have multiple technical prerequisites');
        
        // Verify visual styling (Green theme)
        Assert.areEqual('#4BCE2F', developerExam.styling.primaryColor, 
            'Should use success green as primary color');
        Assert.areEqual('utility:code', developerExam.styling.iconName, 
            'Should use code icon');
        Assert.areEqual('developer-gradient', developerExam.styling.gradientClass, 
            'Should use developer gradient class');
        
        // Verify technical focus in key topics
        Assert.isNotNull(developerExam.keyTopics, 
            'Key topics should be listed');
        Assert.areEqual(5, developerExam.keyTopics.size(), 
            'Should have 5 key topics for Developer track');
        
        Boolean hasAdvancedFlexCards = false;
        Boolean hasIntegrationProcedures = false;
        for (String topic : developerExam.keyTopics) {
            if (topic.contains('Advanced FlexCards')) {
                hasAdvancedFlexCards = true;
            }
            if (topic.contains('Integration Procedures')) {
                hasIntegrationProcedures = true;
            }
        }
        Assert.isTrue(hasAdvancedFlexCards, 'Should include Advanced FlexCards topic');
        Assert.isTrue(hasIntegrationProcedures, 'Should include Integration Procedures topic');
        
        // Verify higher salary range
        Assert.areEqual('$95,000 - $150,000 annually', developerExam.careerOutcome.salaryRange, 
            'Developer should have higher salary range than Consultant');
        Assert.areEqual('OmniStudio Technical Developer', developerExam.careerOutcome.primaryRole, 
            'Primary role should be technical');
    }
    
    /**
     * @description Test user recommendation logic
     */
    @IsTest
    static void testUserRecommendation() {
        Test.startTest();
        ExamSelectionController.ExamSelectionData examData = 
            ExamSelectionController.getExamSelectionData();
        Test.stopTest();
        
        ExamSelectionController.UserRecommendation recommendation = examData.userRecommendation;
        
        Assert.isNotNull(recommendation, 'User recommendation should be provided');
        Assert.isNotNull(recommendation.recommendedExam, 
            'Should recommend a specific exam');
        Assert.isNotNull(recommendation.reasonForRecommendation, 
            'Should provide reason for recommendation');
        Assert.isNotNull(recommendation.matchingFactors, 
            'Should list matching factors');
        Assert.isNotNull(recommendation.confidenceLevel, 
            'Should specify confidence level');
        Assert.isNotNull(recommendation.alternativeOption, 
            'Should provide alternative option');
        
        // Based on setup data, user profile has Consultant preference
        Assert.areEqual('Consultant', recommendation.recommendedExam, 
            'Should recommend Consultant based on user profile');
        Assert.areEqual('High', recommendation.confidenceLevel, 
            'Should have high confidence with profile data');
        Assert.areEqual('Developer', recommendation.alternativeOption, 
            'Should suggest Developer as alternative');
        Assert.isTrue(recommendation.matchingFactors.size() > 0, 
            'Should have matching factors');
        
        // Verify recommendation flags on exams
        for (ExamSelectionController.ExamInfo exam : examData.availableExams) {
            if (exam.examId == 'Consultant') {
                Assert.isTrue(exam.isRecommended, 
                    'Consultant exam should be marked as recommended');
            } else {
                Assert.isFalse(exam.isRecommended, 
                    'Developer exam should not be marked as recommended');
            }
        }
    }
    
    /**
     * @description Test recommendation for user with no profile
     */
    @IsTest
    static void testRecommendationWithoutProfile() {
        // Delete user profile to test default behavior
        delete [SELECT Id FROM UserProfile__c];
        
        Test.startTest();
        ExamSelectionController.ExamSelectionData examData = 
            ExamSelectionController.getExamSelectionData();
        Test.stopTest();
        
        ExamSelectionController.UserRecommendation recommendation = examData.userRecommendation;
        
        // Should default to Consultant for new users
        Assert.areEqual('Consultant', recommendation.recommendedExam, 
            'Should recommend Consultant by default for new users');
        Assert.areEqual('Medium', recommendation.confidenceLevel, 
            'Should have medium confidence without profile data');
        Assert.isTrue(recommendation.reasonForRecommendation.contains('starting point'), 
            'Should mention Consultant as good starting point');
        Assert.isTrue(recommendation.matchingFactors.size() > 0, 
            'Should provide default matching factors');
    }
    
    /**
     * @description Test existing progress detection
     */
    @IsTest
    static void testExistingProgressDetection() {
        Test.startTest();
        ExamSelectionController.ExamSelectionData examData = 
            ExamSelectionController.getExamSelectionData();
        Test.stopTest();
        
        Assert.isTrue(examData.hasExistingProgress, 
            'Should detect existing progress from setup data');
        
        // Test with no progress
        delete [SELECT Id FROM UserAnswer__c];
        delete [SELECT Id FROM UserProfile__c];
        
        Test.startTest();
        ExamSelectionController.ExamSelectionData examDataNoProgress = 
            ExamSelectionController.getExamSelectionData();
        Test.stopTest();
        
        Assert.isFalse(examDataNoProgress.hasExistingProgress, 
            'Should not detect progress when none exists');
    }
    
    /**
     * @description Test exam selection recording
     */
    @IsTest
    static void testRecordExamSelection() {
        Test.startTest();
        Boolean result1 = ExamSelectionController.recordExamSelection('Consultant', 'begin-study');
        Boolean result2 = ExamSelectionController.recordExamSelection('Developer', 'practice-exam');
        Test.stopTest();
        
        Assert.isTrue(result1, 'Should successfully record Consultant selection');
        Assert.isTrue(result2, 'Should successfully record Developer selection');
        
        // Test with invalid data
        Test.startTest();
        Boolean result3 = ExamSelectionController.recordExamSelection(null, null);
        Test.stopTest();
        
        Assert.isTrue(result3, 'Should handle null values gracefully');
    }
    
    /**
     * @description Test exam comparison functionality
     */
    @IsTest
    static void testGetExamComparison() {
        Test.startTest();
        Map<String, Object> comparison = ExamSelectionController.getExamComparison();
        Test.stopTest();
        
        Assert.isNotNull(comparison, 'Comparison data should be returned');
        Assert.isTrue(comparison.containsKey('consultant'), 
            'Should include consultant exam data');
        Assert.isTrue(comparison.containsKey('developer'), 
            'Should include developer exam data');
        Assert.isTrue(comparison.containsKey('sideBySideFeatures'), 
            'Should include comparison features list');
        
        List<String> features = (List<String>) comparison.get('sideBySideFeatures');
        Assert.isNotNull(features, 'Features list should be provided');
        Assert.isTrue(features.size() >= 5, 'Should have multiple comparison features');
        Assert.isTrue(features.contains('Experience Level'), 
            'Should include Experience Level comparison');
        Assert.isTrue(features.contains('Prerequisites'), 
            'Should include Prerequisites comparison');
        Assert.isTrue(features.contains('Career Outcomes'), 
            'Should include Career Outcomes comparison');
    }
    
    /**
     * @description Test error handling
     */
    @IsTest
    static void testErrorHandling() {
        Test.startTest();
        
        try {
            // Normal calls should work
            ExamSelectionController.ExamSelectionData examData = 
                ExamSelectionController.getExamSelectionData();
            Assert.isNotNull(examData, 'Normal call should succeed');
            
            Map<String, Object> comparison = ExamSelectionController.getExamComparison();
            Assert.isNotNull(comparison, 'Comparison call should succeed');
            
        } catch (AuraHandledException e) {
            Assert.fail('Normal calls should not throw exceptions: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test data structure initialization
     */
    @IsTest
    static void testDataStructureInitialization() {
        Test.startTest();
        
        // Test ExamSelectionData constructor
        ExamSelectionController.ExamSelectionData examData = 
            new ExamSelectionController.ExamSelectionData();
        Assert.isNotNull(examData.availableExams, 
            'Available exams list should be initialized');
        
        // Test ExamInfo constructor
        ExamSelectionController.ExamInfo examInfo = 
            new ExamSelectionController.ExamInfo();
        Assert.isNotNull(examInfo.prerequisites, 
            'Prerequisites list should be initialized');
        Assert.isNotNull(examInfo.callToActions, 
            'Call to actions list should be initialized');
        Assert.isNotNull(examInfo.keyTopics, 
            'Key topics list should be initialized');
        
        // Test ExperienceLevel constructor
        ExamSelectionController.ExperienceLevel expLevel = 
            new ExamSelectionController.ExperienceLevel();
        Assert.isNotNull(expLevel.requiredSkills, 
            'Required skills list should be initialized');
        Assert.isNotNull(expLevel.recommendedCertifications, 
            'Recommended certifications list should be initialized');
        
        // Test CareerOutcome constructor
        ExamSelectionController.CareerOutcome careerOutcome = 
            new ExamSelectionController.CareerOutcome();
        Assert.isNotNull(careerOutcome.careerPaths, 
            'Career paths list should be initialized');
        Assert.isNotNull(careerOutcome.nextCertifications, 
            'Next certifications list should be initialized');
        
        // Test UserRecommendation constructor
        ExamSelectionController.UserRecommendation recommendation = 
            new ExamSelectionController.UserRecommendation();
        Assert.isNotNull(recommendation.matchingFactors, 
            'Matching factors list should be initialized');
        
        Test.stopTest();
    }
    
    /**
     * @description Test Developer profile recommendation
     */
    @IsTest
    static void testDeveloperProfileRecommendation() {
        // Update user profile to prefer Developer track
        UserProfile__c userProfile = [SELECT Id FROM UserProfile__c LIMIT 1];
        userProfile.CertificationGoals__c = 'Developer';
        update userProfile;
        
        Test.startTest();
        ExamSelectionController.ExamSelectionData examData = 
            ExamSelectionController.getExamSelectionData();
        Test.stopTest();
        
        ExamSelectionController.UserRecommendation recommendation = examData.userRecommendation;
        
        Assert.areEqual('Developer', recommendation.recommendedExam, 
            'Should recommend Developer based on updated profile');
        Assert.areEqual('Consultant', recommendation.alternativeOption, 
            'Should suggest Consultant as alternative');
        Assert.areEqual('High', recommendation.confidenceLevel, 
            'Should have high confidence with profile data');
        
        // Verify recommendation flags
        for (ExamSelectionController.ExamInfo exam : examData.availableExams) {
            if (exam.examId == 'Developer') {
                Assert.isTrue(exam.isRecommended, 
                    'Developer exam should be marked as recommended');
            } else {
                Assert.isFalse(exam.isRecommended, 
                    'Consultant exam should not be marked as recommended');
            }
        }
    }
    
    /**
     * @description Test visual styling differentiation
     */
    @IsTest
    static void testVisualStylingDifferentiation() {
        Test.startTest();
        ExamSelectionController.ExamSelectionData examData = 
            ExamSelectionController.getExamSelectionData();
        Test.stopTest();
        
        ExamSelectionController.ExamInfo consultantExam = null;
        ExamSelectionController.ExamInfo developerExam = null;
        
        for (ExamSelectionController.ExamInfo exam : examData.availableExams) {
            if (exam.examId == 'Consultant') {
                consultantExam = exam;
            } else if (exam.examId == 'Developer') {
                developerExam = exam;
            }
        }
        
        // Verify distinct color schemes
        Assert.areNotEqual(consultantExam.styling.primaryColor, developerExam.styling.primaryColor, 
            'Primary colors should be different');
        Assert.areNotEqual(consultantExam.styling.secondaryColor, developerExam.styling.secondaryColor, 
            'Secondary colors should be different');
        Assert.areNotEqual(consultantExam.styling.iconName, developerExam.styling.iconName, 
            'Icons should be different');
        Assert.areNotEqual(consultantExam.styling.gradientClass, developerExam.styling.gradientClass, 
            'Gradient classes should be different');
        Assert.areNotEqual(consultantExam.styling.cardClass, developerExam.styling.cardClass, 
            'Card classes should be different');
        
        // Verify blue theme for Consultant
        Assert.isTrue(consultantExam.styling.primaryColor.contains('0176D3') || 
                     consultantExam.styling.primaryColor.contains('blue'), 
            'Consultant should use blue theme');
        
        // Verify green theme for Developer
        Assert.isTrue(developerExam.styling.primaryColor.contains('4BCE2F') || 
                     developerExam.styling.primaryColor.contains('green'), 
            'Developer should use green theme');
    }
    
    /**
     * @description Test URL and navigation paths
     */
    @IsTest
    static void testNavigationUrls() {
        Test.startTest();
        ExamSelectionController.ExamSelectionData examData = 
            ExamSelectionController.getExamSelectionData();
        Test.stopTest();
        
        for (ExamSelectionController.ExamInfo exam : examData.availableExams) {
            Assert.isNotNull(exam.studyPathUrl, 
                'Study path URL should be provided for ' + exam.examId);
            Assert.isNotNull(exam.practiceExamUrl, 
                'Practice exam URL should be provided for ' + exam.examId);
            
            // Verify URL patterns
            Assert.isTrue(exam.studyPathUrl.contains('/study/'), 
                'Study path URL should contain /study/ path');
            Assert.isTrue(exam.practiceExamUrl.contains('/practice/'), 
                'Practice exam URL should contain /practice/ path');
            Assert.isTrue(exam.studyPathUrl.toLowerCase().contains(exam.examId.toLowerCase()), 
                'Study path URL should include exam type');
            Assert.isTrue(exam.practiceExamUrl.toLowerCase().contains(exam.examId.toLowerCase()), 
                'Practice exam URL should include exam type');
            
            // Verify call to action URLs
            for (ExamSelectionController.CallToAction cta : exam.callToActions) {
                Assert.isNotNull(cta.actionUrl, 
                    'Call to action URL should be provided');
                Assert.isTrue(cta.actionUrl.startsWith('/'), 
                    'Action URL should be properly formatted');
            }
        }
    }
}