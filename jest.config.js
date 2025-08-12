const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');

module.exports = {
    ...jestConfig,
    modulePathIgnorePatterns: ['<rootDir>/.localdevserver'],
    testMatch: ['**/__tests__/**/*.test.js'],
    collectCoverageFrom: [
        '**/lwc/**/*.js',
        '!**/__tests__/**',
        '!**/node_modules/**'
    ],
    coverageReporters: ['text', 'html', 'json-summary'],
    coverageThreshold: {
        global: {
            branches: 80,
            functions: 80,
            lines: 80,
            statements: 80
        }
    },
    testEnvironment: 'jsdom',
    testTimeout: 10000,
    setupFilesAfterEnv: ['<rootDir>/jest.setup.js']
};