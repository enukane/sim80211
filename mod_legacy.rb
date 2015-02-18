require "optparse"
require_relative "modulation"
require_relative "utils"

class ModLegacy < Modulation
  # Modulation
  MOD_BPSK  =0
  MOD_QPSK  =1
  MOD_CCK   =2
  MOD2STR = {
    MOD_BPSK  =>  "BPSK",
    MOD_QPSK  =>  "QPSK",
    MOD_CCK   =>  "CCK",
  }

  # coded bits
  CODED_BITS = {
    MOD_BPSK  => 1,
    MOD_QPSK  => 2,
  }

  CHIP_RATE=11.0*1000*1000 # [chips]
  DURATION_PER_CHIP=1/CHIP_RATE # [us] = [sec] / [chips]

  # DSSS
  DURATION_PER_11CHIP_BARKER_CODE=DURATION_PER_CHIP*11 # 
  DSSS_CODE_WORD_RATE=1/DURATION_PER_11CHIP_BARKER_CODE #

  # CCK
  DURATION_PER_8CHIP_CODE = DURATION_PER_CHIP * 8
  CCK_CODE_WORD_RATE = 1 / DURATION_PER_8CHIP_CODE
  CCK_BITS_PER_CODE_WORD_CARRIER_OPT0 = 4
  CCK_BITS_PER_CODE_WORD_CARRIER_OPT1 = 8

  def initialize mod, opt=CCK_BITS_PER_CODE_WORD_CARRIER_OPT1
    @mod = mod
    @opt = opt
  end

  def self.print_list
    ary = []
    ary << self.new(MOD_BPSK)
    ary << self.new(MOD_QPSK)
    ary << self.new(MOD_CCK, CCK_BITS_PER_CODE_WORD_CARRIER_OPT0)
    ary << self.new(MOD_CCK, CCK_BITS_PER_CODE_WORD_CARRIER_OPT1)

    puts "# DSSS/CCK rates"
    printf "%12s %12s %20s\n", "<Modulation>", "<Rate(Mbps)>", "<time for 2312bytes>"
    ary.each do |elm|
      mod  = elm.mod
      mbps = elm.calc_mbps
      usec  = elm.calc_encoded_sec(2312) * 1000 * 1000

      printf "%12s %12.1f %20.1f [usec]\n", MOD2STR[mod], mbps, usec
    end
  end

  def calc_bps
    return _calc_bps(@mod, @opt)
  end

  def calc_encoded_sec bytes
    bits = bytes * 8
    bps = calc_bps()
    return bits.to_f/bps
  end

  #private
  def _calc_bps mod, opt=CCK_BITS_PER_CODE_WORD_CARRIER_OPT1
    if mod == MOD_CCK
      return _calc_bps_cck(opt)
    end
    return _calc_bps_dsss(mod)
  end

  def _calc_bps_cck opt
    case opt
    when CCK_BITS_PER_CODE_WORD_CARRIER_OPT0
    when CCK_BITS_PER_CODE_WORD_CARRIER_OPT1
    else
      raise "CCK bits per code word carrier not supported (#{opt})"
    end
    return CCK_CODE_WORD_RATE * opt
  end

  def _calc_bps_dsss(mod)
    coded_bits = CODED_BITS[mod]
    unless mod
      raise "modulation not supported (#{mod})"
    end

    return DSSS_CODE_WORD_RATE.ceil * coded_bits
  end
end


if __FILE__ == $0
  ModLegacy.print_list
end
