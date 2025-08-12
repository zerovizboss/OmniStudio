/**
 * @description Test class for LearningPathManager
 * @author Claude Code Assistant
 * @since User Story #16 - Differentiated Study Paths
 * @version 1.0
 * 
 * Comprehensive test coverage for differentiated learning paths,
 * study time estimates, and cross-certification mapping.
 */
@IsTest
private class LearningPathManagerTest {
    
    /**
     * @description Test getting Consultant learning path
     */
    @IsTest
    static void testGetConsultantLearningPath() {
        Test.startTest();
        LearningPathManager.LearningPath consultantPath = 
            LearningPathManager.getLearningPath('Consultant');
        Test.stopTest();
        
        // Verify basic path properties
        Assert.areEqual('Consultant', consultantPath.certificationTrack, 
            'Certification track should be Consultant');
        Assert.areEqual('OmniStudio Consultant Certification Path', consultantPath.pathName, 
            'Path name should be set correctly');
        Assert.areEqual(6, consultantPath.recommendedExperienceMonths, 
            'Recommended experience should be 6 months');
        Assert.areEqual(120, consultantPath.totalEstimatedHours, 
            'Total estimated hours should be 120');
        
        // Verify prerequisites
        Assert.isTrue(consultantPath.prerequisites.size() > 0, 
            'Should have prerequisites defined');
        Assert.isTrue(consultantPath.prerequisites[0].contains('Salesforce Administrator'), 
            'Should include Salesforce Admin certification');
        
        // Verify modules structure
        Assert.areEqual(5, consultantPath.modules.size(), 
            'Should have 5 modules (Foundation + 4 exam topics)');
        
        // Verify module sequence and topics
        Assert.areEqual('Foundation', consultantPath.modules[0].topic, 
            'First module should be Foundation');
        Assert.areEqual('FlexCards', consultantPath.modules[1].topic, 
            'Second module should be FlexCards');
        Assert.areEqual('OmniScripts', consultantPath.modules[2].topic, 
            'Third module should be OmniScripts');
        Assert.areEqual('DataTools', consultantPath.modules[3].topic, 
            'Fourth module should be DataTools');
        Assert.areEqual('Solutioning', consultantPath.modules[4].topic, 
            'Fifth module should be Solutioning');
        
        // Verify topic weights (approximately)
        LearningPathManager.StudyModule flexCardsModule = consultantPath.modules[1];
        LearningPathManager.StudyModule omniScriptsModule = consultantPath.modules[2];
        
        Assert.areEqual(28, flexCardsModule.estimatedHours, 
            'FlexCards module should have ~23% of total hours (28h)');
        Assert.areEqual(32, omniScriptsModule.estimatedHours, 
            'OmniScripts module should have ~27% of total hours (32h)');
        
        // Verify cross-certification mappings
        Assert.isTrue(consultantPath.crossCertificationMapping.containsKey('FlexCards'), 
            'Should have FlexCards cross-certification mapping');
        Assert.isTrue(consultantPath.crossCertificationMapping.get('FlexCards').startsWith('Developer'), 
            'FlexCards should map to Developer track content');
    }
    
