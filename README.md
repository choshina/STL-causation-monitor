# Online Causation Monitoring of Signal Temporal Logic
This repository is for the artifact evaluation of the paper "Online Causation Monitoring of Signal Temporal Logic", accepted by CAV 2023.

***
## Repository structure

```

├── Figure7a.m
├── Figure7b.m
├── Install.m
├── LICENSE
├── README.md
├── Tables.m
├── breach
│   ├── @STL_Formula
│   ├── CHANGELOG.md
│   ├── Contents.m
│   ├── Core
│   ├── Doc
│   ├── Examples
│   ├── Ext
│   ├── InitBreach.m
│   ├── InstallBreach.m
│   ├── LICENSE
│   ├── Online
│   │   ├── Makefile
│   │   ├── bin
│   │   ├── experiment
│   │   │   ├── effect_AFC.png
│   │   │   └── effect_AT.png
│   │   ├── include
│   │   │   ├── FlexLexer.h
│   │   │   ├── interval.h
│   │   │   ├── location.hh
│   │   │   ├── position.hh
│   │   │   ├── robustness.h
│   │   │   ├── signal.h
│   │   │   ├── signal_expr.h
│   │   │   ├── stack.hh
│   │   │   ├── stdafx.h
│   │   │   ├── stl_driver.h
│   │   │   ├── stl_parser.h
│   │   │   ├── stl_scanner.h
│   │   │   ├── tools.h
│   │   │   ├── transducer.h
│   │   │   └── y.tab.h
│   │   ├── m_src
│   │   │   └── compile_stl_mex.m
│   │   ├── obj
│   │   ├── simulink_stlib
│   │   │   ├── slblocks.m
│   │   │   └── slstlib.slx
│   │   └── src
│   │       ├── Makefile_Parser
│   │       ├── interval.cpp
│   │       ├── interval_transducer.cpp
│   │       ├── main.cpp
│   │       ├── onlineMonitorWrapper.cpp
│   │       ├── robustness.cpp
│   │       ├── signal.cpp
│   │       ├── signal_expr.cpp
│   │       ├── stl_atom.cpp
│   │       ├── stl_driver.cpp
│   │       ├── stl_eval_mex.cpp
│   │       ├── stl_monitor.cpp
│   │       ├── stl_parser.cpp
│   │       ├── stl_parser.ypp
│   │       ├── stl_scanner.cpp
│   │       ├── stl_scanner.lpp
│   │       ├── tools.cpp
│   │       ├── transducer.cpp
│   │       └── update_transducer.cpp
│   ├── Params
│   ├── Plots
│   ├── README.md
│   └── VERSION
├── log.txt
└── models
    ├── AFC_online
    │   ├── AbstractFuelControl_M1.slx
    │   ├── FC_init_warm.m
    │   ├── FC_online.slx
    │   ├── Init_BrAFC.m
    │   ├── plot_examples.m
    │   └── settling_spec.stl
    ├── Autotrans_online
    │   ├── AT_init_warm.m
    │   ├── Autotrans.slx
    │   ├── Autotrans_online.mdl
    │   ├── autotrans_signal_builder.slx
    │   ├── init_monitor.m
    │   ├── test_falsify.m
    │   └── test_falsify_online.m
    ├── NN_online
    │   ├── NN_online.slx
    │   └── init_NN.m
    └── random_gen
        └── random_gen.slx
```

***

## System requirement

- Operating system: Linux or MacOS;

- MATLAB (Simulink/Stateflow) version: >= 2020a. (MATLAB license needed)

## Installation of our tool:

- Clone the repository, via `https://github.com/choshina/STLCausationMonitor.git`
  
  > Alternatively, you can download this repository via the URL: .

- Start MATLAB GUI, set up a C/C++ compiler using the command `mex -setup`. (Refer to [here](https://www.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html) for more details.)
  > Running with MATLAB in shell is also OK. 
  
- Navigate to the project home, and run `InstallBreach`
  > Note that we customized `InstallBreach`. It only compiles the online monitoring component. For the full functionality of Breach, please refer to [the original repository](https://github.com/decyphir/breach)

***

## Instructions on reproduction of experiment results

 ### Reproduce Figure 7a:
 - Run the script in MATLAB commandline: `Figure7a`
 
 ### Reproduce Figure 7b:
 - Run the script in MATLAB commandline: `Figure7b`
 
 ### Reproduce Table 1 and Table 2:
 
 Table 1 and Table 2 are based on the execution time of the **monitoring block** and the **Simulink model** as a whole, for each trace and each specification. Note the execution time is heavily dependent on the execution environment, e.g., the hardware condition, the OS, so we don't expect the users to exactly reproduce the data in the paper. Nevertheless, the comparison between different data entries, and the magnitude difference between data entries, should be roughly held as in the paper. 
 
 - Run the script in MATLAB commandline: `Tables`
   - According to the prompt, select the specification you want to check
   - According to the prompt, input the number of repeatations for each trace
      > The data obtained in the table are based on 10 repeated executions for each trace and each specification. However, it can take quite some time to obtain the results if the repeatation number is set up to 10. Here, as we test, setting as 3 is fine.
   - During the running, the console displayes the running progress. 
   - After it finishes, the console will display the corresponding row in Table 1, and the corresponding sub-table in Table 2.
 
 ***
 
 ## Usage of this tool on new problem instances
 
   ### New traces
   
   ### New specifications
   
   ### New Simulink models
