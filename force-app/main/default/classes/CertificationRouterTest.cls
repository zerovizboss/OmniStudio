/**
 * @description Test class for CertificationRouter - targeting 90%+ code coverage
 * @author Claude AI OmniStudio Training
 * @date 2025-08-12
 */
@IsTest
private class CertificationRouterTest {
    
    @IsTest
    static void testGetTopicsForTrackConsultant() {
        Test.startTest();
        List<String> consultantTopics = CertificationRouter.getTopicsForTrack('Consultant');
        Test.stopTest();
        
        System.assertNotEquals(null, consultantTopics, 'Consultant topics should not be null');
        System.assert(consultantTopics.size() > 0, 'Should return topics for Consultant track');
        System.assert(consultantTopics.contains('FlexCards'), 'Should include FlexCards topic');
        System.assert(consultantTopics.contains('OmniScripts'), 'Should include OmniScripts topic');
        System.assert(consultantTopics.contains('DataTools'), 'Should include DataTools topic');
        System.assert(consultantTopics.contains('BestFitSolutioning'), 'Should include BestFitSolutioning topic');
    }
    
    @IsTest
    static void testGetTopicsForTrackDeveloper() {
        Test.startTest();
        List<String> developerTopics = CertificationRouter.getTopicsForTrack('Developer');
        Test.stopTest();
        
        System.assertNotEquals(null, developerTopics, 'Developer topics should not be null');
        System.assert(developerTopics.size() > 0, 'Should return topics for Developer track');
        System.assert(developerTopics.contains('FlexCards'), 'Should include FlexCards topic');
        System.assert(developerTopics.contains('IntegrationProcedures'), 'Should include IntegrationProcedures topic');
        System.assert(developerTopics.contains('DataRaptors'), 'Should include DataRaptors topic');
        System.assert(developerTopics.contains('ExpressionSetsDecisionMatrices'), 'Should include ExpressionSetsDecisionMatrices topic');
    }
    
    @IsTest
    static void testGetTopicsForTrackInvalid() {
        Test.startTest();
        List<String> invalidTopics = CertificationRouter.getTopicsForTrack('InvalidTrack');
        Test.stopTest();
        
        System.assertNotEquals(null, invalidTopics, 'Should return empty list, not null');
        System.assertEquals(0, invalidTopics.size(), 'Should return empty list for invalid track');
    }
    
    @IsTest
    static void testGetTopicWeightConsultant() {
        Test.startTest();
        Decimal flexCardWeight = CertificationRouter.getTopicWeight('Consultant', 'FlexCards');
        Decimal omniScriptWeight = CertificationRouter.getTopicWeight('Consultant', 'OmniScripts');
        Test.stopTest();
        
        System.assertEquals(0.23, flexCardWeight, 'FlexCards should have 23% weight for Consultant');
        System.assertEquals(0.27, omniScriptWeight, 'OmniScripts should have 27% weight for Consultant');
    }
    
    @IsTest
    static void testGetTopicWeightDeveloper() {
        Test.startTest();
        Decimal flexCardWeight = CertificationRouter.getTopicWeight('Developer', 'FlexCards');
        Decimal dataRaptorWeight = CertificationRouter.getTopicWeight('Developer', 'DataRaptors');
        Test.stopTest();
        
        System.assertEquals(0.25, flexCardWeight, 'FlexCards should have 25% weight for Developer');
        System.assertEquals(0.15, dataRaptorWeight, 'DataRaptors should have 15% weight for Developer');
    }
    
    @IsTest
    static void testGetTopicWeightDefault() {
        Test.startTest();
        Decimal defaultWeight = CertificationRouter.getTopicWeight('InvalidTrack', 'InvalidTopic');
        Test.stopTest();
        
        System.assertEquals(0.20, defaultWeight, 'Should return 20% default weight for invalid track/topic');
    }
    
    @IsTest
    static void testIsValidTopicForTrack() {
        Test.startTest();
        Boolean consultantValid = CertificationRouter.isValidTopicForTrack('Consultant', 'FlexCards');
        Boolean consultantInvalid = CertificationRouter.isValidTopicForTrack('Consultant', 'DataRaptors');
        Boolean developerValid = CertificationRouter.isValidTopicForTrack('Developer', 'IntegrationProcedures');
        Boolean developerInvalid = CertificationRouter.isValidTopicForTrack('Developer', 'BestFitSolutioning');
        Test.stopTest();
        
        System.assertEquals(true, consultantValid, 'FlexCards should be valid for Consultant');
        System.assertEquals(false, consultantInvalid, 'DataRaptors should not be valid for Consultant');
        System.assertEquals(true, developerValid, 'IntegrationProcedures should be valid for Developer');
        System.assertEquals(false, developerInvalid, 'BestFitSolutioning should not be valid for Developer');
    }
    