    /**
     * @description Test getting Developer learning path
     */
    @IsTest
    static void testGetDeveloperLearningPath() {
        Test.startTest();
        LearningPathManager.LearningPath developerPath = 
            LearningPathManager.getLearningPath('Developer');
        Test.stopTest();
        
        // Verify basic path properties
        Assert.areEqual('Developer', developerPath.certificationTrack, 
            'Certification track should be Developer');
        Assert.areEqual('OmniStudio Developer Certification Path', developerPath.pathName, 
            'Path name should be set correctly');
        Assert.areEqual(12, developerPath.recommendedExperienceMonths, 
            'Recommended experience should be 12 months');
        Assert.areEqual(150, developerPath.totalEstimatedHours, 
            'Total estimated hours should be 150');
        
        // Verify prerequisites are more technical
        Assert.isTrue(developerPath.prerequisites.size() > 0, 
            'Should have prerequisites defined');
        Assert.isTrue(developerPath.prerequisites[0].contains('Platform Developer I'), 
            'Should require Platform Developer I certification');
        
        Boolean hasJavaScriptPrereq = false;
        Boolean hasApexPrereq = false;
        for (String prereq : developerPath.prerequisites) {
            if (prereq.contains('JavaScript')) hasJavaScriptPrereq = true;
            if (prereq.contains('Apex')) hasApexPrereq = true;
        }
        Assert.isTrue(hasJavaScriptPrereq, 'Should require JavaScript experience');
        Assert.isTrue(hasApexPrereq, 'Should require Apex experience');
        
        // Verify modules structure
        Assert.isTrue(developerPath.modules.size() >= 2, 
            'Should have multiple modules including Foundation and FlexCards');
        
        // Verify first modules
        Assert.areEqual('Foundation', developerPath.modules[0].topic, 
            'First module should be Foundation');
        Assert.areEqual('FlexCards', developerPath.modules[1].topic, 
            'Second module should be FlexCards');
        
        // Verify technical focus in FlexCards module
        LearningPathManager.StudyModule flexCardsModule = developerPath.modules[1];
        Assert.areEqual(30, flexCardsModule.estimatedHours, 
            'Developer FlexCards module should have 30 hours');
        Assert.isTrue(flexCardsModule.description.contains('JavaScript'), 
            'FlexCards description should mention JavaScript');
        Assert.isTrue(flexCardsModule.description.contains('CSS'), 
            'FlexCards description should mention CSS');
        
        // Verify cross-certification mappings
        Assert.isTrue(developerPath.crossCertificationMapping.containsKey('FlexCards'), 
            'Should have FlexCards cross-certification mapping');
        Assert.isTrue(developerPath.crossCertificationMapping.get('FlexCards').startsWith('Consultant'), 
            'FlexCards should map to Consultant track content');
    }
    
