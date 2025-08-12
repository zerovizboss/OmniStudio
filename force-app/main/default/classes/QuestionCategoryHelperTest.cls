/**
 * @description Test class for QuestionCategoryHelper utility
 * @author Claude Code Assistant
 * @since User Story #15 - Question Categorization Framework
 * @version 1.0
 * 
 * Comprehensive test coverage for question categorization helper methods
 * and content analysis functionality.
 */
@IsTest
private class QuestionCategoryHelperTest {
    
    /**
     * @description Test data setup
     */
    @TestSetup
    static void setupTestData() {
        // Create sample questions for testing
        List<Question__c> questions = new List<Question__c>();
        
        questions.add(new Question__c(
            Topic__c = 'FlexCards',
            CertificationTrack__c = 'Consultant',
            Difficulty__c = 2,
            QuestionType__c = 'Multiple Choice',
            Active__c = true,
            QuestionText__c = 'What is the primary purpose of FlexCards in OmniStudio?',
            CorrectAnswer__c = 'A',
            OptionA__c = 'Display dynamic data in a responsive card format',
            OptionB__c = 'Process complex business logic',
            OptionC__c = 'Handle data transformations',
            OptionD__c = 'Manage user authentication',
            Explanation__c = 'FlexCards are designed to display dynamic data in responsive, interactive card formats.'
        ));
        
        questions.add(new Question__c(
            Topic__c = 'OmniScripts',
            CertificationTrack__c = 'Developer',
            Difficulty__c = 3,
            QuestionType__c = 'Scenario-based',
            Active__c = true,
            QuestionText__c = 'In a complex multi-step OmniScript scenario, how would you implement conditional logic?',
            CorrectAnswer__c = 'B',
            OptionA__c = 'Use static visibility rules',
            OptionB__c = 'Implement conditional visibility with formula expressions',
            OptionC__c = 'Hard-code the conditions',
            OptionD__c = 'Use external APIs',
            Explanation__c = 'OmniScripts support conditional logic through formula expressions and decision matrices.'
        ));
        
        questions.add(new Question__c(
            Topic__c = 'DataRaptors',
            CertificationTrack__c = 'Developer',
            Difficulty__c = 1,
            QuestionType__c = 'Multiple Choice',
            Active__c = true,
            QuestionText__c = 'What is a DataRaptor Extract used for?',
            CorrectAnswer__c = 'A',
            OptionA__c = 'Retrieving data from Salesforce objects',
            OptionB__c = 'Transforming data formats',
            OptionC__c = 'Loading data into external systems',
            OptionD__c = 'Deleting obsolete records',
            Explanation__c = 'DataRaptor Extract is used to retrieve data from Salesforce objects and format it for consumption.'
        ));
        
        insert questions;
    }
    
    /**
     * @description Test apply categorization to questions
     */
    @IsTest
    static void testApplyCategorization() {
        List<Question__c> questions = [SELECT Id FROM Question__c LIMIT 2];
        
        List<QuestionCategorization.QuestionCategory> categories = new List<QuestionCategorization.QuestionCategory>();
        
        // Create test categories
        Set<String> tags1 = new Set<String>{'flexcard-basics', 'flexcard-datasource'};
        categories.add(QuestionCategorization.createCategory(
            'Consultant',
            'FlexCards',
            'Data Binding',
            QuestionCategorization.DifficultyLevel.INTERMEDIATE,
            QuestionCategorization.QuestionType.MULTIPLE_CHOICE,
            tags1
        ));
        
        Set<String> tags2 = new Set<String>{'omniscript-elements', 'omniscript-conditional-logic'};
        categories.add(QuestionCategorization.createCategory(
            'Developer',
            'OmniScripts',
            'Conditional Logic',
            QuestionCategorization.DifficultyLevel.ADVANCED,
            QuestionCategorization.QuestionType.SCENARIO_BASED,
            tags2
        ));
        
        Test.startTest();
        QuestionCategoryHelper.applyCategorization(questions, categories);
        Test.stopTest();
        
        // Verify categorization was applied
        for (Integer i = 0; i < questions.size(); i++) {
            Question__c question = questions[i];
            QuestionCategorization.QuestionCategory category = categories[i];
            
            Assert.areEqual(category.certificationTrack, question.CertificationTrack__c, 
                'Certification track should be applied');
            Assert.areEqual(category.primaryTopic, question.Topic__c, 
                'Primary topic should be applied');
            Assert.areEqual(category.subTopic, question.SubTopic__c, 
                'Sub-topic should be applied');
            Assert.areEqual(QuestionCategorization.difficultyToInteger(category.difficulty), question.Difficulty__c, 
                'Difficulty should be applied');
            Assert.areEqual(category.topicWeight, question.TopicWeight__c, 
                'Topic weight should be applied');
            Assert.isNotNull(question.CategorizedDate__c, 
                'Categorized date should be set');
            Assert.isTrue(question.ContentTags__c.contains('flexcard-basics') || 
                         question.ContentTags__c.contains('omniscript-elements'), 
                'Content tags should be applied');
        }
    }
    
