mdl = 'NN_online';

u_ts=0.001;

max_rob = 10;
diagnoser = 0;


input = [2.4 1.2 1.8 2.6];
phi_NN = 'alw_[0,20](Pos[t] < 3)';


NN = BreachSimulinkSystem(mdl);
input_gen.type = 'UniStep';
input_gen.cp = 4;
NN.SetInputGen(input_gen);

d = 0;
diagnoser = d;
times = 1;

NN.SetParam({'Ref_u0', 'Ref_u1', 'Ref_u2', 'Ref_u3'}, input);
NN.SetParam({'max_rob', 'diagnoser'}, [max_rob, d]);

tic
for i = 1:times
    NN.ResetSimulations();
    NN.Sim(0:.01:20);
end

simTime = toc;
one_sim_time = simTime/times;


Trace = NN.GetTraces();
idx = FindParam(NN.Sys, {'rob_low', 'rob_up'});
t = Trace{1}.time;

close 
figure;
subplot(3,1,1)

% plot(t,Trace{1}.X(2,:)',t(2:end),Trace{1}.X(6,2:end)', 'LineWidth', 2);
% set(gca, 'LineWidth', 2, 'FontSize',18)

plot(t,Trace{1}.X(6,:)', 'LineWidth', 2);
set(gca, 'LineWidth', 2, 'FontSize',18)


legend({'Pos'});
grid on;
xlim([0 20]);
xticks(0:5:20);

g = title(phi_NN);
set(g,'Interpreter','None')

%============== d=0 ===================
subplot(3,1,2);
hold on;



stairs(t, Trace{1}.X(idx(2),:)', 'LineWidth', 2);
stairs(t, Trace{1}.X(idx(1),:)', 'LineWidth', 2);

xlim([0 20]);
xticks(0:5:20);

ylim([-max_rob max_rob]);

set(gca, 'LineWidth', 2, 'FontSize',18)
set(gcf,'position',[10,10,800,500])

legend({'Upper robustness','Lower robustness'});
grid on;

%============== d=4 ===================

subplot(3,1,3);
hold on;

d = 4;
diagnoser = d;
times = 1;

NN.SetParam({'Ref_u0', 'Ref_u1', 'Ref_u2', 'Ref_u3'}, input);
NN.SetParam({'max_rob', 'diagnoser'}, [max_rob, d]);

tic
for i = 1:times
    NN.ResetSimulations();
    NN.Sim(0:.01:20);
end

simTime = toc;
one_sim_time = simTime/times;


Trace = NN.GetTraces();
idx = FindParam(NN.Sys, {'rob_low', 'rob_up'});
t = Trace{1}.time;

stairs(t, Trace{1}.X(idx(2),:)', 'LineWidth', 2);
stairs(t, Trace{1}.X(idx(1),:)', 'LineWidth', 2);

xlim([0 20]);
xticks(0:5:20);

ylim([-max_rob max_rob]);

set(gca, 'LineWidth', 2, 'FontSize',18)
set(gcf,'position',[10,10,800,500])

legend({'Violation causation distance','Satisfaction causation distance'});
grid on;