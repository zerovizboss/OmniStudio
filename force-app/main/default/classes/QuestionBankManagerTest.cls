/**
 * @description Test class for QuestionBankManager
 * @author Claude Code Assistant
 * @since User Story #17 - Weighted Question Distribution
 * @version 1.0
 * 
 * Comprehensive test coverage for question bank management,
 * health checks, and import functionality.
 */
@IsTest
private class QuestionBankManagerTest {
    
    /**
     * @description Test data setup with varied question quality
     */
    @TestSetup
    static void setupTestData() {
        List<Question__c> questions = new List<Question__c>();
        
        // Create healthy question bank for Consultant
        questions.addAll(createQualityQuestions('Consultant', 'FlexCards', 60, 'Good'));
        questions.addAll(createQualityQuestions('Consultant', 'OmniScripts', 70, 'Good'));
        questions.addAll(createQualityQuestions('Consultant', 'DataTools', 60, 'Good'));
        questions.addAll(createQualityQuestions('Consultant', 'Solutioning', 70, 'Good'));
        
        // Create some problematic questions
        questions.addAll(createQualityQuestions('Consultant', 'FlexCards', 10, 'Poor'));
        questions.addAll(createQualityQuestions('Consultant', 'OmniScripts', 15, 'Outdated'));
        
        // Create minimal Developer bank (below minimum)
        questions.addAll(createQualityQuestions('Developer', 'FlexCards', 30, 'Good'));
        questions.addAll(createQualityQuestions('Developer', 'OmniScripts', 25, 'Good'));
        
        insert questions;
        
        // Create user answers for effectiveness testing
        createTestUserAnswers(questions);
    }
    
    /**
     * @description Create questions with specific quality characteristics
     */
    private static List<Question__c> createQualityQuestions(String track, String topic, 
                                                          Integer count, String quality) {
        List<Question__c> questions = new List<Question__c>();
        
        for (Integer i = 0; i < count; i++) {
            Question__c q = new Question__c();
            q.CertificationTrack__c = track;
            q.Topic__c = topic;
            q.Active__c = true;
            q.QuestionText__c = quality + ' question ' + i + ' for ' + topic;
            q.QuestionType__c = 'Multiple Choice';
            q.Difficulty__c = 2;
            q.CorrectAnswer__c = 'A';
            q.OptionA__c = 'Correct answer';
            q.OptionB__c = 'Incorrect answer 1';
            q.OptionC__c = 'Incorrect answer 2';
            q.OptionD__c = 'Incorrect answer 3';
            q.Explanation__c = 'Explanation for ' + topic;
            q.UsageCount__c = getUsageCountForQuality(quality);
            
            // Set dates based on quality
            if (quality == 'Outdated') {
                q.LastReviewedDate__c = Date.today().addDays(-200); // Old review
                q.LastUpdatedDate__c = Date.today().addDays(-400); // Very old update
            } else if (quality == 'Poor') {
                q.LastReviewedDate__c = Date.today().addDays(-50); // Recent review
                q.UsageCount__c = 50; // High usage for effectiveness testing
            } else {
                q.LastReviewedDate__c = Date.today().addDays(-30); // Recent review
            }
            
            questions.add(q);
        }
        
        return questions;
    }
    
    /**
     * @description Get usage count based on quality type
     */
    private static Integer getUsageCountForQuality(String quality) {
        switch on quality {
            when 'Good' { return 10 + Integer.valueOf(Math.random() * 20); }
            when 'Poor' { return 50 + Integer.valueOf(Math.random() * 30); }
            when 'Outdated' { return 5 + Integer.valueOf(Math.random() * 10); }
            when else { return 10; }
        }
    }
    
    /**
     * @description Create user answers for effectiveness testing
     */
    private static void createTestUserAnswers(List<Question__c> questions) {
        List<UserAnswer__c> answers = new List<UserAnswer__c>();
        String userId = UserInfo.getUserId();
        
        for (Question__c q : questions) {
            // Create answers based on question quality
            Integer answerCount = Integer.valueOf(q.UsageCount__c / 3);
            Decimal correctRate = getCorrectRateForQuality(q.QuestionText__c);
            
            for (Integer i = 0; i < answerCount; i++) {
                UserAnswer__c answer = new UserAnswer__c();
                answer.User__c = userId;
                answer.Question__c = q.Id;
                answer.IsCorrect__c = Math.random() < (correctRate / 100.0);
                answer.ResponseTime__c = 30 + Integer.valueOf(Math.random() * 90);
                answer.AnsweredDate__c = DateTime.now().addDays(-Integer.valueOf(Math.random() * 30));
                
                answers.add(answer);
                
                // Limit to avoid governor limits
                if (answers.size() >= 200) {
                    break;
                }
            }
            
            if (answers.size() >= 200) {
                break;
            }
        }
        
        if (!answers.isEmpty()) {
            insert answers;
        }
    }
    
