fuel_inj_tol = 1.0; 
MAF_sensor_tol = 1.0;
AF_sensor_tol = 1.0; 
pump_tol = 1.;
kappa_tol=1; 
tau_ww_tol=1;
fault_time=50;
kp = 0.04;
ki = 0.14;

% online block init

max_rob = 5;
rob_up_lim = -5;
rob_low_lim = 5;
rob_diff_lim = -inf;

phi_AFC = 'alw_[10, 50](abs(AF[t]-AFref[t]) < 0.1 )';

subform = 'L';
diagnoser = 0;

%mdl = 'AbstractFuelControl_M1';
mdl = 'FC_online';
BrAFC = BreachSimulinkSystem(mdl);

Br0 = BrAFC.copy();
pedal_angle_gen = pulse_signal_gen({'Pedal_Angle'}); % Generate a pulse signal for pedal angle
engine_gen      = fixed_cp_signal_gen({'Engine_Speed'}, ... % signal name
                                       3,...                % number of control points
                                      {'spline'});       % interpolation method 
        
InputGen = BreachSignalGen({pedal_angle_gen, engine_gen});

InputGen.SetParam({'Engine_Speed_u0','Engine_Speed_u1','Engine_Speed_u2'},...
                        [1000 1100 500]);

InputGen.SetParam({'Pedal_Angle_base_value', 'Pedal_Angle_pulse_period', ...
                         'Pedal_Angle_pulse_amp','Pedal_Angle_pulse_width'}, ... 
                         [0 15 30 .5]);
   
BrAFC.SetInputGen(InputGen);



%spec = 'alw_[10, 50](abs(AF[t]-AFref[t]) < 0.1 )'; 
phi_AFC = 'alw_[10, 50](abs(AF[t]-AFref[t]) < 0.1 )';
input = [14.6189808085505	50.1158556033517	1054.98209294230	1063.46064413069	1073.73894107270];

d = 0;

BrAFC.ResetSimulations();
BrAFC.SetParam({'Pedal_Angle_pulse_period', 'Pedal_Angle_pulse_amp', 'Engine_Speed_u0','Engine_Speed_u1','Engine_Speed_u2'}, input);
BrAFC.SetParam({'max_rob', 'diagnoser'}, [0.5, d]);

BrAFC.ResetSimulations();
BrAFC.Sim(0:.1:50);