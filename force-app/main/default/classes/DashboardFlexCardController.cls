/**
 * @description Dashboard FlexCard Controller for OmniStudio Training Platform
 * @author Claude Code Assistant
 * @since User Story #18 - Dashboard FlexCard with Progress Tracking
 * @version 1.0
 * 
 * This class provides backend data and logic for the main dashboard FlexCard,
 * including progress tracking, weak area identification, and real-time updates
 * for learner certification preparation journey.
 */
public with sharing class DashboardFlexCardController {
    
    /**
     * @description Dashboard data structure for FlexCard
     */
    public class DashboardData {
        @AuraEnabled public String userId {get; set;}
        @AuraEnabled public String userName {get; set;}
        @AuraEnabled public String primaryTrack {get; set;}
        @AuraEnabled public OverallProgress overallProgress {get; set;}
        @AuraEnabled public List<TrackProgress> trackProgress {get; set;}
        @AuraEnabled public List<WeakArea> weakAreas {get; set;}
        @AuraEnabled public List<QuickAction> quickActions {get; set;}
        @AuraEnabled public StudyStreak studyStreak {get; set;}
        @AuraEnabled public DateTime lastUpdated {get; set;}
        
        public DashboardData() {
            this.trackProgress = new List<TrackProgress>();
            this.weakAreas = new List<WeakArea>();
            this.quickActions = new List<QuickAction>();
        }
    }
    
    /**
     * @description Overall progress summary
     */
    public class OverallProgress {
        @AuraEnabled public Decimal progressPercentage {get; set;}
        @AuraEnabled public String progressLevel {get; set;} // Beginner, Intermediate, Advanced, Ready
        @AuraEnabled public Integer totalHoursStudied {get; set;}
        @AuraEnabled public Integer questionsAnswered {get; set;}
        @AuraEnabled public Decimal averageScore {get; set;}
        @AuraEnabled public String readinessIndicator {get; set;} // Not Ready, Getting Ready, Exam Ready
        @AuraEnabled public String motivationalMessage {get; set;}
    }
    
    /**
     * @description Progress tracking per certification track
     */
    public class TrackProgress {
        @AuraEnabled public String trackName {get; set;}
        @AuraEnabled public String trackDisplayName {get; set;}
        @AuraEnabled public Decimal progressPercentage {get; set;}
        @AuraEnabled public List<TopicProgress> topicProgress {get; set;}
        @AuraEnabled public Integer hoursCompleted {get; set;}
        @AuraEnabled public Integer totalHours {get; set;}
        @AuraEnabled public String currentModule {get; set;}
        @AuraEnabled public String nextRecommendation {get; set;}
        @AuraEnabled public Boolean isActive {get; set;}
        
        public TrackProgress() {
            this.topicProgress = new List<TopicProgress>();
        }
    }
    
    /**
     * @description Topic-specific progress within a track
     */
    public class TopicProgress {
        @AuraEnabled public String topicName {get; set;}
        @AuraEnabled public String topicDisplayName {get; set;}
        @AuraEnabled public Decimal progressPercentage {get; set;}
        @AuraEnabled public Decimal masteryScore {get; set;}
        @AuraEnabled public Integer questionsAnswered {get; set;}
        @AuraEnabled public String status {get; set;} // Not Started, In Progress, Mastered, Needs Review
        @AuraEnabled public String iconName {get; set;}
        @AuraEnabled public String colorClass {get; set;}
    }
    
    /**
     * @description Weak area identification and recommendations
     */
    public class WeakArea {
        @AuraEnabled public String topicName {get; set;}
        @AuraEnabled public String trackName {get; set;}
        @AuraEnabled public Decimal currentScore {get; set;}
        @AuraEnabled public String severityLevel {get; set;} // Critical, Moderate, Minor
        @AuraEnabled public String recommendation {get; set;}
        @AuraEnabled public String actionUrl {get; set;}
        @AuraEnabled public String iconName {get; set;}
        @AuraEnabled public Integer questionsNeeded {get; set;}
    }
    
    /**
     * @description Quick action buttons for dashboard
     */
    public class QuickAction {
        @AuraEnabled public String actionId {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public String actionUrl {get; set;}
        @AuraEnabled public String iconName {get; set;}
        @AuraEnabled public String buttonClass {get; set;}
        @AuraEnabled public Boolean isEnabled {get; set;}
        @AuraEnabled public String badge {get; set;} // Optional badge text
    }
    
    /**
     * @description Study streak and engagement metrics
     */
    public class StudyStreak {
        @AuraEnabled public Integer currentStreak {get; set;}
        @AuraEnabled public Integer longestStreak {get; set;}
        @AuraEnabled public String streakStatus {get; set;} // Active, At Risk, Lost
        @AuraEnabled public Date lastStudyDate {get; set;}
        @AuraEnabled public Integer studyGoalHours {get; set;}
        @AuraEnabled public Integer weeklyHoursCompleted {get; set;}
        @AuraEnabled public List<String> achievements {get; set;}
        
        public StudyStreak() {
            this.achievements = new List<String>();
        }
    }
    
    /**
     * @description Get comprehensive dashboard data for current user
     * @return DashboardData complete dashboard information
     */
    @AuraEnabled(cacheable=false)
    public static DashboardData getDashboardData() {
        try {
            String userId = UserInfo.getUserId();
            DashboardData dashboardData = new DashboardData();
            
            dashboardData.userId = userId;
            dashboardData.userName = UserInfo.getName();
            dashboardData.lastUpdated = DateTime.now();
            
            // Get user profile to determine primary track
            UserProfile__c userProfile = getUserProfile(userId);
            dashboardData.primaryTrack = userProfile?.CertificationGoals__c != null ? 
                userProfile.CertificationGoals__c : 'Consultant';
            
            // Calculate overall progress
            dashboardData.overallProgress = calculateOverallProgress(userId, dashboardData.primaryTrack);
            
            // Get track-specific progress
            dashboardData.trackProgress = calculateTrackProgress(userId);
            
            // Identify weak areas
            dashboardData.weakAreas = identifyWeakAreas(userId, dashboardData.primaryTrack);
            
            // Generate quick actions
            dashboardData.quickActions = generateQuickActions(userId, dashboardData.primaryTrack, dashboardData.weakAreas);
            
            // Calculate study streak
            dashboardData.studyStreak = calculateStudyStreak(userId);
            
            return dashboardData;
            
        } catch (Exception e) {
            System.debug('Error in getDashboardData: ' + e.getMessage());
            throw new AuraHandledException('Unable to load dashboard data: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get user profile information
     * @param userId User ID to query
     * @return UserProfile__c user profile record
     */
    private static UserProfile__c getUserProfile(String userId) {
        List<UserProfile__c> profiles = [
            SELECT Id, CertificationGoals__c, CurrentDifficulty__c, PreferredLearningStyle__c,
                   StudyHoursPerWeek__c, StudyGoalDate__c
            FROM UserProfile__c 
            WHERE User__c = :userId 
            LIMIT 1
        ];
        
        return profiles.isEmpty() ? null : profiles[0];
    }
    
    /**
     * @description Calculate overall progress across all activities
     * @param userId User ID
     * @param primaryTrack Primary certification track
     * @return OverallProgress progress summary
     */
    private static OverallProgress calculateOverallProgress(String userId, String primaryTrack) {
        OverallProgress progress = new OverallProgress();
        
        // Get user performance summary if it exists
        List<UserPerformanceSummary__c> summaries = [
            SELECT RecentAccuracyRate__c, TotalQuestionsAnswered__c, AverageResponseTime__c,
                   TotalStudyHours__c, LastActivity__c
            FROM UserPerformanceSummary__c 
            WHERE User__c = :userId 
            LIMIT 1
        ];
        
        if (!summaries.isEmpty()) {
            UserPerformanceSummary__c summary = summaries[0];
            progress.questionsAnswered = Integer.valueOf(summary.TotalQuestionsAnswered__c != null ? 
                summary.TotalQuestionsAnswered__c : 0);
            progress.averageScore = summary.RecentAccuracyRate__c != null ? 
                summary.RecentAccuracyRate__c : 0;
            progress.totalHoursStudied = Integer.valueOf(summary.TotalStudyHours__c != null ? 
                summary.TotalStudyHours__c : 0);
        } else {
            progress.questionsAnswered = 0;
            progress.averageScore = 0;
            progress.totalHoursStudied = 0;
        }
        
        // Calculate progress percentage based on questions answered and study time
        Map<String, Integer> studyTimeEstimates = LearningPathManager.getStudyTimeEstimates(primaryTrack);
        Integer totalRequiredHours = 0;
        for (Integer hours : studyTimeEstimates.values()) {
            totalRequiredHours += hours;
        }
        
        Decimal timeProgress = totalRequiredHours > 0 ? 
            (progress.totalHoursStudied * 100.0) / totalRequiredHours : 0;
        Decimal questionProgress = progress.questionsAnswered >= 100 ? 
            Math.min((progress.questionsAnswered * 100.0) / 400, 100) : 0; // 400 questions for full coverage
        
        progress.progressPercentage = (timeProgress + questionProgress) / 2;
        
        // Determine progress level and readiness
        progress.progressLevel = determineProgressLevel(progress.progressPercentage, progress.averageScore);
        progress.readinessIndicator = determineReadinessLevel(progress.progressPercentage, progress.averageScore);
        progress.motivationalMessage = generateMotivationalMessage(progress);
        
        return progress;
    }
    
    /**
     * @description Calculate progress for each certification track
     * @param userId User ID
     * @return List<TrackProgress> progress for each track
     */
    private static List<TrackProgress> calculateTrackProgress(String userId) {
        List<TrackProgress> trackProgressList = new List<TrackProgress>();
        
        // Get learning paths for both tracks
        for (String track : new List<String>{'Consultant', 'Developer'}) {
            TrackProgress trackProg = new TrackProgress();
            trackProg.trackName = track;
            trackProg.trackDisplayName = track + ' Certification';
            trackProg.isActive = true; // Could be determined by user profile
            
            // Get track study time estimates
            Map<String, Integer> timeEstimates = LearningPathManager.getStudyTimeEstimates(track);
            trackProg.totalHours = 0;
            for (Integer hours : timeEstimates.values()) {
                trackProg.totalHours += hours;
            }
            
            // Calculate topic progress for this track
            trackProg.topicProgress = calculateTopicProgressForTrack(userId, track);
            
            // Calculate overall track progress
            Decimal totalTopicProgress = 0;
            for (TopicProgress topicProg : trackProg.topicProgress) {
                totalTopicProgress += topicProg.progressPercentage;
            }
            trackProg.progressPercentage = trackProg.topicProgress.size() > 0 ? 
                totalTopicProgress / trackProg.topicProgress.size() : 0;
            
            trackProg.hoursCompleted = Integer.valueOf(trackProg.progressPercentage * trackProg.totalHours / 100);
            
            // Determine current module and next recommendation
            LearningPathManager.LearningProgress learningProgress = 
                LearningPathManager.getPersonalizedRecommendations(userId, track);
            trackProg.currentModule = learningProgress.currentModuleId;
            trackProg.nextRecommendation = !learningProgress.recommendedNext.isEmpty() ? 
                learningProgress.recommendedNext[0] : 'Continue with current studies';
            
            trackProgressList.add(trackProg);
        }
        
        return trackProgressList;
    }
    
    /**
     * @description Calculate topic progress for a specific track
     * @param userId User ID
     * @param track Certification track
     * @return List<TopicProgress> topic progress list
     */
    private static List<TopicProgress> calculateTopicProgressForTrack(String userId, String track) {
        List<TopicProgress> topicProgressList = new List<TopicProgress>();
        
        Set<String> validTopics = QuestionCategorization.getValidTopics(track);
        
        for (String topic : validTopics) {
            TopicProgress topicProg = new TopicProgress();
            topicProg.topicName = topic;
            topicProg.topicDisplayName = getTopicDisplayName(topic);
            
            // Query user answers for this topic
            List<AggregateResult> topicStats = [
                SELECT COUNT(Id) totalAnswers, 
                       AVG(CASE WHEN IsCorrect__c = true THEN 100.0 ELSE 0.0 END) avgScore
                FROM UserAnswer__c 
                WHERE User__c = :userId 
                  AND Question__r.Topic__c = :topic
                  AND Question__r.CertificationTrack__c = :track
            ];
            
            if (!topicStats.isEmpty() && topicStats[0].get('totalAnswers') != null) {
                Integer totalAnswers = (Integer) topicStats[0].get('totalAnswers');
                Decimal avgScore = (Decimal) topicStats[0].get('avgScore');
                
                topicProg.questionsAnswered = totalAnswers;
                topicProg.masteryScore = avgScore != null ? avgScore : 0;
                
                // Calculate progress based on questions answered and mastery
                topicProg.progressPercentage = Math.min((totalAnswers * 2) + (topicProg.masteryScore * 0.5), 100);
            } else {
                topicProg.questionsAnswered = 0;
                topicProg.masteryScore = 0;
                topicProg.progressPercentage = 0;
            }
            
            // Determine status and styling
            topicProg.status = determineTopicStatus(topicProg.progressPercentage, topicProg.masteryScore);
            topicProg.iconName = getTopicIcon(topic);
            topicProg.colorClass = getTopicColorClass(topicProg.status);
            
            topicProgressList.add(topicProg);
        }
        
        return topicProgressList;
    }
    
    /**
     * @description Identify weak areas requiring attention
     * @param userId User ID
     * @param primaryTrack Primary certification track
     * @return List<WeakArea> identified weak areas
     */
    private static List<WeakArea> identifyWeakAreas(String userId, String primaryTrack) {
        List<WeakArea> weakAreas = new List<WeakArea>();
        
        // Query topics with low performance
        List<AggregateResult> weakTopics = [
            SELECT Question__r.Topic__c topic, Question__r.CertificationTrack__c track,
                   AVG(CASE WHEN IsCorrect__c = true THEN 100.0 ELSE 0.0 END) avgScore,
                   COUNT(Id) totalAnswers
            FROM UserAnswer__c 
            WHERE User__c = :userId 
              AND Question__r.CertificationTrack__c = :primaryTrack
              AND AnsweredDate__c = LAST_N_DAYS:30
            GROUP BY Question__r.Topic__c, Question__r.CertificationTrack__c
            HAVING AVG(CASE WHEN IsCorrect__c = true THEN 100.0 ELSE 0.0 END) < 70
               AND COUNT(Id) >= 5
            ORDER BY AVG(CASE WHEN IsCorrect__c = true THEN 100.0 ELSE 0.0 END) ASC
        ];
        
        for (AggregateResult ar : weakTopics) {
            WeakArea weakArea = new WeakArea();
            weakArea.topicName = (String) ar.get('topic');
            weakArea.trackName = (String) ar.get('track');
            weakArea.currentScore = (Decimal) ar.get('avgScore');
            Integer totalAnswers = (Integer) ar.get('totalAnswers');
            
            // Determine severity
            if (weakArea.currentScore < 50) {
                weakArea.severityLevel = 'Critical';
                weakArea.iconName = 'utility:error';
            } else if (weakArea.currentScore < 60) {
                weakArea.severityLevel = 'Moderate';
                weakArea.iconName = 'utility:warning';
            } else {
                weakArea.severityLevel = 'Minor';
                weakArea.iconName = 'utility:info';
            }
            
            // Generate recommendation
            weakArea.recommendation = generateWeakAreaRecommendation(weakArea.topicName, weakArea.currentScore);
            weakArea.questionsNeeded = Math.max(20 - totalAnswers, 10);
            weakArea.actionUrl = '/study/' + weakArea.topicName.toLowerCase();
            
            weakAreas.add(weakArea);
            
            // Limit to top 5 weak areas
            if (weakAreas.size() >= 5) {
                break;
            }
        }
        
        return weakAreas;
    }
    
    /**
     * @description Generate quick action buttons for dashboard
     * @param userId User ID
     * @param primaryTrack Primary track
     * @param weakAreas Identified weak areas
     * @return List<QuickAction> action buttons
     */
    private static List<QuickAction> generateQuickActions(String userId, String primaryTrack, List<WeakArea> weakAreas) {
        List<QuickAction> actions = new List<QuickAction>();
        
        // Continue studying action
        QuickAction continueStudy = new QuickAction();
        continueStudy.actionId = 'continue-study';
        continueStudy.title = 'Continue Studying';
        continueStudy.description = 'Resume your learning path';
        continueStudy.iconName = 'utility:bookmark';
        continueStudy.buttonClass = 'slds-button_brand';
        continueStudy.isEnabled = true;
        continueStudy.actionUrl = '/study/continue';
        actions.add(continueStudy);
        
        // Practice questions action
        QuickAction practiceQuestions = new QuickAction();
        practiceQuestions.actionId = 'practice-questions';
        practiceQuestions.title = 'Practice Questions';
        practiceQuestions.description = 'Test your knowledge';
        practiceQuestions.iconName = 'utility:question_mark';
        practiceQuestions.buttonClass = 'slds-button_neutral';
        practiceQuestions.isEnabled = true;
        practiceQuestions.actionUrl = '/practice/' + primaryTrack.toLowerCase();
        actions.add(practiceQuestions);
        
        // Mock exam action
        QuickAction mockExam = new QuickAction();
        mockExam.actionId = 'mock-exam';
        mockExam.title = 'Mock Exam';
        mockExam.description = 'Full-length practice exam';
        mockExam.iconName = 'utility:date_time';
        mockExam.buttonClass = 'slds-button_outline-brand';
        mockExam.isEnabled = true;
        mockExam.actionUrl = '/exam/' + primaryTrack.toLowerCase();
        actions.add(mockExam);
        
        // Weak areas action (if any exist)
        if (!weakAreas.isEmpty()) {
            QuickAction focusWeakAreas = new QuickAction();
            focusWeakAreas.actionId = 'focus-weak-areas';
            focusWeakAreas.title = 'Focus on Weak Areas';
            focusWeakAreas.description = 'Target improvement areas';
            focusWeakAreas.iconName = 'utility:target';
            focusWeakAreas.buttonClass = 'slds-button_destructive';
            focusWeakAreas.isEnabled = true;
            focusWeakAreas.badge = String.valueOf(weakAreas.size());
            focusWeakAreas.actionUrl = '/practice/weak-areas';
            actions.add(focusWeakAreas);
        }
        
        return actions;
    }
    
    /**
     * @description Calculate study streak and engagement metrics
     * @param userId User ID
     * @return StudyStreak streak information
     */
    private static StudyStreak calculateStudyStreak(String userId) {
        StudyStreak streak = new StudyStreak();
        
        // Get recent study activity
        List<UserAnswer__c> recentActivity = [
            SELECT AnsweredDate__c 
            FROM UserAnswer__c 
            WHERE User__c = :userId 
              AND AnsweredDate__c = LAST_N_DAYS:30
            ORDER BY AnsweredDate__c DESC
            LIMIT 100
        ];
        
        if (recentActivity.isEmpty()) {
            streak.currentStreak = 0;
            streak.longestStreak = 0;
            streak.streakStatus = 'Lost';
            return streak;
        }
        
        // Calculate current streak
        Date today = Date.today();
        Set<Date> studyDates = new Set<Date>();
        for (UserAnswer__c answer : recentActivity) {
            studyDates.add(answer.AnsweredDate__c.date());
        }
        
        streak.lastStudyDate = recentActivity[0].AnsweredDate__c.date();
        streak.currentStreak = calculateCurrentStreak(studyDates, today);
        streak.longestStreak = calculateLongestStreak(studyDates);
        
        // Determine streak status
        if (streak.lastStudyDate == today || streak.lastStudyDate == today.addDays(-1)) {
            streak.streakStatus = 'Active';
        } else if (streak.lastStudyDate >= today.addDays(-3)) {
            streak.streakStatus = 'At Risk';
        } else {
            streak.streakStatus = 'Lost';
        }
        
        // Set study goals (could be from user profile)
        streak.studyGoalHours = 10; // Default 10 hours per week
        
        // Calculate weekly hours (simplified - would need more detailed tracking)
        streak.weeklyHoursCompleted = Integer.valueOf(recentActivity.size() * 0.1); // Rough estimate
        
        // Add achievements based on streak
        if (streak.currentStreak >= 7) {
            streak.achievements.add('7-Day Streak');
        }
        if (streak.currentStreak >= 30) {
            streak.achievements.add('30-Day Streak');
        }
        if (streak.longestStreak >= 50) {
            streak.achievements.add('Dedication Master');
        }
        
        return streak;
    }
    
    // Helper methods for calculations and formatting
    
    private static String determineProgressLevel(Decimal progressPercentage, Decimal averageScore) {
        if (progressPercentage < 25) {
            return 'Beginner';
        } else if (progressPercentage < 60) {
            return 'Intermediate';
        } else if (progressPercentage < 85) {
            return 'Advanced';
        } else {
            return 'Ready';
        }
    }
    
    private static String determineReadinessLevel(Decimal progressPercentage, Decimal averageScore) {
        if (progressPercentage >= 85 && averageScore >= 80) {
            return 'Exam Ready';
        } else if (progressPercentage >= 60 && averageScore >= 70) {
            return 'Getting Ready';
        } else {
            return 'Not Ready';
        }
    }
    
    private static String generateMotivationalMessage(OverallProgress progress) {
        if (progress.progressPercentage >= 85) {
            return 'You\'re exam ready! Schedule your certification test.';
        } else if (progress.progressPercentage >= 60) {
            return 'Great progress! You\'re getting close to exam readiness.';
        } else if (progress.progressPercentage >= 25) {
            return 'Keep going! You\'re building solid knowledge.';
        } else {
            return 'Every expert was once a beginner. You\'ve got this!';
        }
    }
    
    private static String getTopicDisplayName(String topic) {
        Map<String, String> displayNames = new Map<String, String>{
            'FlexCards' => 'FlexCards',
            'OmniScripts' => 'OmniScripts',
            'DataTools' => 'Data Tools',
            'DataRaptors' => 'DataRaptors',
            'IntegrationProcedures' => 'Integration Procedures',
            'Expressions' => 'Expressions',
            'Solutioning' => 'Solution Design'
        };
        return displayNames.containsKey(topic) ? displayNames.get(topic) : topic;
    }
    
    private static String determineTopicStatus(Decimal progressPercentage, Decimal masteryScore) {
        if (progressPercentage == 0) {
            return 'Not Started';
        } else if (progressPercentage >= 80 && masteryScore >= 85) {
            return 'Mastered';
        } else if (masteryScore < 60) {
            return 'Needs Review';
        } else {
            return 'In Progress';
        }
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
    
    private static String getTopicColorClass(String status) {
        Map<String, String> colorClasses = new Map<String, String>{
            'Not Started' => 'slds-progress-bar__value_success',
            'In Progress' => 'slds-progress-bar__value_warning',
            'Mastered' => 'slds-progress-bar__value_success',
            'Needs Review' => 'slds-progress-bar__value_error'
        };
        return colorClasses.containsKey(status) ? colorClasses.get(status) : 'slds-progress-bar__value';
    }
    
    private static String generateWeakAreaRecommendation(String topic, Decimal score) {
        if (score < 50) {
            return 'Review fundamentals and complete practice exercises for ' + getTopicDisplayName(topic);
        } else if (score < 65) {
            return 'Focus on intermediate concepts and scenario-based questions';
        } else {
            return 'Target advanced topics and edge cases to boost mastery';
        }
    }
    
    private static Integer calculateCurrentStreak(Set<Date> studyDates, Date today) {
        Integer streak = 0;
        Date checkDate = today;
        
        while (studyDates.contains(checkDate)) {
            streak++;
            checkDate = checkDate.addDays(-1);
        }
        
        return streak;
    }
    
    private static Integer calculateLongestStreak(Set<Date> studyDates) {
        List<Date> sortedDates = new List<Date>(studyDates);
        sortedDates.sort();
        
        Integer longestStreak = 0;
        Integer currentStreak = 0;
        Date previousDate = null;
        
        for (Date studyDate : sortedDates) {
            if (previousDate == null || studyDate == previousDate.addDays(1)) {
                currentStreak++;
            } else {
                longestStreak = Math.max(longestStreak, currentStreak);
                currentStreak = 1;
            }
            previousDate = studyDate;
        }
        
        return Math.max(longestStreak, currentStreak);
    }
}