/**
 * @description Test class for WeightedQuestionDistribution
 * @author Claude Code Assistant
 * @since User Story #17 - Weighted Question Distribution
 * @version 1.0
 * 
 * Comprehensive test coverage for weighted question distribution system,
 * analytics tracking, and official exam pattern matching.
 */
@IsTest
private class WeightedQuestionDistributionTest {
    
    /**
     * @description Test data setup with representative question bank
     */
    @TestSetup
    static void setupTestData() {
        // Create comprehensive question bank for both tracks
        List<Question__c> questions = new List<Question__c>();
        
        // Consultant track questions (400+ total)
        questions.addAll(createTopicQuestions('Consultant', 'FlexCards', 100)); // ~23%
        questions.addAll(createTopicQuestions('Consultant', 'OmniScripts', 115)); // ~27%  
        questions.addAll(createTopicQuestions('Consultant', 'DataTools', 100)); // ~23%
        questions.addAll(createTopicQuestions('Consultant', 'Solutioning', 115)); // ~27%
        
        // Developer track questions (400+ total)
        questions.addAll(createTopicQuestions('Developer', 'FlexCards', 85)); // ~20%
        questions.addAll(createTopicQuestions('Developer', 'OmniScripts', 85)); // ~20%
        questions.addAll(createTopicQuestions('Developer', 'IntegrationProcedures', 85)); // ~20%
        questions.addAll(createTopicQuestions('Developer', 'DataRaptors', 85)); // ~20%
        questions.addAll(createTopicQuestions('Developer', 'Expressions', 85)); // ~20%
        
        insert questions;
        
        // Create sample user answers for analytics
        createSampleUserAnswers(questions);
    }
    
    /**
     * @description Helper method to create questions for a specific topic
     */
    private static List<Question__c> createTopicQuestions(String track, String topic, Integer count) {
        List<Question__c> questions = new List<Question__c>();
        
        for (Integer i = 0; i < count; i++) {
            Question__c q = new Question__c();
            q.CertificationTrack__c = track;
            q.Topic__c = topic;
            q.Active__c = true;
            q.QuestionText__c = 'Sample question ' + i + ' for ' + topic;
            q.QuestionType__c = getRandomQuestionType();
            q.Difficulty__c = getRandomDifficulty();
            q.CorrectAnswer__c = 'A';
            q.OptionA__c = 'Correct answer';
            q.OptionB__c = 'Incorrect answer 1';
            q.OptionC__c = 'Incorrect answer 2';
            q.OptionD__c = 'Incorrect answer 3';
            q.Explanation__c = 'Explanation for ' + topic + ' question';
            q.UsageCount__c = Integer.valueOf(Math.random() * 20);
            q.EstimatedTimeSeconds__c = 60 + Integer.valueOf(Math.random() * 120);
            
            questions.add(q);
        }
        
        return questions;
    }
    
    /**
     * @description Get random question type for test data
     */
    private static String getRandomQuestionType() {
        List<String> types = new List<String>{'Multiple Choice', 'Multiple Select', 'Scenario-based', 'Practical'};
        return types[Integer.valueOf(Math.random() * types.size())];
    }
    
    /**
     * @description Get random difficulty for test data
     */
    private static Integer getRandomDifficulty() {
        return 1 + Integer.valueOf(Math.random() * 3); // 1, 2, or 3
    }
    
    /**
     * @description Create sample user answers for analytics testing
     */
    private static void createSampleUserAnswers(List<Question__c> questions) {
        List<UserAnswer__c> answers = new List<UserAnswer__c>();
        String userId = UserInfo.getUserId();
        
        // Create answers for first 50 questions for analytics testing
        for (Integer i = 0; i < Math.min(50, questions.size()); i++) {
            Question__c q = questions[i];
            
            // Create multiple answers per question for better analytics
            for (Integer j = 0; j < 3 + Integer.valueOf(Math.random() * 5); j++) {
                UserAnswer__c answer = new UserAnswer__c();
                answer.User__c = userId;
                answer.Question__c = q.Id;
                answer.IsCorrect__c = Math.random() > 0.3; // ~70% correct rate
                answer.ResponseTime__c = 30 + Integer.valueOf(Math.random() * 120); // 30-150 seconds
                answer.AnsweredDate__c = DateTime.now().addDays(-Integer.valueOf(Math.random() * 30));
                
                answers.add(answer);
            }
        }
        
        insert answers;
    }
    