    /**
     * @description Test invalid certification track handling
     */
    @IsTest
    static void testInvalidCertificationTrack() {
        Test.startTest();
        try {
            LearningPathManager.getLearningPath('InvalidTrack');
            Assert.fail('Should throw IllegalArgumentException for invalid track');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Invalid certification track'), 
                'Error message should mention invalid certification track');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test study unit creation and structure
     */
    @IsTest
    static void testStudyUnitStructure() {
        Test.startTest();
        LearningPathManager.LearningPath consultantPath = 
            LearningPathManager.getLearningPath('Consultant');
        Test.stopTest();
        
        // Get first module's units
        LearningPathManager.StudyModule foundationModule = consultantPath.modules[0];
        Assert.isTrue(foundationModule.units.size() > 0, 
            'Foundation module should have study units');
        
        // Verify unit structure
        LearningPathManager.StudyUnit firstUnit = foundationModule.units[0];
        Assert.isNotNull(firstUnit.unitId, 'Unit ID should be set');
        Assert.isNotNull(firstUnit.unitName, 'Unit name should be set');
        Assert.isNotNull(firstUnit.unitType, 'Unit type should be set');
        Assert.isTrue(firstUnit.estimatedMinutes > 0, 'Estimated minutes should be positive');
        Assert.isNotNull(firstUnit.difficultyLevel, 'Difficulty level should be set');
        Assert.isTrue(firstUnit.contentTags.size() > 0, 'Content tags should be present');
        Assert.isNotNull(firstUnit.scenario, 'Scenario should be set');
        Assert.isTrue(firstUnit.isRequired, 'Unit should be required by default');
        
        // Verify unit types diversity
        Set<String> unitTypes = new Set<String>();
        for (LearningPathManager.StudyUnit unit : foundationModule.units) {
            unitTypes.add(unit.unitType);
        }
        Assert.isTrue(unitTypes.size() > 1, 'Should have diverse unit types');
        Assert.isTrue(unitTypes.contains('Theory') || unitTypes.contains('Practice'), 
            'Should include Theory or Practice units');
    }
    
    /**
     * @description Test learning objectives and prerequisites
     */
    @IsTest
    static void testLearningObjectivesAndPrerequisites() {
        Test.startTest();
        LearningPathManager.LearningPath consultantPath = 
            LearningPathManager.getLearningPath('Consultant');
        Test.stopTest();
        
        // Check FlexCards module (index 1)
        LearningPathManager.StudyModule flexCardsModule = consultantPath.modules[1];
        
        // Verify learning objectives
        Assert.isTrue(flexCardsModule.learningObjectives.size() > 0, 
            'FlexCards module should have learning objectives');
        Assert.isTrue(flexCardsModule.learningObjectives[0].contains('FlexCards'), 
            'Learning objectives should be relevant to FlexCards');
        
        // Check later modules have prerequisites
        LearningPathManager.StudyModule omniScriptsModule = consultantPath.modules[2];
        Assert.isTrue(omniScriptsModule.prerequisites.size() > 0, 
            'OmniScripts module should have prerequisites');
        Assert.isTrue(omniScriptsModule.prerequisites.contains('CONS_M01'), 
            'Should include foundation module as prerequisite');
    }
    
    /**
     * @description Test personalized learning recommendations
     */
    @IsTest
    static void testPersonalizedRecommendations() {
        String testUserId = UserInfo.getUserId();
        
        Test.startTest();
        LearningPathManager.LearningProgress consultantProgress = 
            LearningPathManager.getPersonalizedRecommendations(testUserId, 'Consultant');
        LearningPathManager.LearningProgress developerProgress = 
            LearningPathManager.getPersonalizedRecommendations(testUserId, 'Developer');
        Test.stopTest();
        
        // Verify consultant recommendations
        Assert.areEqual(testUserId, consultantProgress.userId, 
            'User ID should match input');
        Assert.areEqual('Consultant', consultantProgress.certificationTrack, 
            'Certification track should be Consultant');
        Assert.areEqual(0, consultantProgress.overallProgressPercent, 
            'Initial progress should be 0%');
        Assert.areEqual(0, consultantProgress.totalStudyHours, 
            'Initial study hours should be 0');
        Assert.isNotNull(consultantProgress.lastActivity, 
            'Last activity should be set');
        Assert.isNotNull(consultantProgress.currentModuleId, 
            'Current module should be set');
        Assert.isNotNull(consultantProgress.currentUnitId, 
            'Current unit should be set');
        Assert.isTrue(consultantProgress.recommendedNext.size() > 0, 
            'Should have next recommendations');
        
        // Verify developer recommendations
        Assert.areEqual('Developer', developerProgress.certificationTrack, 
            'Certification track should be Developer');
        Assert.isNotNull(developerProgress.currentModuleId, 
            'Developer should also have current module set');
    }
    
    /**
     * @description Test study time estimates
     */
    @IsTest
    static void testStudyTimeEstimates() {
        Test.startTest();
        Map<String, Integer> consultantEstimates = 
            LearningPathManager.getStudyTimeEstimates('Consultant');
        Map<String, Integer> developerEstimates = 
            LearningPathManager.getStudyTimeEstimates('Developer');
        Test.stopTest();
        
        // Verify consultant estimates
        Assert.areEqual(4, consultantEstimates.size(), 
            'Consultant should have 4 topic estimates (excluding Foundation)');
        Assert.isTrue(consultantEstimates.containsKey('FlexCards'), 
            'Should include FlexCards estimate');
        Assert.isTrue(consultantEstimates.containsKey('OmniScripts'), 
            'Should include OmniScripts estimate');
        Assert.isTrue(consultantEstimates.containsKey('DataTools'), 
            'Should include DataTools estimate');
        Assert.isTrue(consultantEstimates.containsKey('Solutioning'), 
            'Should include Solutioning estimate');
        
        // Verify time estimates are reasonable
        Assert.areEqual(28, consultantEstimates.get('FlexCards'), 
            'FlexCards should have 28 hours estimate');
        Assert.areEqual(32, consultantEstimates.get('OmniScripts'), 
            'OmniScripts should have 32 hours estimate');
        
        // Verify developer estimates
        Assert.isTrue(developerEstimates.size() > 0, 
            'Developer should have topic estimates');
        Assert.isTrue(developerEstimates.containsKey('FlexCards'), 
            'Developer should include FlexCards estimate');
        
        // Developer FlexCards should have different time allocation
        Assert.areEqual(30, developerEstimates.get('FlexCards'), 
            'Developer FlexCards should have 30 hours estimate');
    }
    
    /**
     * @description Test cross-certification mappings
     */
    @IsTest
    static void testCrossCertificationMappings() {
        Test.startTest();
        Map<String, String> consultantToDeveloper = 
            LearningPathManager.getCrossCertificationMappings('Consultant', 'Developer');
        Map<String, String> developerToConsultant = 
            LearningPathManager.getCrossCertificationMappings('Developer', 'Consultant');
        Test.stopTest();
        
        // Verify consultant to developer mappings
        Assert.isTrue(consultantToDeveloper.size() > 0, 
            'Should have cross-certification mappings');
        Assert.isTrue(consultantToDeveloper.containsKey('FlexCards'), 
            'Should map FlexCards content');
        Assert.isTrue(consultantToDeveloper.get('FlexCards').startsWith('Developer'), 
            'FlexCards should map to Developer track');
        Assert.isTrue(consultantToDeveloper.get('FlexCards').contains('Advanced'), 
            'Should map to advanced developer content');
        
        // Verify developer to consultant mappings
        Assert.isTrue(developerToConsultant.size() > 0, 
            'Should have reverse mappings');
        Assert.isTrue(developerToConsultant.containsKey('FlexCards'), 
            'Should map FlexCards content from developer perspective');
        Assert.isTrue(developerToConsultant.get('FlexCards').startsWith('Consultant'), 
            'Should map to Consultant track');
        
        // Verify mapping specificity
        if (consultantToDeveloper.containsKey('DataTools')) {
            Assert.isTrue(consultantToDeveloper.get('DataTools').contains('DataRaptors'), 
                'DataTools should map to DataRaptors technical content');
        }
    }
    
    /**
     * @description Test prerequisite checking
     */
    @IsTest
    static void testPrerequisiteChecking() {
        String testUserId = UserInfo.getUserId();
        List<String> noCompletedUnits = new List<String>();
        List<String> foundationCompleted = new List<String>{'CONS_U01_01', 'CONS_U01_02', 'CONS_U01_03'};
        
        Test.startTest();
        
        // Test foundation module (no prerequisites)
        Boolean foundationPrereqs = LearningPathManager.checkPrerequisites(
            testUserId, 'CONS_M01', noCompletedUnits);
        Assert.isTrue(foundationPrereqs, 
            'Foundation module should not require prerequisites');
        
        // Test second module without foundation completed
        Boolean flexCardPrereqsNotMet = LearningPathManager.checkPrerequisites(
            testUserId, 'CONS_M02', noCompletedUnits);
        Assert.isFalse(flexCardPrereqsNotMet, 
            'FlexCards module should require foundation completion');
        
        // Test second module with foundation completed
        Boolean flexCardPrereqsMet = LearningPathManager.checkPrerequisites(
            testUserId, 'CONS_M02', foundationCompleted);
        Assert.isTrue(flexCardPrereqsMet, 
            'FlexCards module should be available after foundation completion');
        
        Test.stopTest();
    }
    
    /**
     * @description Test learning path data structures
     */
    @IsTest
    static void testLearningPathDataStructures() {
        Test.startTest();
        
        // Test LearningPath constructor
        LearningPathManager.LearningPath testPath = new LearningPathManager.LearningPath();
        Assert.isNotNull(testPath.prerequisites, 'Prerequisites list should be initialized');
        Assert.isNotNull(testPath.modules, 'Modules list should be initialized');
        Assert.isNotNull(testPath.crossCertificationMapping, 'Mappings should be initialized');
        
        // Test StudyModule constructor
        LearningPathManager.StudyModule testModule = new LearningPathManager.StudyModule();
        Assert.isNotNull(testModule.learningObjectives, 'Learning objectives should be initialized');
        Assert.isNotNull(testModule.prerequisites, 'Prerequisites should be initialized');
        Assert.isNotNull(testModule.units, 'Units list should be initialized');
        
        // Test StudyUnit constructor
        LearningPathManager.StudyUnit testUnit = new LearningPathManager.StudyUnit();
        Assert.isNotNull(testUnit.contentTags, 'Content tags should be initialized');
        Assert.isTrue(testUnit.isRequired, 'Unit should be required by default');
        
        // Test LearningProgress constructor
        LearningPathManager.LearningProgress testProgress = new LearningPathManager.LearningProgress();
        Assert.isNotNull(testProgress.moduleProgress, 'Module progress should be initialized');
        Assert.isNotNull(testProgress.completedUnits, 'Completed units should be initialized');
        Assert.isNotNull(testProgress.recommendedNext, 'Recommendations should be initialized');
        
        Test.stopTest();
    }
    
    /**
     * @description Test difficulty progression across modules
     */
    @IsTest
    static void testDifficultyProgression() {
        Test.startTest();
        LearningPathManager.LearningPath consultantPath = 
            LearningPathManager.getLearningPath('Consultant');
        Test.stopTest();
        
        // Verify progression through modules
        for (LearningPathManager.StudyModule module : consultantPath.modules) {
            Assert.isNotNull(module.difficultyProgression, 
                'Module should have difficulty progression defined');
            
            // Foundation should start with Beginner
            if (module.topic == 'Foundation') {
                Assert.isTrue(module.difficultyProgression.contains('Beginner'), 
                    'Foundation should include Beginner level');
            }
            
            // Advanced modules should include Advanced level
            if (module.topic == 'Solutioning') {
                Assert.isTrue(module.difficultyProgression.contains('Advanced'), 
                    'Solutioning should include Advanced level');
            }
        }
        
        // Check unit difficulty progression within modules
        LearningPathManager.StudyModule flexCardsModule = consultantPath.modules[1];
        Set<String> difficultyLevels = new Set<String>();
        for (LearningPathManager.StudyUnit unit : flexCardsModule.units) {
            difficultyLevels.add(unit.difficultyLevel);
        }
        Assert.isTrue(difficultyLevels.size() > 1, 
            'Module should have units at different difficulty levels');
    }
    
    /**
     * @description Test content scenarios relevance
     */
    @IsTest
    static void testContentScenarios() {
        Test.startTest();
        LearningPathManager.LearningPath consultantPath = 
            LearningPathManager.getLearningPath('Consultant');
        LearningPathManager.LearningPath developerPath = 
            LearningPathManager.getLearningPath('Developer');
        Test.stopTest();
        
        // Check consultant scenarios are business-focused
        LearningPathManager.StudyModule consultantFlexCards = consultantPath.modules[1];
        for (LearningPathManager.StudyUnit unit : consultantFlexCards.units) {
            Assert.isNotNull(unit.scenario, 'Unit should have scenario defined');
            // Consultant scenarios should be business-focused
            Assert.isTrue(unit.scenario.toLowerCase().contains('customer') || 
                         unit.scenario.toLowerCase().contains('business') || 
                         unit.scenario.toLowerCase().contains('dashboard') ||
                         unit.scenario.toLowerCase().contains('sales') ||
                         unit.scenario.toLowerCase().contains('service'), 
                'Consultant scenarios should be business-focused');
        }
        
        // Check developer scenarios are technical-focused
        if (developerPath.modules.size() > 1) {
            LearningPathManager.StudyModule developerFlexCards = developerPath.modules[1];
            for (LearningPathManager.StudyUnit unit : developerFlexCards.units) {
                Assert.isNotNull(unit.scenario, 'Developer unit should have scenario defined');
                // Developer scenarios should be more technical
                Assert.isTrue(unit.scenario.toLowerCase().contains('javascript') || 
                             unit.scenario.toLowerCase().contains('custom') || 
                             unit.scenario.toLowerCase().contains('development') ||
                             unit.scenario.toLowerCase().contains('integration') ||
                             unit.scenario.toLowerCase().contains('api'), 
                    'Developer scenarios should be technically-focused');
            }
        }
    }
}