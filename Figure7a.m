InitBreach;

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

phi_AFC = 'ev_[10, 30] (alw_[5,10] (abs(AF[t]-AFref[t])>1))';

subform = 'L';
diagnoser = 2;

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

phi_AFC = 'alw_[10, 50](abs(AF[t]-AFref[t]) < 0.1 )'; 
input = [14.6189808085505	50.1158556033517	1054.98209294230	1063.46064413069	1073.73894107270];

d = 0;

BrAFC.ResetSimulations();
BrAFC.SetParam({'Pedal_Angle_pulse_period', 'Pedal_Angle_pulse_amp', 'Engine_Speed_u0','Engine_Speed_u1','Engine_Speed_u2'}, input);
BrAFC.SetParam({'max_rob', 'diagnoser'}, [0.5, d]);


times = 1;
tic
for i = 1:times
    BrAFC.ResetSimulations();
    BrAFC.Sim(0:.1:50);
end

simTime = toc;
one_sim_time = simTime/times;
% 
Trace = BrAFC.GetTraces();
idx = FindParam(BrAFC.Sys, {'rob_low', 'rob_up'});
t = Trace{1}.time;

%% ==============
%begin plotting
close 
figure(1);
subplot(5,1,1)

%plot(t,Trace{1}.X(1,:)',t(2:end),Trace{1}.X(2,2:end)', 'b', 'LineWidth', 2);
plot(t,Trace{1}.X(1,:)',t(2:end),Trace{1}.X(2,2:end)', 'b', 'LineWidth', 2);
set(gca, 'LineWidth', 2, 'FontSize',18)
%set(gcf,'position',[10,10,200,200])


legend({'AF','AFref'});
grid on;
xlim([0 50]);
xticks(0:5:50);

g = title(phi_AFC);
set(g,'Interpreter','None')
subplot(5,1,2);
%subplot(3,1,[2 3]);
hold on;

%==================== d=0 ================

stairs(t, Trace{1}.X(idx(2),:)',  'LineWidth', 2);
stairs(t, Trace{1}.X(idx(1),:)',  'LineWidth', 2);

set(gca, 'LineWidth', 2, 'FontSize',18)
set(gcf,'position',[10,10,800,500])
%set(gcf,'position',[10,10,800,250])
xlim([0 50]);
xticks(0:5:50);

ylim([-0.5 0.5]);
yticks(-0.5:0.5:0.5);

legend({'Upper robustness','Lower robustness'});
grid on;


%hold on;
%=================== d=2 ====================
subplot(5,1,3);
hold on;
d = 2;

BrAFC.ResetSimulations();
BrAFC.SetParam({'Pedal_Angle_pulse_period', 'Pedal_Angle_pulse_amp', 'Engine_Speed_u0','Engine_Speed_u1','Engine_Speed_u2'}, input);
BrAFC.SetParam({'max_rob', 'diagnoser'}, [0.5, d]);

times = 1;
tic
for i = 1:times
    BrAFC.ResetSimulations();
    BrAFC.Sim(0:.1:50);
end

simTime = toc;
one_sim_time = simTime/times;
% 
Trace = BrAFC.GetTraces();
idx = FindParam(BrAFC.Sys, {'rob_low', 'rob_up'});
t = Trace{1}.time;


stairs(t, Trace{1}.X(idx(2),:)',  'LineWidth', 2);
stairs(t, Trace{1}.X(idx(1),:)',  'LineWidth', 2);

set(gca, 'LineWidth', 2, 'FontSize',18)
set(gcf,'position',[10,10,800,500])
%set(gcf,'position',[10,10,800,250])
xlim([0 50]);
xticks(0:5:50);

ylim([-0.5 0.5]);
yticks(-0.5:0.5:0.5);

legend({'Upper robustness','Lower robustness'});
grid on;
%=================== d = 3 ====================

subplot(5,1,4);
hold on;
d = 3;

BrAFC.ResetSimulations();
BrAFC.SetParam({'Pedal_Angle_pulse_period', 'Pedal_Angle_pulse_amp', 'Engine_Speed_u0','Engine_Speed_u1','Engine_Speed_u2'}, input);
BrAFC.SetParam({'max_rob', 'diagnoser'}, [0.5, d]);

times = 1;
tic
for i = 1:times
    BrAFC.ResetSimulations();
    BrAFC.Sim(0:.1:50);
end

simTime = toc;
one_sim_time = simTime/times;
% 
Trace = BrAFC.GetTraces();
idx = FindParam(BrAFC.Sys, {'rob_low', 'rob_up'});
t = Trace{1}.time;

tr = [];
u = Trace{1}.X(idx(2),:);
l = Trace{1}.X(idx(1),:);
for i = 1:numel(t)
    if u(i) < 0
        tr = [tr -1];
    elseif l(i) > 0
        tr = [tr 1];
    else
        tr = [tr 0];
    end
end
plot(t, tr, 'LineWidth', 2);
set(gca, 'LineWidth', 2, 'FontSize',18);

set(gca, 'LineWidth', 2, 'FontSize',18)
set(gcf,'position',[10,10,800,500])
%set(gcf,'position',[10,10,800,250])
xlim([0 50]);
xticks(0:5:50);
ylim([-1 1]);
legend({'Boolean causation monitor verdict'})
grid on;
%=========== d=4 =================
subplot(5,1,5);
hold on;
d = 4;

BrAFC.ResetSimulations();
BrAFC.SetParam({'Pedal_Angle_pulse_period', 'Pedal_Angle_pulse_amp', 'Engine_Speed_u0','Engine_Speed_u1','Engine_Speed_u2'}, input);
BrAFC.SetParam({'max_rob', 'diagnoser'}, [0.5, d]);

times = 1;
tic
for i = 1:times
    BrAFC.ResetSimulations();
    BrAFC.Sim(0:.1:50);
end

simTime = toc;
one_sim_time = simTime/times;
% 
Trace = BrAFC.GetTraces();
idx = FindParam(BrAFC.Sys, {'rob_low', 'rob_up'});
t = Trace{1}.time;

stairs(t, Trace{1}.X(idx(2),:)',  'LineWidth', 2);
stairs(t, Trace{1}.X(idx(1),:)',  'LineWidth', 2);

set(gca, 'LineWidth', 2, 'FontSize',18)
set(gcf,'position',[10,10,800,500])
%set(gcf,'position',[10,10,800,250])
xlim([0 50]);
xticks(0:5:50);

ylim([-0.5 0.5]);
yticks(-0.5:0.5:0.5);

legend({'Violation causation distance','Satisfaction causation distance'});
grid on;

%%
save2pdf('CausationOnlinePlot.pdf')    