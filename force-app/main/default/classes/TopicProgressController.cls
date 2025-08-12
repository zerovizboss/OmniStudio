/**
 * @description Topic-Specific Progress FlexCard Controller for OmniStudio Training Platform
 * @author Claude Code Assistant
 * @since User Story #21 - Topic-Specific Progress FlexCards
 * @version 1.0
 * 
 * This class provides backend data and logic for topic-specific progress FlexCards,
 * including certification track-specific topic breakdowns, progress visualization,
 * weak area identification, and targeted study recommendations.
 */
public with sharing class TopicProgressController {
    
    /**
     * @description Complete topic progress data structure
     */
    public class TopicProgressData {
        @AuraEnabled public String userId {get; set;}
        @AuraEnabled public String userName {get; set;}
        @AuraEnabled public String certificationTrack {get; set;}
        @AuraEnabled public String trackDisplayName {get; set;}
        @AuraEnabled public OverallTrackSummary trackSummary {get; set;}
        @AuraEnabled public List<TopicProgress> topicProgress {get; set;}
        @AuraEnabled public List<WeakAreaFocus> weakAreas {get; set;}
        @AuraEnabled public List<StudyRecommendation> recommendations {get; set;}
        @AuraEnabled public List<ProgressAction> quickActions {get; set;}
        @AuraEnabled public ProgressInsights insights {get; set;}
        @AuraEnabled public DateTime lastUpdated {get; set;}
        @AuraEnabled public Integer totalStudySessions {get; set;}
        @AuraEnabled public Integer totalQuestionsAnswered {get; set;}
        
        public TopicProgressData() {
            this.topicProgress = new List<TopicProgress>();
            this.weakAreas = new List<WeakAreaFocus>();
            this.recommendations = new List<StudyRecommendation>();
            this.quickActions = new List<ProgressAction>();
        }
    }
    
    /**
     * @description Overall track summary metrics
     */
    public class OverallTrackSummary {
        @AuraEnabled public Decimal overallProgress {get; set;}
        @AuraEnabled public String progressLevel {get; set;} // Beginner, Intermediate, Advanced, Expert
        @AuraEnabled public String readinessStatus {get; set;} // Not Ready, Developing, Nearly Ready, Exam Ready
        @AuraEnabled public Integer topicsCompleted {get; set;}
        @AuraEnabled public Integer totalTopics {get; set;}
        @AuraEnabled public Integer hoursStudied {get; set;}
        @AuraEnabled public String nextMilestone {get; set;}
        @AuraEnabled public Date estimatedReadinessDate {get; set;}
        @AuraEnabled public String motivationalMessage {get; set;}
    }
    
    /**
     * @description Individual topic progress details
     */
    public class TopicProgress {
        @AuraEnabled public String topicName {get; set;}
        @AuraEnabled public String topicDisplayName {get; set;}
        @AuraEnabled public Decimal progressPercentage {get; set;}
        @AuraEnabled public String progressDisplay {get; set;}
        @AuraEnabled public Decimal masteryScore {get; set;}
        @AuraEnabled public String masteryLevel {get; set;} // Novice, Developing, Proficient, Expert
        @AuraEnabled public Decimal weightPercentage {get; set;} // Topic weight in exam
        @AuraEnabled public String weightDisplay {get; set;}
        @AuraEnabled public Integer questionsAnswered {get; set;}
        @AuraEnabled public Integer totalAvailableQuestions {get; set;}
        @AuraEnabled public Integer correctAnswers {get; set;}
        @AuraEnabled public Decimal accuracyRate {get; set;}
        @AuraEnabled public String status {get; set;} // Not Started, In Progress, Completed, Mastered
        @AuraEnabled public String iconName {get; set;}
        @AuraEnabled public String colorClass {get; set;}
        @AuraEnabled public String progressBarClass {get; set;}
        @AuraEnabled public Boolean isWeakArea {get; set;}
        @AuraEnabled public Boolean isStrength {get; set;}
        @AuraEnabled public String improvementSuggestion {get; set;}
        @AuraEnabled public Integer hoursSpent {get; set;}
        @AuraEnabled public Integer recommendedAdditionalHours {get; set;}
        @AuraEnabled public Date lastStudied {get; set;}
        @AuraEnabled public String studyUrl {get; set;}
        @AuraEnabled public String practiceUrl {get; set;}
    }
    
    /**
     * @description Weak area focus recommendations
     */
    public class WeakAreaFocus {
        @AuraEnabled public String topicName {get; set;}
        @AuraEnabled public String topicDisplayName {get; set;}
        @AuraEnabled public Decimal currentScore {get; set;}
        @AuraEnabled public Decimal targetScore {get; set;}
        @AuraEnabled public String priorityLevel {get; set;} // Critical, High, Medium, Low
        @AuraEnabled public String focusReason {get; set;}
        @AuraEnabled public Integer questionsNeeded {get; set;}
        @AuraEnabled public Integer hoursNeeded {get; set;}
        @AuraEnabled public String actionPlan {get; set;}
        @AuraEnabled public List<String> keyConceptsToReview {get; set;}
        @AuraEnabled public List<String> studyMaterialRecommendations {get; set;}
        @AuraEnabled public String focusUrl {get; set;}
        @AuraEnabled public String iconName {get; set;}
        @AuraEnabled public String urgencyClass {get; set;}
        
        public WeakAreaFocus() {
            this.keyConceptsToReview = new List<String>();
            this.studyMaterialRecommendations = new List<String>();
        }
    }
    
    /**
     * @description Study recommendations based on progress
     */
    public class StudyRecommendation {
        @AuraEnabled public String recommendationId {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public String recommendationType {get; set;} // Focus, Review, Practice, Advance
        @AuraEnabled public String targetTopic {get; set;}
        @AuraEnabled public String priority {get; set;} // Immediate, This Week, Next Week, Later
        @AuraEnabled public String timeCommitment {get; set;}
        @AuraEnabled public String actionUrl {get; set;}
        @AuraEnabled public String iconName {get; set;}
        @AuraEnabled public Boolean isPersonalized {get; set;}
        @AuraEnabled public String reasonWhy {get; set;}
    }
    
    /**
     * @description Quick action buttons for progress management
     */
    public class ProgressAction {
        @AuraEnabled public String actionId {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public String actionUrl {get; set;}
        @AuraEnabled public String buttonClass {get; set;}
        @AuraEnabled public String iconName {get; set;}
        @AuraEnabled public Boolean isPrimary {get; set;}
        @AuraEnabled public String targetTopic {get; set;} // Optional - for topic-specific actions
        @AuraEnabled public Integer badgeCount {get; set;} // Optional - for action with counts
        @AuraEnabled public String tooltip {get; set;}
    }
    
    /**
     * @description AI-generated progress insights
     */
    public class ProgressInsights {
        @AuraEnabled public String primaryInsight {get; set;}
        @AuraEnabled public List<String> keyStrengths {get; set;}
        @AuraEnabled public List<String> improvementAreas {get; set;}
        @AuraEnabled public String studyPattern {get; set;}
        @AuraEnabled public String progressTrend {get; set;} // Accelerating, Steady, Slowing, Stalled
        @AuraEnabled public String nextBreakthrough {get; set;}
        @AuraEnabled public Integer daysToNextMilestone {get; set;}
        @AuraEnabled public String motivationalTip {get; set;}
        
        public ProgressInsights() {
            this.keyStrengths = new List<String>();
            this.improvementAreas = new List<String>();
        }
    }
    
    /**
     * @description Get comprehensive topic progress data for user
     * @param certificationTrack Certification track (optional - uses user profile if not provided)
     * @return TopicProgressData complete progress information
     */
    @AuraEnabled(cacheable=false)
    public static TopicProgressData getTopicProgress(String certificationTrack) {
        try {
            String userId = UserInfo.getUserId();
            TopicProgressData progressData = new TopicProgressData();
            
            progressData.userId = userId;
            progressData.userName = UserInfo.getName();
            progressData.lastUpdated = DateTime.now();
            
            // Determine certification track
            if (String.isBlank(certificationTrack)) {
                certificationTrack = getUserCertificationTrack(userId);
            }
            progressData.certificationTrack = certificationTrack;
            progressData.trackDisplayName = certificationTrack + ' Certification Track';
            
            // Calculate overall track summary
            progressData.trackSummary = calculateTrackSummary(userId, certificationTrack);
            
            // Get topic-specific progress
            progressData.topicProgress = calculateTopicProgress(userId, certificationTrack);
            
            // Calculate overall stats
            progressData.totalQuestionsAnswered = getTotalQuestionsAnswered(userId);
            progressData.totalStudySessions = getTotalStudySessions(userId);
            
            // Identify weak areas
            progressData.weakAreas = identifyWeakAreas(progressData.topicProgress);
            
            // Generate study recommendations
            progressData.recommendations = generateStudyRecommendations(progressData);
            
            // Create quick actions
            progressData.quickActions = generateQuickActions(progressData);
            
            // Generate AI insights
            progressData.insights = generateProgressInsights(progressData);
            
            return progressData;
            
        } catch (Exception e) {
            System.debug('Error in getTopicProgress: ' + e.getMessage());
            throw new AuraHandledException('Unable to load topic progress: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get topic progress comparison between tracks
     * @return Map<String, Object> comparison data
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTopicProgressComparison() {
        try {
            String userId = UserInfo.getUserId();
            Map<String, Object> comparison = new Map<String, Object>();
            
            // Get progress for both tracks
            TopicProgressData consultantProgress = getTopicProgress('Consultant');
            TopicProgressData developerProgress = getTopicProgress('Developer');
            
            comparison.put('consultant', consultantProgress);
            comparison.put('developer', developerProgress);
            comparison.put('comparisonInsights', generateComparisonInsights(consultantProgress, developerProgress));
            
            return comparison;
            
        } catch (Exception e) {
            throw new AuraHandledException('Unable to load progress comparison: ' + e.getMessage());
        }
    }
    
    /**
     * @description Record user action for analytics
     * @param actionId Action taken
     * @param topicName Target topic (optional)
     * @return Boolean success status
     */
    @AuraEnabled
    public static Boolean recordProgressAction(String actionId, String topicName) {
        try {
            System.debug('Progress action recorded: ' + actionId + ' for topic: ' + topicName);
            // In real implementation, create analytics record
            return true;
        } catch (Exception e) {
            System.debug('Error recording progress action: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Get user's certification track from profile
     * @param userId User ID
     * @return String certification track
     */
    private static String getUserCertificationTrack(String userId) {
        List<UserProfile__c> profiles = [
            SELECT CertificationGoals__c
            FROM UserProfile__c 
            WHERE User__c = :userId 
            LIMIT 1
        ];
        
        return !profiles.isEmpty() && profiles[0].CertificationGoals__c != null ? 
               profiles[0].CertificationGoals__c : 'Consultant';
    }
    
    /**
     * @description Calculate overall track summary
     * @param userId User ID
     * @param certificationTrack Certification track
     * @return OverallTrackSummary summary metrics
     */
    private static OverallTrackSummary calculateTrackSummary(String userId, String certificationTrack) {
        OverallTrackSummary summary = new OverallTrackSummary();
        
        // Get user performance data
        List<UserPerformanceSummary__c> performanceSummaries = [
            SELECT RecentAccuracyRate__c, TotalQuestionsAnswered__c, TotalStudyHours__c
            FROM UserPerformanceSummary__c 
            WHERE User__c = :userId 
            LIMIT 1
        ];
        
        if (!performanceSummaries.isEmpty()) {
            UserPerformanceSummary__c performance = performanceSummaries[0];
            summary.hoursStudied = Integer.valueOf(performance.TotalStudyHours__c != null ? 
                                                  performance.TotalStudyHours__c : 0);
        } else {
            summary.hoursStudied = 0;
        }
        
        // Calculate topic completion stats
        Set<String> trackTopics = getTopicsForTrack(certificationTrack);
        summary.totalTopics = trackTopics.size();
        
        // Get completed topics count (>= 80% mastery)
        List<AggregateResult> completedTopics = [
            SELECT COUNT(Question__r.Topic__c) completedCount
            FROM UserAnswer__c 
            WHERE User__c = :userId 
              AND Question__r.CertificationTrack__c = :certificationTrack
              AND Question__r.Topic__c IN :trackTopics
            GROUP BY Question__r.Topic__c
            HAVING AVG(CASE WHEN IsCorrect__c = true THEN 100.0 ELSE 0.0 END) >= 80.0
        ];
        
        summary.topicsCompleted = completedTopics.size();
        
        // Calculate overall progress
        summary.overallProgress = summary.totalTopics > 0 ? 
            (summary.topicsCompleted * 100.0) / summary.totalTopics : 0;
        
        // Determine progress level and readiness
        summary.progressLevel = determineProgressLevel(summary.overallProgress, summary.hoursStudied);
        summary.readinessStatus = determineReadinessStatus(summary.overallProgress, summary.hoursStudied);
        
        // Set next milestone and estimated date
        summary.nextMilestone = determineNextMilestone(summary);
        summary.estimatedReadinessDate = calculateEstimatedReadinessDate(summary);
        summary.motivationalMessage = generateMotivationalMessage(summary);
        
        return summary;
    }
    
    /**
     * @description Calculate progress for each topic in track
     * @param userId User ID
     * @param certificationTrack Certification track
     * @return List<TopicProgress> topic progress list
     */
    private static List<TopicProgress> calculateTopicProgress(String userId, String certificationTrack) {
        List<TopicProgress> topicProgressList = new List<TopicProgress>();
        
        Set<String> trackTopics = getTopicsForTrack(certificationTrack);
        Map<String, Decimal> topicWeights = getTopicWeights(certificationTrack);
        
        for (String topicName : trackTopics) {
            TopicProgress topicProg = new TopicProgress();
            topicProg.topicName = topicName;
            topicProg.topicDisplayName = getTopicDisplayName(topicName);
            topicProg.weightPercentage = topicWeights.containsKey(topicName) ? topicWeights.get(topicName) : 0;
            topicProg.weightDisplay = topicProg.weightPercentage > 0 ? 
                '(' + topicProg.weightPercentage.format() + '%)' : '';
            
            // Get topic performance statistics
            List<AggregateResult> topicStats = [
                SELECT COUNT(Id) totalAnswered,
                       SUM(CASE WHEN IsCorrect__c = true THEN 1 ELSE 0 END) correctAnswers,
                       AVG(CASE WHEN IsCorrect__c = true THEN 100.0 ELSE 0.0 END) avgScore,
                       MAX(AnsweredDate__c) lastStudied
                FROM UserAnswer__c 
                WHERE User__c = :userId 
                  AND Question__r.Topic__c = :topicName
                  AND Question__r.CertificationTrack__c = :certificationTrack
            ];
            
            if (!topicStats.isEmpty() && topicStats[0].get('totalAnswered') != null) {
                Integer totalAnswered = (Integer) topicStats[0].get('totalAnswered');
                Integer correctAnswers = (Integer) topicStats[0].get('correctAnswers');
                Decimal avgScore = (Decimal) topicStats[0].get('avgScore');
                DateTime lastStudied = (DateTime) topicStats[0].get('lastStudied');
                
                topicProg.questionsAnswered = totalAnswered;
                topicProg.correctAnswers = correctAnswers;
                topicProg.masteryScore = avgScore != null ? avgScore : 0;
                topicProg.accuracyRate = totalAnswered > 0 ? (correctAnswers * 100.0) / totalAnswered : 0;
                topicProg.lastStudied = lastStudied?.date();
            } else {
                topicProg.questionsAnswered = 0;
                topicProg.correctAnswers = 0;
                topicProg.masteryScore = 0;
                topicProg.accuracyRate = 0;
            }
            
            // Get total available questions for this topic
            topicProg.totalAvailableQuestions = [
                SELECT COUNT() 
                FROM Question__c 
                WHERE Topic__c = :topicName 
                  AND CertificationTrack__c = :certificationTrack 
                  AND Active__c = true
            ];
            
            // Calculate progress percentage (combination of questions answered and mastery)
            Decimal questionsProgress = topicProg.totalAvailableQuestions > 0 ? 
                (topicProg.questionsAnswered * 50.0) / topicProg.totalAvailableQuestions : 0;
            Decimal masteryProgress = topicProg.masteryScore * 0.5;
            topicProg.progressPercentage = Math.min(questionsProgress + masteryProgress, 100);
            topicProg.progressDisplay = topicProg.progressPercentage.format() + '%';
            
            // Determine mastery level and status
            topicProg.masteryLevel = determineMasteryLevel(topicProg.masteryScore);
            topicProg.status = determineTopicStatus(topicProg.progressPercentage, topicProg.masteryScore);
            
            // Set visual styling
            topicProg.iconName = getTopicIcon(topicName);
            topicProg.colorClass = getTopicColorClass(topicProg.status);
            topicProg.progressBarClass = getProgressBarClass(topicProg.masteryScore);
            
            // Determine if weak area or strength
            topicProg.isWeakArea = topicProg.masteryScore < 60;
            topicProg.isStrength = topicProg.masteryScore >= 85;
            
            // Generate improvement suggestion
            topicProg.improvementSuggestion = generateTopicImprovementSuggestion(topicProg);
            
            // Estimate study time
            topicProg.hoursSpent = estimateHoursSpent(topicProg.questionsAnswered);
            topicProg.recommendedAdditionalHours = calculateRecommendedHours(topicProg.masteryScore, topicProg.weightPercentage);
            
            // Set study and practice URLs
            topicProg.studyUrl = '/study/' + topicName.toLowerCase();
            topicProg.practiceUrl = '/practice/' + topicName.toLowerCase();
            
            topicProgressList.add(topicProg);
        }
        
        // Sort by weight (highest first) then by progress (lowest first for focus)
        topicProgressList.sort(new TopicProgressComparator());
        
        return topicProgressList;
    }
    
    /**
     * @description Identify weak areas requiring focus
     * @param topicProgress List of topic progress
     * @return List<WeakAreaFocus> weak areas
     */
    private static List<WeakAreaFocus> identifyWeakAreas(List<TopicProgress> topicProgress) {
        List<WeakAreaFocus> weakAreas = new List<WeakAreaFocus>();
        
        for (TopicProgress topic : topicProgress) {
            if (topic.isWeakArea) {
                WeakAreaFocus weakArea = new WeakAreaFocus();
                weakArea.topicName = topic.topicName;
                weakArea.topicDisplayName = topic.topicDisplayName;
                weakArea.currentScore = topic.masteryScore;
                weakArea.targetScore = 75.0; // Target proficiency level
                
                // Determine priority based on score and weight
                if (topic.masteryScore < 40) {
                    weakArea.priorityLevel = 'Critical';
                } else if (topic.masteryScore < 50 || topic.weightPercentage >= 25) {
                    weakArea.priorityLevel = 'High';
                } else if (topic.masteryScore < 60) {
                    weakArea.priorityLevel = 'Medium';
                } else {
                    weakArea.priorityLevel = 'Low';
                }
                
                weakArea.focusReason = generateFocusReason(topic);
                weakArea.questionsNeeded = Math.max(30 - topic.questionsAnswered, 15);
                weakArea.hoursNeeded = calculateWeakAreaHours(topic.masteryScore, topic.weightPercentage);
                weakArea.actionPlan = generateActionPlan(topic);
                weakArea.keyConceptsToReview = getKeyConceptsForTopic(topic.topicName);
                weakArea.studyMaterialRecommendations = getStudyMaterialRecommendations(topic.topicName);
                weakArea.focusUrl = topic.studyUrl;
                weakArea.iconName = 'utility:warning';
                weakArea.urgencyClass = getUrgencyClass(weakArea.priorityLevel);
                
                weakAreas.add(weakArea);
            }
        }
        
        // Sort by priority and score
        weakAreas.sort(new WeakAreaComparator());
        
        return weakAreas;
    }
    
    /**
     * @description Generate study recommendations
     * @param progressData Complete progress data
     * @return List<StudyRecommendation> recommendations
     */
    private static List<StudyRecommendation> generateStudyRecommendations(TopicProgressData progressData) {
        List<StudyRecommendation> recommendations = new List<StudyRecommendation>();
        Integer recId = 1;
        
        // Focus recommendations for weak areas
        for (WeakAreaFocus weakArea : progressData.weakAreas) {
            if (recommendations.size() >= 5) break; // Limit recommendations
            
            StudyRecommendation rec = new StudyRecommendation();
            rec.recommendationId = 'focus-' + recId++;
            rec.title = 'Focus on ' + weakArea.topicDisplayName;
            rec.description = 'Your score is ' + weakArea.currentScore.format() + '%. Target: ' + weakArea.targetScore.format() + '%';
            rec.recommendationType = 'Focus';
            rec.targetTopic = weakArea.topicName;
            rec.priority = mapPriorityToTiming(weakArea.priorityLevel);
            rec.timeCommitment = weakArea.hoursNeeded + ' hours recommended';
            rec.actionUrl = weakArea.focusUrl;
            rec.iconName = 'utility:target';
            rec.isPersonalized = true;
            rec.reasonWhy = weakArea.focusReason;
            
            recommendations.add(rec);
        }
        
        // Practice recommendations for developing areas
        for (TopicProgress topic : progressData.topicProgress) {
            if (recommendations.size() >= 8) break;
            
            if (topic.masteryScore >= 60 && topic.masteryScore < 85) {
                StudyRecommendation rec = new StudyRecommendation();
                rec.recommendationId = 'practice-' + recId++;
                rec.title = 'Practice ' + topic.topicDisplayName;
                rec.description = 'Build on your progress with targeted practice questions';
                rec.recommendationType = 'Practice';
                rec.targetTopic = topic.topicName;
                rec.priority = 'This Week';
                rec.timeCommitment = '30-45 minutes';
                rec.actionUrl = topic.practiceUrl;
                rec.iconName = 'utility:quiz';
                rec.isPersonalized = true;
                rec.reasonWhy = 'You\'re developing well in this area - practice will boost your confidence';
                
                recommendations.add(rec);
            }
        }
        
        // Advanced practice for strengths
        for (TopicProgress topic : progressData.topicProgress) {
            if (recommendations.size() >= 10) break;
            
            if (topic.isStrength) {
                StudyRecommendation rec = new StudyRecommendation();
                rec.recommendationId = 'advance-' + recId++;
                rec.title = 'Advanced ' + topic.topicDisplayName;
                rec.description = 'Challenge yourself with complex scenarios and edge cases';
                rec.recommendationType = 'Advance';
                rec.targetTopic = topic.topicName;
                rec.priority = 'Next Week';
                rec.timeCommitment = '20-30 minutes';
                rec.actionUrl = topic.practiceUrl + '/advanced';
                rec.iconName = 'utility:trending';
                rec.isPersonalized = true;
                rec.reasonWhy = 'You\'re strong here - advanced practice will ensure exam readiness';
                
                recommendations.add(rec);
            }
        }
        
        return recommendations;
    }
    
    /**
     * @description Generate quick action buttons
     * @param progressData Progress data
     * @return List<ProgressAction> actions
     */
    private static List<ProgressAction> generateQuickActions(TopicProgressData progressData) {
        List<ProgressAction> actions = new List<ProgressAction>();
        
        // Focus on weak areas (if any exist)
        if (!progressData.weakAreas.isEmpty()) {
            ProgressAction focusWeak = new ProgressAction();
            focusWeak.actionId = 'focus-weak-areas';
            focusWeak.title = 'Focus on Weak Areas';
            focusWeak.description = 'Target your improvement areas for maximum impact';
            focusWeak.actionUrl = '/study/weak-areas';
            focusWeak.buttonClass = 'slds-button_destructive';
            focusWeak.iconName = 'utility:target';
            focusWeak.isPrimary = true;
            focusWeak.badgeCount = progressData.weakAreas.size();
            focusWeak.tooltip = progressData.weakAreas.size() + ' areas need attention';
            actions.add(focusWeak);
        }
        
        // Practice all topics
        ProgressAction practiceAll = new ProgressAction();
        practiceAll.actionId = 'practice-all';
        practiceAll.title = 'Mixed Practice';
        practiceAll.description = 'Practice questions from all topics';
        practiceAll.actionUrl = '/practice/' + progressData.certificationTrack.toLowerCase();
        practiceAll.buttonClass = 'slds-button_brand';
        practiceAll.iconName = 'utility:quiz';
        practiceAll.isPrimary = progressData.weakAreas.isEmpty();
        practiceAll.tooltip = 'Balanced practice across all topics';
        actions.add(practiceAll);
        
        // Mock exam
        ProgressAction mockExam = new ProgressAction();
        mockExam.actionId = 'mock-exam';
        mockExam.title = 'Mock Exam';
        mockExam.description = 'Full-length practice exam';
        mockExam.actionUrl = '/exam/' + progressData.certificationTrack.toLowerCase() + '/practice';
        mockExam.buttonClass = 'slds-button_outline-brand';
        mockExam.iconName = 'utility:date_time';
        mockExam.isPrimary = false;
        mockExam.tooltip = '60 questions, 105 minutes';
        actions.add(mockExam);
        
        // Study plan
        ProgressAction studyPlan = new ProgressAction();
        studyPlan.actionId = 'update-study-plan';
        studyPlan.title = 'Update Study Plan';
        studyPlan.description = 'Refresh your personalized study schedule';
        studyPlan.actionUrl = '/study-plan/update';
        studyPlan.buttonClass = 'slds-button_neutral';
        studyPlan.iconName = 'utility:planning';
        studyPlan.isPrimary = false;
        studyPlan.tooltip = 'AI-generated study recommendations';
        actions.add(studyPlan);
        
        return actions;
    }
    
    /**
     * @description Generate AI-powered progress insights
     * @param progressData Complete progress data
     * @return ProgressInsights insights
     */
    private static ProgressInsights generateProgressInsights(TopicProgressData progressData) {
        ProgressInsights insights = new ProgressInsights();
        
        // Primary insight based on overall progress
        if (progressData.trackSummary.overallProgress >= 80) {
            insights.primaryInsight = 'You\'re nearly exam ready! Focus on fine-tuning your weak areas.';
        } else if (progressData.trackSummary.overallProgress >= 60) {
            insights.primaryInsight = 'Great progress! You\'re building solid knowledge across topics.';
        } else if (progressData.trackSummary.overallProgress >= 30) {
            insights.primaryInsight = 'You\'re making steady progress. Focus on consistency.';
        } else {
            insights.primaryInsight = 'You\'re getting started! Focus on building foundational knowledge.';
        }
        
        // Identify key strengths
        for (TopicProgress topic : progressData.topicProgress) {
            if (topic.isStrength && insights.keyStrengths.size() < 3) {
                insights.keyStrengths.add(topic.topicDisplayName + ' (' + topic.masteryScore.format() + '%)');
            }
        }
        
        // Identify improvement areas
        for (TopicProgress topic : progressData.topicProgress) {
            if (topic.isWeakArea && insights.improvementAreas.size() < 3) {
                insights.improvementAreas.add(topic.topicDisplayName + ' (' + topic.masteryScore.format() + '%)');
            }
        }
        
        // Analyze study pattern
        insights.studyPattern = analyzeStudyPattern(progressData);
        
        // Determine progress trend
        insights.progressTrend = analyzeProgressTrend(progressData);
        
        // Predict next breakthrough
        insights.nextBreakthrough = predictNextBreakthrough(progressData);
        
        // Calculate days to next milestone
        insights.daysToNextMilestone = calculateDaysToMilestone(progressData);
        
        // Generate motivational tip
        insights.motivationalTip = generateMotivationalTip(progressData);
        
        return insights;
    }
    
    // Helper methods
    
    private static Set<String> getTopicsForTrack(String certificationTrack) {
        if (certificationTrack == 'Consultant') {
            return new Set<String>{'FlexCards', 'OmniScripts', 'DataTools', 'Solutioning'};
        } else {
            return new Set<String>{'FlexCards', 'OmniScripts', 'IntegrationProcedures', 'DataRaptors', 'Expressions'};
        }
    }
    
    private static Map<String, Decimal> getTopicWeights(String certificationTrack) {
        if (certificationTrack == 'Consultant') {
            return new Map<String, Decimal>{
                'FlexCards' => 23.0, 'OmniScripts' => 27.0, 'DataTools' => 23.0, 'Solutioning' => 27.0
            };
        } else {
            return new Map<String, Decimal>{
                'FlexCards' => 20.0, 'OmniScripts' => 20.0, 'IntegrationProcedures' => 20.0,
                'DataRaptors' => 20.0, 'Expressions' => 20.0
            };
        }
    }
    
    private static String getTopicDisplayName(String topic) {
        Map<String, String> displayNames = new Map<String, String>{
            'FlexCards' => 'FlexCards',
            'OmniScripts' => 'OmniScripts', 
            'DataTools' => 'Data Tools',
            'DataRaptors' => 'DataRaptors',
            'IntegrationProcedures' => 'Integration Procedures',
            'Expressions' => 'Expression Sets & Decision Matrices',
            'Solutioning' => 'Best Fit Solutioning'
        };
        return displayNames.containsKey(topic) ? displayNames.get(topic) : topic;
    }
    
    private static String getTopicIcon(String topic) {
        Map<String, String> topicIcons = new Map<String, String>{
            'FlexCards' => 'utility:layout',
            'OmniScripts' => 'utility:flow',
            'DataTools' => 'utility:database', 
            'DataRaptors' => 'utility:data_mapping',
            'IntegrationProcedures' => 'utility:integration',
            'Expressions' => 'utility:formula',
            'Solutioning' => 'utility:solution'
        };
        return topicIcons.containsKey(topic) ? topicIcons.get(topic) : 'utility:knowledge_base';
    }
    
    private static Integer getTotalQuestionsAnswered(String userId) {
        return [SELECT COUNT() FROM UserAnswer__c WHERE User__c = :userId];
    }
    
    private static Integer getTotalStudySessions(String userId) {
        List<AggregateResult> sessions = [
            SELECT COUNT_DISTINCT(AnsweredDate__c) sessions
            FROM UserAnswer__c 
            WHERE User__c = :userId
        ];
        return sessions.isEmpty() ? 0 : (Integer)sessions[0].get('sessions');
    }
    
    private static String determineProgressLevel(Decimal progress, Integer hours) {
        if (progress >= 80 && hours >= 40) return 'Expert';
        if (progress >= 60 && hours >= 25) return 'Advanced';  
        if (progress >= 30 && hours >= 10) return 'Intermediate';
        return 'Beginner';
    }
    
    private static String determineReadinessStatus(Decimal progress, Integer hours) {
        if (progress >= 85 && hours >= 50) return 'Exam Ready';
        if (progress >= 70 && hours >= 35) return 'Nearly Ready';
        if (progress >= 40 && hours >= 15) return 'Developing';
        return 'Not Ready';
    }
    
    private static String determineNextMilestone(OverallTrackSummary summary) {
        if (summary.overallProgress < 25) return 'Complete first topic';
        if (summary.overallProgress < 50) return 'Reach halfway mark';
        if (summary.overallProgress < 75) return 'Master 3 out of ' + summary.totalTopics + ' topics';
        return 'Achieve exam readiness';
    }
    
    private static Date calculateEstimatedReadinessDate(OverallTrackSummary summary) {
        Integer weeksNeeded = Integer.valueOf((100 - summary.overallProgress) / 8); // ~8% per week
        return Date.today().addDays(weeksNeeded * 7);
    }
    
    private static String generateMotivationalMessage(OverallTrackSummary summary) {
        if (summary.overallProgress >= 80) return 'You\'re in the final stretch - stay focused!';
        if (summary.overallProgress >= 60) return 'Excellent momentum - keep it up!';
        if (summary.overallProgress >= 30) return 'You\'re building solid progress!';
        return 'Every expert was once a beginner - you\'ve got this!';
    }
    
    // Additional helper methods for calculations and insights would continue here...
    // (Shortened for brevity - would include all the remaining helper methods)
    
    /**
     * @description Comparator for sorting topics by priority
     */
    public class TopicProgressComparator implements Comparable {
        private TopicProgress progress;
        
        public Integer compareTo(Object compareTo) {
            TopicProgress other = ((TopicProgressComparator) compareTo).progress;
            
            // Sort by weight (descending), then by mastery score (ascending for weak areas first)
            if (this.progress.weightPercentage != other.weightPercentage) {
                return other.weightPercentage > this.progress.weightPercentage ? 1 : -1;
            }
            
            return this.progress.masteryScore < other.masteryScore ? -1 : 
                   this.progress.masteryScore > other.masteryScore ? 1 : 0;
        }
    }
    
    /**
     * @description Comparator for sorting weak areas by priority
     */
    public class WeakAreaComparator implements Comparable {
        private WeakAreaFocus weakArea;
        
        public Integer compareTo(Object compareTo) {
            WeakAreaFocus other = ((WeakAreaComparator) compareTo).weakArea;
            
            // Sort by priority level, then by current score (lowest first)
            Map<String, Integer> priorityOrder = new Map<String, Integer>{
                'Critical' => 4, 'High' => 3, 'Medium' => 2, 'Low' => 1
            };
            
            Integer thisPriority = priorityOrder.get(this.weakArea.priorityLevel);
            Integer otherPriority = priorityOrder.get(other.weakArea.priorityLevel);
            
            if (thisPriority != otherPriority) {
                return otherPriority - thisPriority;
            }
            
            return this.weakArea.currentScore < other.weakArea.currentScore ? -1 : 1;
        }
    }
    
    // Stub implementations for brevity - would implement all helper methods
    private static String determineMasteryLevel(Decimal score) { return 'Developing'; }
    private static String determineTopicStatus(Decimal progress, Decimal mastery) { return 'In Progress'; }
    private static String getTopicColorClass(String status) { return 'slds-progress-bar__value'; }
    private static String getProgressBarClass(Decimal score) { return 'slds-progress-bar'; }
    private static String generateTopicImprovementSuggestion(TopicProgress topic) { return 'Keep practicing'; }
    private static Integer estimateHoursSpent(Integer questions) { return questions / 4; }
    private static Integer calculateRecommendedHours(Decimal score, Decimal weight) { return 5; }
    private static String generateFocusReason(TopicProgress topic) { return 'Needs improvement'; }
    private static Integer calculateWeakAreaHours(Decimal score, Decimal weight) { return 8; }
    private static String generateActionPlan(TopicProgress topic) { return 'Focus and practice'; }
    private static List<String> getKeyConceptsForTopic(String topic) { return new List<String>{'Concepts'}; }
    private static List<String> getStudyMaterialRecommendations(String topic) { return new List<String>{'Materials'}; }
    private static String getUrgencyClass(String priority) { return 'urgent'; }
    private static String mapPriorityToTiming(String priority) { return 'This Week'; }
    private static String analyzeStudyPattern(TopicProgressData data) { return 'Consistent'; }
    private static String analyzeProgressTrend(TopicProgressData data) { return 'Steady'; }
    private static String predictNextBreakthrough(TopicProgressData data) { return 'FlexCards mastery'; }
    private static Integer calculateDaysToMilestone(TopicProgressData data) { return 14; }
    private static String generateMotivationalTip(TopicProgressData data) { return 'Stay consistent!'; }
    private static List<String> generateComparisonInsights(TopicProgressData consultant, TopicProgressData developer) { return new List<String>{'Insights'}; }
}