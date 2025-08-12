/**
 * @description Test class for ResultsSummaryController
 * @author Claude Code Assistant
 * @since User Story #20 - Results Summary FlexCards
 * @version 1.0
 * 
 * Comprehensive test coverage for exam results FlexCards controller,
 * pass/fail state management, topic breakdown analysis, and next step recommendations.
 */
@IsTest
private class ResultsSummaryControllerTest {
    
    /**
     * @description Test data setup with exam sessions and answers
     */
    @TestSetup
    static void setupTestData() {
        // Create user profile
        UserProfile__c userProfile = new UserProfile__c();
        userProfile.User__c = UserInfo.getUserId();
        userProfile.CertificationGoals__c = 'Consultant';
        userProfile.CurrentDifficulty__c = 2;
        userProfile.PreferredLearningStyle__c = 'Mixed';
        insert userProfile;
        
        // Create questions for both tracks
        List<Question__c> questions = new List<Question__c>();
        
        // Consultant questions
        questions.addAll(createTopicQuestions('Consultant', 'FlexCards', 15));
        questions.addAll(createTopicQuestions('Consultant', 'OmniScripts', 16));
        questions.addAll(createTopicQuestions('Consultant', 'DataTools', 14));
        questions.addAll(createTopicQuestions('Consultant', 'Solutioning', 15));
        
        // Developer questions
        questions.addAll(createTopicQuestions('Developer', 'FlexCards', 12));
        questions.addAll(createTopicQuestions('Developer', 'OmniScripts', 12));
        questions.addAll(createTopicQuestions('Developer', 'IntegrationProcedures', 12));
        questions.addAll(createTopicQuestions('Developer', 'DataRaptors', 12));
        questions.addAll(createTopicQuestions('Developer', 'Expressions', 12));
        
        insert questions;
        
        // Create exam sessions
        createExamSessions(questions);
    }
    
    /**
     * @description Create test questions for specific topics
     */
    private static List<Question__c> createTopicQuestions(String track, String topic, Integer count) {
        List<Question__c> questions = new List<Question__c>();
        
        for (Integer i = 0; i < count; i++) {
            Question__c q = new Question__c();
            q.CertificationTrack__c = track;
            q.Topic__c = topic;
            q.Active__c = true;
            q.QuestionText__c = 'Test question ' + i + ' for ' + topic + ' in ' + track;
            q.QuestionType__c = 'Multiple Choice';
            q.Difficulty__c = 1 + Math.mod(i, 3);
            q.CorrectAnswer__c = 'A';
            q.OptionA__c = 'Correct answer for ' + topic;
            q.OptionB__c = 'Wrong answer 1';
            q.OptionC__c = 'Wrong answer 2';
            q.OptionD__c = 'Wrong answer 3';
            q.Explanation__c = 'Explanation for ' + topic + ' question';
            q.UsageCount__c = i + 1;
            
            questions.add(q);
        }
        
        return questions;
    }
    
    /**
     * @description Create exam sessions with different outcomes
     */
    private static void createExamSessions(List<Question__c> questions) {
        List<ExamSession__c> examSessions = new List<ExamSession__c>();
        String userId = UserInfo.getUserId();
        
        // Passing exam session for Consultant track
        ExamSession__c passingSession = new ExamSession__c();
        passingSession.User__c = userId;
        passingSession.CertificationTrack__c = 'Consultant';
        passingSession.Status__c = 'Completed';
        passingSession.FinalScore__c = 78.5;
        passingSession.TotalQuestions__c = 60;
        passingSession.CorrectAnswers__c = 47;
        passingSession.StartTime__c = DateTime.now().addHours(-2);
        passingSession.CompletedDate__c = DateTime.now().addMinutes(-15);
        passingSession.DurationMinutes__c = 95;
        examSessions.add(passingSession);
        
        // Failing exam session for Developer track
        ExamSession__c failingSession = new ExamSession__c();
        failingSession.User__c = userId;
        failingSession.CertificationTrack__c = 'Developer';
        failingSession.Status__c = 'Completed';
        failingSession.FinalScore__c = 58.3;
        failingSession.TotalQuestions__c = 60;
        failingSession.CorrectAnswers__c = 35;
        failingSession.StartTime__c = DateTime.now().addDays(-1);
        failingSession.CompletedDate__c = DateTime.now().addDays(-1).addMinutes(105);
        failingSession.DurationMinutes__c = 105;
        examSessions.add(failingSession);
        
        // High-performing exam session
        ExamSession__c excellentSession = new ExamSession__c();
        excellentSession.User__c = userId;
        excellentSession.CertificationTrack__c = 'Consultant';
        excellentSession.Status__c = 'Completed';
        excellentSession.FinalScore__c = 92.0;
        excellentSession.TotalQuestions__c = 60;
        excellentSession.CorrectAnswers__c = 55;
        excellentSession.StartTime__c = DateTime.now().addDays(-2);
        excellentSession.CompletedDate__c = DateTime.now().addDays(-2).addMinutes(85);
        excellentSession.DurationMinutes__c = 85;
        examSessions.add(excellentSession);
        
        insert examSessions;
        
        // Create exam answers with realistic performance patterns
        createExamAnswers(examSessions, questions);
    }
    
