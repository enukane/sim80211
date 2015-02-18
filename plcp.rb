require "./utils.rb"

class PLCP
  PHY_DSSS=0

  PREAMBLE_LONG=0
  PREAMBLE_SHORT=1

  DSSS_PLCP_PREAMBLE_MBPS=1
  DSSS_PLCP_PREAMBLE_SYNC_BITS=128
  DSSS_PLCP_PREAMBLE_SFD_BITS=16
  DSSS_PLCP_PREAMBLE_BITS=
    DSSS_PLCP_PREAMBLE_SYNC_BITS+
    DSSS_PLCP_PREAMBLE_SFD_BITS

  DSSS_PLCP_SHORT_PREAMBLE_MBPS=1
  DSSS_PLCP_SHORT_PREAMBLE_shortSYNC_BITS=56
  DSSS_PLCP_SHORT_PREAMBLE_shortSFD_BITS=16
  DSSS_PLCP_SHORT_PREAMBLE_BITS=
    DSSS_PLCP_SHORT_PREAMBLE_shortSYNC_BITS+
    DSSS_PLCP_SHORT_PREAMBLE_shortSFD_BITS

  DSSS_PLCP_HEADER_SIGNAL_BITS=8
  DSSS_PLCP_HEADER_SERVICE_BITS=8
  DSSS_PLCP_HEADER_LENGTH_BITS=16
  DSSS_PLCP_HEADER_CRC_BITS=16
  DSSS_PLCP_HEADER_BITS=
    DSSS_PLCP_HEADER_SIGNAL_BITS+
    DSSS_PLCP_HEADER_SERVICE_BITS+
    DSSS_PLCP_HEADER_LENGTH_BITS+
    DSSS_PLCP_HEADER_CRC_BITS
  DSSS_PLCP_HEADER_MBPS=2

  def initialize phy, preamble
    @phy = phy
    @preamble = preamble
  end

  def time
    return plcp_preamble_time + plcp_header_time
  end

  def plcp_preamble_time
    case @phy
    when PHY_DSSS
      return dsss_plcp_preamble_time
    else
      print "ERROR: phy not supported (#{@phy})\n"
    end
  end

  def dsss_plcp_preamble_time
    if @preamble == PREAMBLE_LONG
      return dsss_plcp_preamble_long_time
    else
      return dsss_plcp_preamble_short_time
    end
  end

  def dsss_plcp_preamble_long_time
    dp "preamble bits => #{DSSS_PLCP_PREAMBLE_BITS}"
    s = Utils.bits_to_sec(DSSS_PLCP_PREAMBLE_BITS, DSSS_PLCP_PREAMBLE_MBPS)
    dp "preamble sec => #{s}"
    return s
  end

  def dsss_plcp_preamble_short_time
    dp "spreamble bits => #{DSSS_PLCP_SHORT_PREAMBLE_BITS}"
    s = Utils.bits_to_sec(DSSS_PLCP_SHORT_PREAMBLE_BITS, DSSS_PLCP_SHORT_PREAMBLE_MBPS)
    dp "spreamble sec => #{s}"
    return s
  end

  def plcp_header_time
    case @phy
    when PHY_DSSS
      return dsss_plcp_header_time
    else
      print "ERROR: phy not supported (#{@phy})\n"
    end
  end

  def dsss_plcp_header_time
    dp "header bits => #{DSSS_PLCP_HEADER_BITS}"
    s = Utils.bits_to_sec(DSSS_PLCP_HEADER_BITS, DSSS_PLCP_HEADER_MBPS)
    dp "s => #{s}"
    return s
  end
end

if __FILE__ == $0
  plcp = PLCP.new(PLCP::PHY_DSSS, PLCP::PREAMBLE_LONG)
  p plcp.time
  p "===="
  plcp = PLCP.new(PLCP::PHY_DSSS, PLCP::PREAMBLE_SHORT)
  p plcp.time
end