    @IsTest
    static void testGetWeightedTopicDistributionConsultant() {
        Test.startTest();
        Map<String, Integer> distribution = CertificationRouter.getWeightedTopicDistribution('Consultant', 100);
        Test.stopTest();
        
        System.assertNotEquals(null, distribution, 'Distribution should not be null');
        System.assert(distribution.size() > 0, 'Should return topic distribution');
        
        // Verify total adds up to 100
        Integer total = 0;
        for (Integer count : distribution.values()) {
            total += count;
        }
        System.assertEquals(100, total, 'Total questions should equal requested amount');
        
        // Verify topics are included
        System.assert(distribution.containsKey('FlexCards'), 'Should include FlexCards');
        System.assert(distribution.containsKey('OmniScripts'), 'Should include OmniScripts');
    }
    
    @IsTest
    static void testGetWeightedTopicDistributionDeveloper() {
        Test.startTest();
        Map<String, Integer> distribution = CertificationRouter.getWeightedTopicDistribution('Developer', 50);
        Test.stopTest();
        
        System.assertNotEquals(null, distribution, 'Distribution should not be null');
        
        // Verify total adds up to 50
        Integer total = 0;
        for (Integer count : distribution.values()) {
            total += count;
        }
        System.assertEquals(50, total, 'Total questions should equal requested amount');
        
        // Verify developer topics are included
        System.assert(distribution.containsKey('DataRaptors'), 'Should include DataRaptors');
        System.assert(distribution.containsKey('ExpressionSetsDecisionMatrices'), 'Should include ExpressionSetsDecisionMatrices');
    }
    
    @IsTest
    static void testGetWeightedTopicDistributionSmallNumber() {
        Test.startTest();
        Map<String, Integer> distribution = CertificationRouter.getWeightedTopicDistribution('Consultant', 5);
        Test.stopTest();
        
        // Verify total adds up to 5 (tests rounding logic)
        Integer total = 0;
        for (Integer count : distribution.values()) {
            total += count;
        }
        System.assertEquals(5, total, 'Total questions should equal requested amount even with small numbers');
    }
    
    @IsTest
    static void testGetPrimaryTopicConsultant() {
        Test.startTest();
        String primaryTopic = CertificationRouter.getPrimaryTopic('Consultant');
        Test.stopTest();
        
        System.assertNotEquals(null, primaryTopic, 'Primary topic should not be null');
        System.assert(primaryTopic == 'OmniScripts' || primaryTopic == 'BestFitSolutioning', 
                     'Primary topic should be highest weighted (OmniScripts or BestFitSolutioning at 27%)');
    }
    
    @IsTest
    static void testGetPrimaryTopicDeveloper() {
        Test.startTest();
        String primaryTopic = CertificationRouter.getPrimaryTopic('Developer');
        Test.stopTest();
        
        System.assertNotEquals(null, primaryTopic, 'Primary topic should not be null');
        System.assert(primaryTopic == 'FlexCards' || primaryTopic == 'OmniScripts', 
                     'Primary topic should be highest weighted (FlexCards or OmniScripts at 25%)');
    }
    
    @IsTest
    static void testGetCertificationCriteriaConsultant() {
        Test.startTest();
        CertificationRouter.CertificationCriteria criteria = CertificationRouter.getCertificationCriteria('Consultant');
        Test.stopTest();
        
        System.assertNotEquals(null, criteria, 'Criteria should not be null');
        System.assertEquals(105, criteria.examDuration, 'Consultant exam should be 105 minutes');
        System.assertEquals(65, criteria.passingScore, 'Consultant passing score should be 65%');
        System.assertEquals(60, criteria.questionCount, 'Consultant exam should have 60 questions');
        System.assertEquals('Business Analysis', criteria.skillLevel, 'Consultant skill level should be Business Analysis');
        System.assert(criteria.focusAreas.contains('Solution Design'), 'Should include Solution Design focus area');
    }
    
    @IsTest
    static void testGetCertificationCriteriaDeveloper() {
        Test.startTest();
        CertificationRouter.CertificationCriteria criteria = CertificationRouter.getCertificationCriteria('Developer');
        Test.stopTest();
        
        System.assertNotEquals(null, criteria, 'Criteria should not be null');
        System.assertEquals(105, criteria.examDuration, 'Developer exam should be 105 minutes');
        System.assertEquals(68, criteria.passingScore, 'Developer passing score should be 68%');
        System.assertEquals(60, criteria.questionCount, 'Developer exam should have 60 questions');
        System.assertEquals('Technical Development', criteria.skillLevel, 'Developer skill level should be Technical Development');
        System.assert(criteria.focusAreas.contains('Technical Implementation'), 'Should include Technical Implementation focus area');
    }
    
    @IsTest
    static void testGetCertificationCriteriaDefault() {
        Test.startTest();
        CertificationRouter.CertificationCriteria criteria = CertificationRouter.getCertificationCriteria('Unknown');
        Test.stopTest();
        
        System.assertNotEquals(null, criteria, 'Criteria should not be null');
        System.assertEquals(90, criteria.examDuration, 'Default exam should be 90 minutes');
        System.assertEquals(70, criteria.passingScore, 'Default passing score should be 70%');
        System.assertEquals(50, criteria.questionCount, 'Default exam should have 50 questions');
        System.assertEquals('Mixed', criteria.skillLevel, 'Default skill level should be Mixed');
    }
}