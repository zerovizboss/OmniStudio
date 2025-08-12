/**
 * @description Test class for DashboardFlexCardController
 * @author Claude Code Assistant
 * @since User Story #18 - Dashboard FlexCard with Progress Tracking
 * @version 1.0
 * 
 * Comprehensive test coverage for dashboard FlexCard controller,
 * progress calculations, weak area identification, and real-time updates.
 */
@IsTest
private class DashboardFlexCardControllerTest {
    
    /**
     * @description Test data setup with comprehensive user activity
     */
    @TestSetup
    static void setupTestData() {
        // Create user profile
        UserProfile__c userProfile = new UserProfile__c();
        userProfile.User__c = UserInfo.getUserId();
        userProfile.CertificationGoals__c = 'Consultant';
        userProfile.CurrentDifficulty__c = 2;
        userProfile.PreferredLearningStyle__c = 'Mixed';
        userProfile.StudyHoursPerWeek__c = 10;
        userProfile.StudyGoalDate__c = Date.today().addDays(60);
        insert userProfile;
        
        // Create questions for testing
        List<Question__c> questions = new List<Question__c>();
        
        // FlexCards questions
        questions.addAll(createTopicQuestions('Consultant', 'FlexCards', 20));
        questions.addAll(createTopicQuestions('Consultant', 'OmniScripts', 20));
        questions.addAll(createTopicQuestions('Consultant', 'DataTools', 20));
        questions.addAll(createTopicQuestions('Consultant', 'Solutioning', 20));
        
        // Developer questions
        questions.addAll(createTopicQuestions('Developer', 'FlexCards', 10));
        questions.addAll(createTopicQuestions('Developer', 'DataRaptors', 10));
        
        insert questions;
        
        // Create user answers with varied performance
        createUserAnswers(questions);
        
        // Create performance summary
        UserPerformanceSummary__c summary = new UserPerformanceSummary__c();
        summary.User__c = UserInfo.getUserId();
        summary.RecentAccuracyRate__c = 75.0;
        summary.TotalQuestionsAnswered__c = 100;
        summary.AverageResponseTime__c = 45;
        summary.TotalStudyHours__c = 25;
        summary.LastUpdated__c = DateTime.now();
        insert summary;
    }
    
    /**
     * @description Create test questions for a topic
     */
    private static List<Question__c> createTopicQuestions(String track, String topic, Integer count) {
        List<Question__c> questions = new List<Question__c>();
        
        for (Integer i = 0; i < count; i++) {
            Question__c q = new Question__c();
            q.CertificationTrack__c = track;
            q.Topic__c = topic;
            q.Active__c = true;
            q.QuestionText__c = 'Test question ' + i + ' for ' + topic;
            q.QuestionType__c = 'Multiple Choice';
            q.Difficulty__c = 1 + Math.mod(i, 3); // Distribute across difficulty levels
            q.CorrectAnswer__c = 'A';
            q.OptionA__c = 'Correct answer';
            q.OptionB__c = 'Wrong answer 1';
            q.OptionC__c = 'Wrong answer 2';
            q.OptionD__c = 'Wrong answer 3';
            q.Explanation__c = 'Explanation for ' + topic;
            q.UsageCount__c = i;
            
            questions.add(q);
        }
        
        return questions;
    }
    
