# -*- encoding: utf-8 -*-
# stub: rmega 0.2.7 ruby lib

Gem::Specification.new do |s|
  s.name = "rmega".freeze
  s.version = "0.2.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["topac".freeze]
  s.date = "2020-06-23"
  s.description = "mega.nz ruby api".freeze
  s.email = ["topac@users.noreply.github.com".freeze]
  s.executables = ["rmega-dl".freeze, "rmega-up".freeze]
  s.files = ["bin/rmega-dl".freeze, "bin/rmega-up".freeze]
  s.homepage = "https://github.com/topac/rmega".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3".freeze)
  s.rubygems_version = "3.0.8".freeze
  s.summary = "mega.nz ruby api".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<pbkdf2-ruby>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<pbkdf2-ruby>.freeze, [">= 0"])
      s.add_dependency(%q<pry>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<pbkdf2-ruby>.freeze, [">= 0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
