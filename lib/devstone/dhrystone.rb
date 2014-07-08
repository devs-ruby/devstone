module DEVStone

  module Dhrystone
    VERSION = '1.1'.freeze
    LOOPS   = 5000

    IDENT1 = 0
    IDENT2 = 1
    IDENT3 = 2
    IDENT4 = 3
    IDENT5 = 4

    Record = Struct.new(:ptr_comp, :discr, :enum_comp, :int_comp, :string_comp)

    @int_glob = 0
    @bool_glob = false
    @char1_glob = '\0'
    @char2_glob = '\0'
    @array1_glob = Array.new(51, 0)
    @array2_glob = Array.new(51) { Array.new(51, 0) }
    @ptr_glob = nil
    @ptr_glob_next = nil

    class << self
      attr_accessor :int_glob, :bool_glob, :char1_glob, :char2_glob,
                    :array1_glob, :array2_glob, :ptr_glob, :ptr_glob_next
    end

    module_function

    def run(loops = LOOPS)
      bench_time, stones = proc0(loops)
      puts "Dhrystone Ruby v#{VERSION} time for #{loops} passes: #{bench_time}"
      puts "This machine benchmarks at #{stones} stones/second"
    end

    def run_for(time = 1.0)
      proc01(time) unless time.zero?
    end

    def proc01(time)
      Dhrystone.ptr_glob_next = Record.new
      Dhrystone.ptr_glob = Record.new(Dhrystone.ptr_glob_next, IDENT2, IDENT3, 40, 'DHRYSTONE PROGRAM, SOME STRING')
      string1 = "DHRYSTONE PROGRAM, 1'ST STRING"
      Dhrystone.array2_glob[8][7] = 10

      start_time = Time.now
      bench_time = start_time

      begin
        proc5
        proc4
        int1 = 2
        int2 = 3
        int3 = 0
        string2 = "DHRYSTONE PROGRAM, 2'ND STRING"
        enum = IDENT2
        Dhrystone.bool_glob = !func2(string1, string2)
        while int1 < int2
          int3 = 5 * int1 - int2
          int3 = proc7(int1, int2)
          int1 = int1 + 1
        end
        proc8(Dhrystone.array1_glob, Dhrystone.array2_glob, int1, int3)
        Dhrystone.ptr_glob = proc1(Dhrystone.ptr_glob)
        chr_idx = 'A'
        while chr_idx <= Dhrystone.char2_glob
          enum = proc6(IDENT1) if enum == func1(chr_idx, 'C')
          chr_idx = (chr_idx.ord + 1).chr
        end
        int3 = int2 * int1
        int2 = int3 / int1
        int2 = 7 * (int3 - int2) - int1
        int1 = proc2(int1)

        bench_time = Time.now - start_time
      end until bench_time >= time

      bench_time
    end

    def proc0(n)
      start_time = Time.now
      n.times {}
      null_time = Time.now - start_time

      Dhrystone.ptr_glob_next = Record.new
      Dhrystone.ptr_glob = Record.new(Dhrystone.ptr_glob_next, IDENT2, IDENT3, 40, 'DHRYSTONE PROGRAM, SOME STRING')
      string1 = "DHRYSTONE PROGRAM, 1'ST STRING"
      Dhrystone.array2_glob[8][7] = 10

      start_time = Time.now

      n.times do
        proc5
        proc4
        int1 = 2
        int2 = 3
        int3 = 0
        string2 = "DHRYSTONE PROGRAM, 2'ND STRING"
        enum = IDENT2
        Dhrystone.bool_glob = !func2(string1, string2)
        while int1 < int2
          int3 = 5 * int1 - int2
          int3 = proc7(int1, int2)
          int1 = int1 + 1
        end
        proc8(Dhrystone.array1_glob, Dhrystone.array2_glob, int1, int3)
        Dhrystone.ptr_glob = proc1(Dhrystone.ptr_glob)
        chr_idx = 'A'
        while chr_idx <= Dhrystone.char2_glob
          enum = proc6(IDENT1) if enum == func1(chr_idx, 'C')
          chr_idx = (chr_idx.ord + 1).chr
        end
        int3 = int2 * int1
        int2 = int3 / int1
        int2 = 7 * (int3 - int2) - int1
        int1 = proc2(int1)
      end

      bench_time = Time.now - start_time - null_time

      loops_per_bench = if bench_time.zero?
                          0.0
                        else
                          n / bench_time
                        end

      [bench_time, loops_per_bench]
    end

    def proc1(ptr)
      ptr.ptr_comp = next_record = Dhrystone.ptr_glob.dup
      ptr.int_comp = 5
      next_record.int_comp = ptr.int_comp
      next_record.ptr_comp = ptr.ptr_comp
      next_record.ptr_comp = proc3(next_record.ptr_comp)

      if next_record.discr == IDENT1
        next_record.int_comp = 6
        next_record.enum_comp = proc6(ptr.enum_comp)
        next_record.ptr_comp = Dhrystone.ptr_glob.ptr_comp
        next_record.int_comp = proc7(next_record.int_comp, 10)
      else
        ptr = next_record.dup
      end

      next_record.ptr_comp = nil

      ptr
    end

    def proc2(v)
      int = v + 10
      enum = -1

      loop do
        if Dhrystone.char1_glob == 'A'
          int -= 1
          v = int - Dhrystone.int_glob
          enum = IDENT1
        end
        break if enum == IDENT1
      end

      v
    end

    def proc3(ptr)
      if Dhrystone.ptr_glob != nil
        ptr = Dhrystone.ptr_glob.ptr_comp
      else
        Dhrystone.int_glob = 100
      end

      Dhrystone.ptr_glob.int_comp = proc7(10, Dhrystone.int_glob)
      ptr
    end

    def proc4
      bool = Dhrystone.char1_glob == 'A'
      bool = bool || Dhrystone.bool_glob
      Dhrystone.char2_glob = 'B'
    end

    def proc5
      Dhrystone.char1_glob = 'A'
      Dhrystone.bool_glob = false
    end

    def proc6(enum)
      out = enum
      out = IDENT4 unless func3(enum)

      out = case enum
      when IDENT1
        IDENT1
      when IDENT2
        if Dhrystone.int_glob > 100
          IDENT1
        else
          IDENT4
        end
      when IDENT3
        IDENT2
      when IDENT5
        IDENT3
      end
    end

    def proc7(int1, int2)
      int = int1 + 2
      out = int2 + int
    end

    def proc8(ary1, ary2, int1, int2)
      int = int1 + 5
      ary1[int] = int2
      ary1[int+1] = ary1[int]
      ary1[int+30] = int

      i = int
      while i <= int+1
        ary2[int][i] = int
        i += 1
      end
      ary2[int][int-1] += 1
      ary2[int+20][int] = ary1[int]
      Dhrystone.int_glob = 5
    end

    def func1(char1, char2)
      c1 = char1
      c2 = c1

      if c2 != char2
        IDENT1
      else
        IDENT2
      end
    end

    def func2(str1, str2)
      i = 1
      while i <= 1
        if func1(str1[i], str2[i+1]) == IDENT1
          char = 'A'
          i += 1
        end
      end

      i = 7 if char >= 'W' && char <= 'Z'

      if char == 'X'
        true
      else
        if str1 > str2
          i += 7
          true
        else
          false
        end
      end
    end

    def func3(enum1)
      enum2 = enum1
      return true if enum2 == IDENT3
      false
    end
  end
end
