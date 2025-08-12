/**
 * @description Weighted Question Distribution System for OmniStudio Training Platform
 * @author Claude Code Assistant
 * @since User Story #17 - Weighted Question Distribution
 * @version 1.0
 * 
 * This class manages question bank distribution to match official Salesforce
 * certification exam weightings, ensuring practice sessions accurately reflect
 * real exam patterns and difficulty distribution.
 */
public with sharing class WeightedQuestionDistribution {
    
    /**
     * @description Question bank statistics and metadata
     */
    public class QuestionBankStats {
        public String certificationTrack {get; set;}
        public Integer totalQuestions {get; set;}
        public Map<String, Integer> topicCounts {get; set;}
        public Map<String, Decimal> actualWeights {get; set;}
        public Map<String, Decimal> targetWeights {get; set;}
        public Map<String, Decimal> deviations {get; set;}
        public DateTime lastUpdated {get; set;}
        public Boolean meetsMinimumRequirements {get; set;}
        
        public QuestionBankStats() {
            this.topicCounts = new Map<String, Integer>();
            this.actualWeights = new Map<String, Decimal>();
            this.targetWeights = new Map<String, Decimal>();
            this.deviations = new Map<String, Decimal>();
        }
    }
    
    /**
     * @description Question selection parameters for practice sessions
     */
    public class QuestionSelectionRequest {
        public String certificationTrack {get; set;}
        public Integer requestedQuestions {get; set;}
        public String difficultyFocus {get; set;} // 'Balanced', 'Progressive', 'Advanced'
        public Set<String> excludeTopics {get; set;}
        public Set<String> focusTopics {get; set;}
        public List<String> excludeQuestionIds {get; set;}
        public Boolean enforceWeighting {get; set;}
        public String sessionType {get; set;} // 'Practice', 'Mock_Exam', 'Topic_Focus'
        
        public QuestionSelectionRequest() {
            this.excludeTopics = new Set<String>();
            this.focusTopics = new Set<String>();
            this.excludeQuestionIds = new List<String>();
            this.enforceWeighting = true;
            this.difficultyFocus = 'Balanced';
            this.sessionType = 'Practice';
        }
    }
    
    /**
     * @description Selected question set with metadata
     */
    public class QuestionSet {
        public List<Question__c> questions {get; set;}
        public Map<String, Integer> topicDistribution {get; set;}
        public Map<String, Integer> difficultyDistribution {get; set;}
        public Map<String, Integer> questionTypeDistribution {get; set;}
        public Integer totalEstimatedMinutes {get; set;}
        public Decimal averageDifficulty {get; set;}
        public String selectionStrategy {get; set;}
        public DateTime generatedAt {get; set;}
        
        public QuestionSet() {
            this.questions = new List<Question__c>();
            this.topicDistribution = new Map<String, Integer>();
            this.difficultyDistribution = new Map<String, Integer>();
            this.questionTypeDistribution = new Map<String, Integer>();
            this.generatedAt = DateTime.now();
        }
    }
    
    /**
     * @description Question effectiveness analytics
     */
    public class QuestionAnalytics {
        public String questionId {get; set;}
        public String topic {get; set;}
        public Integer totalAttempts {get; set;}
        public Decimal correctRate {get; set;}
        public Decimal averageResponseTime {get; set;}
        public Decimal difficultyRating {get; set;}
        public Integer reportedIssues {get; set;}
        public DateTime lastUsed {get; set;}
        public String effectivenessScore {get; set;} // 'Excellent', 'Good', 'Fair', 'Poor'
        
        public QuestionAnalytics() {
            this.totalAttempts = 0;
            this.correctRate = 0.0;
            this.averageResponseTime = 0.0;
            this.reportedIssues = 0;
        }
    }
    
    // Constants for minimum question bank requirements
    private static final Integer MINIMUM_QUESTIONS_PER_TRACK = 400;
    private static final Integer MINIMUM_QUESTIONS_PER_TOPIC = 50;
    private static final Decimal ACCEPTABLE_WEIGHT_DEVIATION = 5.0; // 5% deviation tolerance
    
    /**
     * @description Get current question bank statistics for a certification track
     * @param certificationTrack The certification track to analyze
     * @return QuestionBankStats current statistics
     */
    public static QuestionBankStats getQuestionBankStats(String certificationTrack) {
        QuestionBankStats stats = new QuestionBankStats();
        stats.certificationTrack = certificationTrack;
        stats.lastUpdated = DateTime.now();
        
        // Get target weights from categorization framework
        Map<String, Decimal> targetWeights;
        if (certificationTrack == 'Consultant') {
            targetWeights = QuestionCategorization.CONSULTANT_TOPIC_WEIGHTS;
        } else if (certificationTrack == 'Developer') {
            targetWeights = QuestionCategorization.DEVELOPER_TOPIC_WEIGHTS;
        } else {
            throw new IllegalArgumentException('Invalid certification track: ' + certificationTrack);
        }
        
        stats.targetWeights = targetWeights;
        
        // Query actual question distribution
        List<AggregateResult> topicCounts = [
            SELECT Topic__c, COUNT(Id) questionCount
            FROM Question__c 
            WHERE CertificationTrack__c = :certificationTrack 
              AND Active__c = true
            GROUP BY Topic__c
        ];
        
        Integer totalQuestions = 0;
        for (AggregateResult ar : topicCounts) {
            String topic = (String) ar.get('Topic__c');
            Integer count = (Integer) ar.get('questionCount');
            stats.topicCounts.put(topic, count);
            totalQuestions += count;
        }
        
        stats.totalQuestions = totalQuestions;
        stats.meetsMinimumRequirements = (totalQuestions >= MINIMUM_QUESTIONS_PER_TRACK);
        
        // Calculate actual weights and deviations
        for (String topic : targetWeights.keySet()) {
            Integer actualCount = stats.topicCounts.containsKey(topic) ? stats.topicCounts.get(topic) : 0;
            Decimal actualWeight = totalQuestions > 0 ? (actualCount * 100.0) / totalQuestions : 0;
            Decimal targetWeight = targetWeights.get(topic);
            Decimal deviation = actualWeight - targetWeight;
            
            stats.actualWeights.put(topic, actualWeight);
            stats.deviations.put(topic, deviation);
            
            // Check minimum questions per topic
            if (actualCount < MINIMUM_QUESTIONS_PER_TOPIC) {
                stats.meetsMinimumRequirements = false;
            }
        }
        
        return stats;
    }
    
    /**
     * @description Select questions for practice session with weighted distribution
     * @param request Question selection parameters
     * @return QuestionSet selected questions with metadata
     */
    public static QuestionSet selectWeightedQuestions(QuestionSelectionRequest request) {
        QuestionSet result = new QuestionSet();
        result.selectionStrategy = buildSelectionStrategy(request);
        
        // Calculate target distribution based on weights
        Map<String, Integer> targetDistribution = calculateTargetDistribution(
            request.certificationTrack, 
            request.requestedQuestions,
            request.focusTopics
        );
        
        // Select questions for each topic
        for (String topic : targetDistribution.keySet()) {
            Integer targetCount = targetDistribution.get(topic);
            
            if (request.excludeTopics.contains(topic)) {
                continue; // Skip excluded topics
            }
            
            List<Question__c> topicQuestions = selectQuestionsForTopic(
                request.certificationTrack,
                topic,
                targetCount,
                request.difficultyFocus,
                request.excludeQuestionIds
            );
            
            result.questions.addAll(topicQuestions);
            result.topicDistribution.put(topic, topicQuestions.size());
        }
        
        // Randomize final order while maintaining distribution
        result.questions = randomizeQuestionOrder(result.questions);
        
        // Calculate metadata
        calculateQuestionSetMetadata(result);
        
        return result;
    }
    
    /**
     * @description Calculate target question distribution based on exam weights
     * @param certificationTrack The certification track
     * @param totalQuestions Total number of questions requested
     * @param focusTopics Topics to emphasize (optional)
     * @return Map<String, Integer> topic to question count mapping
     */
    private static Map<String, Integer> calculateTargetDistribution(String certificationTrack, 
                                                                   Integer totalQuestions, 
                                                                   Set<String> focusTopics) {
        Map<String, Integer> distribution = new Map<String, Integer>();
        Map<String, Decimal> weights;
        
        if (certificationTrack == 'Consultant') {
            weights = QuestionCategorization.CONSULTANT_TOPIC_WEIGHTS;
        } else if (certificationTrack == 'Developer') {
            weights = QuestionCategorization.DEVELOPER_TOPIC_WEIGHTS;
        } else {
            return distribution;
        }
        
        // Adjust weights if focus topics are specified
        if (!focusTopics.isEmpty()) {
            weights = adjustWeightsForFocusTopics(weights, focusTopics);
        }
        
        Integer allocatedQuestions = 0;
        List<String> topics = new List<String>(weights.keySet());
        
        // Calculate base allocation
        for (Integer i = 0; i < topics.size() - 1; i++) {
            String topic = topics[i];
            Decimal weight = weights.get(topic);
            Integer questionCount = Integer.valueOf((weight / 100.0) * totalQuestions);
            distribution.put(topic, questionCount);
            allocatedQuestions += questionCount;
        }
        
        // Assign remaining questions to last topic
        if (!topics.isEmpty()) {
            String lastTopic = topics[topics.size() - 1];
            distribution.put(lastTopic, totalQuestions - allocatedQuestions);
        }
        
        return distribution;
    }
    
    /**
     * @description Adjust topic weights when focus topics are specified
     * @param originalWeights The original topic weights
     * @param focusTopics Topics to emphasize
     * @return Map<String, Decimal> adjusted weights
     */
    private static Map<String, Decimal> adjustWeightsForFocusTopics(Map<String, Decimal> originalWeights, 
                                                                   Set<String> focusTopics) {
        Map<String, Decimal> adjustedWeights = new Map<String, Decimal>();
        Decimal focusBoost = 1.5; // 50% increase for focus topics
        Decimal totalOriginalWeight = 0;
        Decimal totalAdjustedWeight = 0;
        
        // Calculate adjusted weights
        for (String topic : originalWeights.keySet()) {
            Decimal originalWeight = originalWeights.get(topic);
            totalOriginalWeight += originalWeight;
            
            if (focusTopics.contains(topic)) {
                adjustedWeights.put(topic, originalWeight * focusBoost);
            } else {
                adjustedWeights.put(topic, originalWeight);
            }
        }
        
        // Calculate total adjusted weight
        for (Decimal weight : adjustedWeights.values()) {
            totalAdjustedWeight += weight;
        }
        
        // Normalize to 100%
        for (String topic : adjustedWeights.keySet()) {
            Decimal normalizedWeight = (adjustedWeights.get(topic) / totalAdjustedWeight) * 100;
            adjustedWeights.put(topic, normalizedWeight);
        }
        
        return adjustedWeights;
    }
    
    /**
     * @description Select questions for a specific topic with difficulty considerations
     * @param certificationTrack The certification track
     * @param topic The topic to select questions for
     * @param targetCount Number of questions to select
     * @param difficultyFocus Difficulty distribution strategy
     * @param excludeIds Question IDs to exclude
     * @return List<Question__c> selected questions
     */
    private static List<Question__c> selectQuestionsForTopic(String certificationTrack,
                                                           String topic,
                                                           Integer targetCount,
                                                           String difficultyFocus,
                                                           List<String> excludeIds) {
        
        // Build difficulty distribution based on focus
        Map<Integer, Integer> difficultyTargets = calculateDifficultyDistribution(targetCount, difficultyFocus);
        
        List<Question__c> selectedQuestions = new List<Question__c>();
        
        // Select questions for each difficulty level
        for (Integer difficultyLevel : difficultyTargets.keySet()) {
            Integer neededCount = difficultyTargets.get(difficultyLevel);
            
            String query = 'SELECT Id, QuestionText__c, Topic__c, Difficulty__c, QuestionType__c, ' +
                          'CorrectAnswer__c, OptionA__c, OptionB__c, OptionC__c, OptionD__c, ' +
                          'Explanation__c, UsageCount__c, EstimatedTimeSeconds__c ' +
                          'FROM Question__c ' +
                          'WHERE CertificationTrack__c = :certificationTrack ' +
                          'AND Topic__c = :topic ' +
                          'AND Difficulty__c = :difficultyLevel ' +
                          'AND Active__c = true';
            
            if (!excludeIds.isEmpty()) {
                query += ' AND Id NOT IN :excludeIds';
            }
            
            // Prioritize less-used questions
            query += ' ORDER BY UsageCount__c ASC, RANDOM() ' +
                    'LIMIT :neededCount';
            
            List<Question__c> difficultyQuestions = Database.query(query);
            selectedQuestions.addAll(difficultyQuestions);
        }
        
        return selectedQuestions;
    }
    
    /**
     * @description Calculate difficulty distribution based on focus strategy
     * @param totalQuestions Total questions needed
     * @param difficultyFocus The difficulty focus strategy
     * @return Map<Integer, Integer> difficulty level to count mapping
     */
    private static Map<Integer, Integer> calculateDifficultyDistribution(Integer totalQuestions, String difficultyFocus) {
        Map<Integer, Integer> distribution = new Map<Integer, Integer>();
        
        switch on difficultyFocus {
            when 'Balanced' {
                // Even distribution across all difficulty levels
                Integer perLevel = totalQuestions / 3;
                Integer remainder = Math.mod(totalQuestions, 3);
                
                distribution.put(1, perLevel + (remainder > 0 ? 1 : 0)); // Beginner
                distribution.put(2, perLevel + (remainder > 1 ? 1 : 0)); // Intermediate  
                distribution.put(3, perLevel); // Advanced
            }
            when 'Progressive' {
                // More beginner and intermediate, fewer advanced
                distribution.put(1, Integer.valueOf(totalQuestions * 0.4)); // 40% Beginner
                distribution.put(2, Integer.valueOf(totalQuestions * 0.4)); // 40% Intermediate
                distribution.put(3, totalQuestions - distribution.get(1) - distribution.get(2)); // 20% Advanced
            }
            when 'Advanced' {
                // More intermediate and advanced, fewer beginner
                distribution.put(1, Integer.valueOf(totalQuestions * 0.2)); // 20% Beginner
                distribution.put(2, Integer.valueOf(totalQuestions * 0.4)); // 40% Intermediate
                distribution.put(3, totalQuestions - distribution.get(1) - distribution.get(2)); // 40% Advanced
            }
            when else {
                // Default to balanced
                return calculateDifficultyDistribution(totalQuestions, 'Balanced');
            }
        }
        
        return distribution;
    }
    
    /**
     * @description Randomize question order while preserving metadata
     * @param questions List of questions to randomize
     * @return List<Question__c> randomized questions
     */
    private static List<Question__c> randomizeQuestionOrder(List<Question__c> questions) {
        // Create list of indices
        List<Integer> indices = new List<Integer>();
        for (Integer i = 0; i < questions.size(); i++) {
            indices.add(i);
        }
        
        // Shuffle indices using Fisher-Yates algorithm
        for (Integer i = indices.size() - 1; i > 0; i--) {
            Integer j = Integer.valueOf(Math.random() * (i + 1));
            Integer temp = indices[i];
            indices[i] = indices[j];
            indices[j] = temp;
        }
        
        // Build randomized list
        List<Question__c> randomized = new List<Question__c>();
        for (Integer index : indices) {
            randomized.add(questions[index]);
        }
        
        return randomized;
    }
    
    /**
     * @description Calculate metadata for the selected question set
     * @param questionSet The question set to analyze
     */
    private static void calculateQuestionSetMetadata(QuestionSet questionSet) {
        Integer totalTime = 0;
        Integer totalDifficulty = 0;
        Map<String, Integer> typeCount = new Map<String, Integer>();
        Map<String, Integer> difficultyCount = new Map<String, Integer>();
        
        for (Question__c q : questionSet.questions) {
            // Time estimation
            if (q.EstimatedTimeSeconds__c != null) {
                totalTime += Integer.valueOf(q.EstimatedTimeSeconds__c);
            } else {
                // Default time based on type and difficulty
                totalTime += QuestionCategorization.getEstimatedTime(
                    getQuestionTypeFromString(q.QuestionType__c),
                    QuestionCategorization.integerToDifficulty(Integer.valueOf(q.Difficulty__c))
                );
            }
            
            // Difficulty tracking
            totalDifficulty += Integer.valueOf(q.Difficulty__c);
            String difficultyKey = String.valueOf(q.Difficulty__c);
            difficultyCount.put(difficultyKey, 
                difficultyCount.containsKey(difficultyKey) ? difficultyCount.get(difficultyKey) + 1 : 1);
            
            // Question type tracking
            String typeKey = q.QuestionType__c;
            typeCount.put(typeKey, 
                typeCount.containsKey(typeKey) ? typeCount.get(typeKey) + 1 : 1);
        }
        
        questionSet.totalEstimatedMinutes = Integer.valueOf(totalTime / 60);
        questionSet.averageDifficulty = questionSet.questions.size() > 0 ? 
            Decimal.valueOf(totalDifficulty) / questionSet.questions.size() : 0;
        questionSet.difficultyDistribution = difficultyCount;
        questionSet.questionTypeDistribution = typeCount;
    }
    
    /**
     * @description Convert question type string to enum
     * @param questionType String representation of question type
     * @return QuestionCategorization.QuestionType enum value
     */
    private static QuestionCategorization.QuestionType getQuestionTypeFromString(String questionType) {
        if (String.isBlank(questionType)) {
            return QuestionCategorization.QuestionType.MULTIPLE_CHOICE;
        }
        
        switch on questionType.toLowerCase().replaceAll('\\s+', '') {
            when 'multiplechoice' {
                return QuestionCategorization.QuestionType.MULTIPLE_CHOICE;
            }
            when 'multipleselect' {
                return QuestionCategorization.QuestionType.MULTIPLE_SELECT;
            }
            when 'scenario-based', 'scenario' {
                return QuestionCategorization.QuestionType.SCENARIO_BASED;
            }
            when 'practical' {
                return QuestionCategorization.QuestionType.PRACTICAL;
            }
            when 'draganddrop' {
                return QuestionCategorization.QuestionType.DRAG_AND_DROP;
            }
            when else {
                return QuestionCategorization.QuestionType.MULTIPLE_CHOICE;
            }
        }
    }
    
    /**
     * @description Build selection strategy description
     * @param request The selection request
     * @return String strategy description
     */
    private static String buildSelectionStrategy(QuestionSelectionRequest request) {
        List<String> strategy = new List<String>();
        
        strategy.add('Track: ' + request.certificationTrack);
        strategy.add('Questions: ' + request.requestedQuestions);
        strategy.add('Difficulty: ' + request.difficultyFocus);
        strategy.add('Session: ' + request.sessionType);
        
        if (!request.focusTopics.isEmpty()) {
            strategy.add('Focus: ' + String.join(new List<String>(request.focusTopics), ', '));
        }
        
        if (!request.excludeTopics.isEmpty()) {
            strategy.add('Exclude: ' + String.join(new List<String>(request.excludeTopics), ', '));
        }
        
        return String.join(strategy, ' | ');
    }
    
    /**
     * @description Get question analytics for effectiveness tracking
     * @param questionIds List of question IDs to analyze
     * @return List<QuestionAnalytics> analytics data
     */
    public static List<QuestionAnalytics> getQuestionAnalytics(List<String> questionIds) {
        List<QuestionAnalytics> analytics = new List<QuestionAnalytics>();
        
        // Query question performance data
        Map<String, AggregateResult> performanceData = new Map<String, AggregateResult>();
        for (AggregateResult ar : [
            SELECT Question__c, COUNT(Id) attempts, AVG(ResponseTime__c) avgTime, 
                   SUM(CASE WHEN IsCorrect__c = true THEN 1 ELSE 0 END) correctCount
            FROM UserAnswer__c 
            WHERE Question__c IN :questionIds 
            GROUP BY Question__c
        ]) {
            performanceData.put((String) ar.get('Question__c'), ar);
        }
        
        // Query question basic info
        for (Question__c q : [
            SELECT Id, Topic__c, Difficulty__c, UsageCount__c, LastUsedDate__c
            FROM Question__c 
            WHERE Id IN :questionIds
        ]) {
            QuestionAnalytics qa = new QuestionAnalytics();
            qa.questionId = q.Id;
            qa.topic = q.Topic__c;
            qa.difficultyRating = q.Difficulty__c;
            qa.lastUsed = q.LastUsedDate__c;
            
            if (performanceData.containsKey(q.Id)) {
                AggregateResult ar = performanceData.get(q.Id);
                qa.totalAttempts = (Integer) ar.get('attempts');
                qa.averageResponseTime = (Decimal) ar.get('avgTime');
                Integer correctCount = (Integer) ar.get('correctCount');
                qa.correctRate = qa.totalAttempts > 0 ? 
                    (correctCount * 100.0) / qa.totalAttempts : 0;
            }
            
            // Calculate effectiveness score
            qa.effectivenessScore = calculateEffectivenessScore(qa);
            
            analytics.add(qa);
        }
        
        return analytics;
    }
    
    /**
     * @description Calculate question effectiveness score
     * @param analytics The question analytics data
     * @return String effectiveness rating
     */
    private static String calculateEffectivenessScore(QuestionAnalytics analytics) {
        Integer score = 0;
        
        // Usage frequency score (0-25 points)
        if (analytics.totalAttempts >= 50) {
            score += 25;
        } else if (analytics.totalAttempts >= 20) {
            score += 20;
        } else if (analytics.totalAttempts >= 10) {
            score += 15;
        } else if (analytics.totalAttempts >= 5) {
            score += 10;
        }
        
        // Correct rate score (0-40 points) - optimal range 60-80%
        if (analytics.correctRate >= 60 && analytics.correctRate <= 80) {
            score += 40;
        } else if (analytics.correctRate >= 50 && analytics.correctRate <= 90) {
            score += 30;
        } else if (analytics.correctRate >= 40 && analytics.correctRate <= 95) {
            score += 20;
        } else {
            score += 10; // Too easy or too hard
        }
        
        // Response time score (0-25 points)
        Decimal expectedTime = 60; // Base expectation in seconds
        if (analytics.averageResponseTime <= expectedTime * 1.2 && 
            analytics.averageResponseTime >= expectedTime * 0.8) {
            score += 25;
        } else if (analytics.averageResponseTime <= expectedTime * 1.5 && 
                  analytics.averageResponseTime >= expectedTime * 0.6) {
            score += 20;
        } else {
            score += 10;
        }
        
        // Issue reports score (0-10 points)
        if (analytics.reportedIssues == 0) {
            score += 10;
        } else if (analytics.reportedIssues <= 2) {
            score += 5;
        }
        
        // Convert to rating
        if (score >= 85) {
            return 'Excellent';
        } else if (score >= 70) {
            return 'Good';
        } else if (score >= 55) {
            return 'Fair';
        } else {
            return 'Poor';
        }
    }
    
    /**
     * @description Update question usage statistics
     * @param questionIds List of question IDs that were used
     */
    public static void updateQuestionUsage(List<String> questionIds) {
        List<Question__c> questionsToUpdate = [
            SELECT Id, UsageCount__c 
            FROM Question__c 
            WHERE Id IN :questionIds
        ];
        
        for (Question__c q : questionsToUpdate) {
            q.UsageCount__c = (q.UsageCount__c != null ? q.UsageCount__c : 0) + 1;
            q.LastUsedDate__c = Date.today();
        }
        
        update questionsToUpdate;
    }
}