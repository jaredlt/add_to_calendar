module AddToCalendar
  class RecurrenceSettings
    # @todo add more tests, check 'yearly' events, implement converting params to other resources instead RRULE
    #
    # possible values:
    #   freq: 'weekly', 'monthly', 'daily', 'yearly'
    #   byday: 'Su,Mo', 1, [1,2,3]
    #   bymonthday: 1 (for 'monthly' and 'yearly' freq)
    #   interval: 1 (interval between days, weeks, months, years)
    #   count: (count repeats of event)
    #   end_at: datetime or string (RRULE UNTIL)

    #   freq: 'yearly'
    #     bymonth: '1,2'

    #   freq: 'monthly'
    #     monthly_week: 1 (required monthly_week_day)
    #     monthly_week_day: 2 (required monthly_week)
    #     (both of them will be in RRULE BYDAY)

    # more info about RRULE https://icalendar.org/iCalendar-RFC-5545/3-8-5-3-recurrence-rule.html

    RRULES_ATTRS = %i[freq byday bymonth bymonthday interval count].freeze
    ATTRS = (RRULES_ATTRS + %i[end_at monthly_week monthly_week_day]).freeze

    attr_accessor(*ATTRS)

    def initialize(options = {})
      ATTRS.each do |atr|
        self.send("#{atr}=", options[atr]) unless options[atr].nil?
      end
    end

    class << self
      def prepare_rrule_key(atr)
        case atr
        when :monthly_week
          'BYDAY'
        when :end_at
          'UNTIL'
        else
          atr.upcase
        end
      end

      def prepare_byday(val, separator = ',')
        return val if val.is_a?(String)

        return day_num_to_s(val) if val.is_a?(Integer)

        return val.sort.map { |v| day_num_to_s(v.to_i) }.join(separator) if val.is_a?(Array)

        val
      end

      def day_num_to_s(num)
        days = Date::DAYNAMES.dup
        (days + [days.shift])[num - 1].to_s[0..1]
      end
    end

    # REND is depricated and currently no way to send recurrence settings
    def to_yahoo
      return ''
      #   # REND – the end date & time. This is represented by the total number of seconds since 1/1/1970 12:00:00 AM.
      #   # RPAT – the duration of between repeats. Here are a few values you can use:
      #   # Day: 01Dy
      #   # Week: 01Wk
      #   # Month: 01Mh
      #   # Year: 01Yr
      #   # Mon Wedn Fri: 01MoWeFr
      #   # Tues Thurs: 01TuTh
      #   # Mon – Fri: 01MoTuWeThFr
      #   # Sat – Sun: 01SuSa

      #   params = { rend: end_at.to_i }

      #   params[:rpat] = case freq
      #   when 'daily'
      #     "#{interval}Dy"
      #   when 'weekly'
      #     res = [interval.to_s.size == 1 ? "0#{interval}" : interval]
      #     res << (byday.empty? ? 'Wk' : self.class.prepare_byday(byday, ''))
      #     res.join
      #   else
      #     return {}
      #   end

      #   params
    end

    def to_rrule(prefix = 'RRULE:')
      @to_rrule ||= {}

      @to_rrule[prefix] ||= begin
        res = []

        (RRULES_ATTRS + [:monthly_week, :end_at]).each do |atr|
          val = send(atr)

          unless val.nil?
            res << "#{self.class.prepare_rrule_key(atr)}=#{prepare_rrule atr, val}"
          end
        end

        return '' if res.empty?

        "#{prefix}#{res.sort_by { |k, _v| k }.join(';')}"
      end
    end

    protected

    def prepare_rrule(atr, val)
      val = val.dup

      case atr
      when :freq
        val.upcase!
      when :byday
        return self.class.prepare_byday(val).upcase
      when :end_at
        return val if val.is_a?(String)

        val = val.strftime('%Y%m%dT%H%M%SZ')
      when :monthly_week
        val = [val, self.class.day_num_to_s(monthly_week_day)].join
      end

      val
    end
  end
end
