require "optparse"

class MCS
  MILLI=1/1000.0
  MICRO=MILLI/1000.0
  NANO=MICRO/1000.0
  SEC_PER_SYMBOL=4.0/1000.0/1000.0

  MCS_MIN=0
  MCS_MAX=31

  SPATIALSTREM_MIN=1
  SPATIALSTREM_MAX=4

  CODING_RATE_1_2=(1.0/2.0)
  CODING_RATE_3_4=(3.0/4.0)
  CODING_RATE_2_3=(2.0/3.0)
  CODING_RATE_5_6=(5.0/6.0)
  CODING_RATES = {
    CODING_RATE_1_2 => "1/2",
    CODING_RATE_3_4 => "3/4",
    CODING_RATE_2_3 => "2/3",
    CODING_RATE_5_6 => "5/6"
  }

  MOD_BPSK=0
  MOD_QPSK=1
  MOD_16QAM=2
  MOD_64QAM=3
  MOD_256QAM=4
  MODULATIONS = {
    MOD_BPSK    => "BPSK",
    MOD_QPSK    => "QPSK",
    MOD_16QAM   => "16-QAM",
    MOD_64QAM   => "64-QAM",
    MOD_256QAM  => "256-QAM",
  }

  CODEDBITS_PER_CARRIER={
    MOD_BPSK  => 1,
    MOD_QPSK  => 2,
    MOD_16QAM => 4,
    MOD_64QAM => 6,
    MOD_256QAM=> 8
  }

  WIDTH_AG=20
  WIDTH_20=20
  WIDTH_40=40
  WIDTH_80=80
  WIDTH_160=160

  SUBCARRIER_FOR_WIDTH={
    # subcarrier = ((highest carrier - lowest carrier) + 1) * 2 (upper/lower) - pilot
    WIDTH_AG  => 48,   # ((26  - 1) + 1) * 2 - 4 (pilot) = 48
    WIDTH_20  => 52,   # ((28  - 1) + 1) * 2 - 4 (pilot) = 52
    WIDTH_40  => 108,  # ((58  - 2) + 1) * 2 - 6 (pilot) = 108
    WIDTH_80  => 234,  # ((122 - 2) + 1) * 2 - 8 (pilot) = 234
    WIDTH_160 => 468,  # ((250 - 130) + 1 + (126 - 6) + 1) * 2 - 16 (pilot) = 468
  }

  PILOTVALUE_FOR_WIDTH={
    WIDTH_20 => 4,
    WIDTH_40 => 6
  }

  def self.calc_databits ss, mod, rate, width
    codedbits_per_carrier = CODEDBITS_PER_CARRIER[mod] # bits/symbol
    sub_carriers = SUBCARRIER_FOR_WIDTH[width] # subcarrier [n]

    # [bits/symbol] of carriers = [bits/symbol] of single carrier * n * n
    databits_per_ss = codedbits_per_carrier * sub_carriers * rate

    # multiple stream : [bits/symbol] = [bits/symbol] of single stream
    return databits_per_ss * ss
  end

  def self.calc_rate ss, mod, rate, width, shortgi=false
    # ss = spatial streams [n]
    # mod = modulation
    # rate = rate [n]
    # width = width

    # [bits/symbol] of sub carriers and streams
    databits = calc_databits(ss, mod, rate, width)

    # [bits/sec] of single stream = [bits/symbol]  / [sec/symbol]
    if shortgi
      bps = databits / (SEC_PER_SYMBOL - 400 * NANO)
    else
      bps = databits / SEC_PER_SYMBOL
    end

    # shortgi: XXX this is no good
    # bps = bps * 1.11 if shortgi

    # [Mbits/sec] = [bits/sec] / 1M
    mbps = bps / 1000.0 / 1000.0

    return mbps
  end
end

class MCSEntry
  attr_reader :index, :stream, :modulation, :rate, :width, :shortgi
  def initialize info
    @index = info[:index]
    @stream = info[:stream]
    @modulation = info[:modulation]
    @rate = info[:rate]
    @width = info[:width]
    @shortgi = info[:shortgi] || false
  end

  def get_rate
    return MCS.calc_rate(@stream, @modulation, @rate, @width, @shortgi)
  end

  def get_bits_per_symbol
    return MCS.calc_databits(@stream, @modulation, @rate, @width)
  end
end