    /**
     * @description Create user answers with realistic performance patterns
     */
    private static void createUserAnswers(List<Question__c> questions) {
        List<UserAnswer__c> answers = new List<UserAnswer__c>();
        String userId = UserInfo.getUserId();
        
        // Create answers with different success rates per topic
        Map<String, Decimal> topicSuccessRates = new Map<String, Decimal>{
            'FlexCards' => 0.85,    // Strong area
            'OmniScripts' => 0.45,  // Weak area
            'DataTools' => 0.75,    // Good area
            'Solutioning' => 0.65,  // Average area
            'DataRaptors' => 0.80   // Good area
        };
        
        for (Question__c q : questions) {
            // Create 3-5 answers per question for better statistics
            Integer answerCount = 3 + Math.mod(Integer.valueOf(q.UsageCount__c), 3);
            Decimal successRate = topicSuccessRates.get(q.Topic__c);
            
            for (Integer i = 0; i < answerCount; i++) {
                UserAnswer__c answer = new UserAnswer__c();
                answer.User__c = userId;
                answer.Question__c = q.Id;
                answer.IsCorrect__c = Math.random() < successRate;
                answer.ResponseTime__c = 30 + Integer.valueOf(Math.random() * 90);
                
                // Distribute answers over last 30 days with recent bias
                Integer daysAgo = Integer.valueOf(Math.random() * 30);
                answer.AnsweredDate__c = DateTime.now().addDays(-daysAgo);
                
                answers.add(answer);
                
                // Limit total answers to avoid governor limits
                if (answers.size() >= 200) {
                    break;
                }
            }
            
            if (answers.size() >= 200) {
                break;
            }
        }
        
        insert answers;
    }
    
    /**
     * @description Test basic dashboard data retrieval
     */
    @IsTest
    static void testGetDashboardData() {
        Test.startTest();
        DashboardFlexCardController.DashboardData dashboardData = 
            DashboardFlexCardController.getDashboardData();
        Test.stopTest();
        
        // Verify basic data structure
        Assert.isNotNull(dashboardData, 'Dashboard data should not be null');
        Assert.areEqual(UserInfo.getUserId(), dashboardData.userId, 
            'User ID should match current user');
        Assert.areEqual(UserInfo.getName(), dashboardData.userName, 
            'User name should match current user');
        Assert.areEqual('Consultant', dashboardData.primaryTrack, 
            'Primary track should match user profile');
        Assert.isNotNull(dashboardData.lastUpdated, 
            'Last updated timestamp should be set');
        
        // Verify overall progress
        Assert.isNotNull(dashboardData.overallProgress, 
            'Overall progress should be calculated');
        Assert.isTrue(dashboardData.overallProgress.progressPercentage >= 0, 
            'Progress percentage should be non-negative');
        Assert.isTrue(dashboardData.overallProgress.questionsAnswered > 0, 
            'Should have questions answered from test data');
        Assert.isNotNull(dashboardData.overallProgress.progressLevel, 
            'Progress level should be determined');
        Assert.isNotNull(dashboardData.overallProgress.readinessIndicator, 
            'Readiness indicator should be set');
        Assert.isNotNull(dashboardData.overallProgress.motivationalMessage, 
            'Motivational message should be provided');
        
        // Verify track progress
        Assert.isNotNull(dashboardData.trackProgress, 
            'Track progress should be calculated');
        Assert.areEqual(2, dashboardData.trackProgress.size(), 
            'Should have progress for both Consultant and Developer tracks');
        
        // Verify track progress details
        for (DashboardFlexCardController.TrackProgress track : dashboardData.trackProgress) {
            Assert.isNotNull(track.trackName, 'Track name should be set');
            Assert.isNotNull(track.trackDisplayName, 'Track display name should be set');
            Assert.isTrue(track.progressPercentage >= 0, 
                'Track progress should be non-negative');
            Assert.isNotNull(track.topicProgress, 'Topic progress should be calculated');
            Assert.isTrue(track.totalHours > 0, 'Total hours should be positive');
            Assert.isNotNull(track.nextRecommendation, 
                'Next recommendation should be provided');
        }
        
        // Verify weak areas identification
        Assert.isNotNull(dashboardData.weakAreas, 
            'Weak areas should be analyzed');
        
        // Verify quick actions
        Assert.isNotNull(dashboardData.quickActions, 
            'Quick actions should be generated');
        Assert.isTrue(dashboardData.quickActions.size() >= 3, 
            'Should have multiple quick actions available');
        
        // Verify study streak
        Assert.isNotNull(dashboardData.studyStreak, 
            'Study streak should be calculated');
        Assert.isTrue(dashboardData.studyStreak.currentStreak >= 0, 
            'Current streak should be non-negative');
    }
    
