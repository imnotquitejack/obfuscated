Gem::Specification.new do |s|
  s.name        = 'obfuscated'
  s.version     = '0.1.6'
  s.date        = '2012-05-10'
  s.summary     = "Primary Key Obfuscation"
  s.description = "Obfuscate your autoincrementing primary key ids."
  s.authors     = ["Jon Collier"]
  s.email       = "github@joncollier.com"
  s.files       = ["lib/obfuscated.rb"]
  s.homepage    = "https://github.com/imnotquitejack/obfuscated"
  s.add_dependency 'activerecord', '>= 2.3.0'
end