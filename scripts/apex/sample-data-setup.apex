// Sample Data Setup Script for OmniStudio Training Platform
// Execute this script in Anonymous Apex to create initial test data

System.debug('Starting OmniStudio Training Platform sample data setup...');

try {
    // Create sample questions for Consultant track
    List<Question__c> consultantQuestions = new List<Question__c>();
    
    consultantQuestions.add(new Question__c(
        Topic__c = 'FlexCards',
        CertificationTrack__c = 'Consultant',
        Difficulty__c = 2,
        QuestionType__c = 'MultipleChoice',
        Active__c = true,
        QuestionText__c = 'What is the primary purpose of FlexCards in OmniStudio?',
        CorrectAnswer__c = 'A',
        OptionA__c = 'Display dynamic data in a responsive card format',
        OptionB__c = 'Process complex business logic',
        OptionC__c = 'Handle data transformations',
        OptionD__c = 'Manage user authentication',
        Explanation__c = 'FlexCards are designed to display dynamic data in responsive, interactive card formats.',
        UsageCount__c = 0
    ));
    
    consultantQuestions.add(new Question__c(
        Topic__c = 'OmniScripts',
        CertificationTrack__c = 'Consultant',
        Difficulty__c = 1,
        QuestionType__c = 'Scenario',
        Active__c = true,
        QuestionText__c = 'In which scenario would you use an OmniScript over a standard Lightning Flow?',
        CorrectAnswer__c = 'B',
        OptionA__c = 'Simple data entry forms',
        OptionB__c = 'Complex multi-step processes with dynamic UI',
        OptionC__c = 'Basic record updates',
        OptionD__c = 'Email notifications',
        Explanation__c = 'OmniScripts excel at complex, multi-step processes with conditional logic and dynamic user interfaces.',
        UsageCount__c = 0
    ));
    
    // Create sample questions for Developer track
    List<Question__c> developerQuestions = new List<Question__c>();
    
    developerQuestions.add(new Question__c(
        Topic__c = 'DataRaptors',
        CertificationTrack__c = 'Developer',
        Difficulty__c = 3,
        QuestionType__c = 'Practical',
        Active__c = true,
        QuestionText__c = 'How would you optimize a DataRaptor Extract for better performance?',
        CorrectAnswer__c = 'C',
        OptionA__c = 'Use more fields in the extract',
        OptionB__c = 'Add more filter conditions',
        OptionC__c = 'Use Turbo Extract and implement caching',
        OptionD__c = 'Increase timeout values',
        Explanation__c = 'Turbo Extract DataRaptors with proper caching strategies provide optimal performance for data retrieval.',
        UsageCount__c = 0
    ));
    
    developerQuestions.add(new Question__c(
        Topic__c = 'IntegrationProcedures',
        CertificationTrack__c = 'Developer',
        Difficulty__c = 2,
        QuestionType__c = 'MultipleChoice',
        Active__c = true,
        QuestionText__c = 'What is the main advantage of using Integration Procedures?',
        CorrectAnswer__c = 'A',
        OptionA__c = 'Server-side processing with multiple data operations',
        OptionB__c = 'Client-side data validation',
        OptionC__c = 'User interface rendering',
        OptionD__c = 'Email template processing',
        Explanation__c = 'Integration Procedures provide powerful server-side processing capabilities for complex data operations.',
        UsageCount__c = 0
    ));
    
    // Insert all sample questions
    List<Question__c> allQuestions = new List<Question__c>();
    allQuestions.addAll(consultantQuestions);
    allQuestions.addAll(developerQuestions);
    
    insert allQuestions;
    
    System.debug('✅ Created ' + allQuestions.size() + ' sample questions');
    
    // Create a sample user profile
    User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    
    UserProfile__c sampleProfile = new UserProfile__c(
        User__c = currentUser.Id,
        CurrentDifficulty__c = 2,
        PreferredLearningStyle__c = 'Mixed',
        StudyHoursPerWeek__c = 10,
        CertificationGoals__c = 'Consultant'
    );
    
    insert sampleProfile;
    System.debug('✅ Created sample user profile');
    
    // Create some sample user answers to populate performance data
    List<UserAnswer__c> sampleAnswers = new List<UserAnswer__c>();
    
    for (Question__c q : [SELECT Id FROM Question__c LIMIT 4]) {
        sampleAnswers.add(new UserAnswer__c(
            User__c = currentUser.Id,
            Question__c = q.Id,
            IsCorrect__c = Math.random() > 0.3, // 70% correct rate
            ResponseTime__c = Integer.valueOf(Math.random() * 60 + 30), // 30-90 seconds
            AnsweredDate__c = DateTime.now().addDays(-Integer.valueOf(Math.random() * 7))
        ));
    }
    
    insert sampleAnswers;
    System.debug('✅ Created ' + sampleAnswers.size() + ' sample user answers');
    
    // Create performance summary
    UserPerformanceSummary__c performanceSummary = new UserPerformanceSummary__c(
        User__c = currentUser.Id,
        RecentAccuracyRate__c = 0.70,
        TotalQuestionsAnswered__c = sampleAnswers.size(),
        AverageResponseTime__c = 45,
        LastUpdated__c = DateTime.now()
    );
    
    insert performanceSummary;
    System.debug('✅ Created performance summary');
    
    System.debug('🎉 Sample data setup completed successfully!');
    
} catch (Exception e) {
    System.debug('❌ Error during sample data setup: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}