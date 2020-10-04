# Yts

YTS is a utility tool for converting YARD documents to Swagger's schema.

## Installation

```
gem specific_install -l 'https://github.com/k-motoyan/yts'
```

## Initialization

```
yts init
```

## Make skelton

generate endpoint.

```
yts gen -t endpoint -n search
```

generate entity.

```
yts gen -t entity -n search_response
```

## Output swagger

```
yts convert -t [/path/to/yts-dir]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/yts. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/yts/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Yts project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/yts/blob/master/CODE_OF_CONDUCT.md).
