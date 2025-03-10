export default {
  moduleDirectories: ['node_modules', 'app/javascript'],
  moduleFileExtensions: ['js'],
  automock: false,
  resetMocks: true,
  cacheDirectory: '<rootDir>/.jest-cache',
  collectCoverage: true,
  coverageDirectory: 'coverage/frontend',
  coverageReporters: ['text', 'lcov'],
  collectCoverageFrom: [
    '<rootDir>/app/javascript/**/*.js',
    '!<rootDir>/app/javascript/scripts/govuk_assets_import.js'
  ],
  reporters: ['default'],
  transformIgnorePatterns: ['node_modules/*'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/app/javascript/$1'
  },
  roots: ['app/javascript'],
  testEnvironment: 'jsdom',
  testMatch: ['**/app/javascript/**/*.spec.js'],
  testEnvironmentOptions: {
    url: 'http://localhost/'
  },
  testPathIgnorePatterns: [],
  transform: {
    '^.+\\.jsx?$': 'esbuild-jest-transform'
  }
}
