# ABPageFetcher

ABPageFetcher is a Ruby library that simplifies fetching paginated data from Maxio Advanced Billing API. It handles pagination transparently and supports concurrent requests to improve performance.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ab_page_fetcher', git: 'https://github.com/imlukedewitt/ABPageFetcher'
```

And then execute:

```bash
$ bundle install
```

## Usage

### Basic Example

```ruby
require 'ab_page_fetcher'
include ABPageFetcher

# Set up your credentials
credentials = {
  api_key: 'your_api_key',
  subdomain: 'your_subdomain',
  domain: 'chargify.com'
}

# Fetch all customers
customers = fetch_paginated_data(
  '/customers.json',
  credentials
)

puts "Fetched #{customers.length} customers"
```

### Advanced Usage

```ruby
# Fetch with custom parameters and data extraction
subscriptions = fetch_paginated_data(
  '/invoices.json',
  credentials,
  per_page: 100,                                 # Items per page
  batch_size: 10,                                # Concurrent requests
  params: { state: 'active' },                   # Additional query parameters
  data_extractor: ->(json) { json['invoices'] }  # Extract specific data from the response
)
```

## Configuration

### Logging

You can configure the logger to control output verbosity:

```ruby
# Use default logger with INFO level
ABPageFetcher.logger

# Set custom logger
custom_logger = Logger.new('ab_fetcher.log')
custom_logger.level = Logger::DEBUG
ABPageFetcher.configure_logger(custom_logger)
```

## API Reference

### `fetch_paginated_data(endpoint, credentials, options)`

Fetches and combines paginated data from an API endpoint.

**Parameters:**

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `endpoint` | String | The API endpoint to fetch from | |
| `credentials` | Hash | API credentials with `:api_key`, `:subdomain`, and `:domain` | |
| `per_page` | Integer | Number of items per page | 200 |
| `batch_size` | Integer | Number of concurrent requests | 20 |
| `params` | Hash | Additional query parameters | {} |
| `data_extractor` | Proc | Lambda to extract data from response | `->(json) { json }` |

**Returns:**

An array containing the combined results from all pages.

## Error Handling

The library handles common HTTP errors and timeouts, logging appropriate messages:
- Request timeouts
- Failed HTTP responses
- Network errors

Error messages are sent to the configured logger.

## License

This project is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
