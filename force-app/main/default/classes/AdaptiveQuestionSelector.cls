/**
 * @description Decision Matrix for adaptive question selection in OmniStudio Training
 * @author Claude AI OmniStudio Training
 * @date 2025-08-12
 */
public with sharing class AdaptiveQuestionSelector {
    
    // Constants for certification tracks
    public static final String CONSULTANT_TRACK = 'Consultant';
    public static final String DEVELOPER_TRACK = 'Developer';
    
    // Constants for difficulty levels
    public static final Integer MIN_DIFFICULTY = 1;
    public static final Integer MAX_DIFFICULTY = 5;
    
    // Performance thresholds
    private static final Decimal ADVANCEMENT_THRESHOLD = 0.75; // 75% correct to advance
    private static final Decimal REMEDIATION_THRESHOLD = 0.50; // Below 50% needs remediation
    
    /**
     * @description Main decision matrix entry point for adaptive question selection
     * @param userId User ID for personalization
     * @param certificationTrack Certification track (Consultant/Developer)
     * @param requestedQuestionCount Number of questions requested
     * @return List of selected question IDs with adaptive routing
     */
    public static List<String> selectAdaptiveQuestions(Id userId, String certificationTrack, Integer requestedQuestionCount) {
        try {
            // Get user performance data
            UserPerformanceData userPerformance = UserPerformanceTracker.getUserPerformance(userId);
            
            // Identify weak areas for topic selection
            List<String> priorityTopics = identifyWeakAreas(userPerformance, certificationTrack);
            
            // Calculate appropriate difficulty level
            Integer targetDifficulty = calculateDifficultyLevel(userPerformance);
            
            // Apply question type variation strategy
            Map<String, Integer> questionTypeDistribution = calculateQuestionTypeDistribution(requestedQuestionCount);
            
            // Get questions using decision matrix
            List<String> selectedQuestions = executeDecisionMatrix(
                priorityTopics,
                targetDifficulty,
                questionTypeDistribution,
                certificationTrack,
                userId
            );
            
            // Apply fallback logic if insufficient questions
            if (selectedQuestions.size() < requestedQuestionCount) {
                selectedQuestions.addAll(getFallbackQuestions(
                    requestedQuestionCount - selectedQuestions.size(),
                    certificationTrack,
                    selectedQuestions
                ));
            }
            
            // Log selection for performance tracking
            logQuestionSelection(userId, selectedQuestions, certificationTrack);
            
            return selectedQuestions;
            
        } catch (Exception e) {
            System.debug('Error in adaptive question selection: ' + e.getMessage());
            // Fallback to random selection for new users
            return getRandomQuestions(requestedQuestionCount, certificationTrack);
        }
    }
    
    /**
     * @description Identifies user's weak areas based on performance history
     * @param userPerformance User performance data
     * @param certificationTrack Certification track for topic filtering
     * @return List of priority topics to focus on
     */
    private static List<String> identifyWeakAreas(UserPerformanceData userPerformance, String certificationTrack) {
        List<String> weakAreas = new List<String>();
        
        // Get certification-specific topics
        List<String> availableTopics = CertificationRouter.getTopicsForTrack(certificationTrack);
        
        // Analyze performance by topic
        for (String topic : availableTopics) {
            Decimal topicPerformance = userPerformance.getTopicPerformance(topic);
            
            // Topics below remediation threshold get highest priority
            if (topicPerformance < REMEDIATION_THRESHOLD) {
                weakAreas.add(topic);
            }
        }
        
        // If no weak areas, focus on lowest performing topics
        if (weakAreas.isEmpty()) {
            weakAreas = userPerformance.getLowestPerformingTopics(3);
        }
        
        // If still empty (new user), use balanced approach
        if (weakAreas.isEmpty()) {
            weakAreas = availableTopics;
        }
        
        return weakAreas;
    }
    
    /**
     * @description Calculates appropriate difficulty level based on user performance
     * @param userPerformance User performance data
     * @return Target difficulty level (1-5)
     */
    private static Integer calculateDifficultyLevel(UserPerformanceData userPerformance) {
        Decimal overallPerformance = userPerformance.getOverallPerformance();
        
        // New user starts at level 2
        if (userPerformance.getTotalQuestionsAnswered() == 0) {
            return 2;
        }
        
        // Performance-based difficulty adjustment
        if (overallPerformance >= 0.85) {
            return Math.min(userPerformance.getCurrentDifficulty() + 1, MAX_DIFFICULTY);
        } else if (overallPerformance >= ADVANCEMENT_THRESHOLD) {
            return userPerformance.getCurrentDifficulty(); // Maintain current level
        } else if (overallPerformance < REMEDIATION_THRESHOLD) {
            return Math.max(userPerformance.getCurrentDifficulty() - 1, MIN_DIFFICULTY);
        } else {
            return userPerformance.getCurrentDifficulty(); // Slight decrease for struggle
        }
    }
    
    /**
     * @description Calculates question type distribution to maintain engagement
     * @param totalQuestions Total number of questions requested
     * @return Map of question type to count distribution
     */
    private static Map<String, Integer> calculateQuestionTypeDistribution(Integer totalQuestions) {
        Map<String, Integer> distribution = new Map<String, Integer>();
        
        // Ensure variety in question types (prevent monotony)
        Integer multipleChoiceCount = (Integer) Math.ceil(totalQuestions * 0.70); // 70% multiple choice
        Integer scenarioCount = (Integer) Math.ceil(totalQuestions * 0.20); // 20% scenario-based
        Integer practicalCount = totalQuestions - multipleChoiceCount - scenarioCount; // Remainder practical
        
        distribution.put('MultipleChoice', multipleChoiceCount);
        distribution.put('Scenario', scenarioCount);
        distribution.put('Practical', Math.max(practicalCount, 0));
        
        return distribution;
    }
    
    /**
     * @description Executes the main decision matrix logic
     * @param priorityTopics Topics to focus on
     * @param targetDifficulty Target difficulty level
     * @param questionTypeDistribution Question type distribution
     * @param certificationTrack Certification track
     * @param userId User ID for logging
     * @return List of selected question IDs
     */
    private static List<String> executeDecisionMatrix(
        List<String> priorityTopics,
        Integer targetDifficulty,
        Map<String, Integer> questionTypeDistribution,
        String certificationTrack,
        Id userId
    ) {
        List<String> selectedQuestions = new List<String>();
        
        // Query questions based on decision matrix criteria
        String query = 'SELECT Id, Topic__c, Difficulty__c, QuestionType__c, CertificationTrack__c ' +
                       'FROM Question__c ' +
                       'WHERE CertificationTrack__c = :certificationTrack ' +
                       'AND Topic__c IN :priorityTopics ' +
                       'AND Difficulty__c = :targetDifficulty ' +
                       'AND Active__c = true ' +
                       'ORDER BY LastUsed__c ASC NULLS FIRST, CreatedDate DESC';
        
        List<SObject> questions = Database.query(query);
        
        // Distribute questions by type
        for (String questionType : questionTypeDistribution.keySet()) {
            Integer neededCount = questionTypeDistribution.get(questionType);
            Integer foundCount = 0;
            
            for (SObject question : questions) {
                if (foundCount >= neededCount) break;
                
                if (String.valueOf(question.get('QuestionType__c')) == questionType) {
                    selectedQuestions.add(String.valueOf(question.get('Id')));
                    foundCount++;
                }
            }
        }
        
        return selectedQuestions;
    }
    
    /**
     * @description Provides fallback questions when insufficient questions found
     * @param neededCount Number of additional questions needed
     * @param certificationTrack Certification track
     * @param excludeQuestions Questions to exclude
     * @return List of fallback question IDs
     */
    private static List<String> getFallbackQuestions(Integer neededCount, String certificationTrack, List<String> excludeQuestions) {
        List<String> fallbackQuestions = new List<String>();
        
        String query = 'SELECT Id FROM Question__c ' +
                       'WHERE CertificationTrack__c = :certificationTrack ' +
                       'AND Active__c = true ' +
                       'AND Id NOT IN :excludeQuestions ' +
                       'ORDER BY RANDOM() ' +
                       'LIMIT :neededCount';
        
        List<SObject> questions = Database.query(query);
        
        for (SObject question : questions) {
            fallbackQuestions.add(String.valueOf(question.get('Id')));
        }
        
        return fallbackQuestions;
    }
    
    /**
     * @description Provides random questions for new users without performance history
     * @param questionCount Number of questions requested
     * @param certificationTrack Certification track
     * @return List of random question IDs
     */
    private static List<String> getRandomQuestions(Integer questionCount, String certificationTrack) {
        List<String> randomQuestions = new List<String>();
        
        String query = 'SELECT Id FROM Question__c ' +
                       'WHERE CertificationTrack__c = :certificationTrack ' +
                       'AND Active__c = true ' +
                       'AND Difficulty__c = 2 ' + // Start new users at medium difficulty
                       'ORDER BY RANDOM() ' +
                       'LIMIT :questionCount';
        
        List<SObject> questions = Database.query(query);
        
        for (SObject question : questions) {
            randomQuestions.add(String.valueOf(question.get('Id')));
        }
        
        return randomQuestions;
    }
    
    /**
     * @description Logs question selection for performance tracking
     * @param userId User ID
     * @param selectedQuestions Selected question IDs
     * @param certificationTrack Certification track
     */
    private static void logQuestionSelection(Id userId, List<String> selectedQuestions, String certificationTrack) {
        // Create question selection log record
        QuestionSelectionLog__c log = new QuestionSelectionLog__c(
            User__c = userId,
            CertificationTrack__c = certificationTrack,
            QuestionsSelected__c = String.join(selectedQuestions, ','),
            SelectionTimestamp__c = DateTime.now(),
            SelectionMethod__c = 'Adaptive'
        );
        
        try {
            insert log;
        } catch (Exception e) {
            System.debug('Failed to log question selection: ' + e.getMessage());
        }
    }
}