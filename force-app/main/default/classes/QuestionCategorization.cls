/**
 * @description Question Categorization Framework for OmniStudio Training Platform
 * @author Claude Code Assistant
 * @since User Story #15 - Question Categorization Framework
 * @version 1.0
 * 
 * This class provides comprehensive categorization and weighting for both
 * Consultant and Developer certification exam questions according to official
 * Salesforce exam blueprints.
 */
public with sharing class QuestionCategorization {
    
    /**
     * @description Consultant exam topic distribution based on official blueprint
     */
    public static final Map<String, Decimal> CONSULTANT_TOPIC_WEIGHTS = new Map<String, Decimal>{
        'FlexCards' => 23.0,
        'OmniScripts' => 27.0,
        'DataTools' => 23.0,
        'Solutioning' => 27.0
    };
    
    /**
     * @description Developer exam topic distribution with equal weighting
     */
    public static final Map<String, Decimal> DEVELOPER_TOPIC_WEIGHTS = new Map<String, Decimal>{
        'FlexCards' => 20.0,
        'OmniScripts' => 20.0,
        'IntegrationProcedures' => 20.0,
        'DataRaptors' => 20.0,
        'Expressions' => 20.0
    };
    
    /**
     * @description Question difficulty levels with numerical scaling
     */
    public enum DifficultyLevel {
        BEGINNER,    // Level 1 - Basic concepts and terminology
        INTERMEDIATE, // Level 2 - Practical application and configuration
        ADVANCED     // Level 3 - Complex scenarios and best practices
    }
    
    /**
     * @description Question type taxonomy for different assessment approaches
     */
    public enum QuestionType {
        MULTIPLE_CHOICE,     // Single correct answer from 4 options
        MULTIPLE_SELECT,     // Multiple correct answers from options
        SCENARIO_BASED,      // Real-world scenario with analysis
        PRACTICAL,           // Hands-on implementation exercise
        DRAG_AND_DROP        // Visual arrangement/ordering questions
    }
    
    /**
     * @description Content tags for granular categorization
     */
    public static final Set<String> CONTENT_TAGS = new Set<String>{
        // FlexCards Tags
        'flexcard-basics', 'flexcard-datasource', 'flexcard-styling', 
        'flexcard-actions', 'flexcard-conditional-visibility', 'flexcard-deployment',
        
        // OmniScript Tags  
        'omniscript-elements', 'omniscript-data-json', 'omniscript-conditional-logic',
        'omniscript-integration', 'omniscript-deployment', 'omniscript-performance',
        
        // DataTools Tags
        'dataraptor-extract', 'dataraptor-transform', 'dataraptor-load',
        'dataraptor-turbo', 'calculation-procedures', 'data-mapping',
        
        // Integration Tags
        'integration-procedures', 'rest-api', 'soap-api', 'http-callouts',
        'error-handling', 'batch-processing',
        
        // Expression Tags
        'formula-expressions', 'apex-remote', 'decision-matrices',
        'expression-sets', 'custom-functions',
        
        // Solutioning Tags
        'business-requirements', 'solution-architecture', 'best-practices',
        'performance-optimization', 'security-considerations', 'scalability'
    };
    
    /**
     * @description Wrapper class for question categorization data
     */
    public class QuestionCategory {
        public String certificationTrack {get; set;}
        public String primaryTopic {get; set;}
        public String subTopic {get; set;}
        public DifficultyLevel difficulty {get; set;}
        public QuestionType questionType {get; set;}
        public Set<String> tags {get; set;}
        public Decimal topicWeight {get; set;}
        public Integer estimatedTimeMinutes {get; set;}
        
        public QuestionCategory() {
            this.tags = new Set<String>();
        }
    }
    
    /**
     * @description Get topic weight for a specific certification track and topic
     * @param certificationTrack Either 'Consultant' or 'Developer'
     * @param topic The topic to get weight for
     * @return Decimal weight percentage or 0 if not found
     */
    public static Decimal getTopicWeight(String certificationTrack, String topic) {
        Map<String, Decimal> weights;
        
        if (certificationTrack == 'Consultant') {
            weights = CONSULTANT_TOPIC_WEIGHTS;
        } else if (certificationTrack == 'Developer') {
            weights = DEVELOPER_TOPIC_WEIGHTS;
        } else {
            return 0;
        }
        
        return weights.containsKey(topic) ? weights.get(topic) : 0;
    }
    
    /**
     * @description Get all valid topics for a certification track
     * @param certificationTrack Either 'Consultant' or 'Developer'
     * @return Set<String> of valid topics
     */
    public static Set<String> getValidTopics(String certificationTrack) {
        if (certificationTrack == 'Consultant') {
            return CONSULTANT_TOPIC_WEIGHTS.keySet();
        } else if (certificationTrack == 'Developer') {
            return DEVELOPER_TOPIC_WEIGHTS.keySet();
        } else {
            return new Set<String>();
        }
    }
    
    /**
     * @description Convert difficulty level enum to integer
     * @param difficulty The difficulty level enum
     * @return Integer representation (1-3)
     */
    public static Integer difficultyToInteger(DifficultyLevel difficulty) {
        switch on difficulty {
            when BEGINNER {
                return 1;
            }
            when INTERMEDIATE {
                return 2;
            }
            when ADVANCED {
                return 3;
            }
            when else {
                return 1; // Default to beginner
            }
        }
    }
    
    /**
     * @description Convert integer to difficulty level enum
     * @param level Integer level (1-3)
     * @return DifficultyLevel enum
     */
    public static DifficultyLevel integerToDifficulty(Integer level) {
        switch on level {
            when 1 {
                return DifficultyLevel.BEGINNER;
            }
            when 2 {
                return DifficultyLevel.INTERMEDIATE;
            }
            when 3 {
                return DifficultyLevel.ADVANCED;
            }
            when else {
                return DifficultyLevel.BEGINNER; // Default
            }
        }
    }
    
    /**
     * @description Get estimated time in minutes based on question type and difficulty
     * @param questionType The type of question
     * @param difficulty The difficulty level
     * @return Integer estimated minutes
     */
    public static Integer getEstimatedTime(QuestionType questionType, DifficultyLevel difficulty) {
        Integer baseTime;
        
        // Base time by question type
        switch on questionType {
            when MULTIPLE_CHOICE {
                baseTime = 60; // 1 minute
            }
            when MULTIPLE_SELECT {
                baseTime = 90; // 1.5 minutes
            }
            when SCENARIO_BASED {
                baseTime = 180; // 3 minutes
            }
            when PRACTICAL {
                baseTime = 300; // 5 minutes
            }
            when DRAG_AND_DROP {
                baseTime = 120; // 2 minutes
            }
            when else {
                baseTime = 60;
            }
        }
        
        // Adjust for difficulty
        switch on difficulty {
            when BEGINNER {
                return baseTime;
            }
            when INTERMEDIATE {
                return Integer.valueOf(baseTime * 1.3);
            }
            when ADVANCED {
                return Integer.valueOf(baseTime * 1.6);
            }
            when else {
                return baseTime;
            }
        }
    }
    
    /**
     * @description Validate that a question category is properly configured
     * @param category The question category to validate
     * @return List<String> validation errors (empty if valid)
     */
    public static List<String> validateCategory(QuestionCategory category) {
        List<String> errors = new List<String>();
        
        // Validate certification track
        if (String.isBlank(category.certificationTrack) || 
            (category.certificationTrack != 'Consultant' && category.certificationTrack != 'Developer')) {
            errors.add('Invalid certification track. Must be "Consultant" or "Developer"');
        }
        
        // Validate primary topic
        if (String.isBlank(category.primaryTopic)) {
            errors.add('Primary topic is required');
        } else if (category.certificationTrack != null) {
            Set<String> validTopics = getValidTopics(category.certificationTrack);
            if (!validTopics.contains(category.primaryTopic)) {
                errors.add('Invalid primary topic for ' + category.certificationTrack + ' track');
            }
        }
        
        // Validate tags
        if (category.tags != null) {
            for (String tag : category.tags) {
                if (!CONTENT_TAGS.contains(tag)) {
                    errors.add('Invalid content tag: ' + tag);
                }
            }
        }
        
        return errors;
    }
    
    /**
     * @description Create a properly configured question category
     * @param certificationTrack The certification track
     * @param primaryTopic The primary topic
     * @param subTopic The sub-topic (optional)
     * @param difficulty The difficulty level
     * @param questionType The question type
     * @param tags Set of content tags
     * @return QuestionCategory configured category
     */
    public static QuestionCategory createCategory(
        String certificationTrack,
        String primaryTopic,
        String subTopic,
        DifficultyLevel difficulty,
        QuestionType questionType,
        Set<String> tags
    ) {
        QuestionCategory category = new QuestionCategory();
        category.certificationTrack = certificationTrack;
        category.primaryTopic = primaryTopic;
        category.subTopic = subTopic;
        category.difficulty = difficulty;
        category.questionType = questionType;
        category.tags = tags != null ? tags : new Set<String>();
        category.topicWeight = getTopicWeight(certificationTrack, primaryTopic);
        category.estimatedTimeMinutes = getEstimatedTime(questionType, difficulty);
        
        return category;
    }
    
    /**
     * @description Get recommended topic distribution for practice sessions
     * @param certificationTrack The certification track
     * @param totalQuestions Number of questions in the session
     * @return Map<String, Integer> topic to question count mapping
     */
    public static Map<String, Integer> getRecommendedDistribution(String certificationTrack, Integer totalQuestions) {
        Map<String, Integer> distribution = new Map<String, Integer>();
        Map<String, Decimal> weights;
        
        if (certificationTrack == 'Consultant') {
            weights = CONSULTANT_TOPIC_WEIGHTS;
        } else if (certificationTrack == 'Developer') {
            weights = DEVELOPER_TOPIC_WEIGHTS;
        } else {
            return distribution;
        }
        
        Integer allocatedQuestions = 0;
        List<String> topics = new List<String>(weights.keySet());
        
        // Calculate question allocation based on weights
        for (Integer i = 0; i < topics.size() - 1; i++) {
            String topic = topics[i];
            Decimal weight = weights.get(topic);
            Integer questionCount = Integer.valueOf((weight / 100) * totalQuestions);
            distribution.put(topic, questionCount);
            allocatedQuestions += questionCount;
        }
        
        // Assign remaining questions to last topic to ensure total is met
        String lastTopic = topics[topics.size() - 1];
        distribution.put(lastTopic, totalQuestions - allocatedQuestions);
        
        return distribution;
    }
    
    /**
     * @description Get content tags related to a specific topic
     * @param topic The topic to get tags for
     * @return Set<String> related content tags
     */
    public static Set<String> getTopicTags(String topic) {
        Set<String> relatedTags = new Set<String>();
        
        switch on topic.toLowerCase() {
            when 'flexcards' {
                relatedTags.addAll(new Set<String>{
                    'flexcard-basics', 'flexcard-datasource', 'flexcard-styling',
                    'flexcard-actions', 'flexcard-conditional-visibility', 'flexcard-deployment'
                });
            }
            when 'omniscripts' {
                relatedTags.addAll(new Set<String>{
                    'omniscript-elements', 'omniscript-data-json', 'omniscript-conditional-logic',
                    'omniscript-integration', 'omniscript-deployment', 'omniscript-performance'
                });
            }
            when 'datatools', 'dataraptors' {
                relatedTags.addAll(new Set<String>{
                    'dataraptor-extract', 'dataraptor-transform', 'dataraptor-load',
                    'dataraptor-turbo', 'calculation-procedures', 'data-mapping'
                });
            }
            when 'integrationprocedures' {
                relatedTags.addAll(new Set<String>{
                    'integration-procedures', 'rest-api', 'soap-api', 'http-callouts',
                    'error-handling', 'batch-processing'
                });
            }
            when 'expressions' {
                relatedTags.addAll(new Set<String>{
                    'formula-expressions', 'apex-remote', 'decision-matrices',
                    'expression-sets', 'custom-functions'
                });
            }
            when 'solutioning' {
                relatedTags.addAll(new Set<String>{
                    'business-requirements', 'solution-architecture', 'best-practices',
                    'performance-optimization', 'security-considerations', 'scalability'
                });
            }
        }
        
        return relatedTags;
    }
}