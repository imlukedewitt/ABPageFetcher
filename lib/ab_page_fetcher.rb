# frozen_string_literal: true

require 'dotenv'
require 'json'
require 'typhoeus'

# Fetches paginated data from Maxio Advanced Billing
module ABPageFetcher
  def fetch(
    endpoint,
    credentials,
    per_page: 200,
    batch_size: 20,
    params: {},
    data_extractor: ->(json) { json }
  )
    page = 1
    all_data = []
    hydra = configure_hydra(batch_size)

    loop do
      stop = process_batch(
        endpoint: endpoint,
        credentials: credentials,
        page: page,
        hydra: hydra,
        all_data: all_data,
        params: params,
        per_page: per_page,
        batch_size: batch_size,
        data_extractor: data_extractor
      )

      break if stop

      page += batch_size
    end

    all_data
  end

  private

  def build_http_options(credentials)
    {
      method: 'get',
      userpwd: "#{credentials[:api_key]}:x",
      headers: { ContentType: 'Application/JSON' }
    }
  end

  def root_url(credentials)
    "https://#{credentials[:subdomain]}.#{credentials[:domain]}"
  end

  def configure_hydra(batch_size)
    Typhoeus::Hydra.new(max_concurrency: batch_size)
  end

  def process_batch(endpoint:, credentials:, page:, hydra:, all_data:, params:, per_page:, batch_size:, data_extractor:)
    stop = false

    batch_size.times do |i|
      request = create_paginated_request(
        endpoint: endpoint,
        page: page + i,
        credentials: credentials,
        base_params: params.merge(per_page: per_page)
      )

      request.on_complete do |response|
        stop = handle_paginated_response(response, all_data, per_page, data_extractor)
      end

      hydra.queue(request)
    end

    hydra.run
    stop
  end

  def create_paginated_request(endpoint:, page:, credentials:, base_params:)
    http_options = build_http_options(credentials)
    http_options[:params] = base_params.merge(page: page)
    Typhoeus::Request.new("#{root_url(credentials)}#{endpoint}", http_options)
  end

  def handle_paginated_response(response, all_data, per_page, data_extractor)
    if response.success?
      resp_json = JSON.parse(response.body)
      current_data = data_extractor.call(resp_json)
      all_data.concat(current_data)
      return current_data.count < per_page
    end

    if response.timed_out?
      puts 'Request timed out'
    elsif response.code.zero?
      puts "No HTTP response: #{response.return_code} - #{response.return_message}"
    else
      puts "HTTP request failed: #{response.code}"
    end
    false
  end
end