    /**
     * @description Test apply categorization with invalid inputs
     */
    @IsTest
    static void testApplyCategorizationInvalidInputs() {
        List<Question__c> questions = [SELECT Id FROM Question__c LIMIT 1];
        List<QuestionCategorization.QuestionCategory> categories = new List<QuestionCategorization.QuestionCategory>();
        
        Test.startTest();
        try {
            // Test with null questions
            QuestionCategoryHelper.applyCategorization(null, categories);
            Assert.fail('Should throw IllegalArgumentException for null questions');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('must not be null'), 
                'Error message should mention null parameter');
        }
        
        try {
            // Test with mismatched sizes
            QuestionCategoryHelper.applyCategorization(questions, categories);
            Assert.fail('Should throw IllegalArgumentException for mismatched sizes');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('same size'), 
                'Error message should mention size mismatch');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test auto-categorization of questions
     */
    @IsTest
    static void testAutoCategorizaQuestions() {
        List<Question__c> questions = [
            SELECT Id, QuestionText__c, Explanation__c, Difficulty__c, 
                   QuestionType__c, CertificationTrack__c
            FROM Question__c
        ];
        
        Test.startTest();
        List<QuestionCategorization.QuestionCategory> categories = 
            QuestionCategoryHelper.autoCategorizaQuestions(questions);
        Test.stopTest();
        
        Assert.areEqual(questions.size(), categories.size(), 
            'Should return same number of categories as questions');
        
        for (QuestionCategorization.QuestionCategory category : categories) {
            Assert.isNotNull(category.certificationTrack, 'Certification track should be set');
            Assert.isNotNull(category.primaryTopic, 'Primary topic should be set');
            Assert.isNotNull(category.difficulty, 'Difficulty should be set');
            Assert.isNotNull(category.questionType, 'Question type should be set');
            Assert.isNotNull(category.tags, 'Tags should be set');
        }
    }
    
    /**
     * @description Test primary topic analysis
     */
    @IsTest
    static void testPrimaryTopicAnalysis() {
        Question__c flexCardQuestion = new Question__c(
            QuestionText__c = 'How do you configure FlexCard data source and conditional visibility?',
            CertificationTrack__c = 'Consultant',
            Explanation__c = 'FlexCards use data sources to populate card content dynamically.'
        );
        
        Question__c omniScriptQuestion = new Question__c(
            QuestionText__c = 'What OmniScript elements are used for data JSON manipulation?',
            CertificationTrack__c = 'Developer',
            Explanation__c = 'OmniScript elements can manipulate data JSON through various step types.'
        );
        
        Question__c dataRaptorQuestion = new Question__c(
            QuestionText__c = 'How do you optimize DataRaptor Extract performance with Turbo Extract?',
            CertificationTrack__c = 'Developer',
            Explanation__c = 'DataRaptor Turbo Extract provides enhanced performance for data retrieval.'
        );
        
        List<Question__c> questions = new List<Question__c>{flexCardQuestion, omniScriptQuestion, dataRaptorQuestion};
        
        Test.startTest();
        List<QuestionCategorization.QuestionCategory> categories = 
            QuestionCategoryHelper.autoCategorizaQuestions(questions);
        Test.stopTest();
        
        Assert.areEqual('FlexCards', categories[0].primaryTopic, 
            'Should identify FlexCards topic from content');
        Assert.areEqual('OmniScripts', categories[1].primaryTopic, 
            'Should identify OmniScripts topic from content');
        Assert.areEqual('DataRaptors', categories[2].primaryTopic, 
            'Should identify DataRaptors topic from content');
    }
    
