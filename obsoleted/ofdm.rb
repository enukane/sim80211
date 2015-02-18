require "./utils.rb"

class OFDM
  SYMBOL_SEC=4.0/1000.0/1000.0

  MOD_BPSK=0
  MOD_QPSK=1
  MOD_16QAM=2
  MOD_64QAM=3
  MOD_256QM=4
  MODS=[MOD_BPSK, MOD_QPSK, MOD_16QAM, MOD_64QAM, MOD_256QM]
  MODS_NAME=["BPSK", "QPSK", "16-QAM", "64-QAM", "256-QAM"]

  CODEDBITS_SYMBOL_BPSK=48*1
  CODEDBITS_SYMBOL_QPSK=48*2
  CODEDBITS_SYMBOL_16QAM=48*4
  CODEDBITS_SYMBOL_64QAM=48*6
  CODEDBITS_SYMBOL_256QAM=48*8

  CODEDBITS_SYMBOL=[
    CODEDBITS_SYMBOL_BPSK,
    CODEDBITS_SYMBOL_QPSK,
    CODEDBITS_SYMBOL_16QAM,
    CODEDBITS_SYMBOL_64QAM,
    CODEDBITS_SYMBOL_256QAM
  ]

  CODING_RATE_1_2=(1.0/2.0)
  CODING_RATE_2_3=(2.0/3.0)
  CODING_RATE_3_4=(3.0/4.0)
  CODING_RATES = [
    CODING_RATE_1_2,
    CODING_RATE_2_3,
    CODING_RATE_3_4,
  ]
  CODING_RATES_NAME=[
    "1/2", "3/4", "2/3"
  ]

  def print_list
    print "mod\tMbps\tRate\tCDB/S\tDB/s\n"
    MODS.each do |mod|
      CODING_RATES.each_with_index do |rate, idx|
        # bits/symbol
        cbits_per_symbol = CODEDBITS_SYMBOL[mod]
        # bits/symbol = bits/symbol * rate
        databits_per_symbol = cbits_per_symbol * rate
        # bits/sec = bits/symbol / sec/symbol
        bps = databits_per_symbol / SYMBOL_SEC
        mbps = bps / 1000.0 / 1000.0

        print "#{MODS_NAME[mod]}\t#{mbps.to_i}\t#{CODING_RATES_NAME[idx]}\t#{cbits_per_symbol}\t#{databits_per_symbol}\n"
      end
    end
  end
end

if __FILE__ == $0
  OFDM.new.print_list
end
