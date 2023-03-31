require './lib/aion_s3/version'

Gem::Specification.new do |spec|
  spec.name          = 'aion-s3'
  spec.version       = AionS3::VERSION
  spec.date          = '2019-11-07'
  spec.summary       = 'Aion S3'
  spec.description   = 'A tool for compressing, encrypting and uploading files to AWS S3'
  spec.authors       = ['Michael Andersen']
  spec.email         = 'michael@aion.dk'

  spec.require_paths = ['lib']
  spec.files         = Dir['lib/**/*.rb']

  spec.homepage      = 'https://github.com/aion-dk/aion-s3'
  spec.license       = 'MIT'

  spec.add_dependency 'aws-sdk-s3', '~> 1'

  spec.add_development_dependency 'bundler', '~> 2.2.10'
  spec.add_development_dependency 'uri', '~> 0.12.1'
  spec.add_development_dependency 'rake', '~> 12.3.1'
  spec.add_development_dependency 'minitest', '~> 5.11.3'
end