    /**
     * @description Test difficulty analysis
     */
    @IsTest
    static void testDifficultyAnalysis() {
        Question__c beginnerQuestion = new Question__c(
            QuestionText__c = 'What is the basic definition of FlexCards?',
            CertificationTrack__c = 'Consultant',
            Explanation__c = 'FlexCards are a fundamental component for displaying data.'
        );
        
        Question__c intermediateQuestion = new Question__c(
            QuestionText__c = 'How do you configure FlexCard data source for practical use cases?',
            CertificationTrack__c = 'Consultant',
            Explanation__c = 'Configuration involves setting up data sources and implementing custom logic.'
        );
        
        Question__c advancedQuestion = new Question__c(
            QuestionText__c = 'What are the architecture and performance optimization best practices for enterprise FlexCard deployment?',
            CertificationTrack__c = 'Consultant',
            Explanation__c = 'Advanced enterprise deployment requires complex architecture considerations and security optimization.'
        );
        
        List<Question__c> questions = new List<Question__c>{beginnerQuestion, intermediateQuestion, advancedQuestion};
        
        Test.startTest();
        List<QuestionCategorization.QuestionCategory> categories = 
            QuestionCategoryHelper.autoCategorizaQuestions(questions);
        Test.stopTest();
        
        Assert.areEqual(QuestionCategorization.DifficultyLevel.BEGINNER, categories[0].difficulty, 
            'Should identify beginner difficulty from content');
        Assert.areEqual(QuestionCategorization.DifficultyLevel.INTERMEDIATE, categories[1].difficulty, 
            'Should identify intermediate difficulty from content');
        Assert.areEqual(QuestionCategorization.DifficultyLevel.ADVANCED, categories[2].difficulty, 
            'Should identify advanced difficulty from content');
    }
    
    /**
     * @description Test question type analysis
     */
    @IsTest
    static void testQuestionTypeAnalysis() {
        Question__c multipleChoiceQuestion = new Question__c(
            QuestionText__c = 'Which option best describes FlexCards?',
            QuestionType__c = 'Multiple Choice'
        );
        
        Question__c multipleSelectQuestion = new Question__c(
            QuestionText__c = 'Select all valid OmniScript element types from the following options.',
            QuestionType__c = 'Multiple Select'
        );
        
        Question__c scenarioQuestion = new Question__c(
            QuestionText__c = 'In a complex scenario where you need to implement a multi-step customer onboarding process with conditional logic and data integration, how would you approach this using OmniStudio components?',
            QuestionType__c = 'Scenario-based'
        );
        
        Question__c practicalQuestion = new Question__c(
            QuestionText__c = 'Implement a DataRaptor Extract to retrieve account information with related contacts.',
            QuestionType__c = 'Practical'
        );
        
        List<Question__c> questions = new List<Question__c>{
            multipleChoiceQuestion, multipleSelectQuestion, scenarioQuestion, practicalQuestion
        };
        
        Test.startTest();
        List<QuestionCategorization.QuestionCategory> categories = 
            QuestionCategoryHelper.autoCategorizaQuestions(questions);
        Test.stopTest();
        
        Assert.areEqual(QuestionCategorization.QuestionType.MULTIPLE_CHOICE, categories[0].questionType, 
            'Should identify multiple choice type');
        Assert.areEqual(QuestionCategorization.QuestionType.MULTIPLE_SELECT, categories[1].questionType, 
            'Should identify multiple select type');
        Assert.areEqual(QuestionCategorization.QuestionType.SCENARIO_BASED, categories[2].questionType, 
            'Should identify scenario-based type');
        Assert.areEqual(QuestionCategorization.QuestionType.PRACTICAL, categories[3].questionType, 
            'Should identify practical type');
    }
    
    /**
     * @description Test content tag generation
     */
    @IsTest
    static void testContentTagGeneration() {
        Question__c flexCardQuestion = new Question__c(
            QuestionText__c = 'How do you implement FlexCard conditional visibility with data source configuration?',
            CertificationTrack__c = 'Consultant',
            Explanation__c = 'FlexCard conditional visibility uses data source binding and formula expressions.'
        );
        
        Test.startTest();
        List<QuestionCategorization.QuestionCategory> categories = 
            QuestionCategoryHelper.autoCategorizaQuestions(new List<Question__c>{flexCardQuestion});
        Test.stopTest();
        
        QuestionCategorization.QuestionCategory category = categories[0];
        Assert.isTrue(category.tags.size() > 0, 'Should generate content tags');
        
        // Check that tags are relevant to FlexCards
        Set<String> flexCardTags = QuestionCategorization.getTopicTags('FlexCards');
        Boolean hasRelevantTag = false;
        for (String tag : category.tags) {
            if (flexCardTags.contains(tag)) {
                hasRelevantTag = true;
                break;
            }
        }
        Assert.isTrue(hasRelevantTag, 'Should include relevant FlexCard tags');
    }
    