    /**
     * @description Create exam answers with different performance by topic
     */
    private static void createExamAnswers(List<ExamSession__c> examSessions, List<Question__c> questions) {
        List<ExamAnswer__c> examAnswers = new List<ExamAnswer__c>();
        
        for (ExamSession__c session : examSessions) {
            // Filter questions for this session's track
            List<Question__c> sessionQuestions = new List<Question__c>();
            for (Question__c q : questions) {
                if (q.CertificationTrack__c == session.CertificationTrack__c) {
                    sessionQuestions.add(q);
                }
            }
            
            // Create answers based on session performance
            Map<String, Decimal> topicPerformance = getTopicPerformancePattern(session);
            Integer answersCreated = 0;
            
            for (Question__c q : sessionQuestions) {
                if (answersCreated >= 60) { // Limit to 60 questions per exam
                    break;
                }
                
                ExamAnswer__c answer = new ExamAnswer__c();
                answer.ExamSession__c = session.Id;
                answer.Question__c = q.Id;
                answer.User__c = session.User__c;
                
                // Set correctness based on topic performance pattern
                Decimal successRate = topicPerformance.get(q.Topic__c);
                answer.IsCorrect__c = Math.random() < (successRate / 100.0);
                
                answer.SelectedAnswer__c = answer.IsCorrect__c ? 'A' : 'B';
                answer.ResponseTime__c = 45 + Integer.valueOf(Math.random() * 90);
                answer.AnsweredAt__c = session.StartTime__c.addMinutes(answersCreated * 2);
                
                examAnswers.add(answer);
                answersCreated++;
            }
        }
        
        insert examAnswers;
    }
    
    /**
     * @description Get realistic topic performance patterns for each exam
     */
    private static Map<String, Decimal> getTopicPerformancePattern(ExamSession__c session) {
        if (session.FinalScore__c >= 90) {
            // Excellent performance - all topics strong
            return new Map<String, Decimal>{
                'FlexCards' => 95.0, 'OmniScripts' => 92.0, 'DataTools' => 90.0, 'Solutioning' => 88.0,
                'IntegrationProcedures' => 94.0, 'DataRaptors' => 90.0, 'Expressions' => 91.0
            };
        } else if (session.FinalScore__c >= 63) {
            // Passing performance - mixed strengths
            return new Map<String, Decimal>{
                'FlexCards' => 85.0, 'OmniScripts' => 75.0, 'DataTools' => 80.0, 'Solutioning' => 70.0,
                'IntegrationProcedures' => 78.0, 'DataRaptors' => 72.0, 'Expressions' => 75.0
            };
        } else {
            // Failing performance - clear weak areas
            return new Map<String, Decimal>{
                'FlexCards' => 65.0, 'OmniScripts' => 45.0, 'DataTools' => 55.0, 'Solutioning' => 50.0,
                'IntegrationProcedures' => 60.0, 'DataRaptors' => 40.0, 'Expressions' => 48.0
            };
        }
    }
    
