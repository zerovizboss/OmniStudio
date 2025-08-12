/**
 * @description Wrapper class for user performance data and analysis
 * @author Claude AI OmniStudio Training
 * @date 2025-08-12
 */
public with sharing class UserPerformanceData {
    
    private Map<String, List<UserAnswer__c>> answersByTopic;
    private Map<String, Decimal> topicPerformanceMap;
    private UserProfile__c userProfile;
    private Integer totalQuestionsAnswered;
    private Decimal overallAccuracy;
    
    /**
     * @description Constructor with user answers and profile
     * @param answers List of user's answer history
     * @param profile User profile with preferences
     */
    public UserPerformanceData(List<UserAnswer__c> answers, UserProfile__c profile) {
        this.userProfile = profile;
        this.totalQuestionsAnswered = answers.size();
        this.answersByTopic = new Map<String, List<UserAnswer__c>>();
        this.topicPerformanceMap = new Map<String, Decimal>();
        
        initializeTopicAnalysis(answers);
        calculateOverallAccuracy(answers);
    }
    
    /**
     * @description Default constructor for new users
     */
    public UserPerformanceData() {
        this.answersByTopic = new Map<String, List<UserAnswer__c>>();
        this.topicPerformanceMap = new Map<String, Decimal>();
        this.totalQuestionsAnswered = 0;
        this.overallAccuracy = 0;
        this.userProfile = new UserProfile__c(CurrentDifficulty__c = 2);
    }
    
    /**
     * @description Gets performance rate for a specific topic
     * @param topic Topic name to analyze
     * @return Decimal performance rate (0.0 to 1.0)
     */
    public Decimal getTopicPerformance(String topic) {
        return topicPerformanceMap.containsKey(topic) ? topicPerformanceMap.get(topic) : 0.5;
    }
    
    /**
     * @description Gets overall performance across all topics
     * @return Decimal overall accuracy rate
     */
    public Decimal getOverallPerformance() {
        return this.overallAccuracy;
    }
    
    /**
     * @description Gets total number of questions answered by user
     * @return Integer count of answered questions
     */
    public Integer getTotalQuestionsAnswered() {
        return this.totalQuestionsAnswered;
    }
    
    /**
     * @description Gets current difficulty level from user profile
     * @return Integer current difficulty (1-5)
     */
    public Integer getCurrentDifficulty() {
        return userProfile?.CurrentDifficulty__c != null ? 
               Integer.valueOf(userProfile.CurrentDifficulty__c) : 2;
    }
    
    /**
     * @description Gets user's lowest performing topics for focus
     * @param topCount Number of topics to return
     * @return List of topic names with lowest performance
     */
    public List<String> getLowestPerformingTopics(Integer topCount) {
        List<TopicPerformance> topicList = new List<TopicPerformance>();
        
        for (String topic : topicPerformanceMap.keySet()) {
            topicList.add(new TopicPerformance(topic, topicPerformanceMap.get(topic)));
        }
        
        // Sort by performance (lowest first)
        topicList.sort();
        
        List<String> lowestTopics = new List<String>();
        for (Integer i = 0; i < Math.min(topCount, topicList.size()); i++) {
            lowestTopics.add(topicList[i].topicName);
        }
        
        return lowestTopics;
    }
    
    /**
     * @description Gets recent performance trend (improving/declining)
     * @return String trend indicator
     */
    public String getPerformanceTrend() {
        if (totalQuestionsAnswered < 10) {
            return 'Insufficient Data';
        }
        
        // Compare recent 10 answers vs previous 10
        List<UserAnswer__c> allAnswers = new List<UserAnswer__c>();
        for (List<UserAnswer__c> topicAnswers : answersByTopic.values()) {
            allAnswers.addAll(topicAnswers);
        }
        
        if (allAnswers.size() < 20) {
            return 'Building Baseline';
        }
        
        // Sort by date (most recent first)
        allAnswers.sort(new AnswerDateComparator());
        
        Integer recentCorrect = 0;
        Integer previousCorrect = 0;
        
        // Count correct in recent 10
        for (Integer i = 0; i < 10; i++) {
            if (allAnswers[i].IsCorrect__c) {
                recentCorrect++;
            }
        }
        
        // Count correct in previous 10
        for (Integer i = 10; i < 20; i++) {
            if (allAnswers[i].IsCorrect__c) {
                previousCorrect++;
            }
        }
        
        if (recentCorrect > previousCorrect + 1) {
            return 'Improving';
        } else if (recentCorrect < previousCorrect - 1) {
            return 'Declining';
        } else {
            return 'Stable';
        }
    }
    
    /**
     * @description Initializes topic-based performance analysis
     * @param answers List of user answers to analyze
     */
    private void initializeTopicAnalysis(List<UserAnswer__c> answers) {
        // Group answers by topic
        for (UserAnswer__c answer : answers) {
            String topic = answer.Question__r.Topic__c;
            if (!answersByTopic.containsKey(topic)) {
                answersByTopic.put(topic, new List<UserAnswer__c>());
            }
            answersByTopic.get(topic).add(answer);
        }
        
        // Calculate performance for each topic
        for (String topic : answersByTopic.keySet()) {
            List<UserAnswer__c> topicAnswers = answersByTopic.get(topic);
            Integer correctCount = 0;
            
            for (UserAnswer__c answer : topicAnswers) {
                if (answer.IsCorrect__c) {
                    correctCount++;
                }
            }
            
            Decimal performance = topicAnswers.size() > 0 ? 
                                 (Decimal) correctCount / topicAnswers.size() : 0;
            topicPerformanceMap.put(topic, performance);
        }
    }
    
    /**
     * @description Calculates overall accuracy rate
     * @param answers List of all user answers
     */
    private void calculateOverallAccuracy(List<UserAnswer__c> answers) {
        Integer correctCount = 0;
        
        for (UserAnswer__c answer : answers) {
            if (answer.IsCorrect__c) {
                correctCount++;
            }
        }
        
        this.overallAccuracy = answers.size() > 0 ? 
                              (Decimal) correctCount / answers.size() : 0;
    }
    
    /**
     * @description Inner class for topic performance tracking
     */
    private class TopicPerformance implements Comparable {
        public String topicName;
        public Decimal performance;
        
        public TopicPerformance(String topicName, Decimal performance) {
            this.topicName = topicName;
            this.performance = performance;
        }
        
        public Integer compareTo(Object compareTo) {
            TopicPerformance other = (TopicPerformance) compareTo;
            if (this.performance < other.performance) return -1;
            if (this.performance > other.performance) return 1;
            return 0;
        }
    }
    
    /**
     * @description Comparator for sorting answers by date
     */
    private class AnswerDateComparator implements Comparator<UserAnswer__c> {
        public Integer compare(UserAnswer__c a, UserAnswer__c b) {
            if (a.AnsweredDate__c > b.AnsweredDate__c) return -1;
            if (a.AnsweredDate__c < b.AnsweredDate__c) return 1;
            return 0;
        }
    }
}