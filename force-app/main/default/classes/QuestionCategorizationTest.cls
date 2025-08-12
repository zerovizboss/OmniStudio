/**
 * @description Test class for QuestionCategorization framework
 * @author Claude Code Assistant
 * @since User Story #15 - Question Categorization Framework
 * @version 1.0
 * 
 * Comprehensive test coverage for question categorization, topic weighting,
 * difficulty scaling, and content tagging functionality.
 */
@IsTest
private class QuestionCategorizationTest {
    
    /**
     * @description Test consultant exam topic weights
     */
    @IsTest
    static void testConsultantTopicWeights() {
        // Test all consultant topics have correct weights
        Assert.areEqual(23.0, QuestionCategorization.getTopicWeight('Consultant', 'FlexCards'), 
            'FlexCards should have 23% weight for Consultant track');
        Assert.areEqual(27.0, QuestionCategorization.getTopicWeight('Consultant', 'OmniScripts'), 
            'OmniScripts should have 27% weight for Consultant track');
        Assert.areEqual(23.0, QuestionCategorization.getTopicWeight('Consultant', 'DataTools'), 
            'DataTools should have 23% weight for Consultant track');
        Assert.areEqual(27.0, QuestionCategorization.getTopicWeight('Consultant', 'Solutioning'), 
            'Solutioning should have 27% weight for Consultant track');
        
        // Test invalid topic returns 0
        Assert.areEqual(0, QuestionCategorization.getTopicWeight('Consultant', 'InvalidTopic'), 
            'Invalid topic should return 0 weight');
    }
    
    /**
     * @description Test developer exam topic weights
     */
    @IsTest
    static void testDeveloperTopicWeights() {
        // Test all developer topics have equal 20% weight
        Assert.areEqual(20.0, QuestionCategorization.getTopicWeight('Developer', 'FlexCards'), 
            'FlexCards should have 20% weight for Developer track');
        Assert.areEqual(20.0, QuestionCategorization.getTopicWeight('Developer', 'OmniScripts'), 
            'OmniScripts should have 20% weight for Developer track');
        Assert.areEqual(20.0, QuestionCategorization.getTopicWeight('Developer', 'IntegrationProcedures'), 
            'IntegrationProcedures should have 20% weight for Developer track');
        Assert.areEqual(20.0, QuestionCategorization.getTopicWeight('Developer', 'DataRaptors'), 
            'DataRaptors should have 20% weight for Developer track');
        Assert.areEqual(20.0, QuestionCategorization.getTopicWeight('Developer', 'Expressions'), 
            'Expressions should have 20% weight for Developer track');
        
        // Test invalid certification track returns 0
        Assert.areEqual(0, QuestionCategorization.getTopicWeight('InvalidTrack', 'FlexCards'), 
            'Invalid certification track should return 0 weight');
    }
    
    /**
     * @description Test valid topics retrieval
     */
    @IsTest
    static void testGetValidTopics() {
        // Test consultant topics
        Set<String> consultantTopics = QuestionCategorization.getValidTopics('Consultant');
        Assert.areEqual(4, consultantTopics.size(), 'Consultant should have 4 topics');
        Assert.isTrue(consultantTopics.contains('FlexCards'), 'Consultant topics should include FlexCards');
        Assert.isTrue(consultantTopics.contains('OmniScripts'), 'Consultant topics should include OmniScripts');
        Assert.isTrue(consultantTopics.contains('DataTools'), 'Consultant topics should include DataTools');
        Assert.isTrue(consultantTopics.contains('Solutioning'), 'Consultant topics should include Solutioning');
        
        // Test developer topics
        Set<String> developerTopics = QuestionCategorization.getValidTopics('Developer');
        Assert.areEqual(5, developerTopics.size(), 'Developer should have 5 topics');
        Assert.isTrue(developerTopics.contains('FlexCards'), 'Developer topics should include FlexCards');
        Assert.isTrue(developerTopics.contains('OmniScripts'), 'Developer topics should include OmniScripts');
        Assert.isTrue(developerTopics.contains('IntegrationProcedures'), 'Developer topics should include IntegrationProcedures');
        Assert.isTrue(developerTopics.contains('DataRaptors'), 'Developer topics should include DataRaptors');
        Assert.isTrue(developerTopics.contains('Expressions'), 'Developer topics should include Expressions');
        
        // Test invalid track returns empty set
        Set<String> invalidTopics = QuestionCategorization.getValidTopics('InvalidTrack');
        Assert.areEqual(0, invalidTopics.size(), 'Invalid track should return empty topic set');
    }
    
