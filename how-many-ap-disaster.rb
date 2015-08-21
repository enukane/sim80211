# this is so-much-wrong

require "optparse"

require_relative "plcp_build"
require_relative "mod_legacy"
require_relative "mod_ofdm"
require_relative "mcstable/mcstable"

class BeaconsTimeDSSSLong
  DEFAULT_BEACON_LEN=24+228
  def initialize beacon_length=DEFAULT_BEACON_LEN
    @blen = beacon_length
    @mod = ModLegacy.new(ModLegacy::MOD_BPSK)
  end

  def single_beacon_time_us
    preamble_header = 192
    data = @mod.calc_encoded_sec(@blen) * 1000 * 1000
    difs = 50
    return preamble_header + data + difs
  end
end

class BeaconsTimeDSSSShort
  DEFAULT_BEACON_LEN=24+228
  def initialize beacon_length=DEFAULT_BEACON_LEN
    @blen = beacon_length
    @mod = ModLegacy.new(ModLegacy::MOD_BPSK)
  end

  def single_beacon_time_us
    preamble_header = 96
    data = @mod.calc_encoded_sec(@blen) * 1000 * 1000
    difs = 50
    return preamble_header + data + difs
  end
end


class BeaconsTimeOFDM5G
  DEFAULT_BEACON_LEN=24+228
  def initialize beacon_length=DEFAULT_BEACON_LEN
    @blen = beacon_length
    @mod = ModOFDM.new(ModOFDM::MOD_BPSK, ModOFDM::CODING_RATE_1_2)
  end

  def single_beacon_time_us
    preamble = 16 # us
    signal = 4 # us = 1 OFDM symbol ( .8 us + 3.2 us )
    data = @mod.calc_encoded_sec(@blen) * 1000 * 1000
    difs = 34

    return preamble + signal + data + 34
  end
end

class APTimeCounter
  attr_reader :free_us
  DEFAULT_AP_NUM = 1
  TOTAL_US = 1 * 1000 * 1000
  AP_BEACON_PER_SEC = 10
  def initialize us_per_beacon, ap_num=DEFAULT_AP_NUM
    @us_per_beacon = us_per_beacon
    bnum = ap_num * AP_BEACON_PER_SEC
    @free_us = TOTAL_US - bnum * @us_per_beacon
  end

  def total_bps bps
    free_bps = bps * (free_us.to_f / (1000 * 1000))
    return free_bps
  end
end

b_dssslong = BeaconsTimeDSSSLong.new.single_beacon_time_us
b_dsssshort = BeaconsTimeDSSSShort.new.single_beacon_time_us
b_ofdm =  BeaconsTimeOFDM5G.new.single_beacon_time_us

1.upto(40) do |n|
  long = APTimeCounter.new(b_dssslong, n).total_bps(130)
  short = APTimeCounter.new(b_dsssshort, n).total_bps(130)
  ofdm = APTimeCounter.new(b_ofdm, n).total_bps(130)
  print "#{long}, #{short}, #{ofdm}\n"
end

