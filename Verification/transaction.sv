class transaction;

  rand bit oper;          // Randomized bit for operation control (1 or 0)
  bit rd, wr;              // Read and write control bits
  bit [7:0] data_in;       // 8-bit data input
  bit full, empty;         // Flags for full and empty status
  bit [7:0] data_out;      // 8-bit data output

  constraint oper_ctrl {
    oper dist {1 :/ 50 , 0 :/ 50};  // Constraint to randomize 'oper' with 50% probability of 1 and 50% probability of 0
  }

  // Functional coverage group -- sampled explicitly from the monitor
  // once wr/rd/full/empty/data_in/data_out are all populated for a cycle.
  covergroup cov_grp;
    option.per_instance = 1;
    option.comment = "FIFO transaction coverage";

    OPER: coverpoint oper {
      bins write_req = {1};
      bins read_req  = {0};
    }

    WR: coverpoint wr {
      bins wr_low  = {0};
      bins wr_high = {1};
    }

    RD: coverpoint rd {
      bins rd_low  = {0};
      bins rd_high = {1};
    }

    FULL: coverpoint full {
      bins not_full = {0};
      bins is_full  = {1};
    }

    EMPTY: coverpoint empty {
      bins not_empty = {0};
      bins is_empty  = {1};
    }

    DATA_IN: coverpoint data_in {
      bins low  = {[0:3]};
      bins mid  = {[4:7]};
      bins high = {[8:10]};
      bins others = default;
    }

    DATA_OUT: coverpoint data_out {
      bins low  = {[0:3]};
      bins mid  = {[4:7]};
      bins high = {[8:10]};
      bins others = default;
    }

    // Cross coverage -- the interesting corner cases:
    // writing while full, reading while empty.
    WR_FULL_CROSS:   cross WR, FULL;
    RD_EMPTY_CROSS:  cross RD, EMPTY;

  endgroup

  function new(string inst_name = "cov_grp");
    cov_grp = new();
    cov_grp.set_inst_name(inst_name);
  endfunction

endclass
endclass