    /**
     * @description Get correct rate based on question quality
     */
    private static Decimal getCorrectRateForQuality(String questionText) {
        if (questionText.contains('Poor')) {
            return 20.0; // Too difficult - 20% correct rate
        } else if (questionText.contains('Outdated')) {
            return 95.0; // Too easy - 95% correct rate  
        } else {
            return 70.0; // Good - 70% correct rate
        }
    }
    
    /**
     * @description Test health check for healthy question bank
     */
    @IsTest
    static void testHealthyQuestionBankCheck() {
        Test.startTest();
        QuestionBankManager.QuestionBankHealth health = 
            QuestionBankManager.performHealthCheck('Consultant');
        Test.stopTest();
        
        // Verify basic health metrics
        Assert.areEqual('Consultant', health.certificationTrack, 
            'Certification track should be set');
        Assert.isTrue(health.totalQuestions >= 250, 
            'Should have adequate questions from setup');
        Assert.isNotNull(health.overallHealth, 
            'Overall health should be calculated');
        Assert.isNotNull(health.lastHealthCheck, 
            'Health check timestamp should be set');
        
        // Verify recommendations are provided
        Assert.isNotNull(health.recommendations, 
            'Recommendations list should be initialized');
        
        // Should meet basic requirements
        Assert.isTrue(health.meetsMinimumCount, 
            'Should meet minimum question count');
        
        // Health should be reasonable given good setup data
        Assert.isTrue(health.overallHealth == 'Good' || health.overallHealth == 'Excellent' || health.overallHealth == 'Fair', 
            'Overall health should be positive with test data: ' + health.overallHealth);
    }
    
    /**
     * @description Test health check for unhealthy question bank
     */
    @IsTest
    static void testUnhealthyQuestionBankCheck() {
        Test.startTest();
        QuestionBankManager.QuestionBankHealth health = 
            QuestionBankManager.performHealthCheck('Developer');
        Test.stopTest();
        
        // Developer bank is intentionally small in test setup
        Assert.isFalse(health.meetsMinimumCount, 
            'Developer bank should not meet minimum with small test set');
        Assert.isTrue(health.recommendations.size() > 0, 
            'Should provide recommendations for improvement');
        
        // Should recommend adding questions
        Boolean hasAddQuestionRecommendation = false;
        for (String recommendation : health.recommendations) {
            if (recommendation.toLowerCase().contains('add') && recommendation.toLowerCase().contains('questions')) {
                hasAddQuestionRecommendation = true;
                break;
            }
        }
        Assert.isTrue(hasAddQuestionRecommendation, 
            'Should recommend adding more questions');
    }
    
    /**
     * @description Test question import functionality
     */
    @IsTest
    static void testQuestionImport() {
        List<Map<String, Object>> importData = new List<Map<String, Object>>();
        
        // Create valid question data
        Map<String, Object> validQuestion = new Map<String, Object>{
            'questionText' => 'New imported question about FlexCards?',
            'topic' => 'FlexCards',
            'difficulty' => 2,
            'questionType' => 'Multiple Choice',
            'correctAnswer' => 'B',
            'optionA' => 'Wrong answer',
            'optionB' => 'Correct answer',
            'optionC' => 'Another wrong answer',
            'optionD' => 'Yet another wrong answer',
            'explanation' => 'This explains why B is correct'
        };
        importData.add(validQuestion);
        
        // Create invalid question data (missing required fields)
        Map<String, Object> invalidQuestion = new Map<String, Object>{
            'questionText' => '',
            'topic' => 'InvalidTopic'
        };
        importData.add(invalidQuestion);
        
        // Create duplicate question
        Map<String, Object> duplicateQuestion = new Map<String, Object>{
            'questionText' => 'Good question 1 for FlexCards', // Matches existing
            'topic' => 'FlexCards',
            'correctAnswer' => 'A',
            'optionA' => 'Answer'
        };
        importData.add(duplicateQuestion);
        
        Test.startTest();
        QuestionBankManager.ImportResult result = 
            QuestionBankManager.importQuestions(importData, 'Consultant');
        Test.stopTest();
        
        // Verify import results
        Assert.areEqual(3, result.totalProcessed, 
            'Should process all 3 questions');
        Assert.areEqual(1, result.successfulImports, 
            'Should successfully import 1 valid question');
        Assert.areEqual(1, result.failed, 
            'Should fail 1 invalid question');
        Assert.areEqual(1, result.duplicates, 
            'Should detect 1 duplicate question');
        Assert.isTrue(result.errors.size() > 0, 
            'Should report errors for failed imports');
        Assert.isTrue(result.warnings.size() > 0, 
            'Should report warnings for duplicates');
        
        // Verify question was actually created
        List<Question__c> newQuestions = [
            SELECT Id, QuestionText__c 
            FROM Question__c 
            WHERE QuestionText__c = 'New imported question about FlexCards?'
        ];
        Assert.areEqual(1, newQuestions.size(), 
            'Valid question should be created in database');
    }
    