    /**
     * @description Test difficulty level conversion methods
     */
    @IsTest
    static void testDifficultyLevelConversion() {
        // Test enum to integer conversion
        Assert.areEqual(1, QuestionCategorization.difficultyToInteger(QuestionCategorization.DifficultyLevel.BEGINNER), 
            'Beginner should convert to 1');
        Assert.areEqual(2, QuestionCategorization.difficultyToInteger(QuestionCategorization.DifficultyLevel.INTERMEDIATE), 
            'Intermediate should convert to 2');
        Assert.areEqual(3, QuestionCategorization.difficultyToInteger(QuestionCategorization.DifficultyLevel.ADVANCED), 
            'Advanced should convert to 3');
        
        // Test integer to enum conversion
        Assert.areEqual(QuestionCategorization.DifficultyLevel.BEGINNER, 
            QuestionCategorization.integerToDifficulty(1), 'Integer 1 should convert to BEGINNER');
        Assert.areEqual(QuestionCategorization.DifficultyLevel.INTERMEDIATE, 
            QuestionCategorization.integerToDifficulty(2), 'Integer 2 should convert to INTERMEDIATE');
        Assert.areEqual(QuestionCategorization.DifficultyLevel.ADVANCED, 
            QuestionCategorization.integerToDifficulty(3), 'Integer 3 should convert to ADVANCED');
        
        // Test invalid integer defaults to BEGINNER
        Assert.areEqual(QuestionCategorization.DifficultyLevel.BEGINNER, 
            QuestionCategorization.integerToDifficulty(5), 'Invalid integer should default to BEGINNER');
        Assert.areEqual(QuestionCategorization.DifficultyLevel.BEGINNER, 
            QuestionCategorization.integerToDifficulty(0), 'Zero should default to BEGINNER');
    }
    
    /**
     * @description Test estimated time calculation
     */
    @IsTest
    static void testEstimatedTimeCalculation() {
        // Test base times for different question types
        Assert.areEqual(60, QuestionCategorization.getEstimatedTime(
            QuestionCategorization.QuestionType.MULTIPLE_CHOICE, 
            QuestionCategorization.DifficultyLevel.BEGINNER), 
            'Multiple choice beginner should be 60 seconds');
        Assert.areEqual(90, QuestionCategorization.getEstimatedTime(
            QuestionCategorization.QuestionType.MULTIPLE_SELECT, 
            QuestionCategorization.DifficultyLevel.BEGINNER), 
            'Multiple select beginner should be 90 seconds');
        Assert.areEqual(180, QuestionCategorization.getEstimatedTime(
            QuestionCategorization.QuestionType.SCENARIO_BASED, 
            QuestionCategorization.DifficultyLevel.BEGINNER), 
            'Scenario-based beginner should be 180 seconds');
        Assert.areEqual(300, QuestionCategorization.getEstimatedTime(
            QuestionCategorization.QuestionType.PRACTICAL, 
            QuestionCategorization.DifficultyLevel.BEGINNER), 
            'Practical beginner should be 300 seconds');
        Assert.areEqual(120, QuestionCategorization.getEstimatedTime(
            QuestionCategorization.QuestionType.DRAG_AND_DROP, 
            QuestionCategorization.DifficultyLevel.BEGINNER), 
            'Drag and drop beginner should be 120 seconds');
        
        // Test difficulty multipliers
        Integer beginnerTime = QuestionCategorization.getEstimatedTime(
            QuestionCategorization.QuestionType.MULTIPLE_CHOICE, 
            QuestionCategorization.DifficultyLevel.BEGINNER);
        Integer intermediateTime = QuestionCategorization.getEstimatedTime(
            QuestionCategorization.QuestionType.MULTIPLE_CHOICE, 
            QuestionCategorization.DifficultyLevel.INTERMEDIATE);
        Integer advancedTime = QuestionCategorization.getEstimatedTime(
            QuestionCategorization.QuestionType.MULTIPLE_CHOICE, 
            QuestionCategorization.DifficultyLevel.ADVANCED);
        
        Assert.isTrue(intermediateTime > beginnerTime, 'Intermediate should take longer than beginner');
        Assert.isTrue(advancedTime > intermediateTime, 'Advanced should take longer than intermediate');
        Assert.areEqual(78, intermediateTime, 'Intermediate should be 30% more than beginner (60 * 1.3 = 78)');
        Assert.areEqual(96, advancedTime, 'Advanced should be 60% more than beginner (60 * 1.6 = 96)');
    }
    