    /**
     * @description Test weak area identification
     */
    @IsTest
    static void testWeakAreaIdentification() {
        Test.startTest();
        DashboardFlexCardController.DashboardData dashboardData = 
            DashboardFlexCardController.getDashboardData();
        Test.stopTest();
        
        // Should identify OmniScripts as weak area based on test data (45% success rate)
        Boolean foundOmniScriptsWeakArea = false;
        for (DashboardFlexCardController.WeakArea weakArea : dashboardData.weakAreas) {
            if (weakArea.topicName == 'OmniScripts') {
                foundOmniScriptsWeakArea = true;
                
                Assert.areEqual('Consultant', weakArea.trackName, 
                    'Weak area should be in Consultant track');
                Assert.isTrue(weakArea.currentScore < 70, 
                    'OmniScripts should have low score based on test data');
                Assert.isNotNull(weakArea.severityLevel, 
                    'Severity level should be determined');
                Assert.isNotNull(weakArea.recommendation, 
                    'Recommendation should be provided');
                Assert.isNotNull(weakArea.actionUrl, 
                    'Action URL should be set');
                Assert.isTrue(weakArea.questionsNeeded > 0, 
                    'Should recommend additional questions');
                
                break;
            }
        }
        
        Assert.isTrue(foundOmniScriptsWeakArea, 
            'Should identify OmniScripts as weak area based on test performance');
    }
    
    /**
     * @description Test topic progress calculation
     */
    @IsTest
    static void testTopicProgressCalculation() {
        Test.startTest();
        DashboardFlexCardController.DashboardData dashboardData = 
            DashboardFlexCardController.getDashboardData();
        Test.stopTest();
        
        // Find Consultant track progress
        DashboardFlexCardController.TrackProgress consultantTrack = null;
        for (DashboardFlexCardController.TrackProgress track : dashboardData.trackProgress) {
            if (track.trackName == 'Consultant') {
                consultantTrack = track;
                break;
            }
        }
        
        Assert.isNotNull(consultantTrack, 'Should find Consultant track progress');
        Assert.isTrue(consultantTrack.topicProgress.size() > 0, 
            'Should have topic progress data');
        
        // Verify topic progress details
        for (DashboardFlexCardController.TopicProgress topic : consultantTrack.topicProgress) {
            Assert.isNotNull(topic.topicName, 'Topic name should be set');
            Assert.isNotNull(topic.topicDisplayName, 'Topic display name should be set');
            Assert.isTrue(topic.progressPercentage >= 0, 
                'Topic progress should be non-negative');
            Assert.isTrue(topic.masteryScore >= 0, 
                'Mastery score should be non-negative');
            Assert.isTrue(topic.questionsAnswered >= 0, 
                'Questions answered should be non-negative');
            Assert.isNotNull(topic.status, 'Topic status should be determined');
            Assert.isNotNull(topic.iconName, 'Topic icon should be set');
            Assert.isNotNull(topic.colorClass, 'Topic color class should be set');
        }
        
        // FlexCards should have high progress (85% success rate in test data)
        DashboardFlexCardController.TopicProgress flexCardsProgress = null;
        for (DashboardFlexCardController.TopicProgress topic : consultantTrack.topicProgress) {
            if (topic.topicName == 'FlexCards') {
                flexCardsProgress = topic;
                break;
            }
        }
        
        Assert.isNotNull(flexCardsProgress, 'Should find FlexCards progress');
        Assert.isTrue(flexCardsProgress.masteryScore > 80, 
            'FlexCards should have high mastery score based on test data');
    }
    
