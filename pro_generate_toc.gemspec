Gem::Specification.new do |spec|
  spec.name          = 'pro_generate_toc'
  spec.version       = '1.0.2'
  spec.summary       = 'Jekyll Table of Contents plugin'
  spec.description   = 'Jekyll (Ruby static website generator) plugin which generates a Table of Contents for the page.'
  spec.authors       = %w[Ryan]
  spec.email         = 'sonnb@mageplaza.com'
  spec.homepage      = 'https://mageplaza.com'
  spec.license       = 'Ryan'
  spec.require_paths = ['lib']

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

   spec.files         = `git ls-files -z`.split("\x0")
end
