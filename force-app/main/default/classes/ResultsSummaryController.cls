/**
 * @description Results Summary FlexCard Controller for OmniStudio Training Platform
 * @author Claude Code Assistant
 * @since User Story #20 - Results Summary FlexCards
 * @version 1.0
 * 
 * This class provides backend data and logic for exam results FlexCards,
 * including pass/fail state management, topic breakdown analysis, and
 * personalized next-step recommendations.
 */
public with sharing class ResultsSummaryController {
    
    /**
     * @description Complete exam results data structure
     */
    public class ExamResultsData {
        @AuraEnabled public String userId {get; set;}
        @AuraEnabled public String userName {get; set;}
        @AuraEnabled public String examSessionId {get; set;}
        @AuraEnabled public String certificationTrack {get; set;}
        @AuraEnabled public ExamSummary examSummary {get; set;}
        @AuraEnabled public List<TopicScore> topicBreakdown {get; set;}
        @AuraEnabled public List<WeakArea> weakAreas {get; set;}
        @AuraEnabled public List<NextStepAction> nextSteps {get; set;}
        @AuraEnabled public VisualStyling styling {get; set;}
        @AuraEnabled public CertificationInfo certificationInfo {get; set;}
        @AuraEnabled public DateTime resultsGeneratedAt {get; set;}
        @AuraEnabled public Boolean hasPassedPreviously {get; set;}
        @AuraEnabled public Integer attemptNumber {get; set;}
        
        public ExamResultsData() {
            this.topicBreakdown = new List<TopicScore>();
            this.weakAreas = new List<WeakArea>();
            this.nextSteps = new List<NextStepAction>();
        }
    }
    
    /**
     * @description Exam summary with overall performance
     */
    public class ExamSummary {
        @AuraEnabled public Decimal finalScore {get; set;}
        @AuraEnabled public String scoreDisplay {get; set;}
        @AuraEnabled public Boolean passed {get; set;}
        @AuraEnabled public String resultStatus {get; set;}
        @AuraEnabled public String resultMessage {get; set;}
        @AuraEnabled public Integer totalQuestions {get; set;}
        @AuraEnabled public Integer correctAnswers {get; set;}
        @AuraEnabled public Integer incorrectAnswers {get; set;}
        @AuraEnabled public Decimal passingScore {get; set;}
        @AuraEnabled public String passingScoreDisplay {get; set;}
        @AuraEnabled public Integer examDurationMinutes {get; set;}
        @AuraEnabled public Integer actualDurationMinutes {get; set;}
        @AuraEnabled public DateTime examCompletedAt {get; set;}
        @AuraEnabled public String performanceLevel {get; set;} // Excellent, Good, Fair, Needs Improvement
    }
    
    /**
     * @description Topic-specific score breakdown
     */
    public class TopicScore {
        @AuraEnabled public String topicName {get; set;}
        @AuraEnabled public String topicDisplayName {get; set;}
        @AuraEnabled public Decimal scorePercentage {get; set;}
        @AuraEnabled public String scoreDisplay {get; set;}
        @AuraEnabled public Integer questionsAnswered {get; set;}
        @AuraEnabled public Integer correctAnswers {get; set;}
        @AuraEnabled public String performanceLevel {get; set;} // Mastered, Proficient, Developing, Needs Work
        @AuraEnabled public Decimal weightPercentage {get; set;} // Topic weight in exam
        @AuraEnabled public String iconName {get; set;}
        @AuraEnabled public String colorClass {get; set;}
        @AuraEnabled public Boolean isWeakArea {get; set;}
        @AuraEnabled public String improvementSuggestion {get; set;}
    }
    
    /**
     * @description Weak areas requiring attention
     */
    public class WeakArea {
        @AuraEnabled public String topicName {get; set;}
        @AuraEnabled public String topicDisplayName {get; set;}
        @AuraEnabled public Decimal currentScore {get; set;}
        @AuraEnabled public String priorityLevel {get; set;} // High, Medium, Low
        @AuraEnabled public String recommendation {get; set;}
        @AuraEnabled public Integer additionalQuestionsNeeded {get; set;}
        @AuraEnabled public Integer estimatedStudyHours {get; set;}
        @AuraEnabled public String focusAreaUrl {get; set;}
        @AuraEnabled public List<String> keyConceptsToReview {get; set;}
        @AuraEnabled public String iconName {get; set;}
        
        public WeakArea() {
            this.keyConceptsToReview = new List<String>();
        }
    }
    
    /**
     * @description Next step actions based on results
     */
    public class NextStepAction {
        @AuraEnabled public String actionId {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public String actionUrl {get; set;}
        @AuraEnabled public String buttonClass {get; set;}
        @AuraEnabled public String iconName {get; set;}
        @AuraEnabled public Boolean isPrimary {get; set;}
        @AuraEnabled public String priority {get; set;} // Immediate, Soon, Later
        @AuraEnabled public String estimatedTimeCommitment {get; set;}
    }
    
    /**
     * @description Visual styling for pass/fail states
     */
    public class VisualStyling {
        @AuraEnabled public String primaryColor {get; set;}
        @AuraEnabled public String secondaryColor {get; set;}
        @AuraEnabled public String backgroundColor {get; set;}
        @AuraEnabled public String borderColor {get; set;}
        @AuraEnabled public String gradientClass {get; set;}
        @AuraEnabled public String cardClass {get; set;}
        @AuraEnabled public String resultIconName {get; set;}
        @AuraEnabled public String resultIconClass {get; set;}
        @AuraEnabled public String messageClass {get; set;}
        @AuraEnabled public String badgeClass {get; set;}
    }
    
    /**
     * @description Certification information and next certifications
     */
    public class CertificationInfo {
        @AuraEnabled public String certificateName {get; set;}
        @AuraEnabled public String certificateId {get; set;}
        @AuraEnabled public String certificateUrl {get; set;}
        @AuraEnabled public Date issueDate {get; set;}
        @AuraEnabled public Date expirationDate {get; set;}
        @AuraEnabled public Integer validityYears {get; set;}
        @AuraEnabled public List<String> nextRecommendedCertifications {get; set;}
        @AuraEnabled public String digitalBadgeUrl {get; set;}
        @AuraEnabled public String trailheadBadgeUrl {get; set;}
        
        public CertificationInfo() {
            this.nextRecommendedCertifications = new List<String>();
        }
    }
    
    /**
     * @description Get comprehensive exam results data
     * @param examSessionId Unique exam session identifier
     * @return ExamResultsData complete results information
     */
    @AuraEnabled(cacheable=false)
    public static ExamResultsData getExamResults(String examSessionId) {
        try {
            if (String.isBlank(examSessionId)) {
                throw new AuraHandledException('Exam session ID is required');
            }
            
            ExamResultsData resultsData = new ExamResultsData();
            resultsData.userId = UserInfo.getUserId();
            resultsData.userName = UserInfo.getName();
            resultsData.examSessionId = examSessionId;
            resultsData.resultsGeneratedAt = DateTime.now();
            
            // Get exam session details
            ExamSession__c examSession = getExamSession(examSessionId);
            resultsData.certificationTrack = examSession.CertificationTrack__c;
            resultsData.attemptNumber = getAttemptNumber(resultsData.userId, resultsData.certificationTrack);
            resultsData.hasPassedPreviously = checkPreviousPass(resultsData.userId, resultsData.certificationTrack);
            
            // Calculate exam summary
            resultsData.examSummary = calculateExamSummary(examSession);
            
            // Calculate topic breakdown
            resultsData.topicBreakdown = calculateTopicBreakdown(examSessionId, resultsData.certificationTrack);
            
            // Identify weak areas (for failed exams or areas needing improvement)
            resultsData.weakAreas = identifyWeakAreas(resultsData.topicBreakdown, resultsData.examSummary.passed);
            
            // Generate next step actions
            resultsData.nextSteps = generateNextSteps(resultsData);
            
            // Set visual styling based on pass/fail
            resultsData.styling = determineVisualStyling(resultsData.examSummary.passed, resultsData.examSummary.finalScore);
            
            // Generate certification info (if passed)
            if (resultsData.examSummary.passed) {
                resultsData.certificationInfo = generateCertificationInfo(resultsData.certificationTrack, examSession.CompletedDate__c);
            }
            
            return resultsData;
            
        } catch (Exception e) {
            System.debug('Error in getExamResults: ' + e.getMessage());
            throw new AuraHandledException('Unable to load exam results: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get latest exam results for current user
     * @return ExamResultsData most recent exam results
     */
    @AuraEnabled(cacheable=false)
    public static ExamResultsData getLatestExamResults() {
        try {
            String userId = UserInfo.getUserId();
            
            // Find most recent completed exam session
            List<ExamSession__c> recentSessions = [
                SELECT Id, CertificationTrack__c, FinalScore__c, CompletedDate__c
                FROM ExamSession__c 
                WHERE User__c = :userId 
                  AND Status__c = 'Completed'
                ORDER BY CompletedDate__c DESC 
                LIMIT 1
            ];
            
            if (recentSessions.isEmpty()) {
                throw new AuraHandledException('No completed exam sessions found');
            }
            
            return getExamResults(recentSessions[0].Id);
            
        } catch (Exception e) {
            System.debug('Error in getLatestExamResults: ' + e.getMessage());
            throw new AuraHandledException('Unable to load latest exam results: ' + e.getMessage());
        }
    }
    
    /**
     * @description Record user action on results (analytics)
     * @param actionId Action taken by user
     * @param examSessionId Exam session ID
     * @return Boolean success status
     */
    @AuraEnabled
    public static Boolean recordResultsAction(String actionId, String examSessionId) {
        try {
            // Record user interaction for analytics
            System.debug('User action recorded: ' + actionId + ' for exam session: ' + examSessionId);
            
            // In a real implementation, this would create analytics records
            // ExamResultsAnalytics__c analytics = new ExamResultsAnalytics__c(...);
            
            return true;
            
        } catch (Exception e) {
            System.debug('Error recording results action: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Get exam session details
     * @param examSessionId Session ID
     * @return ExamSession__c exam session record
     */
    private static ExamSession__c getExamSession(String examSessionId) {
        List<ExamSession__c> sessions = [
            SELECT Id, User__c, CertificationTrack__c, FinalScore__c, Status__c,
                   TotalQuestions__c, CorrectAnswers__c, StartTime__c, CompletedDate__c,
                   DurationMinutes__c
            FROM ExamSession__c 
            WHERE Id = :examSessionId 
              AND Status__c = 'Completed'
            LIMIT 1
        ];
        
        if (sessions.isEmpty()) {
            throw new AuraHandledException('Exam session not found or not completed');
        }
        
        return sessions[0];
    }
    
    /**
     * @description Calculate overall exam summary
     * @param examSession Exam session record
     * @return ExamSummary summary information
     */
    private static ExamSummary calculateExamSummary(ExamSession__c examSession) {
        ExamSummary summary = new ExamSummary();
        
        summary.finalScore = examSession.FinalScore__c != null ? examSession.FinalScore__c : 0;
        summary.scoreDisplay = summary.finalScore.format() + '%';
        summary.passingScore = 63.0; // Standard OmniStudio passing score
        summary.passingScoreDisplay = '63%';
        summary.passed = summary.finalScore >= summary.passingScore;
        
        // Set result status and message
        if (summary.passed) {
            summary.resultStatus = '🎉 PASSED!';
            summary.resultMessage = 'Congratulations! You have successfully passed the certification exam.';
        } else {
            summary.resultStatus = 'Keep Studying!';
            summary.resultMessage = 'You\'re making progress! Focus on your weak areas and try again.';
        }
        
        // Set performance level
        if (summary.finalScore >= 85) {
            summary.performanceLevel = 'Excellent';
        } else if (summary.finalScore >= 75) {
            summary.performanceLevel = 'Good';
        } else if (summary.finalScore >= 65) {
            summary.performanceLevel = 'Fair';
        } else {
            summary.performanceLevel = 'Needs Improvement';
        }
        
        summary.totalQuestions = Integer.valueOf(examSession.TotalQuestions__c != null ? examSession.TotalQuestions__c : 60);
        summary.correctAnswers = Integer.valueOf(examSession.CorrectAnswers__c != null ? examSession.CorrectAnswers__c : 0);
        summary.incorrectAnswers = summary.totalQuestions - summary.correctAnswers;
        summary.examDurationMinutes = 105; // Standard exam duration
        summary.actualDurationMinutes = Integer.valueOf(examSession.DurationMinutes__c != null ? examSession.DurationMinutes__c : 0);
        summary.examCompletedAt = examSession.CompletedDate__c;
        
        return summary;
    }
    
    /**
     * @description Calculate topic breakdown scores
     * @param examSessionId Exam session ID
     * @param certificationTrack Certification track
     * @return List<TopicScore> topic scores
     */
    private static List<TopicScore> calculateTopicBreakdown(String examSessionId, String certificationTrack) {
        List<TopicScore> topicScores = new List<TopicScore>();
        
        // Get topic performance from exam answers
        List<AggregateResult> topicResults = [
            SELECT Question__r.Topic__c topic, 
                   COUNT(Id) totalQuestions,
                   SUM(CASE WHEN IsCorrect__c = true THEN 1 ELSE 0 END) correctAnswers
            FROM ExamAnswer__c 
            WHERE ExamSession__c = :examSessionId
            GROUP BY Question__r.Topic__c
            ORDER BY Question__r.Topic__c
        ];
        
        // Get topic weights
        Map<String, Decimal> topicWeights = getTopicWeights(certificationTrack);
        
        for (AggregateResult result : topicResults) {
            String topicName = (String) result.get('topic');
            Integer totalQuestions = (Integer) result.get('totalQuestions');
            Integer correctAnswers = (Integer) result.get('correctAnswers');
            
            TopicScore topicScore = new TopicScore();
            topicScore.topicName = topicName;
            topicScore.topicDisplayName = getTopicDisplayName(topicName);
            topicScore.questionsAnswered = totalQuestions;
            topicScore.correctAnswers = correctAnswers;
            topicScore.scorePercentage = totalQuestions > 0 ? (correctAnswers * 100.0) / totalQuestions : 0;
            topicScore.scoreDisplay = topicScore.scorePercentage.format() + '%';
            topicScore.weightPercentage = topicWeights.containsKey(topicName) ? topicWeights.get(topicName) : 0;
            
            // Determine performance level
            if (topicScore.scorePercentage >= 85) {
                topicScore.performanceLevel = 'Mastered';
                topicScore.colorClass = 'slds-progress-bar__value_success';
                topicScore.isWeakArea = false;
            } else if (topicScore.scorePercentage >= 70) {
                topicScore.performanceLevel = 'Proficient';
                topicScore.colorClass = 'slds-progress-bar__value_success';
                topicScore.isWeakArea = false;
            } else if (topicScore.scorePercentage >= 55) {
                topicScore.performanceLevel = 'Developing';
                topicScore.colorClass = 'slds-progress-bar__value_warning';
                topicScore.isWeakArea = true;
            } else {
                topicScore.performanceLevel = 'Needs Work';
                topicScore.colorClass = 'slds-progress-bar__value_error';
                topicScore.isWeakArea = true;
            }
            
            topicScore.iconName = getTopicIcon(topicName);
            topicScore.improvementSuggestion = generateImprovementSuggestion(topicName, topicScore.scorePercentage);
            
            topicScores.add(topicScore);
        }
        
        return topicScores;
    }
    
    /**
     * @description Identify weak areas requiring attention
     * @param topicScores Topic performance data
     * @param examPassed Whether exam was passed
     * @return List<WeakArea> weak areas
     */
    private static List<WeakArea> identifyWeakAreas(List<TopicScore> topicScores, Boolean examPassed) {
        List<WeakArea> weakAreas = new List<WeakArea>();
        
        for (TopicScore topicScore : topicScores) {
            if (topicScore.isWeakArea || (!examPassed && topicScore.scorePercentage < 75)) {
                WeakArea weakArea = new WeakArea();
                weakArea.topicName = topicScore.topicName;
                weakArea.topicDisplayName = topicScore.topicDisplayName;
                weakArea.currentScore = topicScore.scorePercentage;
                
                // Determine priority level
                if (topicScore.scorePercentage < 50) {
                    weakArea.priorityLevel = 'High';
                } else if (topicScore.scorePercentage < 65) {
                    weakArea.priorityLevel = 'Medium';
                } else {
                    weakArea.priorityLevel = 'Low';
                }
                
                weakArea.recommendation = generateWeakAreaRecommendation(topicScore.topicName, topicScore.scorePercentage);
                weakArea.additionalQuestionsNeeded = calculateAdditionalQuestions(topicScore.scorePercentage);
                weakArea.estimatedStudyHours = calculateStudyHours(topicScore.scorePercentage, topicScore.weightPercentage);
                weakArea.focusAreaUrl = '/study/' + topicScore.topicName.toLowerCase();
                weakArea.keyConceptsToReview = getKeyConceptsForTopic(topicScore.topicName);
                weakArea.iconName = 'utility:warning';
                
                weakAreas.add(weakArea);
            }
        }
        
        // Sort by priority and score (lowest scores first)
        weakAreas.sort(new WeakAreaComparator());
        
        return weakAreas;
    }
    
    /**
     * @description Generate next step actions based on results
     * @param resultsData Complete results data
     * @return List<NextStepAction> recommended actions
     */
    private static List<NextStepAction> generateNextSteps(ExamResultsData resultsData) {
        List<NextStepAction> nextSteps = new List<NextStepAction>();
        
        if (resultsData.examSummary.passed) {
            // Actions for passed exam
            NextStepAction viewCertificate = new NextStepAction();
            viewCertificate.actionId = 'view-certificate';
            viewCertificate.title = 'View Certificate';
            viewCertificate.description = 'Download your official certification';
            viewCertificate.actionUrl = '/certificate/' + resultsData.certificationInfo.certificateId;
            viewCertificate.buttonClass = 'slds-button_brand';
            viewCertificate.iconName = 'utility:badge';
            viewCertificate.isPrimary = true;
            viewCertificate.priority = 'Immediate';
            viewCertificate.estimatedTimeCommitment = '5 minutes';
            nextSteps.add(viewCertificate);
            
            NextStepAction whatsNext = new NextStepAction();
            whatsNext.actionId = 'whats-next';
            whatsNext.title = 'What\'s Next?';
            whatsNext.description = 'Explore advanced certifications and career paths';
            whatsNext.actionUrl = '/career-path/' + resultsData.certificationTrack.toLowerCase();
            whatsNext.buttonClass = 'slds-button_outline-brand';
            whatsNext.iconName = 'utility:forward';
            whatsNext.isPrimary = false;
            whatsNext.priority = 'Soon';
            whatsNext.estimatedTimeCommitment = '15 minutes';
            nextSteps.add(whatsNext);
            
            NextStepAction shareSuccess = new NextStepAction();
            shareSuccess.actionId = 'share-success';
            shareSuccess.title = 'Share Your Success';
            shareSuccess.description = 'Share your achievement on LinkedIn';
            shareSuccess.actionUrl = '/share/linkedin';
            shareSuccess.buttonClass = 'slds-button_neutral';
            shareSuccess.iconName = 'utility:share';
            shareSuccess.isPrimary = false;
            shareSuccess.priority = 'Later';
            shareSuccess.estimatedTimeCommitment = '2 minutes';
            nextSteps.add(shareSuccess);
            
        } else {
            // Actions for failed exam
            NextStepAction createStudyPlan = new NextStepAction();
            createStudyPlan.actionId = 'create-study-plan';
            createStudyPlan.title = 'Create Study Plan';
            createStudyPlan.description = 'Generate a personalized study plan based on your results';
            createStudyPlan.actionUrl = '/study-plan/create';
            createStudyPlan.buttonClass = 'slds-button_brand';
            createStudyPlan.iconName = 'utility:planning';
            createStudyPlan.isPrimary = true;
            createStudyPlan.priority = 'Immediate';
            createStudyPlan.estimatedTimeCommitment = '10 minutes';
            nextSteps.add(createStudyPlan);
            
            NextStepAction practiceMore = new NextStepAction();
            practiceMore.actionId = 'practice-more';
            practiceMore.title = 'More Practice Questions';
            practiceMore.description = 'Focus on your weak areas with targeted practice';
            practiceMore.actionUrl = '/practice/weak-areas';
            practiceMore.buttonClass = 'slds-button_outline-brand';
            practiceMore.iconName = 'utility:question_mark';
            practiceMore.isPrimary = false;
            practiceMore.priority = 'Immediate';
            practiceMore.estimatedTimeCommitment = '30-60 minutes';
            nextSteps.add(practiceMore);
            
            if (resultsData.attemptNumber >= 2) {
                NextStepAction getHelp = new NextStepAction();
                getHelp.actionId = 'get-help';
                getHelp.title = 'Get Study Help';
                getHelp.description = 'Connect with mentors and study groups';
                getHelp.actionUrl = '/community/help';
                getHelp.buttonClass = 'slds-button_neutral';
                getHelp.iconName = 'utility:groups';
                getHelp.isPrimary = false;
                getHelp.priority = 'Soon';
                getHelp.estimatedTimeCommitment = '15 minutes';
                nextSteps.add(getHelp);
            }
        }
        
        return nextSteps;
    }
    
    /**
     * @description Determine visual styling based on pass/fail
     * @param passed Whether exam was passed
     * @param finalScore Final exam score
     * @return VisualStyling styling configuration
     */
    private static VisualStyling determineVisualStyling(Boolean passed, Decimal finalScore) {
        VisualStyling styling = new VisualStyling();
        
        if (passed) {
            // Success styling - blue gradient
            styling.primaryColor = '#4facfe';
            styling.secondaryColor = '#00f2fe';
            styling.backgroundColor = 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)';
            styling.borderColor = '#28a745';
            styling.gradientClass = 'results-pass-gradient';
            styling.cardClass = 'results-pass-card';
            styling.resultIconName = 'utility:success';
            styling.resultIconClass = 'slds-icon-text-success';
            styling.messageClass = 'results-pass-message';
            styling.badgeClass = 'slds-badge_success';
            
            // Enhanced styling for exceptional performance
            if (finalScore >= 90) {
                styling.cardClass = 'results-pass-card results-exceptional';
            }
            
        } else {
            // Motivational styling - pink gradient
            styling.primaryColor = '#ff9a9e';
            styling.secondaryColor = '#fecfef';
            styling.backgroundColor = 'linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)';
            styling.borderColor = '#dc3545';
            styling.gradientClass = 'results-retry-gradient';
            styling.cardClass = 'results-retry-card';
            styling.resultIconName = 'utility:refresh';
            styling.resultIconClass = 'slds-icon-text-warning';
            styling.messageClass = 'results-retry-message';
            styling.badgeClass = 'slds-badge_warning';
        }
        
        return styling;
    }
    
    /**
     * @description Generate certification information for passed exams
     * @param certificationTrack Certification track
     * @param completedDate Exam completion date
     * @return CertificationInfo certification details
     */
    private static CertificationInfo generateCertificationInfo(String certificationTrack, DateTime completedDate) {
        CertificationInfo certInfo = new CertificationInfo();
        
        certInfo.certificateName = 'Salesforce OmniStudio ' + certificationTrack;
        certInfo.certificateId = 'OSC-' + certificationTrack.toUpperCase() + '-' + completedDate.format('yyyyMMdd');
        certInfo.certificateUrl = '/certificate/' + certInfo.certificateId;
        certInfo.issueDate = completedDate.date();
        certInfo.validityYears = 3;
        certInfo.expirationDate = certInfo.issueDate.addYears(certInfo.validityYears);
        certInfo.digitalBadgeUrl = '/badges/' + certificationTrack.toLowerCase();
        certInfo.trailheadBadgeUrl = 'https://trailhead.salesforce.com/credentials/omnistudio';
        
        // Set next recommended certifications
        if (certificationTrack == 'Consultant') {
            certInfo.nextRecommendedCertifications.addAll(new List<String>{
                'Salesforce Certified Technical Architect',
                'Salesforce Certified Application Architect',
                'Industry Cloud Consultant Certifications'
            });
        } else if (certificationTrack == 'Developer') {
            certInfo.nextRecommendedCertifications.addAll(new List<String>{
                'Salesforce Certified Technical Architect',
                'Integration Architecture Designer',
                'Platform Developer II'
            });
        }
        
        return certInfo;
    }
    
    // Helper methods
    
    private static Integer getAttemptNumber(String userId, String certificationTrack) {
        return [
            SELECT COUNT() 
            FROM ExamSession__c 
            WHERE User__c = :userId 
              AND CertificationTrack__c = :certificationTrack 
              AND Status__c = 'Completed'
        ];
    }
    
    private static Boolean checkPreviousPass(String userId, String certificationTrack) {
        return [
            SELECT COUNT() 
            FROM ExamSession__c 
            WHERE User__c = :userId 
              AND CertificationTrack__c = :certificationTrack 
              AND Status__c = 'Completed'
              AND FinalScore__c >= 63.0
        ] > 0;
    }
    
    private static Map<String, Decimal> getTopicWeights(String certificationTrack) {
        if (certificationTrack == 'Consultant') {
            return new Map<String, Decimal>{
                'FlexCards' => 23.0,
                'OmniScripts' => 27.0,
                'DataTools' => 23.0,
                'Solutioning' => 27.0
            };
        } else {
            return new Map<String, Decimal>{
                'FlexCards' => 20.0,
                'OmniScripts' => 20.0,
                'IntegrationProcedures' => 20.0,
                'DataRaptors' => 20.0,
                'Expressions' => 20.0
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
    
    private static String generateImprovementSuggestion(String topic, Decimal score) {
        if (score < 50) {
            return 'Focus on fundamental concepts and complete all recommended study materials';
        } else if (score < 70) {
            return 'Review intermediate concepts and practice with scenario-based questions';
        } else if (score < 85) {
            return 'Fine-tune understanding with advanced topics and edge cases';
        } else {
            return 'Excellent performance! Consider helping others learn this topic';
        }
    }
    
    private static String generateWeakAreaRecommendation(String topic, Decimal score) {
        String baseRecommendation = 'Focus on ' + getTopicDisplayName(topic);
        
        if (score < 40) {
            return baseRecommendation + ' - Start with fundamentals and basic concepts';
        } else if (score < 55) {
            return baseRecommendation + ' - Review core concepts and practice exercises';
        } else {
            return baseRecommendation + ' - Focus on advanced scenarios and edge cases';
        }
    }
    
    private static Integer calculateAdditionalQuestions(Decimal score) {
        if (score < 40) {
            return 50;
        } else if (score < 55) {
            return 30;
        } else {
            return 20;
        }
    }
    
    private static Integer calculateStudyHours(Decimal score, Decimal weight) {
        Decimal baseHours = (70 - score) * 0.2; // Lower scores need more hours
        Decimal weightMultiplier = weight / 20.0; // Higher weight topics get more focus
        return Integer.valueOf(Math.max(baseHours * weightMultiplier, 2));
    }
    
    private static List<String> getKeyConceptsForTopic(String topic) {
        Map<String, List<String>> topicConcepts = new Map<String, List<String>>{
            'FlexCards' => new List<String>{'Data Sources', 'States', 'Actions', 'Styling'},
            'OmniScripts' => new List<String>{'Elements', 'Flow Logic', 'Data JSON', 'Conditional Navigation'},
            'DataTools' => new List<String>{'Reports', 'Dashboards', 'Data Integration', 'Analytics'},
            'DataRaptors' => new List<String>{'Extract', 'Transform', 'Load', 'JSON Processing'},
            'IntegrationProcedures' => new List<String>{'Remote Actions', 'REST APIs', 'Data Processing'},
            'Expressions' => new List<String>{'Decision Matrices', 'Expression Sets', 'Business Rules'},
            'Solutioning' => new List<String>{'Requirements Analysis', 'Solution Design', 'Best Practices'}
        };
        
        return topicConcepts.containsKey(topic) ? topicConcepts.get(topic) : new List<String>{'Core Concepts'};
    }
    
    /**
     * @description Comparator for sorting weak areas by priority and score
     */
    public class WeakAreaComparator implements Comparable {
        public WeakArea weakArea;
        
        public WeakAreaComparator(WeakArea wa) {
            this.weakArea = wa;
        }
        
        public Integer compareTo(Object compareTo) {
            WeakAreaComparator other = (WeakAreaComparator) compareTo;
            
            // First sort by priority (High > Medium > Low)
            Map<String, Integer> priorityOrder = new Map<String, Integer>{
                'High' => 3, 'Medium' => 2, 'Low' => 1
            };
            
            Integer thisPriority = priorityOrder.get(this.weakArea.priorityLevel);
            Integer otherPriority = priorityOrder.get(other.weakArea.priorityLevel);
            
            if (thisPriority != otherPriority) {
                return otherPriority - thisPriority; // Descending order
            }
            
            // Then sort by score (lower scores first)
            if (this.weakArea.currentScore < other.weakArea.currentScore) {
                return -1;
            } else if (this.weakArea.currentScore > other.weakArea.currentScore) {
                return 1;
            } else {
                return 0;
            }
        }
    }
}