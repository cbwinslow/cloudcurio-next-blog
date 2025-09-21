# Agent Recommendations for CloudCurio

This document provides guidance on when and how to use specialized agents to work with the CloudCurio codebase effectively.

## General-Purpose Agent

Use the general-purpose agent for:
- Researching specific parts of the codebase
- Searching for code patterns or implementations
- Understanding how different components interact
- Finding examples of similar functionality

Example usage:
```
Find all implementations of the review worker functionality in the codebase
```

## Code Review Agent

Use after implementing significant changes to:
- Review new code for best practices
- Check for potential bugs or security issues
- Ensure consistency with existing code style
- Validate that new features follow established patterns

## Testing Agent

Use when working with tests to:
- Generate new test cases for features
- Identify gaps in test coverage
- Suggest improvements to existing tests
- Help debug failing tests

## Documentation Agent

Use when updating documentation to:
- Ensure technical accuracy
- Improve clarity and readability
- Maintain consistency across documents
- Suggest missing documentation areas

## Security Agent

Use when working on security-sensitive features to:
- Review authentication and authorization logic
- Check for potential vulnerabilities
- Ensure compliance with security best practices
- Validate secure handling of sensitive data

## Performance Agent

Use when optimizing the application to:
- Identify performance bottlenecks
- Suggest caching strategies
- Optimize database queries
- Review worker efficiency

## Deployment Agent

Use when working on deployment-related tasks to:
- Review container configurations
- Check systemd unit files
- Validate installation scripts
- Ensure proper environment setup

## When to Use Agents

1. **Before major changes**: Use the general-purpose agent to understand existing implementations
2. **During implementation**: Use specialized agents for specific concerns (security, performance)
3. **After implementation**: Use code review and testing agents to validate changes
4. **For documentation**: Use the documentation agent to maintain accurate docs