    /**
     * @description Test question update request submission
     */
    @IsTest
    static void testQuestionUpdateRequest() {
        Question__c testQuestion = [SELECT Id FROM Question__c LIMIT 1];
        
        QuestionBankManager.QuestionUpdateRequest validRequest = 
            new QuestionBankManager.QuestionUpdateRequest();
        validRequest.questionId = testQuestion.Id;
        validRequest.updateType = 'Content';
        validRequest.reason = 'Outdated information';
        validRequest.newContent = 'Updated question text';
        
        Test.startTest();
        Boolean validResult = QuestionBankManager.submitQuestionUpdate(validRequest);
        Test.stopTest();
        
        Assert.isTrue(validResult, 
            'Valid update request should be submitted successfully');
        
        // Test invalid request
        QuestionBankManager.QuestionUpdateRequest invalidRequest = 
            new QuestionBankManager.QuestionUpdateRequest();
        // Missing required fields
        
        Boolean invalidResult = QuestionBankManager.submitQuestionUpdate(invalidRequest);
        Assert.isFalse(invalidResult, 
            'Invalid update request should fail');
    }
    
    /**
     * @description Test getting questions requiring attention
     */
    @IsTest
    static void testGetQuestionsRequiringAttention() {
        Test.startTest();
        List<Question__c> attentionQuestions = 
            QuestionBankManager.getQuestionsRequiringAttention('Consultant');
        Test.stopTest();
        
        Assert.isTrue(attentionQuestions.size() > 0, 
            'Should find questions requiring attention from test data');
        
        // Verify returned questions have concerning characteristics
        Boolean foundOutdatedQuestion = false;
        Boolean foundPoorQuestion = false;
        
        for (Question__c q : attentionQuestions) {
            if (q.QuestionText__c.contains('Outdated')) {
                foundOutdatedQuestion = true;
            }
            if (q.QuestionText__c.contains('Poor')) {
                foundPoorQuestion = true;
            }
        }
        
        Assert.isTrue(foundOutdatedQuestion || foundPoorQuestion, 
            'Should return questions with quality issues from test data');
    }
    
    /**
     * @description Test data structure constructors
     */
    @IsTest
    static void testDataStructureInitialization() {
        Test.startTest();
        
        // Test QuestionBankHealth
        QuestionBankManager.QuestionBankHealth health = 
            new QuestionBankManager.QuestionBankHealth();
        Assert.isNotNull(health.recommendations, 
            'Recommendations list should be initialized');
        Assert.isNotNull(health.lastHealthCheck, 
            'Health check timestamp should be set');
        
        // Test QuestionUpdateRequest
        QuestionBankManager.QuestionUpdateRequest request = 
            new QuestionBankManager.QuestionUpdateRequest();
        Assert.isNotNull(request.requestDate, 
            'Request date should be set');
        Assert.areEqual(UserInfo.getUserId(), request.submittedBy, 
            'Submitted by should default to current user');
        
        // Test ImportResult
        QuestionBankManager.ImportResult result = 
            new QuestionBankManager.ImportResult();
        Assert.isNotNull(result.errors, 
            'Errors list should be initialized');
        Assert.isNotNull(result.warnings, 
            'Warnings list should be initialized');
        Assert.isNotNull(result.importDate, 
            'Import date should be set');
        
        Test.stopTest();
    }
    