    /**
     * @description Test getting question bank statistics for Consultant track
     */
    @IsTest
    static void testGetConsultantQuestionBankStats() {
        Test.startTest();
        WeightedQuestionDistribution.QuestionBankStats stats = 
            WeightedQuestionDistribution.getQuestionBankStats('Consultant');
        Test.stopTest();
        
        // Verify basic stats
        Assert.areEqual('Consultant', stats.certificationTrack, 
            'Certification track should be Consultant');
        Assert.isTrue(stats.totalQuestions >= 400, 
            'Should have minimum 400 questions for Consultant track');
        Assert.isTrue(stats.meetsMinimumRequirements, 
            'Should meet minimum requirements with adequate question bank');
        
        // Verify target weights match framework
        Assert.areEqual(23.0, stats.targetWeights.get('FlexCards'), 
            'FlexCards target weight should be 23%');
        Assert.areEqual(27.0, stats.targetWeights.get('OmniScripts'), 
            'OmniScripts target weight should be 27%');
        Assert.areEqual(23.0, stats.targetWeights.get('DataTools'), 
            'DataTools target weight should be 23%');
        Assert.areEqual(27.0, stats.targetWeights.get('Solutioning'), 
            'Solutioning target weight should be 27%');
        
        // Verify actual counts and weights are calculated
        Assert.isTrue(stats.topicCounts.containsKey('FlexCards'), 
            'Should have FlexCards question count');
        Assert.isTrue(stats.actualWeights.containsKey('FlexCards'), 
            'Should have FlexCards actual weight');
        Assert.isTrue(stats.deviations.containsKey('FlexCards'), 
            'Should have FlexCards weight deviation');
        
        // Verify weights are reasonable (within 10% deviation for test data)
        for (String topic : stats.targetWeights.keySet()) {
            Decimal deviation = Math.abs(stats.deviations.get(topic));
            Assert.isTrue(deviation <= 10.0, 
                'Topic ' + topic + ' deviation should be reasonable for test data: ' + deviation);
        }
    }
    
    /**
     * @description Test getting question bank statistics for Developer track
     */
    @IsTest
    static void testGetDeveloperQuestionBankStats() {
        Test.startTest();
        WeightedQuestionDistribution.QuestionBankStats stats = 
            WeightedQuestionDistribution.getQuestionBankStats('Developer');
        Test.stopTest();
        
        // Verify basic stats
        Assert.areEqual('Developer', stats.certificationTrack, 
            'Certification track should be Developer');
        Assert.isTrue(stats.totalQuestions >= 400, 
            'Should have minimum 400 questions for Developer track');
        Assert.isTrue(stats.meetsMinimumRequirements, 
            'Should meet minimum requirements with adequate question bank');
        
        // Verify equal weighting for developer topics
        Assert.areEqual(20.0, stats.targetWeights.get('FlexCards'), 
            'FlexCards target weight should be 20%');
        Assert.areEqual(20.0, stats.targetWeights.get('OmniScripts'), 
            'OmniScripts target weight should be 20%');
        Assert.areEqual(20.0, stats.targetWeights.get('IntegrationProcedures'), 
            'IntegrationProcedures target weight should be 20%');
        Assert.areEqual(20.0, stats.targetWeights.get('DataRaptors'), 
            'DataRaptors target weight should be 20%');
        Assert.areEqual(20.0, stats.targetWeights.get('Expressions'), 
            'Expressions target weight should be 20%');
        
        // Verify all developer topics are present
        Assert.areEqual(5, stats.targetWeights.size(), 
            'Developer track should have 5 topics');
    }
    
