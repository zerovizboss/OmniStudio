/**
 * @description Helper class for managing Question categorization and metadata
 * @author Claude Code Assistant
 * @since User Story #15 - Question Categorization Framework
 * @version 1.0
 * 
 * This utility class provides methods to work with Question records and
 * apply categorization framework rules for content organization.
 */
public with sharing class QuestionCategoryHelper {
    
    /**
     * @description Apply categorization metadata to Question records
     * @param questions List of Question__c records to categorize
     * @param categories List of QuestionCategory objects with categorization data
     */
    public static void applyCategorization(List<Question__c> questions, 
                                         List<QuestionCategorization.QuestionCategory> categories) {
        
        if (questions == null || categories == null || questions.size() != categories.size()) {
            throw new IllegalArgumentException('Questions and categories lists must not be null and must have the same size');
        }
        
        for (Integer i = 0; i < questions.size(); i++) {
            Question__c question = questions[i];
            QuestionCategorization.QuestionCategory category = categories[i];
            
            // Apply basic categorization
            question.CertificationTrack__c = category.certificationTrack;
            question.Topic__c = category.primaryTopic;
            question.SubTopic__c = category.subTopic;
            question.Difficulty__c = QuestionCategorization.difficultyToInteger(category.difficulty);
            question.QuestionType__c = getQuestionTypeString(category.questionType);
            
            // Apply metadata
            question.TopicWeight__c = category.topicWeight;
            question.EstimatedTimeSeconds__c = category.estimatedTimeMinutes;
            
            // Apply content tags (convert Set to semicolon-delimited string)
            if (category.tags != null && !category.tags.isEmpty()) {
                question.ContentTags__c = String.join(new List<String>(category.tags), ';');
            }
            
            // Set categorization timestamp
            question.CategorizedDate__c = DateTime.now();
        }
    }
    
    /**
     * @description Auto-categorize questions based on content analysis
     * @param questions List of Question__c records to auto-categorize
     * @return List<QuestionCategorization.QuestionCategory> suggested categories
     */
    public static List<QuestionCategorization.QuestionCategory> autoCategorizaQuestions(List<Question__c> questions) {
        List<QuestionCategorization.QuestionCategory> categories = new List<QuestionCategorization.QuestionCategory>();
        
        for (Question__c question : questions) {
            QuestionCategorization.QuestionCategory category = analyzeQuestionContent(question);
            categories.add(category);
        }
        
        return categories;
    }
    
    /**
     * @description Analyze question content to suggest categorization
     * @param question Question__c record to analyze
     * @return QuestionCategorization.QuestionCategory suggested category
     */
    private static QuestionCategorization.QuestionCategory analyzeQuestionContent(Question__c question) {
        String questionText = (question.QuestionText__c != null ? question.QuestionText__c.toLowerCase() : '');
        String explanation = (question.Explanation__c != null ? question.Explanation__c.toLowerCase() : '');
        String allText = questionText + ' ' + explanation;
        
        // Determine certification track (default from existing field or analyze content)
        String certificationTrack = question.CertificationTrack__c != null ? 
                                   question.CertificationTrack__c : 'Consultant';
        
        // Analyze primary topic based on keywords
        String primaryTopic = analyzePrimaryTopic(allText, certificationTrack);
        
        // Determine difficulty based on content complexity
        QuestionCategorization.DifficultyLevel difficulty = analyzeDifficulty(allText, question.Difficulty__c);
        
        // Determine question type
        QuestionCategorization.QuestionType questionType = analyzeQuestionType(question);
        
        // Generate content tags
        Set<String> tags = generateContentTags(allText, primaryTopic);
        
        return QuestionCategorization.createCategory(
            certificationTrack,
            primaryTopic,
            null, // SubTopic to be manually set
            difficulty,
            questionType,
            tags
        );
    }
    
    /**
     * @description Analyze text content to determine primary topic
     * @param content Text content to analyze
     * @param certificationTrack The certification track
     * @return String primary topic
     */
    private static String analyzePrimaryTopic(String content, String certificationTrack) {
        Map<String, Integer> topicScores = new Map<String, Integer>();
        Set<String> validTopics = QuestionCategorization.getValidTopics(certificationTrack);
        
        // Initialize scores
        for (String topic : validTopics) {
            topicScores.put(topic, 0);
        }
        
        // FlexCards keywords
        if (content.contains('flexcard') || content.contains('card') || content.contains('data source') ||
            content.contains('conditional visibility') || content.contains('card layout')) {
            topicScores.put('FlexCards', topicScores.get('FlexCards') + 10);
        }
        
        // OmniScript keywords
        if (content.contains('omniscript') || content.contains('script') || content.contains('data json') ||
            content.contains('conditional logic') || content.contains('step') || content.contains('element')) {
            topicScores.put('OmniScripts', topicScores.get('OmniScripts') + 10);
        }
        
        // DataRaptors/DataTools keywords
        if (content.contains('dataraptor') || content.contains('data raptor') || content.contains('extract') ||
            content.contains('transform') || content.contains('load') || content.contains('turbo extract')) {
            if (validTopics.contains('DataRaptors')) {
                topicScores.put('DataRaptors', topicScores.get('DataRaptors') + 10);
            } else if (validTopics.contains('DataTools')) {
                topicScores.put('DataTools', topicScores.get('DataTools') + 10);
            }
        }
        
        // Integration Procedures keywords
        if ((content.contains('integration') && content.contains('procedure')) || 
            content.contains('rest api') || content.contains('soap') || content.contains('http callout')) {
            if (validTopics.contains('IntegrationProcedures')) {
                topicScores.put('IntegrationProcedures', topicScores.get('IntegrationProcedures') + 10);
            }
        }
        
        // Expressions keywords
        if (content.contains('expression') || content.contains('formula') || content.contains('apex remote') ||
            content.contains('decision matrix') || content.contains('expression set')) {
            if (validTopics.contains('Expressions')) {
                topicScores.put('Expressions', topicScores.get('Expressions') + 10);
            }
        }
        
        // Solutioning keywords
        if (content.contains('solution') || content.contains('business requirement') || content.contains('architecture') ||
            content.contains('best practice') || content.contains('performance') || content.contains('scalability')) {
            if (validTopics.contains('Solutioning')) {
                topicScores.put('Solutioning', topicScores.get('Solutioning') + 10);
            }
        }
        
        // Find topic with highest score
        String bestTopic = null;
        Integer highestScore = 0;
        for (String topic : topicScores.keySet()) {
            if (topicScores.get(topic) > highestScore) {
                highestScore = topicScores.get(topic);
                bestTopic = topic;
            }
        }
        
        // Default to first valid topic if no matches found
        return bestTopic != null ? bestTopic : new List<String>(validTopics)[0];
    }
    
    /**
     * @description Analyze content to determine difficulty level
     * @param content Text content to analyze
     * @param existingDifficulty Existing difficulty value from question
     * @return QuestionCategorization.DifficultyLevel difficulty level
     */
    private static QuestionCategorization.DifficultyLevel analyzeDifficulty(String content, Integer existingDifficulty) {
        // Use existing difficulty if available and valid
        if (existingDifficulty != null && existingDifficulty >= 1 && existingDifficulty <= 3) {
            return QuestionCategorization.integerToDifficulty(existingDifficulty);
        }
        
        Integer complexityScore = 0;
        
        // Advanced keywords increase complexity
        String[] advancedKeywords = new String[]{
            'architecture', 'performance', 'optimization', 'best practice', 'scalability',
            'security', 'enterprise', 'integration', 'complex', 'advanced'
        };
        
        String[] intermediateKeywords = new String[]{
            'configuration', 'setup', 'implementation', 'deploy', 'customize',
            'practical', 'scenario', 'use case'
        };
        
        String[] beginnerKeywords = new String[]{
            'basic', 'introduction', 'fundamental', 'overview', 'definition',
            'what is', 'simple', 'beginner'
        };
        
        // Score based on keyword presence
        for (String keyword : advancedKeywords) {
            if (content.contains(keyword)) {
                complexityScore += 3;
            }
        }
        
        for (String keyword : intermediateKeywords) {
            if (content.contains(keyword)) {
                complexityScore += 2;
            }
        }
        
        for (String keyword : beginnerKeywords) {
            if (content.contains(keyword)) {
                complexityScore += 1;
            }
        }
        
        // Determine difficulty based on score
        if (complexityScore >= 6) {
            return QuestionCategorization.DifficultyLevel.ADVANCED;
        } else if (complexityScore >= 3) {
            return QuestionCategorization.DifficultyLevel.INTERMEDIATE;
        } else {
            return QuestionCategorization.DifficultyLevel.BEGINNER;
        }
    }
    
    /**
     * @description Analyze question structure to determine question type
     * @param question Question__c record to analyze
     * @return QuestionCategorization.QuestionType question type
     */
    private static QuestionCategorization.QuestionType analyzeQuestionType(Question__c question) {
        // Use existing type if available
        if (String.isNotBlank(question.QuestionType__c)) {
            switch on question.QuestionType__c.toLowerCase() {
                when 'multiple choice', 'multiplechoice' {
                    return QuestionCategorization.QuestionType.MULTIPLE_CHOICE;
                }
                when 'multiple select', 'multipleselect' {
                    return QuestionCategorization.QuestionType.MULTIPLE_SELECT;
                }
                when 'scenario', 'scenario-based' {
                    return QuestionCategorization.QuestionType.SCENARIO_BASED;
                }
                when 'practical' {
                    return QuestionCategorization.QuestionType.PRACTICAL;
                }
                when 'drag and drop', 'draganddrop' {
                    return QuestionCategorization.QuestionType.DRAG_AND_DROP;
                }
            }
        }
        
        // Analyze question structure
        String questionText = question.QuestionText__c != null ? question.QuestionText__c.toLowerCase() : '';
        
        // Check for scenario-based indicators
        if (questionText.contains('scenario') || questionText.contains('case study') || 
            questionText.contains('situation') || questionText.length() > 200) {
            return QuestionCategorization.QuestionType.SCENARIO_BASED;
        }
        
        // Check for practical indicators
        if (questionText.contains('implement') || questionText.contains('create') || 
            questionText.contains('build') || questionText.contains('configure')) {
            return QuestionCategorization.QuestionType.PRACTICAL;
        }
        
        // Check for multiple select indicators
        if (questionText.contains('select all') || questionText.contains('choose all') ||
            questionText.contains('which of the following') || questionText.contains('mark all')) {
            return QuestionCategorization.QuestionType.MULTIPLE_SELECT;
        }
        
        // Default to multiple choice
        return QuestionCategorization.QuestionType.MULTIPLE_CHOICE;
    }
    
    /**
     * @description Generate content tags based on content analysis
     * @param content Text content to analyze
     * @param primaryTopic The primary topic
     * @return Set<String> relevant content tags
     */
    private static Set<String> generateContentTags(String content, String primaryTopic) {
        Set<String> tags = new Set<String>();
        
        // Get base tags for the topic
        Set<String> topicTags = QuestionCategorization.getTopicTags(primaryTopic);
        
        // Add tags based on specific keywords found in content
        for (String tag : topicTags) {
            String tagKeyword = tag.replace('-', ' ');
            if (content.contains(tagKeyword) || content.contains(tag.replace('-', ''))) {
                tags.add(tag);
            }
        }
        
        // Add at least one base tag if none were found
        if (tags.isEmpty() && !topicTags.isEmpty()) {
            tags.add(new List<String>(topicTags)[0]);
        }
        
        return tags;
    }
    
    /**
     * @description Convert QuestionType enum to string representation
     * @param questionType The question type enum
     * @return String representation
     */
    private static String getQuestionTypeString(QuestionCategorization.QuestionType questionType) {
        switch on questionType {
            when MULTIPLE_CHOICE {
                return 'Multiple Choice';
            }
            when MULTIPLE_SELECT {
                return 'Multiple Select';
            }
            when SCENARIO_BASED {
                return 'Scenario-based';
            }
            when PRACTICAL {
                return 'Practical';
            }
            when DRAG_AND_DROP {
                return 'Drag and Drop';
            }
            when else {
                return 'Multiple Choice';
            }
        }
    }
    
    /**
     * @description Get questions that need categorization review
     * @param certificationTrack The certification track to check
     * @return List<Question__c> questions needing review
     */
    public static List<Question__c> getQuestionsNeedingCategorization(String certificationTrack) {
        return [
            SELECT Id, QuestionText__c, Topic__c, Difficulty__c, QuestionType__c, 
                   ContentTags__c, CategorizedDate__c, CertificationTrack__c
            FROM Question__c 
            WHERE CertificationTrack__c = :certificationTrack
              AND (CategorizedDate__c = null OR 
                   Topic__c = null OR 
                   ContentTags__c = null)
              AND Active__c = true
            ORDER BY CreatedDate DESC
            LIMIT 1000
        ];
    }
    
    /**
     * @description Validate topic distribution for a set of questions
     * @param questions List of questions to validate
     * @param certificationTrack The certification track
     * @return Map<String, Object> validation results
     */
    public static Map<String, Object> validateTopicDistribution(List<Question__c> questions, String certificationTrack) {
        Map<String, Object> results = new Map<String, Object>();
        Map<String, Integer> actualDistribution = new Map<String, Integer>();
        Map<String, Decimal> expectedWeights = (certificationTrack == 'Consultant') ? 
            QuestionCategorization.CONSULTANT_TOPIC_WEIGHTS : 
            QuestionCategorization.DEVELOPER_TOPIC_WEIGHTS;
        
        // Count actual distribution
        for (Question__c question : questions) {
            String topic = question.Topic__c;
            if (String.isNotBlank(topic)) {
                Integer count = actualDistribution.containsKey(topic) ? actualDistribution.get(topic) : 0;
                actualDistribution.put(topic, count + 1);
            }
        }
        
        // Calculate distribution analysis
        Integer totalQuestions = questions.size();
        Map<String, Decimal> actualPercentages = new Map<String, Decimal>();
        Map<String, Decimal> deviations = new Map<String, Decimal>();
        
        for (String topic : expectedWeights.keySet()) {
            Integer actualCount = actualDistribution.containsKey(topic) ? actualDistribution.get(topic) : 0;
            Decimal actualPercentage = totalQuestions > 0 ? (actualCount * 100.0) / totalQuestions : 0;
            Decimal expectedPercentage = expectedWeights.get(topic);
            Decimal deviation = actualPercentage - expectedPercentage;
            
            actualPercentages.put(topic, actualPercentage);
            deviations.put(topic, deviation);
        }
        
        results.put('totalQuestions', totalQuestions);
        results.put('actualDistribution', actualDistribution);
        results.put('actualPercentages', actualPercentages);
        results.put('expectedPercentages', expectedWeights);
        results.put('deviations', deviations);
        
        return results;
    }
}