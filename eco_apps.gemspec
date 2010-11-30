spec = Gem::Specification.new do |s| 
  s.name = "eco_apps"
  s.version = "0.2.0"
  s.author = "Eleutian Technology, LLC"
  s.email = "dev@eleutian.com"
  s.homepage = "https://github.com/eleutian/"
  s.platform = Gem::Platform::RUBY
  s.summary = "Eco Apps enables you to develop an eco-system of Rails applications that function as a single system."
  %w{lib}.each{|folder|
    s.files += Dir["#{folder}/**/*"]
  }
  s.require_path = "lib"
  s.autorequire = "eco_apps"
  s.test_files = Dir["{spec}/**/*"]
  s.add_dependency("netaddr")
end