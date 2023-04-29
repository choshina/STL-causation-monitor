# Online Causation Monitoring of Signal Temporal Logic
This repository is for the artifact evaluation of the paper "Online Causation Monitoring of Signal Temporal Logic", accepted by CAV 2023.

***

## System requirement

- Operating system: Linux or MacOS;

- MATLAB (Simulink/Stateflow) version: >= 2020a. (MATLAB license needed)

## Installation of our tool:

- Clone the repository, via `https://github.com/choshina/STL-causation-monitor.git`
  
  > Alternatively, you can download this repository via the URL: .

- Start MATLAB GUI, set up a C/C++ compiler using the command `mex -setup`. (Refer to [here](https://www.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html) for more details.)
  > Running with MATLAB in shell is also OK. 
  
- Navigate to the project home, and run `Install`


***

## Instructions on reproduction of experiment results

 ### Reproduce Figure 7a:
 - Run the script in MATLAB commandline: `Figure7a`
 - The figure will be shown, and also will be stored as a pdf.
 
 ### Reproduce Figure 7b:
 - Run the script in MATLAB commandline: `Figure7b`
 - The figure will be shown, and also will be stored as a pdf.
 
 ### Reproduce Table 1 and Table 2:
 
 Table 1 and Table 2 are based on the execution time of the **monitoring block** and the **Simulink model** as a whole, for each trace and each specification. Note the execution time is heavily dependent on the execution environment, e.g., the hardware condition, the OS, so we don't expect the users to exactly reproduce the data in the paper. Nevertheless, the comparison between different data entries, and the magnitude difference between data entries, should be roughly held as in the paper. 
 
 - Run the script in MATLAB commandline: `Tables`
   - According to the prompt, select the specification you want to check
   - According to the prompt, input the number of repeatations for each trace
      > The data obtained in the table are based on 10 repeated executions for each trace and each specification. However, it can take quite some time to obtain the results if the repeatation number is set up to 10. Here, this number can be set as a smaller one to save time, but the results can suffer more from the perturbance of running environment.
   - During the running, the console displayes the running progress. 
   - After it finishes, the console will display the corresponding row in Table 1, and the corresponding sub-table in Table 2.
 
 ***
 
 ## Usage of this tool on new problem instances
 
   ### New traces
   The test suite of traces can be updated via the `FC_input` and `AT_input` in `Tables.m`. Note that these two variables store the input signals required in the form of the models, and your new inputs must satisfy the constraints of the input signals. 
   
   The meaning and constraints of each dimension in `FC_input` is as follows:
   - `Pedal_Angle_pulse_period`: `[5 15]`
   - `Pedal_Angle_pulse_amp`: `[50 75]`
   - `Engine_Speed_u0`: `[900 1100]`
   - `Engine_Speed_u1`: `[900 1100]`
   - `Engine_Speed_u2`: `[900 1100]`

   The meaning and constraints of each dimension in `AT_input` is as follows:
   - `Throttle_u0`~`Throttle_u3`: `[0 100]`
   - `Brake_u0`~`Brake_u3`: `[0 325]`
   
   One can add new inputs or change inputs, by updating the contents of these two variables. Each row represents one input.
   
   For example, you can change `FC_input` to be `FC_input = [10 55 1000 1000 1000];`.
   
   ### New specifications
   New specifications can be tested, by modifying the variable of `spec_str`. One can add new specification or change the existing one in `spec_str`. Then, the variable `spec` should be used as the index of the desired specification in `spec_str`. Currently, `spec` is as per the user input; one can also hard-code the value of `spec` to make it point to the desired specification.
   
   The syntax of STL specification should follow the format in [Breach](https://github.com/decyphir/breach#writing-stl-requirements-in-a-file).
   
   ### New Simulink models
   Adding new simulink models requires the users to add a new block in the user-provided Simulink models. 
   
   Please refer to `models/NN_online`, where there is [this instruction](https://github.com/choshina/STL-causation-monitor/blob/main/models/NN_online/README.md) with the example of Neural Network Controller model for an illustration.
   
   To run with the example, please go to `models/NN_online/`, and run `init_NN.m`
   
 ***

## Repository structure

We only show the most relevant part to this project. For other functions of Breach, please refer to the [original repository](https://github.com/decyphir/breach) of Breach.

Some relevant directories:
- `breach/Online/include` and `breach/Online/src`: these two directories store the source code of our online causation monitoring. `onlineMonitorWrapper.cpp` is the main function of the S-function component.
- `models`: this directory stores the Simulink models and the necessary scripts to run the tool. Specifically, `models/NN_online/` stores a neural network controller model that does not appear in the paper, for an illustration of handling new Simulink models.

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
