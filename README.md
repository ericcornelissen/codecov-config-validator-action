# Codecov Config Validator Action

A GitHub action to validate [Codecov] configuration files.

## Usage

```yml
- uses: actions/checkout@v3
- uses: ericcornelissen/codecov-config-validator-action@v1
  with:
    # Provide a path to the location of the Codecov configuration file.
    #
    # Default: ".github/codecov.yml"
    # Required: false
    file: path/to/codecov.yml
```

## Outputs

_See the [steps context] documentation for how to use output values._

- `status-code`: The HTTP status code returned by the Codecov API.

## Permissions

This Action requires no [permissions].

## License

This project is licensed under the Mozilla Public License 2.0, see [LICENSE] for
the full license text.

---

Please [open an issue] if you found a mistake or if you have a suggestion for
how to improve the documentation.

[codecov]: https://codecov.io/
[license]: ./LICENSE
[open an issue]: https://github.com/ericcornelissen/codecov-config-validator-action/issues/new?labels=documentation
[permissions]: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#permissions
[steps context]: https://docs.github.com/en/actions/learn-github-actions/contexts#steps-context