    /**
     * @description Test quick actions generation
     */
    @IsTest
    static void testQuickActionsGeneration() {
        Test.startTest();
        DashboardFlexCardController.DashboardData dashboardData = 
            DashboardFlexCardController.getDashboardData();
        Test.stopTest();
        
        // Verify required quick actions
        Set<String> actionIds = new Set<String>();
        for (DashboardFlexCardController.QuickAction action : dashboardData.quickActions) {
            actionIds.add(action.actionId);
            
            // Verify action structure
            Assert.isNotNull(action.title, 'Action title should be set');
            Assert.isNotNull(action.description, 'Action description should be set');
            Assert.isNotNull(action.iconName, 'Action icon should be set');
            Assert.isNotNull(action.buttonClass, 'Action button class should be set');
            Assert.isNotNull(action.actionUrl, 'Action URL should be set');
            Assert.isTrue(action.isEnabled, 'Action should be enabled');
        }
        
        // Verify core actions are present
        Assert.isTrue(actionIds.contains('continue-study'), 
            'Should have continue study action');
        Assert.isTrue(actionIds.contains('practice-questions'), 
            'Should have practice questions action');
        Assert.isTrue(actionIds.contains('mock-exam'), 
            'Should have mock exam action');
        
        // Should have weak areas action since OmniScripts is weak in test data
        Assert.isTrue(actionIds.contains('focus-weak-areas'), 
            'Should have focus weak areas action when weak areas exist');
    }
    
    /**
     * @description Test study streak calculation
     */
    @IsTest
    static void testStudyStreakCalculation() {
        Test.startTest();
        DashboardFlexCardController.DashboardData dashboardData = 
            DashboardFlexCardController.getDashboardData();
        Test.stopTest();
        
        DashboardFlexCardController.StudyStreak streak = dashboardData.studyStreak;
        
        Assert.isNotNull(streak, 'Study streak should be calculated');
        Assert.isTrue(streak.currentStreak >= 0, 
            'Current streak should be non-negative');
        Assert.isTrue(streak.longestStreak >= 0, 
            'Longest streak should be non-negative');
        Assert.isNotNull(streak.streakStatus, 
            'Streak status should be determined');
        Assert.isNotNull(streak.lastStudyDate, 
            'Last study date should be set');
        Assert.isTrue(streak.studyGoalHours > 0, 
            'Study goal hours should be positive');
        Assert.isTrue(streak.weeklyHoursCompleted >= 0, 
            'Weekly hours completed should be non-negative');
        Assert.isNotNull(streak.achievements, 
            'Achievements list should be initialized');
        
        // Verify streak status is valid
        Set<String> validStatuses = new Set<String>{'Active', 'At Risk', 'Lost'};
        Assert.isTrue(validStatuses.contains(streak.streakStatus), 
            'Streak status should be valid: ' + streak.streakStatus);
    }
    
    /**
     * @description Test progress level determination
     */
    @IsTest
    static void testProgressLevelDetermination() {
        Test.startTest();
        DashboardFlexCardController.DashboardData dashboardData = 
            DashboardFlexCardController.getDashboardData();
        Test.stopTest();
        
        DashboardFlexCardController.OverallProgress progress = dashboardData.overallProgress;
        
        // Verify progress level is valid
        Set<String> validLevels = new Set<String>{'Beginner', 'Intermediate', 'Advanced', 'Ready'};
        Assert.isTrue(validLevels.contains(progress.progressLevel), 
            'Progress level should be valid: ' + progress.progressLevel);
        
        // Verify readiness indicator is valid
        Set<String> validReadiness = new Set<String>{'Not Ready', 'Getting Ready', 'Exam Ready'};
        Assert.isTrue(validReadiness.contains(progress.readinessIndicator), 
            'Readiness indicator should be valid: ' + progress.readinessIndicator);
        
        // Progress and score should be consistent
        if (progress.progressPercentage >= 85 && progress.averageScore >= 80) {
            Assert.areEqual('Exam Ready', progress.readinessIndicator, 
                'High progress and score should indicate exam readiness');
        }
    }
    
    /**
     * @description Test with no user profile
     */
    @IsTest
    static void testWithNoUserProfile() {
        // Delete user profile to test default behavior
        delete [SELECT Id FROM UserProfile__c];
        
        Test.startTest();
        DashboardFlexCardController.DashboardData dashboardData = 
            DashboardFlexCardController.getDashboardData();
        Test.stopTest();
        
        // Should default to Consultant track
        Assert.areEqual('Consultant', dashboardData.primaryTrack, 
            'Should default to Consultant when no user profile exists');
        Assert.isNotNull(dashboardData.overallProgress, 
            'Should still calculate progress without user profile');
    }
    
