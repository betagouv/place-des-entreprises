module Stats::Matches
  class All < Stats::All
    def transmitted_less_than_72h_stats
      TransmittedLessThan72hStats.new(@params)
    end

    def positioning_rate
      PositioningRate.new(@params)
    end
  end
end
