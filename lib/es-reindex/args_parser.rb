class ESReindex
  class ArgsParser

    def self.parse(args)
      remove, update, frame, src, dst = false, false, 1000, nil, nil

      while args[0]
        case arg = args.shift
        when '-r' then remove = true
        when '-f' then frame  = args.shift.to_i
        when '-u' then update = true
        else
          u = arg.chomp '/'
          !src ? (src = u) : !dst ? (dst = u) :
            raise("Unexpected parameter '#{arg}'. Use '-h' for help.")
        end
      end

      return src, dst, {
        remove: remove,
        frame:  frame,
        update: update
      }
    end
  end
end