    /**
     * @description Test question category validation
     */
    @IsTest
    static void testQuestionCategoryValidation() {
        // Test valid category
        QuestionCategorization.QuestionCategory validCategory = new QuestionCategorization.QuestionCategory();
        validCategory.certificationTrack = 'Consultant';
        validCategory.primaryTopic = 'FlexCards';
        validCategory.tags = new Set<String>{'flexcard-basics'};
        
        List<String> errors = QuestionCategorization.validateCategory(validCategory);
        Assert.areEqual(0, errors.size(), 'Valid category should have no validation errors');
        
        // Test invalid certification track
        QuestionCategorization.QuestionCategory invalidTrack = new QuestionCategorization.QuestionCategory();
        invalidTrack.certificationTrack = 'InvalidTrack';
        invalidTrack.primaryTopic = 'FlexCards';
        
        List<String> trackErrors = QuestionCategorization.validateCategory(invalidTrack);
        Assert.areEqual(1, trackErrors.size(), 'Invalid track should have one error');
        Assert.isTrue(trackErrors[0].contains('Invalid certification track'), 
            'Error should mention invalid certification track');
        
        // Test missing primary topic
        QuestionCategorization.QuestionCategory missingTopic = new QuestionCategorization.QuestionCategory();
        missingTopic.certificationTrack = 'Consultant';
        
        List<String> topicErrors = QuestionCategorization.validateCategory(missingTopic);
        Assert.areEqual(1, topicErrors.size(), 'Missing topic should have one error');
        Assert.isTrue(topicErrors[0].contains('Primary topic is required'), 
            'Error should mention missing primary topic');
        
        // Test invalid topic for track
        QuestionCategorization.QuestionCategory invalidTopic = new QuestionCategorization.QuestionCategory();
        invalidTopic.certificationTrack = 'Consultant';
        invalidTopic.primaryTopic = 'IntegrationProcedures'; // Developer-only topic
        
        List<String> invalidTopicErrors = QuestionCategorization.validateCategory(invalidTopic);
        Assert.areEqual(1, invalidTopicErrors.size(), 'Invalid topic for track should have one error');
        Assert.isTrue(invalidTopicErrors[0].contains('Invalid primary topic'), 
            'Error should mention invalid primary topic');
        
        // Test invalid content tag
        QuestionCategorization.QuestionCategory invalidTag = new QuestionCategorization.QuestionCategory();
        invalidTag.certificationTrack = 'Consultant';
        invalidTag.primaryTopic = 'FlexCards';
        invalidTag.tags = new Set<String>{'invalid-tag'};
        
        List<String> tagErrors = QuestionCategorization.validateCategory(invalidTag);
        Assert.areEqual(1, tagErrors.size(), 'Invalid tag should have one error');
        Assert.isTrue(tagErrors[0].contains('Invalid content tag'), 
            'Error should mention invalid content tag');
    }
    
