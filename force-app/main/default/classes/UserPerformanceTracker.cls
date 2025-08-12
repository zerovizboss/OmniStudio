/**
 * @description Tracks and analyzes user performance for adaptive learning
 * @author Claude AI OmniStudio Training
 * @date 2025-08-12
 */
public with sharing class UserPerformanceTracker {
    
    /**
     * @description Gets comprehensive user performance data
     * @param userId User ID to analyze
     * @return UserPerformanceData wrapper with performance metrics
     */
    public static UserPerformanceData getUserPerformance(Id userId) {
        try {
            // Query user's answer history
            List<UserAnswer__c> answers = [
                SELECT Id, Question__r.Topic__c, Question__r.Difficulty__c, 
                       IsCorrect__c, AnsweredDate__c, Question__r.CertificationTrack__c
                FROM UserAnswer__c 
                WHERE User__c = :userId 
                ORDER BY AnsweredDate__c DESC 
                LIMIT 1000
            ];
            
            // Get user's current profile settings
            UserProfile__c profile = getUserProfile(userId);
            
            return new UserPerformanceData(answers, profile);
            
        } catch (Exception e) {
            System.debug('Error retrieving user performance: ' + e.getMessage());
            return new UserPerformanceData(); // Return empty data for new users
        }
    }
    
    /**
     * @description Updates user performance after answering questions
     * @param userId User ID
     * @param questionId Question ID answered
     * @param isCorrect Whether answer was correct
     * @param responseTime Time taken to answer (seconds)
     */
    public static void recordAnswer(Id userId, Id questionId, Boolean isCorrect, Integer responseTime) {
        try {
            UserAnswer__c answer = new UserAnswer__c(
                User__c = userId,
                Question__c = questionId,
                IsCorrect__c = isCorrect,
                ResponseTime__c = responseTime,
                AnsweredDate__c = DateTime.now()
            );
            
            insert answer;
            
            // Update question usage tracking
            updateQuestionUsage(questionId);
            
            // Update user's performance summary
            updateUserPerformanceSummary(userId);
            
        } catch (Exception e) {
            System.debug('Error recording answer: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets user profile with learning preferences
     * @param userId User ID
     * @return UserProfile__c record
     */
    private static UserProfile__c getUserProfile(Id userId) {
        try {
            return [
                SELECT Id, CurrentDifficulty__c, PreferredLearningStyle__c,
                       StudyHoursPerWeek__c, TargetExamDate__c, CertificationGoals__c
                FROM UserProfile__c 
                WHERE User__c = :userId 
                LIMIT 1
            ];
        } catch (Exception e) {
            // Create default profile for new users
            return new UserProfile__c(
                User__c = userId,
                CurrentDifficulty__c = 2,
                PreferredLearningStyle__c = 'Mixed',
                StudyHoursPerWeek__c = 5
            );
        }
    }
    
    /**
     * @description Updates question usage tracking for rotation
     * @param questionId Question ID that was used
     */
    private static void updateQuestionUsage(Id questionId) {
        try {
            Question__c question = [SELECT Id, UsageCount__c, LastUsed__c FROM Question__c WHERE Id = :questionId];
            question.UsageCount__c = (question.UsageCount__c != null ? question.UsageCount__c : 0) + 1;
            question.LastUsed__c = DateTime.now();
            update question;
        } catch (Exception e) {
            System.debug('Error updating question usage: ' + e.getMessage());
        }
    }
    
    /**
     * @description Updates user's overall performance summary
     * @param userId User ID to update
     */
    private static void updateUserPerformanceSummary(Id userId) {
        try {
            // Calculate recent performance metrics
            List<AggregateResult> recentPerformance = [
                SELECT 
                    COUNT(Id) totalAnswers,
                    SUM(CASE WHEN IsCorrect__c = true THEN 1 ELSE 0 END) correctAnswers,
                    AVG(ResponseTime__c) avgResponseTime
                FROM UserAnswer__c 
                WHERE User__c = :userId 
                AND AnsweredDate__c >= :DateTime.now().addDays(-30)
            ];
            
            if (!recentPerformance.isEmpty() && recentPerformance[0].get('totalAnswers') != null) {
                AggregateResult result = recentPerformance[0];
                Integer totalAnswers = (Integer) result.get('totalAnswers');
                Integer correctAnswers = (Integer) result.get('correctAnswers');
                Decimal avgResponseTime = (Decimal) result.get('avgResponseTime');
                
                Decimal accuracyRate = totalAnswers > 0 ? (Decimal) correctAnswers / totalAnswers : 0;
                
                // Update or create user performance summary
                List<UserPerformanceSummary__c> existingSummary = [
                    SELECT Id FROM UserPerformanceSummary__c WHERE User__c = :userId LIMIT 1
                ];
                
                UserPerformanceSummary__c summary = existingSummary.isEmpty() ? 
                    new UserPerformanceSummary__c(User__c = userId) : 
                    existingSummary[0];
                
                summary.RecentAccuracyRate__c = accuracyRate;
                summary.AverageResponseTime__c = avgResponseTime;
                summary.TotalQuestionsAnswered__c = totalAnswers;
                summary.LastUpdated__c = DateTime.now();
                
                upsert summary;
            }
            
        } catch (Exception e) {
            System.debug('Error updating performance summary: ' + e.getMessage());
        }
    }
}