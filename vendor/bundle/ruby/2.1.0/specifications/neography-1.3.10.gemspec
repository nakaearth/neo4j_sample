# -*- encoding: utf-8 -*-
# stub: neography 1.3.10 ruby lib

Gem::Specification.new do |s|
  s.name = "neography"
  s.version = "1.3.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Max De Marzi"]
  s.date = "2014-02-19"
  s.description = "A Ruby wrapper to the Neo4j Rest API see http://docs.neo4j.org/chunked/stable/rest-api.html for more details."
  s.email = "maxdemarzi@gmail.com"
  s.homepage = "http://rubygems.org/gems/neography"
  s.licenses = ["MIT"]
  s.rubyforge_project = "neography"
  s.rubygems_version = "2.2.0.rc.1"
  s.summary = "ruby wrapper to Neo4j Rest API"

  s.installed_by_version = "2.2.0.rc.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 2.11"])
      s.add_development_dependency(%q<net-http-spy>, ["= 0.2.1"])
      s.add_development_dependency(%q<coveralls>, [">= 0"])
      s.add_runtime_dependency(%q<httpclient>, [">= 2.3.3"])
      s.add_runtime_dependency(%q<json>, [">= 1.7.7"])
      s.add_runtime_dependency(%q<os>, [">= 0.9.6"])
      s.add_runtime_dependency(%q<rubyzip>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<multi_json>, [">= 1.3.2"])
      s.add_runtime_dependency(%q<rake>, [">= 0.8.7"])
    else
      s.add_dependency(%q<rspec>, [">= 2.11"])
      s.add_dependency(%q<net-http-spy>, ["= 0.2.1"])
      s.add_dependency(%q<coveralls>, [">= 0"])
      s.add_dependency(%q<httpclient>, [">= 2.3.3"])
      s.add_dependency(%q<json>, [">= 1.7.7"])
      s.add_dependency(%q<os>, [">= 0.9.6"])
      s.add_dependency(%q<rubyzip>, [">= 1.0.0"])
      s.add_dependency(%q<multi_json>, [">= 1.3.2"])
      s.add_dependency(%q<rake>, [">= 0.8.7"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 2.11"])
    s.add_dependency(%q<net-http-spy>, ["= 0.2.1"])
    s.add_dependency(%q<coveralls>, [">= 0"])
    s.add_dependency(%q<httpclient>, [">= 2.3.3"])
    s.add_dependency(%q<json>, [">= 1.7.7"])
    s.add_dependency(%q<os>, [">= 0.9.6"])
    s.add_dependency(%q<rubyzip>, [">= 1.0.0"])
    s.add_dependency(%q<multi_json>, [">= 1.3.2"])
    s.add_dependency(%q<rake>, [">= 0.8.7"])
  end
end
