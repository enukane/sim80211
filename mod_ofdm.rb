require "optparse"
require_relative "modulation"
require_relative "utils"

class ModOFDM < Modulation
  attr_reader :rate

  SEC_PER_SYMBOL=4.0/1000.0/1000.0
  SEC_PER_GUARD_INTERVAL_LONG = 800.0 / 1000 / 1000 / 1000 # [nsec]

  # Modulation
  MOD_BPSK    =0
  MOD_QPSK    =1
  MOD_16QAM   =2
  MOD_64QAM   =3
  MOD_256QAM  = 4
  MOD2STR = {
    MOD_BPSK    =>  "BPSK",
    MOD_QPSK    =>  "QPSK",
    MOD_16QAM   =>  "16-QAM",
    MOD_64QAM   =>  "64-QAM",
    MOD_256QAM  =>  "256-QAM",
  }

  CODEDBITS_PER_SYMBOL = {
    # mod       := number of sub-carriers * coded bits per sub-carrier
    MOD_BPSK    => 48 * 1,
    MOD_QPSK    => 48 * 2,
    MOD_16QAM   => 48 * 4,
    MOD_64QAM   => 48 * 6,
    MOD_256QAM  => 48 * 8,
  }

  CODING_RATE_1_2=(1.0/2.0)
  CODING_RATE_3_4=(3.0/4.0)
  CODING_RATE_2_3=(2.0/3.0)
  CODING_RATES2STR = {
    CODING_RATE_1_2 =>  "1/2",
    CODING_RATE_3_4 =>  "3/4",
    CODING_RATE_2_3 =>  "2/3",
  }

  def initialize mod, rate
    @mod = mod
    @rate = rate
  end

  def self.print_list
    ary = []
    ary << self.new(MOD_BPSK,  CODING_RATE_1_2)
    ary << self.new(MOD_BPSK,  CODING_RATE_3_4)
    ary << self.new(MOD_QPSK,  CODING_RATE_1_2)
    ary << self.new(MOD_QPSK,  CODING_RATE_3_4)
    ary << self.new(MOD_16QAM, CODING_RATE_1_2)
    ary << self.new(MOD_16QAM, CODING_RATE_3_4)
    ary << self.new(MOD_64QAM, CODING_RATE_2_3)
    ary << self.new(MOD_64QAM, CODING_RATE_3_4)

    puts "# OFDM Rates"
    printf "%12s %6s %12s %5s %9s %20s %11s %9s\n",
      "<Modulation>",
      "<Rate>",
      "<Mbps>",
      "<#GI>",
      "<GI usec>",
      "<usec for 2312bytes>",
      "<real Mbps>",
      "<GI \%>"
    ary.each do |elm|
      mod = elm.mod
      rate = elm.rate
      bits_per_symbol = elm.bits_per_symbol()
      gis = elm.gis(2318 * 8)
      mbps = elm.calc_mbps
      sec = elm.calc_encoded_sec(2312)
      usec = sec * 1000 * 1000
      gi_usec = gis * SEC_PER_GUARD_INTERVAL_LONG * 1000 * 1000
      gi_rate = gi_usec / usec * 100
      real_mbps = 2312 * 8.0 / sec / 1000 / 1000

      printf "%12s %6s %12.1f %5d %9.1f %20.1f %11.1f %9.1f\n",
        MOD2STR[mod],
        CODING_RATES2STR[rate],
        mbps,
        gis,
        gi_usec,
        usec,
        real_mbps,
        gi_rate
    end
  end

  def calc_bps
    return _calc_bps(@mod, @rate)
  end

  def calc_encoded_sec bytes
    bits = bytes * 8
    bps = calc_bps()
    return gis(bits) * SEC_PER_GUARD_INTERVAL_LONG + bits.to_f / bps
  end

  #private
  def _calc_bps mod, rate
    codedbits_per_symbol = CODEDBITS_PER_SYMBOL[mod]
    databits_per_symbol = codedbits_per_symbol * rate
    return databits_per_symbol / SEC_PER_SYMBOL
  end

  def bits_per_symbol
    return _bits_per_symbol(@mod, @rate)
  end

  def _bits_per_symbol mod, rate
    return CODEDBITS_PER_SYMBOL[mod] * rate
  end

  def gis bits
    return _gis(_bits_per_symbol(@mod, @rate), bits)
  end

  def _gis per_symbol, bits
    symbols = (bits / per_symbol).ceil
    return symbols - 1
  end
end

if __FILE__ == $0
  ModOFDM.print_list
end
