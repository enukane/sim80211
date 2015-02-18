require "optparse"

class Legacy
  # Modulation
  MOD_BPSK  =0
  MOD_QPSK  =1
  MOD_CCK   =2

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
  def initialize
  end

  def calc_dsss_bps mod
    coded_bits = CODED_BITS[mod]
    unless mod
      raise "modulation not supported (#{mod})"
    end

    return DSSS_CODE_WORD_RATE.ceil * coded_bits
  end

  def calc_cck_bps opt
    case opt
    when CCK_BITS_PER_CODE_WORD_CARRIER_OPT0
    when CCK_BITS_PER_CODE_WORD_CARRIER_OPT1
    else
      raise "CCK bits per code word carrier not supported (#{opt})"
    end
    return CCK_CODE_WORD_RATE * opt
  end
end

if __FILE__ == $0
  def usage
    exit
  end

  opt = OptionParser.new
  opt.parse!(ARGV)

  legacy = Legacy.new

  p legacy.calc_dsss_bps(Legacy::MOD_BPSK)/1000/1000
  p legacy.calc_dsss_bps(Legacy::MOD_QPSK)/1000/1000
  p legacy.calc_cck_bps(Legacy::CCK_BITS_PER_CODE_WORD_CARRIER_OPT0)/1000/1000
  p legacy.calc_cck_bps(Legacy::CCK_BITS_PER_CODE_WORD_CARRIER_OPT1)/1000/1000
end