    /**
     * @description Test getting exam results for passing exam
     */
    @IsTest
    static void testGetExamResultsPassing() {
        // Get passing exam session
        ExamSession__c passingSession = [
            SELECT Id FROM ExamSession__c 
            WHERE CertificationTrack__c = 'Consultant' 
              AND FinalScore__c > 70
            LIMIT 1
        ];
        
        Test.startTest();
        ResultsSummaryController.ExamResultsData resultsData = 
            ResultsSummaryController.getExamResults(passingSession.Id);
        Test.stopTest();
        
        // Verify basic data structure
        Assert.isNotNull(resultsData, 'Results data should not be null');
        Assert.areEqual(UserInfo.getUserId(), resultsData.userId, 
            'User ID should match current user');
        Assert.areEqual('Consultant', resultsData.certificationTrack, 
            'Track should be Consultant');
        Assert.isNotNull(resultsData.resultsGeneratedAt, 
            'Results timestamp should be set');
        
        // Verify exam summary
        Assert.isNotNull(resultsData.examSummary, 'Exam summary should be provided');
        Assert.isTrue(resultsData.examSummary.passed, 'Exam should be marked as passed');
        Assert.areEqual('🎉 PASSED!', resultsData.examSummary.resultStatus, 
            'Result status should indicate pass');
        Assert.isTrue(resultsData.examSummary.finalScore >= 63, 
            'Final score should be passing');
        Assert.isNotNull(resultsData.examSummary.performanceLevel, 
            'Performance level should be determined');
        
        // Verify topic breakdown
        Assert.isNotNull(resultsData.topicBreakdown, 'Topic breakdown should be provided');
        Assert.isTrue(resultsData.topicBreakdown.size() > 0, 
            'Should have topic scores');
        
        // Verify visual styling for pass
        Assert.isNotNull(resultsData.styling, 'Styling should be provided');
        Assert.areEqual('#4facfe', resultsData.styling.primaryColor, 
            'Should use success primary color');
        Assert.areEqual('utility:success', resultsData.styling.resultIconName, 
            'Should use success icon');
        
        // Verify certification info
        Assert.isNotNull(resultsData.certificationInfo, 
            'Certification info should be provided for passed exam');
        Assert.isTrue(resultsData.certificationInfo.certificateName.contains('Consultant'), 
            'Certificate should be for Consultant track');
        
        // Verify next steps
        Assert.isNotNull(resultsData.nextSteps, 'Next steps should be provided');
        Assert.isTrue(resultsData.nextSteps.size() >= 2, 
            'Should have multiple next step options');
        
        Boolean hasViewCertificate = false;
        Boolean hasWhatsNext = false;
        for (ResultsSummaryController.NextStepAction action : resultsData.nextSteps) {
            if (action.actionId == 'view-certificate') {
                hasViewCertificate = true;
                Assert.isTrue(action.isPrimary, 'View certificate should be primary action');
            } else if (action.actionId == 'whats-next') {
                hasWhatsNext = true;
            }
        }
        Assert.isTrue(hasViewCertificate, 'Should have view certificate action');
        Assert.isTrue(hasWhatsNext, 'Should have what\'s next action');
    }
    
