<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->

# Codecov Config Validator Action

A GitHub action to validate [Codecov] configuration files.

## Usage

```yml
- uses: actions/checkout@v4
- uses: ericcornelissen/codecov-config-validator-action@v1
  with:
    # Provide a path to the location of the Codecov configuration file.
    #
    # Default: ".github/codecov.yml"
    # Required: false
    file: path/to/codecov.yml
```

### Recommended Workflow

This workflow is recommended because it minimizes how often the Codecov config
is validated.

```yml
# .github/workflows/config-codecov.yml

name: Codecov Config
on:
  pull_request:
    paths:
      - .github/workflows/config-codecov.yml
      - .github/codecov.yml
  push:
    branches:
      - main # default branch
    paths:
      - .github/workflows/config-codecov.yml
      - .github/codecov.yml

permissions: read-all

jobs:
  validate:
    name: Validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ericcornelissen/codecov-config-validator-action@v1
        with:
          file: .github/codecov.yml
```

## Outputs

_See the [steps context] documentation for how to use output values._

- `status-code`: The HTTP status code returned by the Codecov API.

## Security

### Permissions

This Action requires no [permissions].

### Network

This Action requires network access to the endpoint `codecov.io:443`.

## License

All source code is licensed under the Mozilla Public License 2.0 license, see
[LICENSE] for the full license text. The contents of documentation is licensed
under [CC BY-SA 4.0].

---

Please [open an issue] if you found a mistake or if you have a suggestion for
how to improve the documentation.

[cc by-sa 4.0]: https://creativecommons.org/licenses/by-sa/4.0/
[codecov]: https://codecov.io/
[license]: ./LICENSE
[open an issue]: https://github.com/ericcornelissen/codecov-config-validator-action/issues/new?labels=documentation
[permissions]: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#permissions
[steps context]: https://docs.github.com/en/actions/learn-github-actions/contexts#steps-context