    /**
     * @description Test category creation
     */
    @IsTest
    static void testCreateCategory() {
        Set<String> tags = new Set<String>{'flexcard-basics', 'flexcard-datasource'};
        
        QuestionCategorization.QuestionCategory category = QuestionCategorization.createCategory(
            'Consultant',
            'FlexCards',
            'Data Binding',
            QuestionCategorization.DifficultyLevel.INTERMEDIATE,
            QuestionCategorization.QuestionType.MULTIPLE_CHOICE,
            tags
        );
        
        Assert.areEqual('Consultant', category.certificationTrack, 'Certification track should be set correctly');
        Assert.areEqual('FlexCards', category.primaryTopic, 'Primary topic should be set correctly');
        Assert.areEqual('Data Binding', category.subTopic, 'Sub-topic should be set correctly');
        Assert.areEqual(QuestionCategorization.DifficultyLevel.INTERMEDIATE, category.difficulty, 
            'Difficulty should be set correctly');
        Assert.areEqual(QuestionCategorization.QuestionType.MULTIPLE_CHOICE, category.questionType, 
            'Question type should be set correctly');
        Assert.areEqual(2, category.tags.size(), 'Tags should be set correctly');
        Assert.areEqual(23.0, category.topicWeight, 'Topic weight should be calculated correctly');
        Assert.areEqual(78, category.estimatedTimeMinutes, 'Estimated time should be calculated correctly');
        
        // Test with null tags
        QuestionCategorization.QuestionCategory categoryNoTags = QuestionCategorization.createCategory(
            'Developer',
            'DataRaptors',
            null,
            QuestionCategorization.DifficultyLevel.BEGINNER,
            QuestionCategorization.QuestionType.SCENARIO_BASED,
            null
        );
        
        Assert.isNotNull(categoryNoTags.tags, 'Tags should not be null even when passed as null');
        Assert.areEqual(0, categoryNoTags.tags.size(), 'Tags should be empty set when passed as null');
    }
    
    /**
     * @description Test recommended question distribution
     */
    @IsTest
    static void testRecommendedDistribution() {
        // Test consultant distribution
        Map<String, Integer> consultantDist = QuestionCategorization.getRecommendedDistribution('Consultant', 100);
        
        Assert.areEqual(4, consultantDist.size(), 'Consultant distribution should have 4 topics');
        
        Integer totalQuestions = 0;
        for (Integer count : consultantDist.values()) {
            totalQuestions += count;
        }
        Assert.areEqual(100, totalQuestions, 'Total distributed questions should equal input');
        
        // Test developer distribution
        Map<String, Integer> developerDist = QuestionCategorization.getRecommendedDistribution('Developer', 50);
        
        Assert.areEqual(5, developerDist.size(), 'Developer distribution should have 5 topics');
        
        Integer totalDevQuestions = 0;
        for (Integer count : developerDist.values()) {
            totalDevQuestions += count;
        }
        Assert.areEqual(50, totalDevQuestions, 'Total distributed questions should equal input');
        
        // Test with small number that doesn't divide evenly
        Map<String, Integer> smallDist = QuestionCategorization.getRecommendedDistribution('Consultant', 7);
        
        Integer totalSmallQuestions = 0;
        for (Integer count : smallDist.values()) {
            totalSmallQuestions += count;
        }
        Assert.areEqual(7, totalSmallQuestions, 'Should handle small odd numbers correctly');
        
        // Test invalid track returns empty map
        Map<String, Integer> invalidDist = QuestionCategorization.getRecommendedDistribution('InvalidTrack', 20);
        Assert.areEqual(0, invalidDist.size(), 'Invalid track should return empty distribution');
    }
    
