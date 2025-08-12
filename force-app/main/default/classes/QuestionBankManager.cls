/**
 * @description Question Bank Management System for OmniStudio Training Platform
 * @author Claude Code Assistant
 * @since User Story #17 - Weighted Question Distribution
 * @version 1.0
 * 
 * This class manages question bank maintenance, updates, and quality assurance
 * to ensure the question pool remains current with official exam changes and
 * maintains high effectiveness standards.
 */
public with sharing class QuestionBankManager {
    
    /**
     * @description Question bank health report
     */
    public class QuestionBankHealth {
        public String certificationTrack {get; set;}
        public Integer totalQuestions {get; set;}
        public Boolean meetsMinimumCount {get; set;}
        public Boolean hasProperDistribution {get; set;}
        public Integer questionsNeedingReview {get; set;}
        public Integer outdatedQuestions {get; set;}
        public Integer lowEffectivenessQuestions {get; set;}
        public List<String> recommendations {get; set;}
        public DateTime lastHealthCheck {get; set;}
        public String overallHealth {get; set;} // 'Excellent', 'Good', 'Fair', 'Poor'
        
        public QuestionBankHealth() {
            this.recommendations = new List<String>();
            this.lastHealthCheck = DateTime.now();
        }
    }
    
    /**
     * @description Question update request for content maintenance
     */
    public class QuestionUpdateRequest {
        public String questionId {get; set;}
        public String updateType {get; set;} // 'Content', 'Categorization', 'Effectiveness', 'Retirement'
        public String reason {get; set;}
        public String newContent {get; set;}
        public String newExplanation {get; set;}
        public String newTopic {get; set;}
        public Integer newDifficulty {get; set;}
        public String submittedBy {get; set;}
        public DateTime requestDate {get; set;}
        
        public QuestionUpdateRequest() {
            this.requestDate = DateTime.now();
            this.submittedBy = UserInfo.getUserId();
        }
    }
    
    /**
     * @description Batch import result for new questions
     */
    public class ImportResult {
        public Integer totalProcessed {get; set;}
        public Integer successfulImports {get; set;}
        public Integer failed {get; set;}
        public Integer duplicates {get; set;}
        public List<String> errors {get; set;}
        public List<String> warnings {get; set;}
        public DateTime importDate {get; set;}
        
        public ImportResult() {
            this.errors = new List<String>();
            this.warnings = new List<String>();
            this.importDate = DateTime.now();
        }
    }
    
    private static final Integer MINIMUM_QUESTIONS_PER_TRACK = 400;
    private static final Integer MINIMUM_QUESTIONS_PER_TOPIC = 50;
    private static final Integer QUESTION_REVIEW_DAYS = 180; // 6 months
    private static final Decimal POOR_EFFECTIVENESS_THRESHOLD = 40.0; // Below 40% effectiveness
    
    /**
     * @description Perform comprehensive health check on question bank
     * @param certificationTrack The certification track to analyze
     * @return QuestionBankHealth detailed health report
     */
    public static QuestionBankHealth performHealthCheck(String certificationTrack) {
        QuestionBankHealth health = new QuestionBankHealth();
        health.certificationTrack = certificationTrack;
        
        // Get basic statistics
        WeightedQuestionDistribution.QuestionBankStats stats = 
            WeightedQuestionDistribution.getQuestionBankStats(certificationTrack);
        
        health.totalQuestions = stats.totalQuestions;
        health.meetsMinimumCount = stats.totalQuestions >= MINIMUM_QUESTIONS_PER_TRACK;
        health.hasProperDistribution = checkDistributionHealth(stats);
        
        // Check for questions needing review
        health.questionsNeedingReview = getQuestionsNeedingReview(certificationTrack);
        health.outdatedQuestions = getOutdatedQuestions(certificationTrack);
        health.lowEffectivenessQuestions = getLowEffectivenessQuestions(certificationTrack);
        
        // Generate recommendations
        generateHealthRecommendations(health, stats);
        
        // Calculate overall health score
        health.overallHealth = calculateOverallHealth(health);
        
        return health;
    }
    
    /**
     * @description Check if topic distribution meets quality standards
     * @param stats Question bank statistics
     * @return Boolean true if distribution is healthy
     */
    private static Boolean checkDistributionHealth(WeightedQuestionDistribution.QuestionBankStats stats) {
        // Check minimum questions per topic
        for (String topic : stats.targetWeights.keySet()) {
            Integer topicCount = stats.topicCounts.containsKey(topic) ? stats.topicCounts.get(topic) : 0;
            if (topicCount < MINIMUM_QUESTIONS_PER_TOPIC) {
                return false;
            }
        }
        
        // Check weight deviations
        for (String topic : stats.deviations.keySet()) {
            Decimal deviation = Math.abs(stats.deviations.get(topic));
            if (deviation > 10.0) { // More than 10% deviation
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * @description Get count of questions needing review
     * @param certificationTrack The certification track
     * @return Integer count of questions needing review
     */
    private static Integer getQuestionsNeedingReview(String certificationTrack) {
        Date reviewCutoff = Date.today().addDays(-QUESTION_REVIEW_DAYS);
        
        return [
            SELECT COUNT()
            FROM Question__c 
            WHERE CertificationTrack__c = :certificationTrack
              AND Active__c = true
              AND (LastReviewedDate__c = null OR LastReviewedDate__c < :reviewCutoff)
        ];
    }
    
    /**
     * @description Get count of outdated questions
     * @param certificationTrack The certification track
     * @return Integer count of outdated questions
     */
    private static Integer getOutdatedQuestions(String certificationTrack) {
        Date outdatedCutoff = Date.today().addDays(-365); // 1 year old
        
        return [
            SELECT COUNT()
            FROM Question__c 
            WHERE CertificationTrack__c = :certificationTrack
              AND Active__c = true
              AND CreatedDate < :outdatedCutoff
              AND LastUpdatedDate__c < :outdatedCutoff
        ];
    }
    
    /**
     * @description Get count of questions with low effectiveness
     * @param certificationTrack The certification track
     * @return Integer count of low effectiveness questions
     */
    private static Integer getLowEffectivenessQuestions(String certificationTrack) {
        // This would typically check against effectiveness scores
        // For now, return questions with very high or very low correct rates
        return [
            SELECT COUNT()
            FROM Question__c 
            WHERE CertificationTrack__c = :certificationTrack
              AND Active__c = true
              AND UsageCount__c > 10
              AND Id IN (
                  SELECT Question__c 
                  FROM UserAnswer__c 
                  GROUP BY Question__c
                  HAVING (AVG(CASE WHEN IsCorrect__c = true THEN 100.0 ELSE 0.0 END) < 30 
                         OR AVG(CASE WHEN IsCorrect__c = true THEN 100.0 ELSE 0.0 END) > 90)
              )
        ];
    }
    
    /**
     * @description Generate health improvement recommendations
     * @param health The health report to populate
     * @param stats Question bank statistics
     */
    private static void generateHealthRecommendations(QuestionBankHealth health, 
                                                    WeightedQuestionDistribution.QuestionBankStats stats) {
        // Check minimum count
        if (!health.meetsMinimumCount) {
            Integer needed = MINIMUM_QUESTIONS_PER_TRACK - health.totalQuestions;
            health.recommendations.add('Add ' + needed + ' more questions to meet minimum bank size of ' + 
                                    MINIMUM_QUESTIONS_PER_TRACK);
        }
        
        // Check topic distribution
        for (String topic : stats.targetWeights.keySet()) {
            Integer topicCount = stats.topicCounts.containsKey(topic) ? stats.topicCounts.get(topic) : 0;
            if (topicCount < MINIMUM_QUESTIONS_PER_TOPIC) {
                Integer needed = MINIMUM_QUESTIONS_PER_TOPIC - topicCount;
                health.recommendations.add('Add ' + needed + ' more questions for topic: ' + topic);
            }
        }
        
        // Check weight deviations
        for (String topic : stats.deviations.keySet()) {
            Decimal deviation = stats.deviations.get(topic);
            if (Math.abs(deviation) > 10.0) {
                if (deviation > 0) {
                    health.recommendations.add('Reduce questions for over-represented topic: ' + topic + 
                                            ' (deviation: +' + deviation.format() + '%)');
                } else {
                    health.recommendations.add('Add questions for under-represented topic: ' + topic + 
                                            ' (deviation: ' + deviation.format() + '%)');
                }
            }
        }
        
        // Review recommendations
        if (health.questionsNeedingReview > 0) {
            health.recommendations.add('Review ' + health.questionsNeedingReview + 
                                    ' questions that haven\'t been reviewed in ' + QUESTION_REVIEW_DAYS + ' days');
        }
        
        if (health.outdatedQuestions > 0) {
            health.recommendations.add('Update or retire ' + health.outdatedQuestions + 
                                    ' questions that are over 1 year old');
        }
        
        if (health.lowEffectivenessQuestions > 0) {
            health.recommendations.add('Review ' + health.lowEffectivenessQuestions + 
                                    ' questions with poor effectiveness ratings');
        }
    }
    
    /**
     * @description Calculate overall health rating
     * @param health The health report data
     * @return String overall health rating
     */
    private static String calculateOverallHealth(QuestionBankHealth health) {
        Integer score = 0;
        
        // Basic requirements (40 points)
        if (health.meetsMinimumCount) score += 20;
        if (health.hasProperDistribution) score += 20;
        
        // Quality indicators (60 points)
        Decimal reviewRatio = health.totalQuestions > 0 ? 
            (health.questionsNeedingReview * 100.0) / health.totalQuestions : 100;
        Decimal outdatedRatio = health.totalQuestions > 0 ? 
            (health.outdatedQuestions * 100.0) / health.totalQuestions : 100;
        Decimal lowEffectivenessRatio = health.totalQuestions > 0 ? 
            (health.lowEffectivenessQuestions * 100.0) / health.totalQuestions : 100;
        
        // Review score (20 points)
        if (reviewRatio < 10) score += 20;
        else if (reviewRatio < 25) score += 15;
        else if (reviewRatio < 50) score += 10;
        else score += 5;
        
        // Outdated score (20 points)
        if (outdatedRatio < 5) score += 20;
        else if (outdatedRatio < 15) score += 15;
        else if (outdatedRatio < 30) score += 10;
        else score += 5;
        
        // Effectiveness score (20 points)
        if (lowEffectivenessRatio < 5) score += 20;
        else if (lowEffectivenessRatio < 10) score += 15;
        else if (lowEffectivenessRatio < 20) score += 10;
        else score += 5;
        
        // Convert to rating
        if (score >= 85) return 'Excellent';
        else if (score >= 70) return 'Good';
        else if (score >= 55) return 'Fair';
        else return 'Poor';
    }
    
    /**
     * @description Import new questions from external source
     * @param questionData List of question data maps
     * @param certificationTrack Target certification track
     * @return ImportResult results of the import operation
     */
    public static ImportResult importQuestions(List<Map<String, Object>> questionData, String certificationTrack) {
        ImportResult result = new ImportResult();
        result.totalProcessed = questionData.size();
        
        List<Question__c> questionsToInsert = new List<Question__c>();
        Set<String> existingQuestionTexts = getExistingQuestionTexts(certificationTrack);
        
        for (Map<String, Object> data : questionData) {
            try {
                Question__c newQuestion = createQuestionFromData(data, certificationTrack);
                
                // Check for duplicates
                if (existingQuestionTexts.contains(newQuestion.QuestionText__c.toLowerCase())) {
                    result.duplicates++;
                    result.warnings.add('Duplicate question skipped: ' + newQuestion.QuestionText__c.abbreviate(50));
                    continue;
                }
                
                // Validate question
                List<String> validationErrors = validateQuestion(newQuestion);
                if (!validationErrors.isEmpty()) {
                    result.failed++;
                    result.errors.addAll(validationErrors);
                    continue;
                }
                
                questionsToInsert.add(newQuestion);
                existingQuestionTexts.add(newQuestion.QuestionText__c.toLowerCase());
                
            } catch (Exception e) {
                result.failed++;
                result.errors.add('Error processing question: ' + e.getMessage());
            }
        }
        
        // Insert valid questions
        if (!questionsToInsert.isEmpty()) {
            try {
                insert questionsToInsert;
                result.successfulImports = questionsToInsert.size();
            } catch (DmlException e) {
                result.failed += questionsToInsert.size();
                result.errors.add('Bulk insert failed: ' + e.getMessage());
                result.successfulImports = 0;
            }
        }
        
        return result;
    }
    
    /**
     * @description Get existing question texts to prevent duplicates
     * @param certificationTrack The certification track
     * @return Set<String> existing question texts (lowercase)
     */
    private static Set<String> getExistingQuestionTexts(String certificationTrack) {
        Set<String> existingTexts = new Set<String>();
        
        for (Question__c q : [
            SELECT QuestionText__c 
            FROM Question__c 
            WHERE CertificationTrack__c = :certificationTrack
        ]) {
            existingTexts.add(q.QuestionText__c.toLowerCase());
        }
        
        return existingTexts;
    }
    
    /**
     * @description Create Question record from data map
     * @param data Question data map
     * @param certificationTrack Target certification track
     * @return Question__c new question record
     */
    private static Question__c createQuestionFromData(Map<String, Object> data, String certificationTrack) {
        Question__c question = new Question__c();
        
        question.CertificationTrack__c = certificationTrack;
        question.QuestionText__c = (String) data.get('questionText');
        question.Topic__c = (String) data.get('topic');
        question.Difficulty__c = data.containsKey('difficulty') ? 
            Integer.valueOf(data.get('difficulty')) : 2; // Default to intermediate
        question.QuestionType__c = data.containsKey('questionType') ? 
            (String) data.get('questionType') : 'Multiple Choice';
        question.CorrectAnswer__c = (String) data.get('correctAnswer');
        question.OptionA__c = (String) data.get('optionA');
        question.OptionB__c = (String) data.get('optionB');
        question.OptionC__c = (String) data.get('optionC');
        question.OptionD__c = (String) data.get('optionD');
        question.Explanation__c = (String) data.get('explanation');
        question.Active__c = true;
        question.UsageCount__c = 0;
        
        // Auto-categorize if not provided
        if (!data.containsKey('contentTags') || String.isBlank((String) data.get('contentTags'))) {
            List<QuestionCategorization.QuestionCategory> categories = 
                QuestionCategoryHelper.autoCategorizaQuestions(new List<Question__c>{question});
            if (!categories.isEmpty()) {
                QuestionCategoryHelper.applyCategorization(new List<Question__c>{question}, categories);
            }
        } else {
            question.ContentTags__c = (String) data.get('contentTags');
        }
        
        return question;
    }
    
    /**
     * @description Validate question data quality
     * @param question Question to validate
     * @return List<String> validation errors
     */
    private static List<String> validateQuestion(Question__c question) {
        List<String> errors = new List<String>();
        
        // Required fields
        if (String.isBlank(question.QuestionText__c)) {
            errors.add('Question text is required');
        }
        if (String.isBlank(question.Topic__c)) {
            errors.add('Topic is required');
        }
        if (String.isBlank(question.CorrectAnswer__c)) {
            errors.add('Correct answer is required');
        }
        
        // Validate topic against certification track
        Set<String> validTopics = QuestionCategorization.getValidTopics(question.CertificationTrack__c);
        if (!validTopics.contains(question.Topic__c)) {
            errors.add('Invalid topic for certification track: ' + question.Topic__c);
        }
        
        // Validate difficulty range
        if (question.Difficulty__c < 1 || question.Difficulty__c > 3) {
            errors.add('Difficulty must be between 1 and 3');
        }
        
        // Validate correct answer matches available options
        if (!isValidCorrectAnswer(question)) {
            errors.add('Correct answer must match one of the provided options (A, B, C, D)');
        }
        
        // Validate question length
        if (question.QuestionText__c.length() > 1000) {
            errors.add('Question text is too long (maximum 1000 characters)');
        }
        
        return errors;
    }
    
    /**
     * @description Check if correct answer corresponds to a valid option
     * @param question Question to validate
     * @return Boolean true if valid
     */
    private static Boolean isValidCorrectAnswer(Question__c question) {
        switch on question.CorrectAnswer__c.toUpperCase() {
            when 'A' {
                return String.isNotBlank(question.OptionA__c);
            }
            when 'B' {
                return String.isNotBlank(question.OptionB__c);
            }
            when 'C' {
                return String.isNotBlank(question.OptionC__c);
            }
            when 'D' {
                return String.isNotBlank(question.OptionD__c);
            }
            when else {
                return false;
            }
        }
    }
    
    /**
     * @description Submit question update request
     * @param updateRequest The update request details
     * @return Boolean true if request was submitted successfully
     */
    public static Boolean submitQuestionUpdate(QuestionUpdateRequest updateRequest) {
        try {
            // In a real implementation, this would create a workflow item
            // For now, we'll validate and log the request
            
            if (String.isBlank(updateRequest.questionId)) {
                throw new IllegalArgumentException('Question ID is required');
            }
            
            if (String.isBlank(updateRequest.updateType)) {
                throw new IllegalArgumentException('Update type is required');
            }
            
            // Verify question exists
            List<Question__c> existingQuestions = [
                SELECT Id FROM Question__c WHERE Id = :updateRequest.questionId LIMIT 1
            ];
            
            if (existingQuestions.isEmpty()) {
                throw new IllegalArgumentException('Question not found: ' + updateRequest.questionId);
            }
            
            // Log the request (in real implementation, this would go to a request queue)
            System.debug('Question update request submitted: ' + JSON.serialize(updateRequest));
            
            return true;
            
        } catch (Exception e) {
            System.debug('Error submitting question update request: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Get questions requiring immediate attention
     * @param certificationTrack The certification track
     * @return List<Question__c> questions needing attention
     */
    public static List<Question__c> getQuestionsRequiringAttention(String certificationTrack) {
        Date reviewCutoff = Date.today().addDays(-QUESTION_REVIEW_DAYS);
        
        return [
            SELECT Id, QuestionText__c, Topic__c, Difficulty__c, UsageCount__c, 
                   LastReviewedDate__c, CreatedDate, LastModifiedDate
            FROM Question__c 
            WHERE CertificationTrack__c = :certificationTrack
              AND Active__c = true
              AND (
                  LastReviewedDate__c = null 
                  OR LastReviewedDate__c < :reviewCutoff
                  OR UsageCount__c = 0
                  OR (UsageCount__c > 50 AND Id IN (
                      SELECT Question__c 
                      FROM UserAnswer__c 
                      GROUP BY Question__c
                      HAVING AVG(CASE WHEN IsCorrect__c = true THEN 100.0 ELSE 0.0 END) < 30
                         OR AVG(CASE WHEN IsCorrect__c = true THEN 100.0 ELSE 0.0 END) > 90
                  ))
              )
            ORDER BY LastReviewedDate__c ASC, UsageCount__c DESC
            LIMIT 100
        ];
    }
}