class MCSTable
  TABLE = [
    # idx, ss,     modulation,             coding rate
    [   0,  1,  MCS::MOD_BPSK,    MCS::CODING_RATE_1_2  ],
    [   1,  1,  MCS::MOD_QPSK,    MCS::CODING_RATE_1_2  ],
    [   2,  1,  MCS::MOD_QPSK,    MCS::CODING_RATE_3_4  ],
    [   3,  1,  MCS::MOD_16QAM,   MCS::CODING_RATE_1_2  ],
    [   4,  1,  MCS::MOD_16QAM,   MCS::CODING_RATE_3_4  ],
    [   5,  1,  MCS::MOD_64QAM,   MCS::CODING_RATE_2_3  ],
    [   6,  1,  MCS::MOD_64QAM,   MCS::CODING_RATE_3_4  ],
    [   7,  1,  MCS::MOD_64QAM,   MCS::CODING_RATE_5_6  ],
    [   8,  2,  MCS::MOD_BPSK,    MCS::CODING_RATE_1_2  ],
    [   9,  2,  MCS::MOD_QPSK,    MCS::CODING_RATE_1_2  ],
    [  10,  2,  MCS::MOD_QPSK,    MCS::CODING_RATE_3_4  ],
    [  11,  2,  MCS::MOD_16QAM,   MCS::CODING_RATE_1_2  ],
    [  12,  2,  MCS::MOD_16QAM,   MCS::CODING_RATE_3_4  ],
    [  13,  2,  MCS::MOD_64QAM,   MCS::CODING_RATE_2_3  ],
    [  14,  2,  MCS::MOD_64QAM,   MCS::CODING_RATE_3_4  ],
    [  15,  2,  MCS::MOD_64QAM,   MCS::CODING_RATE_5_6  ],
    [  16,  3,  MCS::MOD_BPSK,    MCS::CODING_RATE_1_2  ],
    [  17,  3,  MCS::MOD_QPSK,    MCS::CODING_RATE_1_2  ],
    [  18,  3,  MCS::MOD_QPSK,    MCS::CODING_RATE_3_4  ],
    [  19,  3,  MCS::MOD_16QAM,   MCS::CODING_RATE_1_2  ],
    [  20,  3,  MCS::MOD_16QAM,   MCS::CODING_RATE_3_4  ],
    [  21,  3,  MCS::MOD_64QAM,   MCS::CODING_RATE_2_3  ],
    [  22,  3,  MCS::MOD_64QAM,   MCS::CODING_RATE_3_4  ],
    [  23,  3,  MCS::MOD_64QAM,   MCS::CODING_RATE_5_6  ],
    [  24,  4,  MCS::MOD_BPSK,    MCS::CODING_RATE_1_2  ],
    [  25,  4,  MCS::MOD_QPSK,    MCS::CODING_RATE_1_2  ],
    [  26,  4,  MCS::MOD_QPSK,    MCS::CODING_RATE_3_4  ],
    [  27,  4,  MCS::MOD_16QAM,   MCS::CODING_RATE_1_2  ],
    [  28,  4,  MCS::MOD_16QAM,   MCS::CODING_RATE_3_4  ],
    [  29,  4,  MCS::MOD_64QAM,   MCS::CODING_RATE_2_3  ],
    [  30,  4,  MCS::MOD_64QAM,   MCS::CODING_RATE_3_4  ],
    [  31,  4,  MCS::MOD_64QAM,   MCS::CODING_RATE_5_6  ],
  ]
  def initialize shortgi=false
    @table20 = []
    @table40 = []
    @table80 = []
    @table160 = []
    generate shortgi
  end

  def generate_entry index, stream, mod, rate, width, shortgi=false
    return MCSEntry.new(:index => index, :stream => stream, :modulation => mod,
                        :rate => rate, :width => width, :shortgi => shortgi)
  end

  def add_index index, stream, mod, rate, shortgi
    @table20[index] = generate_entry(index, stream, mod, rate, MCS::WIDTH_20, shortgi)
    @table40[index] = generate_entry(index, stream, mod, rate, MCS::WIDTH_40, shortgi)
    @table80[index] = generate_entry(index, stream, mod, rate, MCS::WIDTH_80, shortgi)
    @table160[index] = generate_entry(index, stream, mod, rate, MCS::WIDTH_160, shortgi)
  end

  def generate shortgi=false
    TABLE.each do |index, stream, mod, rate|
      add_index(index, stream, mod, rate, shortgi)
    end
  end

  def table width=MCS::WIDTH_20
    table = case width
    when MCS::WIDTH_20
      @table20
    when MCS::WIDTH_40
      @table40
    when MCS::WIDTH_80
      @table80
    when MCS::WIDTH_160
      @table160
    end
    return table
  end

  def bps_list width=MCS::WIDTH_20
    list = Array.new
    table(width).each do |entry|
      list << [entry.index, entry.get_rate]
    end
    return list
  end

  def bits_per_symbol_list width=MCS::WIDTH_20
    list = Array.new
    table(width).each do |entry|
      list << [entry.index, entry.get_bits_per_symbol]
    end
    return list
  end

  def print_list width=MCS::WIDTH_20
    print "# Channel Width = #{width}MHz\n"
    printf "%5s %6s %10s %11s %7s %7s\n",
      "Index", "Stream", "Modulation", "Coding Rate", "ShortGI", "Mbps"
    table(width).each do |entry|
      printf "%5s %6s %10s %11s %7s %7.1f\n",
        entry.index, entry.stream, MCS::MODULATIONS[entry.modulation],
        MCS::CODING_RATES[entry.rate], entry.shortgi, entry.get_rate
    end
  end

  def print_bits_per_symbol_list width=MCS::WIDTH_20
    list = bits_per_symbol_list(width)
    print "# Channel Width = #{width}MHz\n"
    printf "%5s %11s\n", "Index", "Bits/Symbol"
    list.each do |index, bits|
      printf "%5d %11f\n", index, bits
    end
  end
end

if __FILE__ == $0

  def usage
    puts "Calculates MCS Table"
    puts ""
    puts "Usage: #{$0} [options]"
    puts "  -h                show this message"
    puts "  -b                bits per symbol"
    puts "  -s                short guard interval"
    puts "  -w [width]        channel width to show"
    exit 0
  end

  opt = OptionParser.new
  OPTS = {}
  OPTS[:width] = MCS::WIDTH_20
  OPTS[:shortgi] = false
  opt.on("-w VAL") {|v| OPTS[:width] = v.to_i}
  opt.on("-s") {|v| OPTS[:shortgi] = true}
  opt.on("-b") {|v| OPTS[:bits] = true}
  opt.on("-h") {|v| usage() }
  opt.parse!(ARGV)

  mcstable = MCSTable.new(OPTS[:shortgi] == true)
  if OPTS[:bits]
    mcstable.print_bits_per_symbol_list(OPTS[:width])
    exit 0
  end
  mcstable.print_list(OPTS[:width])
end
