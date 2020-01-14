module Secretariat
  module Versioner
    def by_version(version, v1, v2)
      if version == 1
        v1
      elsif version == 2
        v2
      else
        raise "Unsupported Version: #{version}"
      end
    end
  end
end
