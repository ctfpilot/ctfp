# Contributing to CTF Pilot

Thank you for considering contributing to CTF Pilot!  
We appreciate your interest in helping us enhance our platform and tools.

## Contribution Guidelines

We welcome contributions from the community to enhance CTF Pilot.  
To ensure a smooth and efficient contribution process, please adhere to the following guidelines:

### Reporting Issues

If you encounter a bug, have a suggestion, or wish to discuss improvements, please open an issue in the repository That is appropriate for the bug.  
When reporting issues, provide detailed information, steps to reproduce, and, if possible, screenshots or logs to help us understand and resolve the problem efficiently.

### Code Contributions

1. **Fork the Repository:** Fork the CTF Pilot repository you want to contribute code to, to your GitHub account.
2. **Branching:** Create a new branch from the `develop` branch for your changes. Use descriptive branch names that reflect the changes made. If you are working on an issue, reference the issue number in your branch name (e.g., `feature/123`). See the [Branch Naming](#branch-naming) section for more information.
3. **Commit Guidelines:** Follow our [Versioning Guidelines](#versioning-guidelines) to use commit messages that bump the versioning. We recommend also doing this in squash commits.  
For general commits, follow descriptive commit messages that succinctly describe the changes made.  
Reference any related issues or pull requests in your commits using appropriate keywords (e.g., "Fix #123").
4. **Code Style:** Maintain consistent code style and formatting as per the existing project standards.
5. **Testing:** Ensure new code is accompanied by relevant tests where applicable.
6. **Pull Requests:** Submit a pull request against the `develop` branch. Provide a clear description of your changes, ensuring it aligns with the outlined issue or feature request.
7. **Accept CLA:** If prompted, please accept the Contributor License Agreement (CLA) to formalize your contribution. Read more about the CLA in the [CLA repository](https://github.com/ctfpilot/cla).  
We require all contributors to sign the CLA to ensure that contributions can be legally incorporated into the project.
8. **Review Process:** Be responsive to feedback during the review process. Address any requested changes to facilitate the merging of your contribution.
9. **Merging:** Once approved, your changes will be merged into the `develop` branch and subsequently into the `main` branch for release.
Code merging is done at the discretion of the maintainers. They hold the full right to accept or reject any contributions.

### Versioning Guidelines

CTF Pilot adheres to [semantic versioning](https://semver.org/) principles:

- **MAJOR version** for incompatible changes,
- **MINOR version** for backward-compatible functionality additions, and
- **PATCH version** for backward-compatible bug fixes.

### Automatic Versioning with semantic-release

CTF Pilot uses [semantic-release](https://github.com/semantic-release/semantic-release) for versioning and releases. Upon merging changes into the `main` branch, semantic-release generates new versions and publishes them. Merges to `develop` creates pre-releases.

Commit messages follow this format for automated versioning: `<type>(<category>): <message>`

#### Commit Types

Commit types are:

- `fix` - For bug fixes or minor changes. Bumps the PATCH version.
- `feat` - For new features. Bumps the MINOR version.
- `perf` - Major breaking changes. Bumps the MAJOR version.

*These are the main types, but there are others, such as `chore`, `docs`, `test`, etc. These will not trigger a version bump.*
*For more information, see [semantic-release](https://github.com/semantic-release/semantic-release).*

***Types are case-sensitive.***

#### Categories

For categories, we don't have a full list, but this is a core list, of example categories:

- `core` - For core changes.
- `format` - For format changes.
- `docs` - For documentation changes.
- `misc` - For miscellaneous changes.
- `infra` - For infrastructure changes.

We suggest, trying to use a category that will fit, but if you can't find one, you can use `misc` or completely omit it (e.g., `feat: message`).

### Branch naming

When developing, we try to follow some guidelines for branch naming, when possible.

The main branches are:

- `main` - For stable releases.
- `develop` - For pre-releases.

For other branches, try the following naming convention:

- `feature/<issue>/<feature-name>` - For new features.
- `fix/<issue>/<fix-name>` - For bug fixes.
- `chore/<issue>/<chore-name>` - For miscellaneous changes.
- `docs/<issue>/<docs-name>` - For documentation changes.
- `test/<issue>/<test-name>` - For test changes.
- `refactor/<issue>/<refactor-name>` - For refactoring changes.
- `ci/<issue>/<ci-name>` - For CI/CD changes.

*`/<issue>` can be omitted if there is no related issue.*

### Code of Conduct

Review our [Code of Conduct](CODE_OF_CONDUCT.md) to understand the expected behavior within our community.

### Need Help?

If you have any questions or need clarification, try opening an issue in the repository. We will be happy to help!  
We will try to respond as quickly as possible, but please be patient.