    /**
     * @description Test getting exam results for failing exam
     */
    @IsTest
    static void testGetExamResultsFailing() {
        // Get failing exam session
        ExamSession__c failingSession = [
            SELECT Id FROM ExamSession__c 
            WHERE FinalScore__c < 63
            LIMIT 1
        ];
        
        Test.startTest();
        ResultsSummaryController.ExamResultsData resultsData = 
            ResultsSummaryController.getExamResults(failingSession.Id);
        Test.stopTest();
        
        // Verify exam summary
        Assert.isFalse(resultsData.examSummary.passed, 'Exam should be marked as failed');
        Assert.areEqual('Keep Studying!', resultsData.examSummary.resultStatus, 
            'Result status should indicate retry');
        Assert.isTrue(resultsData.examSummary.finalScore < 63, 
            'Final score should be below passing');
        
        // Verify weak areas identified
        Assert.isNotNull(resultsData.weakAreas, 'Weak areas should be identified');
        Assert.isTrue(resultsData.weakAreas.size() > 0, 
            'Should have weak areas for failing exam');
        
        // Verify visual styling for fail
        Assert.areEqual('#ff9a9e', resultsData.styling.primaryColor, 
            'Should use retry primary color');
        Assert.areEqual('utility:refresh', resultsData.styling.resultIconName, 
            'Should use retry icon');
        
        // Verify certification info is null
        Assert.isNull(resultsData.certificationInfo, 
            'Certification info should be null for failed exam');
        
        // Verify next steps for failed exam
        Boolean hasCreateStudyPlan = false;
        Boolean hasPracticeMore = false;
        for (ResultsSummaryController.NextStepAction action : resultsData.nextSteps) {
            if (action.actionId == 'create-study-plan') {
                hasCreateStudyPlan = true;
                Assert.isTrue(action.isPrimary, 'Create study plan should be primary action');
            } else if (action.actionId == 'practice-more') {
                hasPracticeMore = true;
            }
        }
        Assert.isTrue(hasCreateStudyPlan, 'Should have create study plan action');
        Assert.isTrue(hasPracticeMore, 'Should have practice more action');
    }
    
    /**
     * @description Test excellent performance exam results
     */
    @IsTest
    static void testGetExamResultsExcellent() {
        // Get excellent exam session
        ExamSession__c excellentSession = [
            SELECT Id FROM ExamSession__c 
            WHERE FinalScore__c >= 90
            LIMIT 1
        ];
        
        Test.startTest();
        ResultsSummaryController.ExamResultsData resultsData = 
            ResultsSummaryController.getExamResults(excellentSession.Id);
        Test.stopTest();
        
        // Verify excellent performance indicators
        Assert.areEqual('Excellent', resultsData.examSummary.performanceLevel, 
            'Performance level should be excellent');
        Assert.isTrue(resultsData.styling.cardClass.contains('exceptional'), 
            'Should have exceptional styling class');
        
        // Verify minimal weak areas
        Integer weakAreaCount = resultsData.weakAreas.size();
        Assert.isTrue(weakAreaCount <= 1, 
            'Excellent performance should have few or no weak areas');
        
        // Verify topic scores are mostly high
        Boolean hasHighScores = false;
        for (ResultsSummaryController.TopicScore topicScore : resultsData.topicBreakdown) {
            if (topicScore.scorePercentage >= 85) {
                hasHighScores = true;
                Assert.areEqual('Mastered', topicScore.performanceLevel, 
                    'High scores should be marked as mastered');
            }
        }
        Assert.isTrue(hasHighScores, 'Should have high-performing topics');
    }
    
    /**
     * @description Test topic breakdown calculation
     */
    @IsTest
    static void testTopicBreakdownCalculation() {
        ExamSession__c examSession = [SELECT Id FROM ExamSession__c LIMIT 1];
        
        Test.startTest();
        ResultsSummaryController.ExamResultsData resultsData = 
            ResultsSummaryController.getExamResults(examSession.Id);
        Test.stopTest();
        
        // Verify topic breakdown structure
        Assert.isTrue(resultsData.topicBreakdown.size() > 0, 
            'Should have topic breakdown data');
        
        for (ResultsSummaryController.TopicScore topicScore : resultsData.topicBreakdown) {
            // Verify required fields
            Assert.isNotNull(topicScore.topicName, 'Topic name should be set');
            Assert.isNotNull(topicScore.topicDisplayName, 'Topic display name should be set');
            Assert.isTrue(topicScore.scorePercentage >= 0, 
                'Score percentage should be non-negative');
            Assert.isNotNull(topicScore.scoreDisplay, 'Score display should be formatted');
            Assert.isTrue(topicScore.questionsAnswered > 0, 
                'Should have questions answered');
            Assert.isNotNull(topicScore.performanceLevel, 
                'Performance level should be determined');
            Assert.isNotNull(topicScore.iconName, 'Icon should be assigned');
            Assert.isNotNull(topicScore.colorClass, 'Color class should be assigned');
            Assert.isNotNull(topicScore.improvementSuggestion, 
                'Improvement suggestion should be provided');
            
            // Verify performance level mapping
            if (topicScore.scorePercentage >= 85) {
                Assert.areEqual('Mastered', topicScore.performanceLevel, 
                    'High scores should be mastered');
                Assert.isFalse(topicScore.isWeakArea, 
                    'Mastered topics should not be weak areas');
            } else if (topicScore.scorePercentage < 55) {
                Assert.areEqual('Needs Work', topicScore.performanceLevel, 
                    'Low scores should need work');
                Assert.isTrue(topicScore.isWeakArea, 
                    'Low scoring topics should be weak areas');
            }
        }
    }
    
