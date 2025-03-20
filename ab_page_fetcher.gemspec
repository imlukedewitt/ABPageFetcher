Gem::Specification.new do |s|
  s.name        = "ab_page_fetcher"
  s.version     = "0.0.0"
  s.summary     = "Fetches paginated data from Maxio Advanced Billing"
  s.authors     = ["Luke DeWitt"]
  s.files       = ["lib/ab_page_fetcher.rb"]
  s.add_runtime_dependency "typhoeus"
  s.add_runtime_dependency "dotenv"
end