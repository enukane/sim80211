class Modulation
  attr_reader :mod
  def self.print_list
    raise "not implemented"
  end

  def initialize
    raise "not implemented"
  end

  def calc_bps
    raise "not implemented"
  end

  def calc_mbps
    return calc_bps() / 1000.0 / 1000.0
  end

  def calc_encoded_sec bytes
    raise "not implemented"
  end
end
