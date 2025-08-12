/**
 * @description Test class for UserPerformanceData - targeting 90%+ code coverage
 * @author Claude AI OmniStudio Training
 * @date 2025-08-12
 */
@IsTest
private class UserPerformanceDataTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test questions
        List<Question__c> questions = new List<Question__c>();
        questions.add(new Question__c(
            Topic__c = 'FlexCards',
            CertificationTrack__c = 'Consultant',
            Difficulty__c = 2,
            Active__c = true,
            QuestionText__c = 'FlexCard test question'
        ));
        questions.add(new Question__c(
            Topic__c = 'OmniScripts', 
            CertificationTrack__c = 'Consultant',
            Difficulty__c = 3,
            Active__c = true,
            QuestionText__c = 'OmniScript test question'
        ));
        questions.add(new Question__c(
            Topic__c = 'DataTools',
            CertificationTrack__c = 'Consultant',
            Difficulty__c = 1,
            Active__c = true,
            QuestionText__c = 'DataTools test question'
        ));
        insert questions;
    }
    
    @IsTest
    static void testUserPerformanceDataConstructorWithData() {
        List<Question__c> questions = [SELECT Id, Topic__c FROM Question__c];
        
        // Create mock user answers
        List<UserAnswer__c> answers = new List<UserAnswer__c>();
        
        // FlexCards - 80% correct (4 out of 5)
        for (Integer i = 0; i < 5; i++) {
            answers.add(createMockAnswer(questions[0].Id, questions[0].Topic__c, i < 4));
        }
        
        // OmniScripts - 60% correct (3 out of 5)  
        for (Integer i = 0; i < 5; i++) {
            answers.add(createMockAnswer(questions[1].Id, questions[1].Topic__c, i < 3));
        }
        
        // DataTools - 20% correct (1 out of 5)
        for (Integer i = 0; i < 5; i++) {
            answers.add(createMockAnswer(questions[2].Id, questions[2].Topic__c, i < 1));
        }
        
        UserProfile__c profile = new UserProfile__c(CurrentDifficulty__c = 3);
        
        Test.startTest();
        UserPerformanceData performanceData = new UserPerformanceData(answers, profile);
        Test.stopTest();
        
        System.assertEquals(15, performanceData.getTotalQuestionsAnswered(), 'Should have 15 total answers');
        System.assertEquals(3, performanceData.getCurrentDifficulty(), 'Should have difficulty 3 from profile');
        
        // Test topic performance
        System.assertEquals(0.8, performanceData.getTopicPerformance('FlexCards'), 'FlexCards should have 80% performance');
        System.assertEquals(0.6, performanceData.getTopicPerformance('OmniScripts'), 'OmniScripts should have 60% performance');
        System.assertEquals(0.2, performanceData.getTopicPerformance('DataTools'), 'DataTools should have 20% performance');
        
        // Test overall performance (8 correct out of 15 = 53.3%)
        Decimal expectedOverall = 8.0 / 15.0;
        System.assertEquals(expectedOverall, performanceData.getOverallPerformance(), 'Overall performance should be calculated correctly');
    }
    
    @IsTest
    static void testUserPerformanceDataDefaultConstructor() {
        Test.startTest();
        UserPerformanceData performanceData = new UserPerformanceData();
        Test.stopTest();
        
        System.assertEquals(0, performanceData.getTotalQuestionsAnswered(), 'New user should have 0 answers');
        System.assertEquals(2, performanceData.getCurrentDifficulty(), 'New user should default to difficulty 2');
        System.assertEquals(0, performanceData.getOverallPerformance(), 'New user should have 0 overall performance');
        System.assertEquals(0.5, performanceData.getTopicPerformance('FlexCards'), 'Unknown topic should return 0.5 default');
    }
    
    @IsTest
    static void testGetLowestPerformingTopics() {
        List<Question__c> questions = [SELECT Id, Topic__c FROM Question__c];
        
        List<UserAnswer__c> answers = new List<UserAnswer__c>();
        
        // FlexCards - 90% (best)
        for (Integer i = 0; i < 10; i++) {
            answers.add(createMockAnswer(questions[0].Id, questions[0].Topic__c, i < 9));
        }
        
        // OmniScripts - 50% (middle)
        for (Integer i = 0; i < 10; i++) {
            answers.add(createMockAnswer(questions[1].Id, questions[1].Topic__c, i < 5));
        }
        
        // DataTools - 10% (worst)
        for (Integer i = 0; i < 10; i++) {
            answers.add(createMockAnswer(questions[2].Id, questions[2].Topic__c, i < 1));
        }
        
        UserProfile__c profile = new UserProfile__c(CurrentDifficulty__c = 2);
        
        Test.startTest();
        UserPerformanceData performanceData = new UserPerformanceData(answers, profile);
        List<String> lowestTopics = performanceData.getLowestPerformingTopics(2);
        Test.stopTest();
        
        System.assertEquals(2, lowestTopics.size(), 'Should return 2 lowest performing topics');
        System.assertEquals('DataTools', lowestTopics[0], 'DataTools should be lowest (10%)');
        System.assertEquals('OmniScripts', lowestTopics[1], 'OmniScripts should be second lowest (50%)');
    }
    
    @IsTest
    static void testGetLowestPerformingTopicsEmptyData() {
        UserProfile__c profile = new UserProfile__c(CurrentDifficulty__c = 2);
        
        Test.startTest();
        UserPerformanceData performanceData = new UserPerformanceData(new List<UserAnswer__c>(), profile);
        List<String> lowestTopics = performanceData.getLowestPerformingTopics(3);
        Test.stopTest();
        
        System.assertEquals(0, lowestTopics.size(), 'Should return empty list when no data available');
    }
    
    @IsTest
    static void testGetPerformanceTrendInsufficientData() {
        List<UserAnswer__c> answers = new List<UserAnswer__c>();
        
        // Only 5 answers - insufficient for trend analysis
        for (Integer i = 0; i < 5; i++) {
            answers.add(createMockAnswer(UserInfo.getUserId(), 'FlexCards', true));
        }
        
        UserProfile__c profile = new UserProfile__c(CurrentDifficulty__c = 2);
        
        Test.startTest();
        UserPerformanceData performanceData = new UserPerformanceData(answers, profile);
        String trend = performanceData.getPerformanceTrend();
        Test.stopTest();
        
        System.assertEquals('Insufficient Data', trend, 'Should return insufficient data for < 10 answers');
    }
    
    @IsTest
    static void testGetPerformanceTrendBuildingBaseline() {
        List<UserAnswer__c> answers = new List<UserAnswer__c>();
        
        // 15 answers - less than 20 needed for full trend analysis
        for (Integer i = 0; i < 15; i++) {
            answers.add(createMockAnswerWithDate(UserInfo.getUserId(), 'FlexCards', true, DateTime.now().addHours(-i)));
        }
        
        UserProfile__c profile = new UserProfile__c(CurrentDifficulty__c = 2);
        
        Test.startTest();
        UserPerformanceData performanceData = new UserPerformanceData(answers, profile);
        String trend = performanceData.getPerformanceTrend();
        Test.stopTest();
        
        System.assertEquals('Building Baseline', trend, 'Should return building baseline for < 20 answers');
    }
    
    @IsTest
    static void testGetPerformanceTrendImproving() {
        List<UserAnswer__c> answers = new List<UserAnswer__c>();
        
        // Recent 10 answers: 9 correct (90%)
        for (Integer i = 0; i < 10; i++) {
            answers.add(createMockAnswerWithDate(UserInfo.getUserId(), 'FlexCards', i < 9, DateTime.now().addHours(-i)));
        }
        
        // Previous 10 answers: 5 correct (50%)
        for (Integer i = 10; i < 20; i++) {
            answers.add(createMockAnswerWithDate(UserInfo.getUserId(), 'FlexCards', (i - 10) < 5, DateTime.now().addHours(-i)));
        }
        
        UserProfile__c profile = new UserProfile__c(CurrentDifficulty__c = 2);
        
        Test.startTest();
        UserPerformanceData performanceData = new UserPerformanceData(answers, profile);
        String trend = performanceData.getPerformanceTrend();
        Test.stopTest();
        
        System.assertEquals('Improving', trend, 'Should detect improving trend (90% vs 50%)');
    }
    
    @IsTest
    static void testGetPerformanceTrendDeclining() {
        List<UserAnswer__c> answers = new List<UserAnswer__c>();
        
        // Recent 10 answers: 2 correct (20%)
        for (Integer i = 0; i < 10; i++) {
            answers.add(createMockAnswerWithDate(UserInfo.getUserId(), 'FlexCards', i < 2, DateTime.now().addHours(-i)));
        }
        
        // Previous 10 answers: 8 correct (80%)
        for (Integer i = 10; i < 20; i++) {
            answers.add(createMockAnswerWithDate(UserInfo.getUserId(), 'FlexCards', (i - 10) < 8, DateTime.now().addHours(-i)));
        }
        
        UserProfile__c profile = new UserProfile__c(CurrentDifficulty__c = 2);
        
        Test.startTest();
        UserPerformanceData performanceData = new UserPerformanceData(answers, profile);
        String trend = performanceData.getPerformanceTrend();
        Test.stopTest();
        
        System.assertEquals('Declining', trend, 'Should detect declining trend (20% vs 80%)');
    }
    
    @IsTest
    static void testGetPerformanceTrendStable() {
        List<UserAnswer__c> answers = new List<UserAnswer__c>();
        
        // Recent 10 answers: 7 correct (70%)
        for (Integer i = 0; i < 10; i++) {
            answers.add(createMockAnswerWithDate(UserInfo.getUserId(), 'FlexCards', i < 7, DateTime.now().addHours(-i)));
        }
        
        // Previous 10 answers: 7 correct (70%)
        for (Integer i = 10; i < 20; i++) {
            answers.add(createMockAnswerWithDate(UserInfo.getUserId(), 'FlexCards', (i - 10) < 7, DateTime.now().addHours(-i)));
        }
        
        UserProfile__c profile = new UserProfile__c(CurrentDifficulty__c = 2);
        
        Test.startTest();
        UserPerformanceData performanceData = new UserPerformanceData(answers, profile);
        String trend = performanceData.getPerformanceTrend();
        Test.stopTest();
        
        System.assertEquals('Stable', trend, 'Should detect stable trend (70% vs 70%)');
    }
    
    // Helper methods
    private static UserAnswer__c createMockAnswer(Id questionId, String topic, Boolean isCorrect) {
        return createMockAnswerWithDate(questionId, topic, isCorrect, DateTime.now());
    }
    
    private static UserAnswer__c createMockAnswerWithDate(Id questionId, String topic, Boolean isCorrect, DateTime answeredDate) {
        UserAnswer__c answer = new UserAnswer__c();
        answer.Question__c = questionId;
        answer.IsCorrect__c = isCorrect;
        answer.AnsweredDate__c = answeredDate;
        answer.ResponseTime__c = 45;
        
        // Create mock question relationship
        answer.Question__r = new Question__c(
            Id = questionId,
            Topic__c = topic,
            CertificationTrack__c = 'Consultant',
            Difficulty__c = 2
        );
        
        return answer;
    }
}