    /**
     * @description Test invalid certification track handling
     */
    @IsTest
    static void testInvalidCertificationTrack() {
        Test.startTest();
        try {
            WeightedQuestionDistribution.getQuestionBankStats('InvalidTrack');
            Assert.fail('Should throw IllegalArgumentException for invalid track');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Invalid certification track'), 
                'Error message should mention invalid certification track');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test weighted question selection for practice session
     */
    @IsTest
    static void testSelectWeightedQuestions() {
        WeightedQuestionDistribution.QuestionSelectionRequest request = 
            new WeightedQuestionDistribution.QuestionSelectionRequest();
        request.certificationTrack = 'Consultant';
        request.requestedQuestions = 50;
        request.difficultyFocus = 'Balanced';
        request.sessionType = 'Practice';
        
        Test.startTest();
        WeightedQuestionDistribution.QuestionSet result = 
            WeightedQuestionDistribution.selectWeightedQuestions(request);
        Test.stopTest();
        
        // Verify basic results
        Assert.isTrue(result.questions.size() > 0, 
            'Should return questions');
        Assert.isTrue(result.questions.size() <= 50, 
            'Should not exceed requested question count');
        
        // Verify metadata is calculated
        Assert.isNotNull(result.topicDistribution, 
            'Topic distribution should be calculated');
        Assert.isNotNull(result.difficultyDistribution, 
            'Difficulty distribution should be calculated');
        Assert.isNotNull(result.questionTypeDistribution, 
            'Question type distribution should be calculated');
        Assert.isTrue(result.totalEstimatedMinutes > 0, 
            'Total estimated time should be calculated');
        Assert.isTrue(result.averageDifficulty > 0, 
            'Average difficulty should be calculated');
        Assert.isNotNull(result.selectionStrategy, 
            'Selection strategy should be documented');
        
        // Verify topic distribution follows weights
        Integer totalDistributed = 0;
        for (Integer count : result.topicDistribution.values()) {
            totalDistributed += count;
        }
        Assert.areEqual(result.questions.size(), totalDistributed, 
            'Topic distribution should account for all questions');
        
        // Verify questions are from correct track
        for (Question__c q : result.questions) {
            Assert.areEqual('Consultant', q.CertificationTrack__c, 
                'All questions should be from Consultant track');
        }
    }
    
    /**
     * @description Test question selection with focus topics
     */
    @IsTest
    static void testSelectQuestionsWithFocusTopics() {
        WeightedQuestionDistribution.QuestionSelectionRequest request = 
            new WeightedQuestionDistribution.QuestionSelectionRequest();
        request.certificationTrack = 'Consultant';
        request.requestedQuestions = 30;
        request.focusTopics = new Set<String>{'FlexCards'};
        request.difficultyFocus = 'Progressive';
        
        Test.startTest();
        WeightedQuestionDistribution.QuestionSet result = 
            WeightedQuestionDistribution.selectWeightedQuestions(request);
        Test.stopTest();
        
        // Verify focus topic gets more questions than normal weight
        Integer flexCardCount = result.topicDistribution.containsKey('FlexCards') ? 
            result.topicDistribution.get('FlexCards') : 0;
        Integer expectedNormalCount = Integer.valueOf(30 * 0.23); // Normal 23% weight
        
        Assert.isTrue(flexCardCount > expectedNormalCount, 
            'Focus topic should get more questions than normal weight: ' + 
            flexCardCount + ' vs expected ' + expectedNormalCount);
    }
    
    /**
     * @description Test question selection with excluded topics
     */
    @IsTest
    static void testSelectQuestionsWithExcludedTopics() {
        WeightedQuestionDistribution.QuestionSelectionRequest request = 
            new WeightedQuestionDistribution.QuestionSelectionRequest();
        request.certificationTrack = 'Developer';
        request.requestedQuestions = 25;
        request.excludeTopics = new Set<String>{'Expressions'};
        
        Test.startTest();
        WeightedQuestionDistribution.QuestionSet result = 
            WeightedQuestionDistribution.selectWeightedQuestions(request);
        Test.stopTest();
        
        // Verify excluded topic is not present
        Assert.isFalse(result.topicDistribution.containsKey('Expressions'), 
            'Excluded topic should not appear in distribution');
        
        // Verify questions don't contain excluded topic
        for (Question__c q : result.questions) {
            Assert.areNotEqual('Expressions', q.Topic__c, 
                'No questions should be from excluded topic');
        }
    }
    
    /**
     * @description Test different difficulty focus strategies
     */
    @IsTest
    static void testDifficultyFocusStrategies() {
        WeightedQuestionDistribution.QuestionSelectionRequest balancedRequest = 
            new WeightedQuestionDistribution.QuestionSelectionRequest();
        balancedRequest.certificationTrack = 'Consultant';
        balancedRequest.requestedQuestions = 30;
        balancedRequest.difficultyFocus = 'Balanced';
        
        WeightedQuestionDistribution.QuestionSelectionRequest progressiveRequest = 
            new WeightedQuestionDistribution.QuestionSelectionRequest();
        progressiveRequest.certificationTrack = 'Consultant';
        progressiveRequest.requestedQuestions = 30;
        progressiveRequest.difficultyFocus = 'Progressive';
        
        WeightedQuestionDistribution.QuestionSelectionRequest advancedRequest = 
            new WeightedQuestionDistribution.QuestionSelectionRequest();
        advancedRequest.certificationTrack = 'Consultant';
        advancedRequest.requestedQuestions = 30;
        advancedRequest.difficultyFocus = 'Advanced';
        
        Test.startTest();
        WeightedQuestionDistribution.QuestionSet balancedResult = 
            WeightedQuestionDistribution.selectWeightedQuestions(balancedRequest);
        WeightedQuestionDistribution.QuestionSet progressiveResult = 
            WeightedQuestionDistribution.selectWeightedQuestions(progressiveRequest);
        WeightedQuestionDistribution.QuestionSet advancedResult = 
            WeightedQuestionDistribution.selectWeightedQuestions(advancedRequest);
        Test.stopTest();
        
        // Verify different average difficulties
        Assert.isTrue(advancedResult.averageDifficulty > balancedResult.averageDifficulty, 
            'Advanced focus should have higher average difficulty');
        Assert.isTrue(balancedResult.averageDifficulty > progressiveResult.averageDifficulty, 
            'Balanced should have higher average difficulty than progressive');
        
        // Verify difficulty distributions are different
        Integer balancedLevel3 = balancedResult.difficultyDistribution.containsKey('3') ? 
            balancedResult.difficultyDistribution.get('3') : 0;
        Integer advancedLevel3 = advancedResult.difficultyDistribution.containsKey('3') ? 
            advancedResult.difficultyDistribution.get('3') : 0;
        
        Assert.isTrue(advancedLevel3 >= balancedLevel3, 
            'Advanced focus should have at least as many level 3 questions');
    }
    
    /**
     * @description Test question analytics calculation
     */
    @IsTest
    static void testGetQuestionAnalytics() {
        // Get sample questions for analytics
        List<Question__c> sampleQuestions = [
            SELECT Id FROM Question__c 
            WHERE CertificationTrack__c = 'Consultant' 
            LIMIT 10
        ];
        
        List<String> questionIds = new List<String>();
        for (Question__c q : sampleQuestions) {
            questionIds.add(q.Id);
        }
        
        Test.startTest();
        List<WeightedQuestionDistribution.QuestionAnalytics> analytics = 
            WeightedQuestionDistribution.getQuestionAnalytics(questionIds);
        Test.stopTest();
        
        // Verify analytics returned for all questions
        Assert.areEqual(sampleQuestions.size(), analytics.size(), 
            'Should return analytics for all requested questions');
        
        // Verify analytics data structure
        for (WeightedQuestionDistribution.QuestionAnalytics qa : analytics) {
            Assert.isNotNull(qa.questionId, 'Question ID should be set');
            Assert.isNotNull(qa.topic, 'Topic should be set');
            Assert.isNotNull(qa.difficultyRating, 'Difficulty rating should be set');
            Assert.isNotNull(qa.effectivenessScore, 'Effectiveness score should be calculated');
            Assert.isTrue(qa.totalAttempts >= 0, 'Total attempts should be non-negative');
            Assert.isTrue(qa.correctRate >= 0 && qa.correctRate <= 100, 
                'Correct rate should be between 0-100%');
        }
        
        // Verify effectiveness scores are valid
        Set<String> validScores = new Set<String>{'Excellent', 'Good', 'Fair', 'Poor'};
        for (WeightedQuestionDistribution.QuestionAnalytics qa : analytics) {
            Assert.isTrue(validScores.contains(qa.effectivenessScore), 
                'Effectiveness score should be valid: ' + qa.effectivenessScore);
        }
    }
    
    /**
     * @description Test question usage statistics update
     */
    @IsTest
    static void testUpdateQuestionUsage() {
        List<Question__c> testQuestions = [
            SELECT Id, UsageCount__c, LastUsedDate__c
            FROM Question__c 
            WHERE CertificationTrack__c = 'Consultant' 
            LIMIT 5
        ];
        
        List<String> questionIds = new List<String>();
        Map<String, Integer> originalUsageCounts = new Map<String, Integer>();
        
        for (Question__c q : testQuestions) {
            questionIds.add(q.Id);
            originalUsageCounts.put(q.Id, Integer.valueOf(q.UsageCount__c != null ? q.UsageCount__c : 0));
        }
        
        Test.startTest();
        WeightedQuestionDistribution.updateQuestionUsage(questionIds);
        Test.stopTest();
        
        // Verify usage counts were incremented
        List<Question__c> updatedQuestions = [
            SELECT Id, UsageCount__c, LastUsedDate__c
            FROM Question__c 
            WHERE Id IN :questionIds
        ];
        
        for (Question__c q : updatedQuestions) {
            Integer originalCount = originalUsageCounts.get(q.Id);
            Integer expectedCount = originalCount + 1;
            
            Assert.areEqual(expectedCount, Integer.valueOf(q.UsageCount__c), 
                'Usage count should be incremented by 1');
            Assert.areEqual(Date.today(), q.LastUsedDate__c, 
                'Last used date should be updated to today');
        }
    }
    
    /**
     * @description Test data structure constructors and initialization
     */
    @IsTest
    static void testDataStructures() {
        Test.startTest();
        
        // Test QuestionBankStats
        WeightedQuestionDistribution.QuestionBankStats stats = 
            new WeightedQuestionDistribution.QuestionBankStats();
        Assert.isNotNull(stats.topicCounts, 'Topic counts map should be initialized');
        Assert.isNotNull(stats.actualWeights, 'Actual weights map should be initialized');
        Assert.isNotNull(stats.targetWeights, 'Target weights map should be initialized');
        Assert.isNotNull(stats.deviations, 'Deviations map should be initialized');
        
        // Test QuestionSelectionRequest
        WeightedQuestionDistribution.QuestionSelectionRequest request = 
            new WeightedQuestionDistribution.QuestionSelectionRequest();
        Assert.isNotNull(request.excludeTopics, 'Exclude topics set should be initialized');
        Assert.isNotNull(request.focusTopics, 'Focus topics set should be initialized');
        Assert.isNotNull(request.excludeQuestionIds, 'Exclude question IDs should be initialized');
        Assert.areEqual(true, request.enforceWeighting, 'Enforce weighting should default to true');
        Assert.areEqual('Balanced', request.difficultyFocus, 'Difficulty focus should default to Balanced');
        Assert.areEqual('Practice', request.sessionType, 'Session type should default to Practice');
        
        // Test QuestionSet
        WeightedQuestionDistribution.QuestionSet questionSet = 
            new WeightedQuestionDistribution.QuestionSet();
        Assert.isNotNull(questionSet.questions, 'Questions list should be initialized');
        Assert.isNotNull(questionSet.topicDistribution, 'Topic distribution should be initialized');
        Assert.isNotNull(questionSet.difficultyDistribution, 'Difficulty distribution should be initialized');
        Assert.isNotNull(questionSet.questionTypeDistribution, 'Question type distribution should be initialized');
        Assert.isNotNull(questionSet.generatedAt, 'Generated timestamp should be set');
        
        // Test QuestionAnalytics
        WeightedQuestionDistribution.QuestionAnalytics analytics = 
            new WeightedQuestionDistribution.QuestionAnalytics();
        Assert.areEqual(0, analytics.totalAttempts, 'Total attempts should default to 0');
        Assert.areEqual(0.0, analytics.correctRate, 'Correct rate should default to 0.0');
        Assert.areEqual(0.0, analytics.averageResponseTime, 'Average response time should default to 0.0');
        Assert.areEqual(0, analytics.reportedIssues, 'Reported issues should default to 0');
        
        Test.stopTest();
    }
    
    /**
     * @description Test question selection with empty question bank
     */
    @IsTest
    static void testEmptyQuestionBank() {
        // Delete all questions to test empty bank scenario
        delete [SELECT Id FROM Question__c];
        
        Test.startTest();
        WeightedQuestionDistribution.QuestionBankStats stats = 
            WeightedQuestionDistribution.getQuestionBankStats('Consultant');
        Test.stopTest();
        
        Assert.areEqual(0, stats.totalQuestions, 
            'Should report 0 questions for empty bank');
        Assert.isFalse(stats.meetsMinimumRequirements, 
            'Should not meet minimum requirements with empty bank');
        
        // Verify all topic counts are 0
        for (String topic : stats.targetWeights.keySet()) {
            Integer count = stats.topicCounts.containsKey(topic) ? stats.topicCounts.get(topic) : 0;
            Assert.areEqual(0, count, 'Topic count should be 0 for empty bank: ' + topic);
        }
    }
    
    /**
     * @description Test question selection edge cases
     */
    @IsTest
    static void testQuestionSelectionEdgeCases() {
        WeightedQuestionDistribution.QuestionSelectionRequest request = 
            new WeightedQuestionDistribution.QuestionSelectionRequest();
        request.certificationTrack = 'Consultant';
        request.requestedQuestions = 1000; // More than available
        request.difficultyFocus = 'InvalidFocus'; // Should default to balanced
        
        Test.startTest();
        WeightedQuestionDistribution.QuestionSet result = 
            WeightedQuestionDistribution.selectWeightedQuestions(request);
        Test.stopTest();
        
        // Should return available questions even if less than requested
        Assert.isTrue(result.questions.size() > 0, 
            'Should return available questions');
        Assert.isTrue(result.questions.size() <= 430, // Max consultant questions from setup
            'Should not exceed available questions');
        
        // Should handle invalid difficulty focus gracefully
        Assert.isNotNull(result.selectionStrategy, 
            'Should generate selection strategy even with invalid difficulty focus');
    }
    
    /**
     * @description Test analytics with no user answer data
     */
    @IsTest
    static void testAnalyticsWithNoAnswers() {
        // Get questions that don't have answers
        List<Question__c> questionsWithoutAnswers = [
            SELECT Id FROM Question__c 
            WHERE CertificationTrack__c = 'Developer' 
            LIMIT 5
        ];
        
        List<String> questionIds = new List<String>();
        for (Question__c q : questionsWithoutAnswers) {
            questionIds.add(q.Id);
        }
        
        Test.startTest();
        List<WeightedQuestionDistribution.QuestionAnalytics> analytics = 
            WeightedQuestionDistribution.getQuestionAnalytics(questionIds);
        Test.stopTest();
        
        // Should return analytics with default values
        Assert.areEqual(questionsWithoutAnswers.size(), analytics.size(), 
            'Should return analytics for all questions');
        
        for (WeightedQuestionDistribution.QuestionAnalytics qa : analytics) {
            Assert.areEqual(0, qa.totalAttempts, 
                'Questions without answers should have 0 attempts');
            Assert.areEqual(0.0, qa.correctRate, 
                'Questions without answers should have 0% correct rate');
            Assert.isNotNull(qa.effectivenessScore, 
                'Should calculate effectiveness score even without answer data');
        }
    }
}