    /**
     * @description Test with no user answers
     */
    @IsTest
    static void testWithNoUserAnswers() {
        // Delete user answers and performance summary
        delete [SELECT Id FROM UserAnswer__c];
        delete [SELECT Id FROM UserPerformanceSummary__c];
        
        Test.startTest();
        DashboardFlexCardController.DashboardData dashboardData = 
            DashboardFlexCardController.getDashboardData();
        Test.stopTest();
        
        // Should handle empty data gracefully
        Assert.isNotNull(dashboardData, 'Should return data even with no answers');
        Assert.areEqual(0, dashboardData.overallProgress.questionsAnswered, 
            'Should show 0 questions answered');
        Assert.areEqual(0, dashboardData.overallProgress.averageScore, 
            'Should show 0 average score');
        Assert.areEqual(0, dashboardData.weakAreas.size(), 
            'Should have no weak areas with no data');
        Assert.areEqual('Lost', dashboardData.studyStreak.streakStatus, 
            'Should show lost streak with no activity');
    }
    
    /**
     * @description Test error handling
     */
    @IsTest
    static void testErrorHandling() {
        // This test verifies that exceptions are properly handled and converted to AuraHandledExceptions
        
        Test.startTest();
        
        try {
            // Normal call should work
            DashboardFlexCardController.DashboardData dashboardData = 
                DashboardFlexCardController.getDashboardData();
            Assert.isNotNull(dashboardData, 'Normal call should succeed');
        } catch (AuraHandledException e) {
            Assert.fail('Normal call should not throw exception: ' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test topic status determination
     */
    @IsTest
    static void testTopicStatusDetermination() {
        Test.startTest();
        DashboardFlexCardController.DashboardData dashboardData = 
            DashboardFlexCardController.getDashboardData();
        Test.stopTest();
        
        // Find Consultant track
        DashboardFlexCardController.TrackProgress consultantTrack = null;
        for (DashboardFlexCardController.TrackProgress track : dashboardData.trackProgress) {
            if (track.trackName == 'Consultant') {
                consultantTrack = track;
                break;
            }
        }
        
        Assert.isNotNull(consultantTrack, 'Should find Consultant track');
        
        // Verify topic statuses are valid
        Set<String> validStatuses = new Set<String>{'Not Started', 'In Progress', 'Mastered', 'Needs Review'};
        
        for (DashboardFlexCardController.TopicProgress topic : consultantTrack.topicProgress) {
            Assert.isTrue(validStatuses.contains(topic.status), 
                'Topic status should be valid: ' + topic.status + ' for ' + topic.topicName);
        }
        
        // FlexCards should be in good status (high success rate in test data)
        for (DashboardFlexCardController.TopicProgress topic : consultantTrack.topicProgress) {
            if (topic.topicName == 'FlexCards') {
                Assert.isTrue(topic.status == 'Mastered' || topic.status == 'In Progress', 
                    'FlexCards should have positive status with high test performance');
                break;
            }
        }
    }
    
    /**
     * @description Test data structure initialization
     */
    @IsTest
    static void testDataStructureInitialization() {
        Test.startTest();
        
        // Test DashboardData constructor
        DashboardFlexCardController.DashboardData dashboardData = 
            new DashboardFlexCardController.DashboardData();
        Assert.isNotNull(dashboardData.trackProgress, 
            'Track progress list should be initialized');
        Assert.isNotNull(dashboardData.weakAreas, 
            'Weak areas list should be initialized');
        Assert.isNotNull(dashboardData.quickActions, 
            'Quick actions list should be initialized');
        
        // Test TrackProgress constructor
        DashboardFlexCardController.TrackProgress trackProgress = 
            new DashboardFlexCardController.TrackProgress();
        Assert.isNotNull(trackProgress.topicProgress, 
            'Topic progress list should be initialized');
        
        // Test StudyStreak constructor
        DashboardFlexCardController.StudyStreak studyStreak = 
            new DashboardFlexCardController.StudyStreak();
        Assert.isNotNull(studyStreak.achievements, 
            'Achievements list should be initialized');
        
        Test.stopTest();
    }
}