# -*- encoding: utf-8 -*-
# stub: pbkdf2-ruby 0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "pbkdf2-ruby".freeze
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Sam Quigley".freeze]
  s.date = "2014-03-04"
  s.description = "This implementation conforms to RFC 2898, and has been tested using the test vectors in Appendix B of RFC 3962. Note, however, that while those specifications use HMAC-SHA-1, this implementation defaults to HMAC-SHA-256. (SHA-256 provides a longer bit length. In addition, NIST has stated that SHA-1 should be phased out due to concerns over recent cryptanalytic attacks.)".freeze
  s.email = "quigley@emerose.com".freeze
  s.extra_rdoc_files = ["LICENSE.TXT".freeze, "README.markdown".freeze]
  s.files = ["LICENSE.TXT".freeze, "README.markdown".freeze]
  s.homepage = "http://github.com/emerose/pbkdf2-ruby".freeze
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Password-Based Key Derivation Function 2 - PBKDF2".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>.freeze, [">= 1.2.9"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 2.4.2"])
    else
      s.add_dependency(%q<rspec>.freeze, [">= 1.2.9"])
      s.add_dependency(%q<rdoc>.freeze, [">= 2.4.2"])
    end
  else
    s.add_dependency(%q<rspec>.freeze, [">= 1.2.9"])
    s.add_dependency(%q<rdoc>.freeze, [">= 2.4.2"])
  end
end