    /**
     * @description Test empty question bank health check
     */
    @IsTest
    static void testEmptyQuestionBankHealth() {
        // Delete all questions
        delete [SELECT Id FROM Question__c];
        
        Test.startTest();
        QuestionBankManager.QuestionBankHealth health = 
            QuestionBankManager.performHealthCheck('Consultant');
        Test.stopTest();
        
        Assert.areEqual(0, health.totalQuestions, 
            'Should report 0 questions for empty bank');
        Assert.isFalse(health.meetsMinimumCount, 
            'Empty bank should not meet minimum requirements');
        Assert.isFalse(health.hasProperDistribution, 
            'Empty bank should not have proper distribution');
        Assert.areEqual('Poor', health.overallHealth, 
            'Empty bank should have poor health rating');
        Assert.isTrue(health.recommendations.size() > 0, 
            'Should provide recommendations for empty bank');
    }
    
    /**
     * @description Test import with malformed data
     */
    @IsTest
    static void testImportWithMalformedData() {
        List<Map<String, Object>> malformedData = new List<Map<String, Object>>();
        
        // Question with wrong data types
        Map<String, Object> badDataTypes = new Map<String, Object>{
            'questionText' => 'Valid question text',
            'topic' => 'FlexCards',
            'difficulty' => 'NotANumber', // Should be Integer
            'correctAnswer' => 'A',
            'optionA' => 'Answer'
        };
        malformedData.add(badDataTypes);
        
        Test.startTest();
        QuestionBankManager.ImportResult result = 
            QuestionBankManager.importQuestions(malformedData, 'Consultant');
        Test.stopTest();
        
        Assert.areEqual(1, result.totalProcessed, 
            'Should attempt to process malformed data');
        Assert.areEqual(1, result.failed, 
            'Should fail to import malformed data');
        Assert.isTrue(result.errors.size() > 0, 
            'Should report errors for malformed data');
    }
    
    /**
     * @description Test health check with invalid certification track
     */
    @IsTest
    static void testHealthCheckInvalidTrack() {
        Test.startTest();
        try {
            QuestionBankManager.performHealthCheck('InvalidTrack');
            Assert.fail('Should throw exception for invalid certification track');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('Invalid certification track'), 
                'Should throw appropriate error for invalid track');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test update request with non-existent question
     */
    @IsTest
    static void testUpdateRequestNonExistentQuestion() {
        QuestionBankManager.QuestionUpdateRequest request = 
            new QuestionBankManager.QuestionUpdateRequest();
        request.questionId = 'a00000000000000000'; // Non-existent ID
        request.updateType = 'Content';
        request.reason = 'Test update';
        
        Test.startTest();
        Boolean result = QuestionBankManager.submitQuestionUpdate(request);
        Test.stopTest();
        
        Assert.isFalse(result, 
            'Should fail for non-existent question ID');
    }
    
    /**
     * @description Test question validation edge cases
     */
    @IsTest
    static void testQuestionValidationEdgeCases() {
        List<Map<String, Object>> edgeCaseData = new List<Map<String, Object>>();
        
        // Question with extremely long text
        Map<String, Object> longQuestion = new Map<String, Object>{
            'questionText' => 'This is an extremely long question that exceeds the maximum allowed length for question text in the system. '.repeat(20),
            'topic' => 'FlexCards',
            'difficulty' => 2,
            'correctAnswer' => 'A',
            'optionA' => 'Answer'
        };
        edgeCaseData.add(longQuestion);
        
        // Question with invalid difficulty
        Map<String, Object> invalidDifficulty = new Map<String, Object>{
            'questionText' => 'Valid question',
            'topic' => 'FlexCards',
            'difficulty' => 5, // Invalid - should be 1-3
            'correctAnswer' => 'A',
            'optionA' => 'Answer'
        };
        edgeCaseData.add(invalidDifficulty);
        
        // Question with correct answer that doesn't match options
        Map<String, Object> invalidCorrectAnswer = new Map<String, Object>{
            'questionText' => 'Another valid question',
            'topic' => 'FlexCards',
            'difficulty' => 2,
            'correctAnswer' => 'C',
            'optionA' => 'Answer A',
            'optionB' => 'Answer B'
            // Missing optionC but correctAnswer is C
        };
        edgeCaseData.add(invalidCorrectAnswer);
        
        Test.startTest();
        QuestionBankManager.ImportResult result = 
            QuestionBankManager.importQuestions(edgeCaseData, 'Consultant');
        Test.stopTest();
        
        Assert.areEqual(3, result.totalProcessed, 
            'Should process all edge case questions');
        Assert.areEqual(3, result.failed, 
            'All edge case questions should fail validation');
        Assert.isTrue(result.errors.size() >= 3, 
            'Should report validation errors for each failed question');
    }
}