require "optparse"
require_relative "plcp_build"
require_relative "mod_legacy"
require_relative "mod_ofdm"
require_relative "mcstable/mcstable"



class FrameTimeDSSSLong
  def initialize length
    @len = length
    @mod = ModLegacy.new(ModLegacy::MOD_BPSK)
  end

  def single_beacon_time_us
    preamble_header = 192
    data = @mod.calc_encoded_sec(@len) * 1000 * 1000
    difs = 50
    return preamble_header + data + difs
  end
end

class FrameTimeDSSSShort
  def initialize length
    @len = length
    @mod = ModLegacy.new(ModLegacy::MOD_BPSK)
  end

  def single_beacon_time_us
    preamble_header = 96
    data = @mod.calc_encoded_sec(@len) * 1000 * 1000
    difs = 50
    return preamble_header + data + difs
  end
end

class FrameTimeOFDM5G
  def initialize length
    @len = length
    @mod = ModOFDM.new(ModOFDM::MOD_BPSK, ModOFDM::CODING_RATE_1_2)
  end

  def single_beacon_time_us
    preamble = 16 # us
    signal = 4 # us = 1 OFDM symbol ( .8 us + 3.2 us )
    data = @mod.calc_encoded_sec(@len) * 1000 * 1000
    difs = 34

    return preamble + signal + data + 34
  end
end

class AirOccupancyFromSTA
  MOD_OFDM="mod"
  MOD_LONG="long"
  MOD_SHORT="short"

  DEFAULT_BEACON_LENGTH=24+228
  DEFAULT_PROBEREQ_LENGTH=24+182
  DEFAULT_PROBERESP_LENGTH=24+258

  def initialize opt={}
    @ap_num = opt[:ap]
    @client_num = opt[:client]
    @prob = opt[:prob]
    @mod = opt[:mod]

    @modulation = case @mod
                  when "ofdm"
                    FrameTimeOFDM5G
                  when "long"
                    FrameTimeDSSSLong
                  when "short"
                    FrameTimeDSSSShort
                  else
                    FrameTimeOFDM5G
                  end

    @beacon_time = @modulation.new(DEFAULT_BEACON_LENGTH).single_beacon_time_us
    @probereq_time = @modulation.new(DEFAULT_PROBEREQ_LENGTH).single_beacon_time_us
    @proberesp_time = @modulation.new(DEFAULT_PROBERESP_LENGTH).single_beacon_time_us
  end

  def free_us
    total_beacon_us = @beacon_time * @ap_num * 10
    total_probereq_us = @prob * @client_num * @probereq_time
    total_proberesp_us = @ap_num * @prob * @client_num * @proberesp_time
    return 1 * 1000 * 1000.to_f - total_beacon_us - total_probereq_us - total_proberesp_us
  end

  def total_bps bps
    free_bps = bps * (free_us.to_f / (1000 * 1000))
    return 0 if free_bps < 0
    return free_bps
  end

end

if __FILE__ == $0
  def usage
    puts "Calculate AP/STA air occupancy from number"
    puts ""
    puts "  -a [num]        # of AP"
    puts "  -c [num]        # of client"
    puts "  -p [num]        # of percentage of Probe Request"
    puts "  -m [mod]        modulation to use (long, short, ofdm)"
    puts "  -s              sequencer"
    puts ""
    exit
  end

  def sequence opt
    ap_num = opt[:ap]
    client_num = opt[:client]

    1.upto(client_num) do |cnum|
      ary = []
      1.upto(ap_num) do |anum|
        _opt = {
          :ap => anum,
          :client => cnum,
          :prob => opt[:prob],
          :mod => opt[:mod],
        }
        oc = AirOccupancyFromSTA.new(_opt)
        ary << oc.total_bps(130)
      end
      print ary.join(",") + "\n"

    end
  end


  opt = OptionParser.new
  OPTS={
    :ap => 1,
    :client => 10,
    :prob => 1,
    :mod => AirOccupancyFromSTA::MOD_OFDM
  }

  opt.on("-a VAL")  {|v| OPTS[:ap] = v.to_i}
  opt.on("-c VAL")  {|v| OPTS[:client] = v.to_i}
  opt.on("-p VAL")  {|v| OPTS[:prob] = v.to_f}
  opt.on("-m VAL")  {|v| OPTS[:mod] = v.to_s}
  opt.on("-s")      {|v| OPTS[:seq] = true }
  opt.on("-h")      {|v| usage}

  opt.parse!(ARGV)

  if OPTS[:seq]
    sequence(OPTS)
    exit
  end

  oc = AirOccupancyFromSTA.new(OPTS)

  print "free_us, bps\n"
  print "#{oc.free_us}, #{oc.total_bps(130)}\n"
end
