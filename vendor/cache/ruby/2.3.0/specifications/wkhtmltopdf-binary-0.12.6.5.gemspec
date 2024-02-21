# -*- encoding: utf-8 -*-
# stub: wkhtmltopdf-binary 0.12.6.5 ruby .

Gem::Specification.new do |s|
  s.name = "wkhtmltopdf-binary".freeze
  s.version = "0.12.6.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = [".".freeze]
  s.authors = ["Zakir Durumeric".freeze]
  s.date = "2020-10-08"
  s.email = "zakird@gmail.com".freeze
  s.executables = ["wkhtmltopdf".freeze]
  s.files = ["bin/wkhtmltopdf".freeze]
  s.licenses = ["Apache-2.0".freeze]
  s.rubygems_version = "3.0.8".freeze
  s.summary = "Provides binaries for WKHTMLTOPDF project in an easily accessible package.".freeze

  s.installed_by_version = "3.0.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
    else
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
  end
end