    /**
     * @description Test weak area identification
     */
    @IsTest
    static void testWeakAreaIdentification() {
        // Get failing exam (should have weak areas)
        ExamSession__c failingSession = [
            SELECT Id FROM ExamSession__c 
            WHERE FinalScore__c < 63
            LIMIT 1
        ];
        
        Test.startTest();
        ResultsSummaryController.ExamResultsData resultsData = 
            ResultsSummaryController.getExamResults(failingSession.Id);
        Test.stopTest();
        
        Assert.isTrue(resultsData.weakAreas.size() > 0, 
            'Failing exam should identify weak areas');
        
        for (ResultsSummaryController.WeakArea weakArea : resultsData.weakAreas) {
            // Verify weak area structure
            Assert.isNotNull(weakArea.topicName, 'Topic name should be set');
            Assert.isNotNull(weakArea.topicDisplayName, 'Topic display name should be set');
            Assert.isTrue(weakArea.currentScore < 75, 
                'Weak areas should have low scores');
            Assert.isNotNull(weakArea.priorityLevel, 'Priority level should be set');
            Assert.isNotNull(weakArea.recommendation, 'Recommendation should be provided');
            Assert.isTrue(weakArea.additionalQuestionsNeeded > 0, 
                'Should recommend additional questions');
            Assert.isTrue(weakArea.estimatedStudyHours > 0, 
                'Should estimate study hours needed');
            Assert.isNotNull(weakArea.focusAreaUrl, 'Focus area URL should be provided');
            Assert.isNotNull(weakArea.keyConceptsToReview, 
                'Key concepts should be listed');
            
            // Verify priority level logic
            if (weakArea.currentScore < 50) {
                Assert.areEqual('High', weakArea.priorityLevel, 
                    'Very low scores should be high priority');
            } else if (weakArea.currentScore < 65) {
                Assert.areEqual('Medium', weakArea.priorityLevel, 
                    'Moderate scores should be medium priority');
            } else {
                Assert.areEqual('Low', weakArea.priorityLevel, 
                    'Higher scores should be low priority');
            }
        }
    }
    
    /**
     * @description Test getting latest exam results
     */
    @IsTest
    static void testGetLatestExamResults() {
        Test.startTest();
        ResultsSummaryController.ExamResultsData resultsData = 
            ResultsSummaryController.getLatestExamResults();
        Test.stopTest();
        
        Assert.isNotNull(resultsData, 'Should return latest exam results');
        Assert.isNotNull(resultsData.examSessionId, 'Should have exam session ID');
        Assert.isNotNull(resultsData.examSummary, 'Should have exam summary');
        
        // Should be most recent exam (based on test data setup)
        Assert.isTrue(resultsData.examSummary.finalScore > 0, 
            'Should have valid final score');
    }
    
    /**
     * @description Test recording results actions
     */
    @IsTest
    static void testRecordResultsAction() {
        ExamSession__c examSession = [SELECT Id FROM ExamSession__c LIMIT 1];
        
        Test.startTest();
        Boolean result1 = ResultsSummaryController.recordResultsAction(
            'view-certificate', examSession.Id);
        Boolean result2 = ResultsSummaryController.recordResultsAction(
            'create-study-plan', examSession.Id);
        Test.stopTest();
        
        Assert.isTrue(result1, 'Should successfully record certificate view');
        Assert.isTrue(result2, 'Should successfully record study plan creation');
        
        // Test with null values
        Boolean result3 = ResultsSummaryController.recordResultsAction(null, null);
        Assert.isTrue(result3, 'Should handle null values gracefully');
    }
    
