module.exports = {
  moduleDirectories: ['node_modules', 'app/webpacker'],
  moduleFileExtensions: ['js'],
  automock: false,
  resetMocks: true,
  cacheDirectory: '<rootDir>/.jest-cache',
  collectCoverage: true,
  coverageDirectory: 'coverage/frontend',
  coverageReporters: ['text', 'lcov'],
  collectCoverageFrom: [
    '<rootDir>/app/webpacker/**/*.js',
    '!<rootDir>/app/webpacker/packs/*.js',
    '!<rootDir>/app/webpacker/scripts/govuk_assets_import.js',
    '!<rootDir>/app/webpacker/scripts/components.js'
  ],
  reporters: ['default'],
  transformIgnorePatterns: ['node_modules/*'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/app/webpacker/$1'
  },
  roots: ['app/webpacker'],
  testMatch: ['**/app/webpacker/**/*.spec.js'],
  testURL: 'http://localhost/',
  testPathIgnorePatterns: []
}
