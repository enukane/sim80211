require "optparse"

require_relative "encodee"
require_relative "mod_legacy"

class PLCPPreamble < Encodee
  BITS_SYNC=128
  BITS_SFD=16

  def modulation
    ModLegacy.new(ModLegacy::MOD_BPSK)
  end

  def bits
    BITS_SYNC + BITS_SFD
  end

end

class PLCPHeader < Encodee
  BITS_SIGNAL=8
  BITS_SERVICE=8
  BITS_LENGTH=16
  BITS_CRC=16

  def modulation
    @mod = ModLegacy.new(ModLegacy::MOD_BPSK)
  end

  def bits
    BITS_SIGNAL + BITS_SERVICE + BITS_LENGTH + BITS_CRC
  end
end

class PLCPPreamble_DSSS < PLCPPreamble
end

class PLCPPreamble_DSSSshort < PLCPPreamble
  BITS_shortSYNC=56
  BITS_shortSFD=16

  def bits
    BITS_shortSYNC + BITS_shortSFD
  end
end

class PLCPHeader_short < PLCPHeader
  def modulation
    ModLegacy.new(ModLegacy::MOD_QPSK)
  end
end

class PLCPPreamble_OFDM
  def modulation
    nil
  end

  def bits
    nil
  end

  def calc_usec
    # short = (64.0/76) * 4.8 * 10
    # short = 8 = 0.8 * 10
    # long = 8 = 1.6 + 3.2 * 2
    return 16
  end
end

class PLCPHeader_OFDM
end


if __FILE__ == $0
  dssslong = PLCPPreamble_DSSS.new
  header = PLCPHeader.new
  plcp_p_bits = dssslong.bits
  plcp_p_time = dssslong.bits
  plcp_h_bits = header.bits
  plcp_h_time = header.calc_usec
  plcp_bits   = plcp_p_bits + plcp_h_bits
  plcp_time   = plcp_p_time + plcp_h_time
  print "PLCP long preamble: #{plcp_bits}bits #{plcp_time} usec\n"

  dsssshort = PLCPPreamble_DSSSshort.new
  header = PLCPHeader_short.new
  plcp_p_bits = dsssshort.bits
  plcp_p_time = dsssshort.calc_usec
  plcp_h_bits = header.bits
  plcp_h_time = header.calc_usec
  plcp_bits   = plcp_p_bits + plcp_h_bits
  plcp_time   = plcp_p_time + plcp_h_time
  print "PLCP short preamble: #{plcp_bits}bits #{plcp_time} usec\n"
end
