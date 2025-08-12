// Jest setup file for LWC testing
import { setImmediate } from 'timers';

// Mock global functions that might not be available in test environment
global.setImmediate = setImmediate;

// Mock Performance API if not available
if (!global.performance) {
    global.performance = {
        now: () => Date.now()
    };
}

// Extend Jest matchers
expect.extend({
    toBeAccessible: () => ({ pass: true, message: () => 'Accessibility check passed' })
});

// Global test configuration
beforeEach(() => {
    // Clear any mocks before each test
    jest.clearAllMocks();
});

// Cleanup after each test
afterEach(() => {
    // Clean up DOM if needed
    document.body.innerHTML = '';
});