/**
 * @description Test class for UserPerformanceTracker - targeting 90%+ code coverage
 * @author Claude AI OmniStudio Training  
 * @date 2025-08-12
 */
@IsTest
private class UserPerformanceTrackerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test user
        User testUser = new User(
            FirstName = 'Performance',
            LastName = 'TestUser',
            Email = 'perftest@example.com',
            Username = 'perftest@omnistudio.test',
            Alias = 'puser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Create test questions
        List<Question__c> questions = new List<Question__c>();
        questions.add(new Question__c(
            Topic__c = 'FlexCards',
            CertificationTrack__c = 'Consultant',
            Difficulty__c = 2,
            Active__c = true,
            QuestionText__c = 'FlexCard question',
            UsageCount__c = 0
        ));
        questions.add(new Question__c(
            Topic__c = 'OmniScripts',
            CertificationTrack__c = 'Consultant', 
            Difficulty__c = 3,
            Active__c = true,
            QuestionText__c = 'OmniScript question',
            UsageCount__c = 5
        ));
        insert questions;
        
        // Create user profile
        UserProfile__c profile = new UserProfile__c(
            User__c = testUser.Id,
            CurrentDifficulty__c = 2,
            PreferredLearningStyle__c = 'Visual',
            StudyHoursPerWeek__c = 8
        );
        insert profile;
    }
    
    @IsTest
    static void testGetUserPerformanceWithHistory() {
        User testUser = [SELECT Id FROM User WHERE Username = 'perftest@omnistudio.test' LIMIT 1];
        List<Question__c> questions = [SELECT Id FROM Question__c LIMIT 2];
        
        // Create answer history
        List<UserAnswer__c> answers = new List<UserAnswer__c>();
        answers.add(new UserAnswer__c(
            User__c = testUser.Id,
            Question__c = questions[0].Id,
            IsCorrect__c = true,
            ResponseTime__c = 45,
            AnsweredDate__c = DateTime.now().addHours(-1)
        ));
        answers.add(new UserAnswer__c(
            User__c = testUser.Id,
            Question__c = questions[1].Id,
            IsCorrect__c = false,
            ResponseTime__c = 120,
            AnsweredDate__c = DateTime.now().addHours(-2)
        ));
        insert answers;
        
        Test.startTest();
        UserPerformanceData performance = UserPerformanceTracker.getUserPerformance(testUser.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, performance, 'Performance data should not be null');
        System.assertEquals(2, performance.getTotalQuestionsAnswered(), 'Should have 2 answered questions');
        System.assertEquals(0.5, performance.getOverallPerformance(), 'Overall performance should be 50%');
    }
    
    @IsTest
    static void testGetUserPerformanceNewUser() {
        User newUser = new User(
            FirstName = 'New',
            LastName = 'PerformanceUser',
            Email = 'newperf@example.com',
            Username = 'newperf@omnistudio.test',
            Alias = 'npuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert newUser;
        
        Test.startTest();
        UserPerformanceData performance = UserPerformanceTracker.getUserPerformance(newUser.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, performance, 'Performance data should not be null');
        System.assertEquals(0, performance.getTotalQuestionsAnswered(), 'New user should have 0 answered questions');
        System.assertEquals(2, performance.getCurrentDifficulty(), 'New user should start at difficulty 2');
    }
    
    @IsTest
    static void testRecordAnswerSuccess() {
        User testUser = [SELECT Id FROM User WHERE Username = 'perftest@omnistudio.test' LIMIT 1];
        Question__c question = [SELECT Id FROM Question__c LIMIT 1];
        
        Test.startTest();
        UserPerformanceTracker.recordAnswer(testUser.Id, question.Id, true, 60);
        Test.stopTest();
        
        // Verify answer was recorded
        List<UserAnswer__c> answers = [
            SELECT IsCorrect__c, ResponseTime__c 
            FROM UserAnswer__c 
            WHERE User__c = :testUser.Id AND Question__c = :question.Id
        ];
        System.assertEquals(1, answers.size(), 'Answer should be recorded');
        System.assertEquals(true, answers[0].IsCorrect__c, 'Answer should be marked correct');
        System.assertEquals(60, answers[0].ResponseTime__c, 'Response time should match');
        
        // Verify question usage was updated
        Question__c updatedQuestion = [SELECT UsageCount__c, LastUsed__c FROM Question__c WHERE Id = :question.Id];
        System.assertEquals(1, updatedQuestion.UsageCount__c, 'Usage count should be incremented');
        System.assertNotEquals(null, updatedQuestion.LastUsed__c, 'Last used should be updated');
    }
    
    @IsTest
    static void testRecordAnswerErrorHandling() {
        Test.startTest();
        // Test with invalid IDs - should not throw exception
        UserPerformanceTracker.recordAnswer(null, null, true, 60);
        Test.stopTest();
        
        // Should complete without error (errors are logged, not thrown)
        System.assert(true, 'Method should complete without throwing exceptions');
    }
    
    @IsTest 
    static void testPerformanceSummaryUpdate() {
        User testUser = [SELECT Id FROM User WHERE Username = 'perftest@omnistudio.test' LIMIT 1];
        Question__c question = [SELECT Id FROM Question__c LIMIT 1];
        
        Test.startTest();
        // Record multiple answers to trigger summary calculation
        for (Integer i = 0; i < 5; i++) {
            UserPerformanceTracker.recordAnswer(testUser.Id, question.Id, i % 2 == 0, 45 + i);
        }
        Test.stopTest();
        
        // Verify performance summary was created/updated
        List<UserPerformanceSummary__c> summaries = [
            SELECT RecentAccuracyRate__c, TotalQuestionsAnswered__c 
            FROM UserPerformanceSummary__c 
            WHERE User__c = :testUser.Id
        ];
        
        System.assertEquals(1, summaries.size(), 'Performance summary should be created');
        System.assert(summaries[0].RecentAccuracyRate__c >= 0, 'Accuracy rate should be calculated');
        System.assert(summaries[0].TotalQuestionsAnswered__c > 0, 'Question count should be tracked');
    }
    
    @IsTest
    static void testGetUserProfileExisting() {
        User testUser = [SELECT Id FROM User WHERE Username = 'perftest@omnistudio.test' LIMIT 1];
        
        Test.startTest();
        UserPerformanceData performance = UserPerformanceTracker.getUserPerformance(testUser.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, performance, 'Performance data should not be null');
        System.assertEquals(2, performance.getCurrentDifficulty(), 'Should use existing profile difficulty');
    }
    
    @IsTest
    static void testUpdateQuestionUsageErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Username = 'perftest@omnistudio.test' LIMIT 1];
        
        Test.startTest();
        // Try to record answer for non-existent question
        UserPerformanceTracker.recordAnswer(testUser.Id, UserInfo.getUserId(), true, 60); // Invalid question ID
        Test.stopTest();
        
        // Should complete without throwing exception
        System.assert(true, 'Method should handle invalid question ID gracefully');
    }
}