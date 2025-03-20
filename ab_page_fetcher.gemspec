Gem::Specification.new do |s|
  s.name        = "ab_page_fetcher"
  s.version     = "0.0.2"
  s.liscense    = "MIT"
  s.summary     = "Fetches paginated data from Maxio Advanced Billing"
  s.authors     = ["Luke DeWitt"]
  s.files       = ["lib/ab_page_fetcher.rb"]
  s.add_dependency 'typhoeus', '~> 1.4'
end