    /**
     * @description Test getting questions needing categorization
     */
    @IsTest
    static void testGetQuestionsNeedingCategorization() {
        Test.startTest();
        List<Question__c> consultantQuestions = 
            QuestionCategoryHelper.getQuestionsNeedingCategorization('Consultant');
        List<Question__c> developerQuestions = 
            QuestionCategoryHelper.getQuestionsNeedingCategorization('Developer');
        Test.stopTest();
        
        Assert.isTrue(consultantQuestions.size() > 0, 'Should find consultant questions needing categorization');
        Assert.isTrue(developerQuestions.size() > 0, 'Should find developer questions needing categorization');
        
        for (Question__c question : consultantQuestions) {
            Assert.areEqual('Consultant', question.CertificationTrack__c, 
                'Should only return consultant questions');
        }
        
        for (Question__c question : developerQuestions) {
            Assert.areEqual('Developer', question.CertificationTrack__c, 
                'Should only return developer questions');
        }
    }
    
    /**
     * @description Test topic distribution validation
     */
    @IsTest
    static void testValidateTopicDistribution() {
        List<Question__c> questions = [
            SELECT Id, Topic__c, CertificationTrack__c
            FROM Question__c
        ];
        
        Test.startTest();
        Map<String, Object> consultantResults = 
            QuestionCategoryHelper.validateTopicDistribution(questions, 'Consultant');
        Map<String, Object> developerResults = 
            QuestionCategoryHelper.validateTopicDistribution(questions, 'Developer');
        Test.stopTest();
        
        // Verify consultant results structure
        Assert.isTrue(consultantResults.containsKey('totalQuestions'), 
            'Should include total questions count');
        Assert.isTrue(consultantResults.containsKey('actualDistribution'), 
            'Should include actual distribution');
        Assert.isTrue(consultantResults.containsKey('actualPercentages'), 
            'Should include actual percentages');
        Assert.isTrue(consultantResults.containsKey('expectedPercentages'), 
            'Should include expected percentages');
        Assert.isTrue(consultantResults.containsKey('deviations'), 
            'Should include deviation analysis');
        
        // Verify developer results structure
        Assert.isTrue(developerResults.containsKey('totalQuestions'), 
            'Should include total questions count');
        Assert.isTrue(developerResults.containsKey('actualDistribution'), 
            'Should include actual distribution');
        
        // Verify expected percentages match framework
        Map<String, Decimal> consultantExpected = (Map<String, Decimal>) consultantResults.get('expectedPercentages');
        Assert.areEqual(27.0, consultantExpected.get('OmniScripts'), 
            'Should use correct consultant weights');
        
        Map<String, Decimal> developerExpected = (Map<String, Decimal>) developerResults.get('expectedPercentages');
        Assert.areEqual(20.0, developerExpected.get('DataRaptors'), 
            'Should use correct developer weights');
    }
    
    /**
     * @description Test edge cases and error handling
     */
    @IsTest
    static void testEdgeCases() {
        Test.startTest();
        
        // Test with empty question list
        List<Question__c> emptyQuestions = new List<Question__c>();
        List<QuestionCategorization.QuestionCategory> emptyCategoriles = 
            QuestionCategoryHelper.autoCategorizaQuestions(emptyQuestions);
        Assert.areEqual(0, emptyCategoriles.size(), 'Should handle empty question list');
        
        // Test with question having null/empty content
        Question__c emptyQuestion = new Question__c(
            CertificationTrack__c = 'Consultant'
        );
        List<QuestionCategorization.QuestionCategory> nullContentCategories = 
            QuestionCategoryHelper.autoCategorizaQuestions(new List<Question__c>{emptyQuestion});
        
        Assert.areEqual(1, nullContentCategories.size(), 'Should handle null content gracefully');
        Assert.isNotNull(nullContentCategories[0].primaryTopic, 'Should assign default topic');
        
        // Test topic distribution with empty list
        Map<String, Object> emptyDistribution = 
            QuestionCategoryHelper.validateTopicDistribution(emptyQuestions, 'Consultant');
        Assert.areEqual(0, emptyDistribution.get('totalQuestions'), 
            'Should handle empty question list in distribution');
        
        Test.stopTest();
    }
    
    /**
     * @description Test categorization with null tags
     */
    @IsTest
    static void testCategorizationWithNullTags() {
        List<Question__c> questions = [SELECT Id FROM Question__c LIMIT 1];
        
        List<QuestionCategorization.QuestionCategory> categories = new List<QuestionCategorization.QuestionCategory>();
        categories.add(QuestionCategorization.createCategory(
            'Consultant',
            'FlexCards',
            'Test',
            QuestionCategorization.DifficultyLevel.BEGINNER,
            QuestionCategorization.QuestionType.MULTIPLE_CHOICE,
            null // Null tags
        ));
        
        Test.startTest();
        QuestionCategoryHelper.applyCategorization(questions, categories);
        Test.stopTest();
        
        // Should handle null tags gracefully
        Assert.isNotNull(questions[0].CertificationTrack__c, 'Should set certification track');
        // ContentTags__c field should remain null/empty when no tags provided
    }
}