    /**
     * @description Test error handling for invalid exam session
     */
    @IsTest
    static void testErrorHandlingInvalidSession() {
        Test.startTest();
        try {
            ResultsSummaryController.getExamResults('invalid-session-id');
            Assert.fail('Should throw exception for invalid session ID');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Exam session not found'), 
                'Should provide appropriate error message');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test error handling for blank exam session ID
     */
    @IsTest
    static void testErrorHandlingBlankSessionId() {
        Test.startTest();
        try {
            ResultsSummaryController.getExamResults('');
            Assert.fail('Should throw exception for blank session ID');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('required'), 
                'Should indicate session ID is required');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test no completed exams scenario
     */
    @IsTest
    static void testNoCompletedExams() {
        // Delete all exam sessions
        delete [SELECT Id FROM ExamSession__c];
        
        Test.startTest();
        try {
            ResultsSummaryController.getLatestExamResults();
            Assert.fail('Should throw exception when no completed exams exist');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('No completed exam sessions'), 
                'Should indicate no completed exams found');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test certification information generation
     */
    @IsTest
    static void testCertificationInfoGeneration() {
        // Get passing exam session
        ExamSession__c passingSession = [
            SELECT Id FROM ExamSession__c 
            WHERE FinalScore__c >= 63
            LIMIT 1
        ];
        
        Test.startTest();
        ResultsSummaryController.ExamResultsData resultsData = 
            ResultsSummaryController.getExamResults(passingSession.Id);
        Test.stopTest();
        
        // Verify certification info is generated for passing exam
        Assert.isNotNull(resultsData.certificationInfo, 
            'Certification info should be generated for passed exam');
        
        ResultsSummaryController.CertificationInfo certInfo = resultsData.certificationInfo;
        Assert.isNotNull(certInfo.certificateName, 'Certificate name should be set');
        Assert.isNotNull(certInfo.certificateId, 'Certificate ID should be generated');
        Assert.isNotNull(certInfo.certificateUrl, 'Certificate URL should be provided');
        Assert.isNotNull(certInfo.issueDate, 'Issue date should be set');
        Assert.isNotNull(certInfo.expirationDate, 'Expiration date should be calculated');
        Assert.areEqual(3, certInfo.validityYears, 'Should have 3 year validity');
        Assert.isNotNull(certInfo.nextRecommendedCertifications, 
            'Next certifications should be recommended');
        Assert.isTrue(certInfo.nextRecommendedCertifications.size() > 0, 
            'Should have next certification recommendations');
    }
    
    /**
     * @description Test visual styling determination
     */
    @IsTest
    static void testVisualStylingDetermination() {
        // Test passing exam styling
        ExamSession__c passingSession = [
            SELECT Id FROM ExamSession__c 
            WHERE FinalScore__c >= 63
            LIMIT 1
        ];
        
        Test.startTest();
        ResultsSummaryController.ExamResultsData passingResults = 
            ResultsSummaryController.getExamResults(passingSession.Id);
        Test.stopTest();
        
        ResultsSummaryController.VisualStyling passStyling = passingResults.styling;
        Assert.areEqual('#4facfe', passStyling.primaryColor, 
            'Pass styling should use blue primary color');
        Assert.areEqual('utility:success', passStyling.resultIconName, 
            'Pass styling should use success icon');
        Assert.isTrue(passStyling.cardClass.contains('pass'), 
            'Pass styling should include pass card class');
        
        // Test failing exam styling
        ExamSession__c failingSession = [
            SELECT Id FROM ExamSession__c 
            WHERE FinalScore__c < 63
            LIMIT 1
        ];
        
        Test.startTest();
        ResultsSummaryController.ExamResultsData failingResults = 
            ResultsSummaryController.getExamResults(failingSession.Id);
        Test.stopTest();
        
        ResultsSummaryController.VisualStyling failStyling = failingResults.styling;
        Assert.areEqual('#ff9a9e', failStyling.primaryColor, 
            'Fail styling should use pink primary color');
        Assert.areEqual('utility:refresh', failStyling.resultIconName, 
            'Fail styling should use refresh icon');
        Assert.isTrue(failStyling.cardClass.contains('retry'), 
            'Fail styling should include retry card class');
    }
    
    /**
     * @description Test attempt number tracking
     */
    @IsTest
    static void testAttemptNumberTracking() {
        ExamSession__c examSession = [SELECT Id FROM ExamSession__c LIMIT 1];
        
        Test.startTest();
        ResultsSummaryController.ExamResultsData resultsData = 
            ResultsSummaryController.getExamResults(examSession.Id);
        Test.stopTest();
        
        Assert.isTrue(resultsData.attemptNumber > 0, 
            'Attempt number should be positive');
        
        // Verify attempt number is calculated correctly based on setup data
        // (Setup creates multiple sessions for same user/track)
        Assert.isTrue(resultsData.attemptNumber <= 3, 
            'Attempt number should reflect actual sessions created');
    }
    
    /**
     * @description Test data structure initialization
     */
    @IsTest
    static void testDataStructureInitialization() {
        Test.startTest();
        
        // Test ExamResultsData constructor
        ResultsSummaryController.ExamResultsData resultsData = 
            new ResultsSummaryController.ExamResultsData();
        Assert.isNotNull(resultsData.topicBreakdown, 
            'Topic breakdown list should be initialized');
        Assert.isNotNull(resultsData.weakAreas, 
            'Weak areas list should be initialized');
        Assert.isNotNull(resultsData.nextSteps, 
            'Next steps list should be initialized');
        
        // Test WeakArea constructor
        ResultsSummaryController.WeakArea weakArea = 
            new ResultsSummaryController.WeakArea();
        Assert.isNotNull(weakArea.keyConceptsToReview, 
            'Key concepts list should be initialized');
        
        // Test CertificationInfo constructor
        ResultsSummaryController.CertificationInfo certInfo = 
            new ResultsSummaryController.CertificationInfo();
        Assert.isNotNull(certInfo.nextRecommendedCertifications, 
            'Next certifications list should be initialized');
        
        Test.stopTest();
    }
    
    /**
     * @description Test next step action generation variations
     */
    @IsTest
    static void testNextStepActionVariations() {
        // Test passed exam actions
        ExamSession__c passingSession = [
            SELECT Id FROM ExamSession__c 
            WHERE FinalScore__c >= 63
            LIMIT 1
        ];
        
        Test.startTest();
        ResultsSummaryController.ExamResultsData passingResults = 
            ResultsSummaryController.getExamResults(passingSession.Id);
        Test.stopTest();
        
        // Verify passing exam actions
        Set<String> passingActionIds = new Set<String>();
        for (ResultsSummaryController.NextStepAction action : passingResults.nextSteps) {
            passingActionIds.add(action.actionId);
            Assert.isNotNull(action.title, 'Action title should be set');
            Assert.isNotNull(action.description, 'Action description should be set');
            Assert.isNotNull(action.actionUrl, 'Action URL should be set');
            Assert.isNotNull(action.priority, 'Priority should be set');
            Assert.isNotNull(action.estimatedTimeCommitment, 
                'Time commitment should be estimated');
        }
        
        Assert.isTrue(passingActionIds.contains('view-certificate'), 
            'Should have view certificate action for passed exam');
        Assert.isTrue(passingActionIds.contains('whats-next'), 
            'Should have what\'s next action for passed exam');
        
        // Test failed exam actions
        ExamSession__c failingSession = [
            SELECT Id FROM ExamSession__c 
            WHERE FinalScore__c < 63
            LIMIT 1
        ];
        
        Test.startTest();
        ResultsSummaryController.ExamResultsData failingResults = 
            ResultsSummaryController.getExamResults(failingSession.Id);
        Test.stopTest();
        
        Set<String> failingActionIds = new Set<String>();
        for (ResultsSummaryController.NextStepAction action : failingResults.nextSteps) {
            failingActionIds.add(action.actionId);
        }
        
        Assert.isTrue(failingActionIds.contains('create-study-plan'), 
            'Should have create study plan action for failed exam');
        Assert.isTrue(failingActionIds.contains('practice-more'), 
            'Should have practice more action for failed exam');
    }
}