    /**
     * @description Test topic tags retrieval
     */
    @IsTest
    static void testGetTopicTags() {
        // Test FlexCards tags
        Set<String> flexCardTags = QuestionCategorization.getTopicTags('FlexCards');
        Assert.areEqual(6, flexCardTags.size(), 'FlexCards should have 6 related tags');
        Assert.isTrue(flexCardTags.contains('flexcard-basics'), 'Should include flexcard-basics tag');
        Assert.isTrue(flexCardTags.contains('flexcard-conditional-visibility'), 'Should include conditional visibility tag');
        
        // Test OmniScripts tags (case insensitive)
        Set<String> omniScriptTags = QuestionCategorization.getTopicTags('omniscripts');
        Assert.areEqual(6, omniScriptTags.size(), 'OmniScripts should have 6 related tags');
        Assert.isTrue(omniScriptTags.contains('omniscript-elements'), 'Should include omniscript-elements tag');
        Assert.isTrue(omniScriptTags.contains('omniscript-performance'), 'Should include performance tag');
        
        // Test DataRaptors tags
        Set<String> dataRaptorTags = QuestionCategorization.getTopicTags('DataRaptors');
        Assert.areEqual(6, dataRaptorTags.size(), 'DataRaptors should have 6 related tags');
        Assert.isTrue(dataRaptorTags.contains('dataraptor-extract'), 'Should include extract tag');
        Assert.isTrue(dataRaptorTags.contains('dataraptor-turbo'), 'Should include turbo tag');
        
        // Test DataTools alias
        Set<String> dataToolsTags = QuestionCategorization.getTopicTags('DataTools');
        Assert.areEqual(6, dataToolsTags.size(), 'DataTools should have same tags as DataRaptors');
        
        // Test IntegrationProcedures tags
        Set<String> integrationTags = QuestionCategorization.getTopicTags('IntegrationProcedures');
        Assert.areEqual(6, integrationTags.size(), 'IntegrationProcedures should have 6 related tags');
        Assert.isTrue(integrationTags.contains('integration-procedures'), 'Should include integration-procedures tag');
        Assert.isTrue(integrationTags.contains('rest-api'), 'Should include REST API tag');
        
        // Test Expressions tags
        Set<String> expressionTags = QuestionCategorization.getTopicTags('Expressions');
        Assert.areEqual(5, expressionTags.size(), 'Expressions should have 5 related tags');
        Assert.isTrue(expressionTags.contains('formula-expressions'), 'Should include formula expressions tag');
        Assert.isTrue(expressionTags.contains('decision-matrices'), 'Should include decision matrices tag');
        
        // Test Solutioning tags
        Set<String> solutioningTags = QuestionCategorization.getTopicTags('Solutioning');
        Assert.areEqual(6, solutioningTags.size(), 'Solutioning should have 6 related tags');
        Assert.isTrue(solutioningTags.contains('business-requirements'), 'Should include business requirements tag');
        Assert.isTrue(solutioningTags.contains('best-practices'), 'Should include best practices tag');
        
        // Test unknown topic returns empty set
        Set<String> unknownTags = QuestionCategorization.getTopicTags('UnknownTopic');
        Assert.areEqual(0, unknownTags.size(), 'Unknown topic should return empty tag set');
    }
    
    /**
     * @description Test content tags coverage
     */
    @IsTest
    static void testContentTagsCoverage() {
        // Verify we have a comprehensive set of content tags
        Set<String> allTags = QuestionCategorization.CONTENT_TAGS;
        
        Assert.isTrue(allTags.size() > 30, 'Should have comprehensive set of content tags');
        
        // Verify each topic area has related tags
        Assert.isTrue(allTags.contains('flexcard-basics'), 'Should include FlexCard basic tags');
        Assert.isTrue(allTags.contains('omniscript-elements'), 'Should include OmniScript element tags');
        Assert.isTrue(allTags.contains('dataraptor-extract'), 'Should include DataRaptor tags');
        Assert.isTrue(allTags.contains('integration-procedures'), 'Should include integration tags');
        Assert.isTrue(allTags.contains('formula-expressions'), 'Should include expression tags');
        Assert.isTrue(allTags.contains('business-requirements'), 'Should include solutioning tags');
    }
    
    /**
     * @description Test edge cases and error handling
     */
    @IsTest
    static void testEdgeCases() {
        // Test null/empty inputs
        Assert.areEqual(0, QuestionCategorization.getTopicWeight(null, 'FlexCards'), 
            'Null certification track should return 0');
        Assert.areEqual(0, QuestionCategorization.getTopicWeight('Consultant', null), 
            'Null topic should return 0');
        
        // Test empty string inputs
        Assert.areEqual(0, QuestionCategorization.getTopicWeight('', 'FlexCards'), 
            'Empty certification track should return 0');
        Assert.areEqual(0, QuestionCategorization.getTopicWeight('Consultant', ''), 
            'Empty topic should return 0');
        
        // Test case sensitivity
        Assert.areEqual(0, QuestionCategorization.getTopicWeight('consultant', 'FlexCards'), 
            'Lowercase certification track should return 0 (case sensitive)');
        Assert.areEqual(0, QuestionCategorization.getTopicWeight('Consultant', 'flexcards'), 
            'Lowercase topic should return 0 (case sensitive)');
        
        // Test getValidTopics with null/empty
        Set<String> nullTopics = QuestionCategorization.getValidTopics(null);
        Assert.areEqual(0, nullTopics.size(), 'Null certification track should return empty set');
        
        Set<String> emptyTopics = QuestionCategorization.getValidTopics('');
        Assert.areEqual(0, emptyTopics.size(), 'Empty certification track should return empty set');
    }
}