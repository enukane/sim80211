require './mcs.rb'

class GI
  GI_SEC_SHORT=400.0/1000/1000/1000
  GI_SEC_LONG= 800.0/1000/1000/1000

  def initialize shortgi=false
    @shortgi = shortgi
    @mcstable = MCSTable.new(@shortgi)
  end

  def get_gi
    return GI_SEC_SHORT if @shortgi
    return GI_SEC_LONG
  end

  # how many symbols per sec
  def symbol_per_sec
    return 1/MCS::SEC_PER_SYMBOL
  end

  def time_for_sec_symbols
    symbols = symbol_per_sec()
    return symbols * MCS::SEC_PER_SYMBOL + (symbols - 1) * get_gi
  end

  def evaluate width=MCS::WIDTH_20
    ary = Array.new
    bits_per_symbol_list = @mcstable.bits_per_symbol_list(width)
    symbols = symbol_per_sec()
    time = time_for_sec_symbols()

    bits_per_symbol_list.each do |index, bits_per_symbol|
      bits = symbols * bits_per_symbol
      bps = bits / time_for_sec_symbols
      mbps = bps / 1000.0 / 1000.0
      ary << [ index, mbps ]
    end
    return ary
  end

  def print_list width=MCS::WIDTH_20
    bps_list = evaluate(width)

    print "# ShortGI = #{@shortgi == true}\n"
    print "# Channel Width = #{width}\n"
    printf "%5s %10s\n", "index", "Mbps"
    bps_list.each do |index, mbps|
      printf "%5d %10.1f\n", index, mbps
    end
  end
end

if __FILE__ == $0

  def usage
    puts "Calculates how Short Guard Interval does good"
    puts ""
    puts "Usage: #{$0} [options]"
    puts "  -w [width]      Channel Width(20, 40, 80, 160)"
    puts "  -c              Do comparision between LongGI & Short GI on specified channel width"
    puts "  -l              List Mbps with specified channel width & GI (exclusive with -w)"
    puts "  -s              Use Short Guard Interval"

    exit 0
  end

  opt = OptionParser.new
  OPTS={}
  OPTS[:width] = MCS::WIDTH_20
  OPTS[:comparition] = true
  OPTS[:shortgi] = false
  opt.on("-w VAL")  {|v| OPTS[:width] = v.to_i}
  opt.on("-c")      {|v| OPTS[:comparision] = true}
  opt.on("-l")      {|v| OPTS[:list] = true }
  opt.on("-s")      {|v| OPTS[:shortgi] = true }
  begin
    opt.parse!(ARGV)
  rescue
    usage
  end

  longgi  = GI.new(false)
  shortgi = GI.new(true)

  if OPTS[:list]
    gi = if OPTS[:shortgi] == true then shortgi else longgi end
    gi.print_list(OPTS[:width])
    exit
  end

  tlong = longgi.time_for_sec_symbols
  tshort = shortgi.time_for_sec_symbols

  evlong = longgi.evaluate(OPTS[:width])
  evshort = shortgi.evaluate(OPTS[:width])

  print "# Comparision between LongGI and ShortGI\n"
  printf "%10s %13s %13s %10s\n", "MCS Index", "LongGI(Mbps)", "ShortGI(Mbps)", "Rate (%)"
  evlong.each do |index, mbps|
    _index, _mbps = evshort[index]
    raise "something wrong #{index} != #{_index}" if index != _index

    printf "%10d %12.1f %12.1f %9.1f\n", index, mbps, _mbps, (_mbps / mbps * 100)
  end
end
