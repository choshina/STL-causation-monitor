% Run Init_AFC_online first
%phi_AFC = 'alw_[10, 50] ( (not (abs(AF[t]-AFref[t]) > 0.08)) or (ev_[0, 2](abs(AF[t]-AFref[t]) < 0.08)))';
phi_AFC = 'alw_[10, 50](abs(AF[t]-AFref[t]) < 0.1 )'; 
%phi_AFC = 'alw_[10, 48.5](ev_[0,1.5](abs(AF[t] - AFref[t]) < 0.08))';
%diagnoser = 2;

%Pedal_Angle_pulse_period: 5-15
%Pedal_Angle_pulse_amp: 50-75
%Engine_Speed: 900-1100
%rand(1,5).*[10 60 600 600 600] + [5 10 500 500 500]

%input = [ 14.7059   67.4300  791.2254  980.1683  585.1318 ];
%input = [7.3993   72.1628  905.7348  997.9803  933.5854];
%input = [10.3834   74.9034  915.6351  988.5357  921.3306];
input = [14.6189808085505	50.1158556033517	1054.98209294230	1063.46064413069	1073.73894107270];
%input = [13.1814855385962	70.4386773019822	1044.48791847337	929.973088495593	1031.92105058166];
%input = [13.6929220764009	64.4926146841393	1009.97204036727	928.990959644745	1070.60622354438];
%input = [7.3992   53.0830  936.7816  947.9905  983.4534];
%input = [8.90937802323736	70.7844935709767	1060.67287832049	912.094235833979	979.851554122715];
%input = [8.37719409821377	72.5013461604416	973.849356224043	922.240551058757	1056.05041366423];
%input = [10.6119979270966	72.0466625112953	1033.83506090688	938.086653435991	973.783309212779];

d = 3;

BrAFC.ResetSimulations();
BrAFC.SetParam({'Pedal_Angle_pulse_period', 'Pedal_Angle_pulse_amp', 'Engine_Speed_u0','Engine_Speed_u1','Engine_Speed_u2'}, input);
BrAFC.SetParam({'max_rob', 'diagnoser'}, [0.5, d]);

% BrAFC.ResetSimulations();
% BrAFC.Sim(0:.1:50);

times = 1;
tic
for i = 1:times
    BrAFC.ResetSimulations();
    BrAFC.Sim(0:.1:50);
end

simTime = toc;
one_sim_time = simTime/times
% 
Trace = BrAFC.GetTraces();
idx = FindParam(BrAFC.Sys, {'rob_low', 'rob_up'});
t = Trace{1}.time;

%% 
close 
figure(1);
subplot(3,1,1)

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
subplot(3,1,[2 3]);
hold on;


if d== 3
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
    set(gca, 'LineWidth', 2, 'FontSize',18)
else
    stairs(t, Trace{1}.X(idx(2),:)',  'LineWidth', 2);
    stairs(t, Trace{1}.X(idx(1),:)',  'LineWidth', 2);
end

set(gca, 'LineWidth', 2, 'FontSize',18)
set(gcf,'position',[10,10,800,500])
%set(gcf,'position',[10,10,800,250])
xlim([0 50]);
xticks(0:5:50);
if d == 3
    ylim([-1 1]);
else
    ylim([-0.5 0.5]);
    yticks(-0.5:0.5:0.5);
end

if d == 4
    legend({'Violation causation distance','Satisfaction causation distance'});
elseif d == 3
    legend({'Boolean causation monitor verdict'})
else
    legend({'Upper robustness','Lower robustness'});
end

%plot(t,0*t,'k')
grid on;

%%
%save2pdf('RobustOnlinePlot.pdf')    