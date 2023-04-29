InitBreach;

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
times = 1;

AT.SetParam({'Throttle_u0', 'Throttle_u1', 'Throttle_u2', 'Throttle_u3', 'Brake_u0', 'Brake_u1', 'Brake_u2', 'Brake_u3'}, input);
AT.SetParam({'max_rob', 'diagnoser'}, [max_rob, d]);

% AT.ResetSimulations();
% AT.Sim(0:.01:30);
% disp('\n')

tic
for i = 1:times
    AT.ResetSimulations();
    AT.Sim(0:.01:30);
end

simTime = toc;
one_sim_time = simTime/times;


Trace = AT.GetTraces();
idx = FindParam(AT.Sys, {'rob_low', 'rob_up'});
t = Trace{1}.time;

close 
figure;
subplot(5,1,1)

% plot(t,Trace{1}.X(2,:)',t(2:end),Trace{1}.X(6,2:end)', 'LineWidth', 2);
% set(gca, 'LineWidth', 2, 'FontSize',18)
yyaxis right
plot(t,Trace{1}.X(1,:)', 'LineWidth', 2);
set(gca, 'LineWidth', 2, 'FontSize',18)

yyaxis left
plot(t(2:end),Trace{1}.X(6,2:end)', 'LineWidth', 2);


legend({'speed','RPM'});
grid on;
xlim([0 30]);
xticks(0:5:30);

g = title(phi_autotrans);
set(g,'Interpreter','None')

%============== d=0 ===================
subplot(5,1,2);
hold on;



stairs(t, Trace{1}.X(idx(2),:)', 'LineWidth', 2);
stairs(t, Trace{1}.X(idx(1),:)', 'LineWidth', 2);

xlim([0 30]);
xticks(0:5:30);

ylim([-max_rob max_rob]);

set(gca, 'LineWidth', 2, 'FontSize',18)
set(gcf,'position',[10,10,800,500])

legend({'Upper robustness','Lower robustness'});
grid on;


%============== d=2 ===================
subplot(5,1,3);
hold on;

d = 2;
diagnoser = d;
times = 1;

AT.SetParam({'Throttle_u0', 'Throttle_u1', 'Throttle_u2', 'Throttle_u3', 'Brake_u0', 'Brake_u1', 'Brake_u2', 'Brake_u3'}, input);
AT.SetParam({'max_rob', 'diagnoser'}, [max_rob, d]);

% AT.ResetSimulations();
% AT.Sim(0:.01:30);
% disp('\n')

tic
for i = 1:times
    AT.ResetSimulations();
    AT.Sim(0:.01:30);
end

simTime = toc;
one_sim_time = simTime/times;


Trace = AT.GetTraces();
idx = FindParam(AT.Sys, {'rob_low', 'rob_up'});
t = Trace{1}.time;


stairs(t, Trace{1}.X(idx(2),:)', 'LineWidth', 2);
stairs(t, Trace{1}.X(idx(1),:)', 'LineWidth', 2);

xlim([0 30]);
xticks(0:5:30);

ylim([-max_rob max_rob]);

set(gca, 'LineWidth', 2, 'FontSize',18)
set(gcf,'position',[10,10,800,500])

legend({'Upper robustness','Lower robustness'});
grid on;
%============== d=3 ===================

subplot(5,1,4);
hold on;

d = 3;
diagnoser = d;
times = 1;

AT.SetParam({'Throttle_u0', 'Throttle_u1', 'Throttle_u2', 'Throttle_u3', 'Brake_u0', 'Brake_u1', 'Brake_u2', 'Brake_u3'}, input);
AT.SetParam({'max_rob', 'diagnoser'}, [max_rob, d]);

% AT.ResetSimulations();
% AT.Sim(0:.01:30);
% disp('\n')

tic
for i = 1:times
    AT.ResetSimulations();
    AT.Sim(0:.01:30);
end

simTime = toc;
one_sim_time = simTime/times;


Trace = AT.GetTraces();
idx = FindParam(AT.Sys, {'rob_low', 'rob_up'});
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
for i = 2:numel(t-1)
    if tr(i)~=tr(i-1) && tr(i)~=tr(i+1)
        tr(i) = tr(i-1);
    end
end
plot(t, tr, 'LineWidth', 2);
set(gca, 'LineWidth', 2, 'FontSize',18)

xlim([0 30]);
xticks(0:5:30);

ylim([-1 1]);

set(gca, 'LineWidth', 2, 'FontSize',18)
set(gcf,'position',[10,10,800,500])

legend({'Boolean causation monitor verdict'})

grid on;
%============== d=4 ===================

subplot(5,1,5);
hold on;

d = 4;
diagnoser = d;
times = 1;

AT.SetParam({'Throttle_u0', 'Throttle_u1', 'Throttle_u2', 'Throttle_u3', 'Brake_u0', 'Brake_u1', 'Brake_u2', 'Brake_u3'}, input);
AT.SetParam({'max_rob', 'diagnoser'}, [max_rob, d]);

% AT.ResetSimulations();
% AT.Sim(0:.01:30);
% disp('\n')

tic
for i = 1:times
    AT.ResetSimulations();
    AT.Sim(0:.01:30);
end

simTime = toc;
one_sim_time = simTime/times;


Trace = AT.GetTraces();
idx = FindParam(AT.Sys, {'rob_low', 'rob_up'});
t = Trace{1}.time;

stairs(t, Trace{1}.X(idx(2),:)', 'LineWidth', 2);
stairs(t, Trace{1}.X(idx(1),:)', 'LineWidth', 2);

xlim([0 30]);
xticks(0:5:30);

ylim([-max_rob max_rob]);

set(gca, 'LineWidth', 2, 'FontSize',18)
set(gcf,'position',[10,10,800,500])

legend({'Violation causation distance','Satisfaction causation distance'});
grid on;

save2pdf('CausationOnlinePlot.pdf')   