/**
 * @description Routes questions based on certification track requirements
 * @author Claude AI OmniStudio Training
 * @date 2025-08-12
 */
public with sharing class CertificationRouter {
    
    // Certification track topic mappings based on exam guides
    private static final Map<String, List<String>> TRACK_TOPICS = new Map<String, List<String>>{
        'Consultant' => new List<String>{
            'FlexCards',
            'OmniScripts', 
            'DataTools',
            'BestFitSolutioning'
        },
        'Developer' => new List<String>{
            'FlexCards',
            'OmniScripts',
            'IntegrationProcedures',
            'DataRaptors',
            'ExpressionSetsDecisionMatrices'
        }
    };
    
    // Topic weightings for certification exams (percentage)
    private static final Map<String, Map<String, Decimal>> TOPIC_WEIGHTS = new Map<String, Map<String, Decimal>>{
        'Consultant' => new Map<String, Decimal>{
            'FlexCards' => 0.23,
            'OmniScripts' => 0.27,
            'DataTools' => 0.23,
            'BestFitSolutioning' => 0.27
        },
        'Developer' => new Map<String, Map<String, Decimal>>{
            'FlexCards' => 0.25,
            'OmniScripts' => 0.25,
            'IntegrationProcedures' => 0.20,
            'DataRaptors' => 0.15,
            'ExpressionSetsDecisionMatrices' => 0.15
        }
    };
    
    /**
     * @description Gets available topics for a certification track
     * @param certificationTrack Certification track (Consultant/Developer)
     * @return List of topic names for the track
     */
    public static List<String> getTopicsForTrack(String certificationTrack) {
        return TRACK_TOPICS.containsKey(certificationTrack) ? 
               TRACK_TOPICS.get(certificationTrack) : new List<String>();
    }
    
    /**
     * @description Gets topic weight for exam scoring
     * @param certificationTrack Certification track
     * @param topic Topic name
     * @return Decimal weight (0.0 to 1.0)
     */
    public static Decimal getTopicWeight(String certificationTrack, String topic) {
        if (TOPIC_WEIGHTS.containsKey(certificationTrack) && 
            TOPIC_WEIGHTS.get(certificationTrack).containsKey(topic)) {
            return TOPIC_WEIGHTS.get(certificationTrack).get(topic);
        }
        return 0.20; // Default 20% if topic not found
    }
    
    /**
     * @description Validates if a topic belongs to a certification track
     * @param certificationTrack Certification track
     * @param topic Topic to validate
     * @return Boolean true if topic is valid for track
     */
    public static Boolean isValidTopicForTrack(String certificationTrack, String topic) {
        List<String> trackTopics = getTopicsForTrack(certificationTrack);
        return trackTopics.contains(topic);
    }
    
    /**
     * @description Gets weighted topic distribution for question selection
     * @param certificationTrack Certification track
     * @param totalQuestions Total questions to distribute
     * @return Map of topic to question count based on exam weights
     */
    public static Map<String, Integer> getWeightedTopicDistribution(String certificationTrack, Integer totalQuestions) {
        Map<String, Integer> distribution = new Map<String, Integer>();
        List<String> topics = getTopicsForTrack(certificationTrack);
        
        Integer allocatedQuestions = 0;
        
        // Distribute questions based on topic weights
        for (String topic : topics) {
            Decimal weight = getTopicWeight(certificationTrack, topic);
            Integer questionCount = (Integer) Math.round(totalQuestions * weight);
            distribution.put(topic, questionCount);
            allocatedQuestions += questionCount;
        }
        
        // Handle rounding discrepancies
        Integer remaining = totalQuestions - allocatedQuestions;
        if (remaining != 0) {
            // Add/subtract from highest weighted topic
            String primaryTopic = getPrimaryTopic(certificationTrack);
            Integer currentCount = distribution.get(primaryTopic);
            distribution.put(primaryTopic, currentCount + remaining);
        }
        
        return distribution;
    }
    
    /**
     * @description Gets the primary topic with highest weight for a track
     * @param certificationTrack Certification track
     * @return String primary topic name
     */
    public static String getPrimaryTopic(String certificationTrack) {
        Map<String, Decimal> weights = TOPIC_WEIGHTS.get(certificationTrack);
        String primaryTopic = '';
        Decimal maxWeight = 0;
        
        if (weights != null) {
            for (String topic : weights.keySet()) {
                if (weights.get(topic) > maxWeight) {
                    maxWeight = weights.get(topic);
                    primaryTopic = topic;
                }
            }
        }
        
        return primaryTopic;
    }
    
    /**
     * @description Gets certification-specific question selection criteria
     * @param certificationTrack Certification track
     * @return CertificationCriteria wrapper with track-specific requirements
     */
    public static CertificationCriteria getCertificationCriteria(String certificationTrack) {
        CertificationCriteria criteria = new CertificationCriteria();
        
        switch on certificationTrack {
            when 'Consultant' {
                criteria.focusAreas = new List<String>{'Solution Design', 'Business Requirements', 'User Experience'};
                criteria.skillLevel = 'Business Analysis';
                criteria.examDuration = 105; // minutes
                criteria.passingScore = 65; // percentage
                criteria.questionCount = 60;
            }
            when 'Developer' {
                criteria.focusAreas = new List<String>{'Technical Implementation', 'Code Development', 'System Integration'};
                criteria.skillLevel = 'Technical Development';
                criteria.examDuration = 105; // minutes
                criteria.passingScore = 68; // percentage
                criteria.questionCount = 60;
            }
            when else {
                criteria.focusAreas = new List<String>{'General Knowledge'};
                criteria.skillLevel = 'Mixed';
                criteria.examDuration = 90;
                criteria.passingScore = 70;
                criteria.questionCount = 50;
            }
        }
        
        return criteria;
    }
    
    /**
     * @description Inner class for certification-specific criteria
     */
    public class CertificationCriteria {
        public List<String> focusAreas;
        public String skillLevel;
        public Integer examDuration;
        public Integer passingScore;
        public Integer questionCount;
    }
}