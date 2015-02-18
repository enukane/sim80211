class Utils
  MBPS=1000*1000.0
  def self.bits_to_sec bits, mbps
    bits / (MBPS * mbps)
  end
end

def dp str
  if ENV['DEBUG'] == "1"
    print "#{str}\n"
  end
end
