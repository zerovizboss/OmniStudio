/**
 * @description Test class for AdaptiveQuestionSelector - targeting 90%+ code coverage
 * @author Claude AI OmniStudio Training
 * @date 2025-08-12
 */
@IsTest
private class AdaptiveQuestionSelectorTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@omnistudio.test',
            Alias = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        // Create test questions for both certification tracks
        List<Question__c> questions = new List<Question__c>();
        
        // Consultant questions
        questions.add(createTestQuestion('FlexCards', 'Consultant', 2, 'MultipleChoice'));
        questions.add(createTestQuestion('OmniScripts', 'Consultant', 2, 'Scenario'));
        questions.add(createTestQuestion('DataTools', 'Consultant', 1, 'Practical'));
        questions.add(createTestQuestion('BestFitSolutioning', 'Consultant', 3, 'MultipleChoice'));
        
        // Developer questions  
        questions.add(createTestQuestion('FlexCards', 'Developer', 2, 'MultipleChoice'));
        questions.add(createTestQuestion('IntegrationProcedures', 'Developer', 3, 'Scenario'));
        questions.add(createTestQuestion('DataRaptors', 'Developer', 1, 'Practical'));
        questions.add(createTestQuestion('ExpressionSetsDecisionMatrices', 'Developer', 4, 'MultipleChoice'));
        
        insert questions;
        
        // Create user profile
        UserProfile__c profile = new UserProfile__c(
            User__c = testUser.Id,
            CurrentDifficulty__c = 2,
            PreferredLearningStyle__c = 'Mixed',
            StudyHoursPerWeek__c = 10,
            CertificationGoals__c = 'Consultant'
        );
        insert profile;
        
        // Create some user answers for performance history
        List<UserAnswer__c> answers = new List<UserAnswer__c>();
        for (Question__c question : questions) {
            if (question.CertificationTrack__c == 'Consultant') {
                answers.add(new UserAnswer__c(
                    User__c = testUser.Id,
                    Question__c = question.Id,
                    IsCorrect__c = Math.random() > 0.3, // 70% correct rate
                    ResponseTime__c = Integer.valueOf(Math.random() * 60 + 30),
                    AnsweredDate__c = DateTime.now().addDays(-Integer.valueOf(Math.random() * 30))
                ));
            }
        }
        insert answers;
    }
    
    @IsTest
    static void testSelectAdaptiveQuestionsSuccess() {
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@omnistudio.test' LIMIT 1];
        
        Test.startTest();
        List<String> selectedQuestions = AdaptiveQuestionSelector.selectAdaptiveQuestions(
            testUser.Id, 'Consultant', 5
        );
        Test.stopTest();
        
        System.assertNotEquals(null, selectedQuestions, 'Selected questions should not be null');
        System.assert(selectedQuestions.size() <= 5, 'Should not exceed requested question count');
        
        // Verify questions are from correct certification track
        List<Question__c> questions = [SELECT CertificationTrack__c FROM Question__c WHERE Id IN :selectedQuestions];
        for (Question__c question : questions) {
            System.assertEquals('Consultant', question.CertificationTrack__c, 'All questions should be for Consultant track');
        }
    }
    
    @IsTest
    static void testSelectAdaptiveQuestionsNewUser() {
        User newUser = new User(
            FirstName = 'New',
            LastName = 'User',
            Email = 'newuser@example.com',
            Username = 'newuser@omnistudio.test',
            Alias = 'nuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert newUser;
        
        Test.startTest();
        List<String> selectedQuestions = AdaptiveQuestionSelector.selectAdaptiveQuestions(
            newUser.Id, 'Developer', 3
        );
        Test.stopTest();
        
        System.assertNotEquals(null, selectedQuestions, 'Selected questions should not be null');
        System.assert(selectedQuestions.size() <= 3, 'Should not exceed requested question count');
    }
    
    @IsTest
    static void testSelectAdaptiveQuestionsErrorHandling() {
        Test.startTest();
        List<String> selectedQuestions = AdaptiveQuestionSelector.selectAdaptiveQuestions(
            null, 'InvalidTrack', 5
        );
        Test.stopTest();
        
        System.assertNotEquals(null, selectedQuestions, 'Should return fallback questions on error');
    }
    
    @IsTest
    static void testDeveloperTrackSelection() {
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@omnistudio.test' LIMIT 1];
        
        Test.startTest();
        List<String> selectedQuestions = AdaptiveQuestionSelector.selectAdaptiveQuestions(
            testUser.Id, 'Developer', 4
        );
        Test.stopTest();
        
        System.assertNotEquals(null, selectedQuestions, 'Selected questions should not be null');
        
        // Verify questions are from correct certification track
        List<Question__c> questions = [SELECT CertificationTrack__c FROM Question__c WHERE Id IN :selectedQuestions];
        for (Question__c question : questions) {
            System.assertEquals('Developer', question.CertificationTrack__c, 'All questions should be for Developer track');
        }
    }
    
    @IsTest
    static void testLargeQuestionSetRequest() {
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@omnistudio.test' LIMIT 1];
        
        Test.startTest();
        List<String> selectedQuestions = AdaptiveQuestionSelector.selectAdaptiveQuestions(
            testUser.Id, 'Consultant', 20
        );
        Test.stopTest();
        
        System.assertNotEquals(null, selectedQuestions, 'Selected questions should not be null');
        // Should return available questions even if less than requested
        System.assert(selectedQuestions.size() > 0, 'Should return some questions');
    }
    
    @IsTest
    static void testQuestionTypeDistribution() {
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@omnistudio.test' LIMIT 1];
        
        // Add more questions of different types for better testing
        List<Question__c> additionalQuestions = new List<Question__c>();
        for (Integer i = 0; i < 10; i++) {
            additionalQuestions.add(createTestQuestion('FlexCards', 'Consultant', 2, 'MultipleChoice'));
            additionalQuestions.add(createTestQuestion('OmniScripts', 'Consultant', 2, 'Scenario'));
        }
        insert additionalQuestions;
        
        Test.startTest();
        List<String> selectedQuestions = AdaptiveQuestionSelector.selectAdaptiveQuestions(
            testUser.Id, 'Consultant', 10
        );
        Test.stopTest();
        
        System.assertNotEquals(null, selectedQuestions, 'Selected questions should not be null');
        System.assert(selectedQuestions.size() > 0, 'Should return questions');
        
        // Verify question type variety
        List<Question__c> questions = [SELECT QuestionType__c FROM Question__c WHERE Id IN :selectedQuestions];
        Set<String> questionTypes = new Set<String>();
        for (Question__c question : questions) {
            questionTypes.add(question.QuestionType__c);
        }
        System.assert(questionTypes.size() > 1, 'Should have variety in question types');
    }
    
    // Helper method to create test questions
    private static Question__c createTestQuestion(String topic, String track, Integer difficulty, String questionType) {
        return new Question__c(
            Topic__c = topic,
            CertificationTrack__c = track,
            Difficulty__c = difficulty,
            QuestionType__c = questionType,
            Active__c = true,
            QuestionText__c = 'Sample question for ' + topic,
            CorrectAnswer__c = 'A',
            OptionA__c = 'Option A',
            OptionB__c = 'Option B', 
            OptionC__c = 'Option C',
            OptionD__c = 'Option D',
            Explanation__c = 'Sample explanation',
            UsageCount__c = 0
        );
    }
}