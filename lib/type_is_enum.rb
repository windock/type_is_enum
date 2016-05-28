module TypeIsEnum
  Dir.glob(File.expand_path('../type_is_enum/*.rb', __FILE__)).sort.each(&method(:require))
end
