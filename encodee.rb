class Encodee

  def initialize
    @mod = nil
    @bits_ = nil
    _set_modulation
    _set_bits
  end

  def modulation
    raise "not implemented"
  end

  def _set_modulation
    @mod = modulation()
  end

  def bits
    raise "not implemented"
  end

  def _set_bits
    @bits_ = bits
  end

  def calc_usec
    raise "no modulation" if !@mod.is_a?(Modulation)
    return @mod.calc_encoded_sec(@bits_ / 8) * 1000 * 1000
  end
end
