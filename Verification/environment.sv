class environment;

  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  mailbox #(transaction) gdmbx;  // Generator + Driver mailbox
  mailbox #(transaction) msmbx;  // Monitor + Scoreboard mailbox
  event nextgs;
  virtual fifo_if fif;

  function new(virtual fifo_if fif);
    gdmbx = new();
    gen = new(gdmbx);
    drv = new(gdmbx);
    msmbx = new();
    mon = new(msmbx);
    sco = new(msmbx);
    this.fif = fif;
    drv.fif = this.fif;
    mon.fif = this.fif;
    gen.next = nextgs;
    sco.next = nextgs;
  endfunction

  task pre_test();
    drv.reset();
  endtask

  task test();
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_any
  endtask

  task post_test();
    wait(gen.done.triggered);
    $display("---------------------------------------------");
    $display("Error Count :%0d", sco.err);
    $display("---------------------------------------------");
    $display("Functional Coverage Report (sampled via monitor)");
    $display("---------------------------------------------");
    $display("Overall Coverage   : %0.2f %%", mon.tr.cov_grp.get_coverage());
    $display("  OPER            : %0.2f %%", mon.tr.cov_grp.OPER.get_coverage());
    $display("  WR              : %0.2f %%", mon.tr.cov_grp.WR.get_coverage());
    $display("  RD              : %0.2f %%", mon.tr.cov_grp.RD.get_coverage());
    $display("  FULL            : %0.2f %%", mon.tr.cov_grp.FULL.get_coverage());
    $display("  EMPTY           : %0.2f %%", mon.tr.cov_grp.EMPTY.get_coverage());
    $display("  DATA_IN         : %0.2f %%", mon.tr.cov_grp.DATA_IN.get_coverage());
    $display("  DATA_OUT        : %0.2f %%", mon.tr.cov_grp.DATA_OUT.get_coverage());
    $display("  WR_FULL_CROSS   : %0.2f %%", mon.tr.cov_grp.WR_FULL_CROSS.get_coverage());
    $display("  RD_EMPTY_CROSS  : %0.2f %%", mon.tr.cov_grp.RD_EMPTY_CROSS.get_coverage());
    $display("---------------------------------------------");
    $finish();
  endtask

  task run();
    pre_test();
    test();
    post_test();
  endtask

endclass
