mdl = 'Autotrans_online';

% Parameters
max_rob = 500;              % initial robustness is between -max_rob, +max_rob
rob_up_lim = -max_rob;  % stops when rob_up is below 
rob_low_lim = max_rob; 
rob_diff_lim = -inf;

diagnoser = 0;

input = [66.1945   77.0286   35.0218   66.2010  135.2515  273.6270  270.6980   83.3433];

phi_autotrans = 'alw_[0,30](not(speed[t] > 50) or ev_[1,3](RPM[t] < 3000))';

AT = BreachSimulinkSystem(mdl);

input_gen.type = 'UniStep';
input_gen.cp = 4;
AT.SetInputGen(input_gen);

d = 0;
diagnoser = d;
times = 10;

AT.SetParam({'Throttle_u0', 'Throttle_u1', 'Throttle_u2', 'Throttle_u3', 'Brake_u0', 'Brake_u1', 'Brake_u2', 'Brake_u3'}, input);
AT.SetParam({'max_rob', 'diagnoser'}, [max_rob, d]);

AT.ResetSimulations();
AT.Sim(0:.01:30);