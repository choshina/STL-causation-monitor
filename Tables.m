clear;
InitBreach;

init_log();

prompt1 = "Which specification would you like to check? Choose one from (1-4): \n1. AFC-1 \n2. AFC-2\n3. AFC-3\n4. AT-1\n";
spec = input(prompt1);

prompt2 = "How many times would you like to repeat executing for each trace? Input a number (we use 10 in paper):\n";
repeat = input(prompt2);

disp('=======Please wait ...')

%=============write your specification here
spec_str = {'alw_[10, 50](abs(AF[t]-AFref[t]) < 0.1 )', ...
    'alw_[10, 48.5](ev_[0,1.5](abs(AF[t] - AFref[t]) < 0.08))', ...
    'alw_[10, 50] ( (not (abs(AF[t]-AFref[t]) > 0.08)) or (ev_[0, 2](abs(AF[t]-AFref[t]) < 0.08)))', ...
    'alw_[0,30](not(speed[t] > 50) or ev_[1,3](RPM[t] < 3000))'};
spec_mdl = {'AFC', 'AFC', 'AFC', 'AT'};

%=============write your input signals here
FC_input = [ 14.7059   67.4300  791.2254  980.1683  585.1318; ...
    7.3993   72.1628  905.7348  997.9803  933.5854; ...
    10.3834   74.9034  915.6351  988.5357  921.3306; ...
    14.6189808085505	50.1158556033517	1054.98209294230	1063.46064413069	1073.73894107270; ...
    13.1814855385962	70.4386773019822	1044.48791847337	929.973088495593	1031.92105058166; ...
    13.6929220764009	64.4926146841393	1009.97204036727	928.990959644745	1070.60622354438; ...
    7.3992   53.0830  936.7816  947.9905  983.4534; ...
    8.90937802323736	70.7844935709767	1060.67287832049	912.094235833979	979.851554122715; ...
    8.37719409821377	72.5013461604416	973.849356224043	922.240551058757	1056.05041366423; ...
    10.6119979270966	72.0466625112953	1033.83506090688	938.086653435991	973.783309212779];
%FC_input = [15 60 1000 1000 1000];

AT_input = [58.2986   25.1806   29.0441   61.7091   86.2163  267.9223  319.3656  237.3309; ...
    37.6272   19.0924   42.8253   48.2022   39.1988  191.5899   73.5110  125.0012; ...
    61.0959   77.8802   42.3453    9.0823   86.6032   49.9384   91.3267  143.0277; ...
    67.6122   28.9065   67.1808   69.5140   22.0976   82.8068   72.8130  217.0456; ...
    84.4392   34.4462   78.0520   67.5332    2.1825  195.7054  125.7006  297.6972; ...
    98.9872   51.4423   88.4281   58.8026   50.2945   64.9554  132.2603  243.3294; ...
    94.5174   20.8935   70.9282   23.6231   38.8038  197.3738  146.2948  149.0858; ...
    66.1945   77.0286   35.0218   66.2010  135.2515  273.6270  270.6980   83.3433; ...
    99.3705   21.8677   10.5798   10.9697   20.6672  131.4885  145.7212  118.8903; ...
    94.9304   32.7565   67.1264   43.8645  270.8877  249.8776   54.3574  280.1437];

[FC_input_num, ~] = size(FC_input);
[AT_input_num, ~] = size(AT_input);

if strcmp(spec_mdl{spec}, 'AT')
    AT_init_warm;
    %======d=0
    claM_comp = [];
    claM_sim = [];

    for i = 1:AT_input_num
        
        disp(['===============ClaM Trace #', int2str(i)]);
        phi_autotrans = spec_str{spec};
        input = AT_input(i, :);
        d = 0;
        diagnoser = d;
        times = repeat;

        
        AT.SetParam({'Throttle_u0', 'Throttle_u1', 'Throttle_u2', 'Throttle_u3', 'Brake_u0', 'Brake_u1', 'Brake_u2', 'Brake_u3'}, input);
        AT.SetParam({'max_rob', 'diagnoser'}, [max_rob, d]);
        
        init_log();
        
        claM_start = tic;
        for j = 1:times
            AT.ResetSimulations();
            AT.Sim(0:.01:30);
            disp(['ClaM Repeatation: ', int2str(j)]);
        end
        
        simTime = toc(claM_start);
        claM_sim_cost = simTime/times;
       
        arr = read_log();
        claM_comp_cost = mean(arr);

        claM_comp = [claM_comp; claM_comp_cost];
        claM_sim = [claM_sim; claM_sim_cost];
    end
    disp('====ClaM finished')

    %======d=2
    resM_comp = [];
    resM_sim = [];

    for i = 1:AT_input_num
        disp(['===============ResM Trace #', int2str(i)]);
        phi_autotrans = spec_str{spec};
        input = AT_input(i, :);

        d = 2;
        diagnoser = d;
        times = repeat;
        
        AT.SetParam({'Throttle_u0', 'Throttle_u1', 'Throttle_u2', 'Throttle_u3', 'Brake_u0', 'Brake_u1', 'Brake_u2', 'Brake_u3'}, input);
        AT.SetParam({'max_rob', 'diagnoser'}, [max_rob, d]);
        
        init_log();
        
        resM_start = tic;
        for j = 1:times
            AT.ResetSimulations();
            AT.Sim(0:.01:30);
            disp(['ResM Repeatation: ', int2str(j)]);
        end
        
        simTime = toc(resM_start);
        resM_sim_cost = simTime/times;
       
        arr = read_log();
        resM_comp_cost = mean(arr);

        resM_comp = [resM_comp; resM_comp_cost];
        resM_sim = [resM_sim; resM_sim_cost];
    end
    disp('====ResM finished')

    %======d=3
    bCauM_comp = [];
    bCauM_sim = [];

    for i = 1:AT_input_num
        disp(['===============BCauM Trace #', int2str(i)]);
        phi_autotrans = spec_str{spec};
        input = AT_input(i, :);

        d = 3;
        diagnoser = d;
        times = repeat;
        
        AT.SetParam({'Throttle_u0', 'Throttle_u1', 'Throttle_u2', 'Throttle_u3', 'Brake_u0', 'Brake_u1', 'Brake_u2', 'Brake_u3'}, input);
        AT.SetParam({'max_rob', 'diagnoser'}, [max_rob, d]);
        
        init_log();
        
        bCauM_start = tic;
        for j = 1:times
            AT.ResetSimulations();
            AT.Sim(0:.01:30);
            disp(['BCauM Repeatation: ', int2str(j)]);
        end
        
        simTime = toc(bCauM_start);
        bCauM_sim_cost = simTime/times;
       
        arr = read_log();
        bCauM_comp_cost = mean(arr);

        bCauM_comp = [bCauM_comp; bCauM_comp_cost];
        bCauM_sim = [bCauM_sim; bCauM_sim_cost];
    end
    disp('====BCauM finished')

    %======d=4
    qCauM_comp = [];
    qCauM_sim = [];

    for i = 1:AT_input_num
        disp(['===============QCauM Trace #', int2str(i)]);
        phi_autotrans = spec_str{spec};
        input = AT_input(i, :);

        d = 4;
        diagnoser = d;
        times = repeat;
        
        AT.SetParam({'Throttle_u0', 'Throttle_u1', 'Throttle_u2', 'Throttle_u3', 'Brake_u0', 'Brake_u1', 'Brake_u2', 'Brake_u3'}, input);
        AT.SetParam({'max_rob', 'diagnoser'}, [max_rob, d]);
        
        init_log();
        
        qCauM_start = tic;
        for j = 1:times
            AT.ResetSimulations();
            AT.Sim(0:.01:30);
            disp(['QCauM Repeatation: ', int2str(j)]);
        end
        
        simTime = toc(qCauM_start);
        qCauM_sim_cost = simTime/times;
       
        arr = read_log();
        qCauM_comp_cost = mean(arr);

        qCauM_comp = [qCauM_comp; qCauM_comp_cost];
        qCauM_sim = [qCauM_sim; qCauM_sim_cost];
    end
    disp('====QCauM finished')

    %======Table 2
    delta_claM = (qCauM_comp - claM_comp)*100.0./claM_comp;
    delta_resM = (qCauM_comp - resM_comp)*100.0./resM_comp;
    delta_bCauM = (qCauM_comp - bCauM_comp)*100.0./bCauM_comp;

    traces = 1:AT_input_num;
    traces = traces';
    

    table2 = table(traces, claM_comp, resM_comp, bCauM_comp, qCauM_comp, delta_claM, delta_resM, delta_bCauM);
    table2.Properties.VariableNames("claM_comp") = "ClaM";
    table2.Properties.VariableNames("resM_comp") = "ResM";
    table2.Properties.VariableNames("bCauM_comp") = "BCauM";
    table2.Properties.VariableNames("qCauM_comp") = "QCauM";

    %======Table 1
    claM_sim = claM_sim*1000;
    resM_sim = resM_sim*1000;
    bCauM_sim = bCauM_sim*1000;
    qCauM_sim = qCauM_sim*1000;

    claM_comp_mean = mean(claM_comp);
    claM_comp_std = std(claM_comp);
    claM_sim_mean = mean(claM_sim);
    claM_sim_std = std(claM_sim);

    resM_comp_mean = mean(resM_comp);
    resM_comp_std = std(resM_comp);
    resM_sim_mean = mean(resM_sim);
    resM_sim_std = std(resM_sim);

    bCauM_comp_mean = mean(bCauM_comp);
    bCauM_comp_std = std(bCauM_comp);
    bCauM_sim_mean = mean(bCauM_sim);
    bCauM_sim_std = std(bCauM_sim);

    qCauM_comp_mean = mean(qCauM_comp);
    qCauM_comp_std = std(qCauM_comp);
    qCauM_sim_mean = mean(qCauM_sim);
    qCauM_sim_std = std(qCauM_sim);

    table1 = table(claM_comp_mean, claM_comp_std, claM_sim_mean, claM_sim_std,...
        resM_comp_mean, resM_comp_std, resM_sim_mean, resM_sim_std,...
        bCauM_comp_mean, bCauM_comp_std, bCauM_sim_mean, bCauM_sim_std,...
        qCauM_comp_mean, qCauM_comp_std, qCauM_sim_mean, qCauM_sim_std);
    
    table1.Properties.VariableNames("claM_comp_mean") = "ClaM_monitor_avg";
    table1.Properties.VariableNames("claM_comp_std") = "ClaM_monitor_stdv";
    table1.Properties.VariableNames("claM_sim_mean") = "ClaM_total_avg";
    table1.Properties.VariableNames("claM_sim_std") = "ClaM_total_stdv";
    table1.Properties.VariableNames("resM_comp_mean") = "ResM_monitor_avg";
    table1.Properties.VariableNames("resM_comp_std") = "ResM_monitor_stdv";
    table1.Properties.VariableNames("resM_sim_mean") = "ResM_total_avg";
    table1.Properties.VariableNames("resM_sim_std") = "ResM_total_stdv";
    table1.Properties.VariableNames("bCauM_comp_mean") = "BCauM_monitor_avg";
    table1.Properties.VariableNames("bCauM_comp_std") = "BCauM_monitor_stdv";
    table1.Properties.VariableNames("bCauM_sim_mean") = "BCauM_total_avg";
    table1.Properties.VariableNames("bCauM_sim_std") = "BCauM_total_stdv";
    table1.Properties.VariableNames("qCauM_comp_mean") = "QCauM_monitor_avg";
    table1.Properties.VariableNames("qCauM_comp_std") = "QCauM_monitor_stdv";
    table1.Properties.VariableNames("qCauM_sim_mean") = "QCauM_total_avg";
    table1.Properties.VariableNames("qCauM_sim_std") = "QCauM_total_stdv";

    %======display
    disp('==========Table1:');
    disp(table1);

    disp('==========Table2:');
    disp(table2);

else
    FC_init_warm;
    %======d=0
    claM_comp = [];
    claM_sim = [];

    for i = 1:FC_input_num
        %spec = 'alw_[10, 50](abs(AF[t]-AFref[t]) < 0.1 )'; 
        disp(['===============ClaM Trace #', int2str(i)]);
        phi_AFC = spec_str{spec};
        input = FC_input(i, :);
        
        d = 0;
        
        BrAFC.ResetSimulations();
        BrAFC.SetParam({'Pedal_Angle_pulse_period', 'Pedal_Angle_pulse_amp', 'Engine_Speed_u0','Engine_Speed_u1','Engine_Speed_u2'}, input);
        BrAFC.SetParam({'max_rob', 'diagnoser'}, [0.5, d]);
        
        init_log();
        times = repeat;
        claM_start= tic;
        for j = 1:times
            BrAFC.ResetSimulations();
            BrAFC.Sim(0:.1:50);
            disp(['ClaM Repeatation: ', int2str(j)]);
        end
        simTime = toc(claM_start);
        claM_sim_cost = simTime/times;
        
        arr = read_log();
        claM_comp_cost = mean(arr);

        claM_comp = [claM_comp; claM_comp_cost];
        claM_sim = [claM_sim; claM_sim_cost];
    end
    disp('====ClaM finished')

    %======d=2
    resM_comp = [];
    resM_sim = [];

    for i = 1:FC_input_num
        %spec = 'alw_[10, 50](abs(AF[t]-AFref[t]) < 0.1 )'; 
        disp(['===============ResM Trace #', int2str(i)]);
        phi_AFC = spec_str{spec};
        input = FC_input(i, :);
        
        d = 2;
        
        BrAFC.ResetSimulations();
        BrAFC.SetParam({'Pedal_Angle_pulse_period', 'Pedal_Angle_pulse_amp', 'Engine_Speed_u0','Engine_Speed_u1','Engine_Speed_u2'}, input);
        BrAFC.SetParam({'max_rob', 'diagnoser'}, [0.5, d]);
        
        init_log();
        times = repeat;
        resM_start= tic;
        for j = 1:times
            BrAFC.ResetSimulations();
            BrAFC.Sim(0:.1:50);
            disp(['ResM Repeatation: ', int2str(j)]);
        end
        simTime = toc(resM_start);
        resM_sim_cost = simTime/times;
        
        arr = read_log();
        resM_comp_cost = mean(arr);

        resM_comp = [resM_comp; resM_comp_cost];
        resM_sim = [resM_sim; resM_sim_cost];
    end
    disp('====ResM finished')

    %======d=3
    bCauM_comp = [];
    bCauM_sim = [];

    for i = 1:FC_input_num
        disp(['===============BCauM Trace #', int2str(i)]);
        %spec = 'alw_[10, 50](abs(AF[t]-AFref[t]) < 0.1 )'; 
        phi_AFC = spec_str{spec};
        input = FC_input(i, :);
        
        d = 3;
        
        BrAFC.ResetSimulations();
        BrAFC.SetParam({'Pedal_Angle_pulse_period', 'Pedal_Angle_pulse_amp', 'Engine_Speed_u0','Engine_Speed_u1','Engine_Speed_u2'}, input);
        BrAFC.SetParam({'max_rob', 'diagnoser'}, [0.5, d]);
        
        init_log();
        times = repeat;
        bCauM_start= tic;
        for j = 1:times
            BrAFC.ResetSimulations();
            BrAFC.Sim(0:.1:50);
            disp(['BCauM Repeatation: ', int2str(j)]);
        end
        simTime = toc(bCauM_start);
        bCauM_sim_cost = simTime/times;
        
        arr = read_log();
        bCauM_comp_cost = mean(arr);

        bCauM_comp = [bCauM_comp; bCauM_comp_cost];
        bCauM_sim = [bCauM_sim; bCauM_sim_cost];
    end
    disp('====BCauM finished')

    %======d=4
    qCauM_comp = [];
    qCauM_sim = [];

    for i = 1:FC_input_num
        %spec = 'alw_[10, 50](abs(AF[t]-AFref[t]) < 0.1 )'; 
        disp(['===============QCauM Trace #', int2str(i)]);
        phi_AFC = spec_str{spec};
        input = FC_input(i, :);
        
        d = 4;
        
        BrAFC.ResetSimulations();
        BrAFC.SetParam({'Pedal_Angle_pulse_period', 'Pedal_Angle_pulse_amp', 'Engine_Speed_u0','Engine_Speed_u1','Engine_Speed_u2'}, input);
        BrAFC.SetParam({'max_rob', 'diagnoser'}, [0.5, d]);
        
        init_log();
        times = repeat;
        qCauM_start= tic;
        for j = 1:times
            BrAFC.ResetSimulations();
            BrAFC.Sim(0:.1:50);
            disp(['QCauM Repeatation: ', int2str(j)]);
        end
        simTime = toc(qCauM_start);
        qCauM_sim_cost = simTime/times;
        
        arr = read_log();
        qCauM_comp_cost = mean(arr);

        qCauM_comp = [qCauM_comp; qCauM_comp_cost];
        qCauM_sim = [qCauM_sim; qCauM_sim_cost];
    end
    disp('====QCauM finished')

    %======Table 2
    delta_claM = (qCauM_comp - claM_comp)*100.0./claM_comp;
    delta_resM = (qCauM_comp - resM_comp)*100.0./resM_comp;
    delta_bCauM = (qCauM_comp - bCauM_comp)*100.0./bCauM_comp;

    traces = 1:FC_input_num;
    traces = traces';

    table2 = table(traces, claM_comp, resM_comp, bCauM_comp, qCauM_comp, delta_claM, delta_resM, delta_bCauM);
    table2.Properties.VariableNames("claM_comp") = "ClaM";
    table2.Properties.VariableNames("resM_comp") = "ResM";
    table2.Properties.VariableNames("bCauM_comp") = "BCauM";
    table2.Properties.VariableNames("qCauM_comp") = "QCauM";

    %======Table 1
    claM_sim = claM_sim*1000;
    resM_sim = resM_sim*1000;
    bCauM_sim = bCauM_sim*1000;
    qCauM_sim = qCauM_sim*1000;

    claM_comp_mean = mean(claM_comp);
    claM_comp_std = std(claM_comp);
    claM_sim_mean = mean(claM_sim);
    claM_sim_std = std(claM_sim);

    resM_comp_mean = mean(resM_comp);
    resM_comp_std = std(resM_comp);
    resM_sim_mean = mean(resM_sim);
    resM_sim_std = std(resM_sim);

    bCauM_comp_mean = mean(bCauM_comp);
    bCauM_comp_std = std(bCauM_comp);
    bCauM_sim_mean = mean(bCauM_sim);
    bCauM_sim_std = std(bCauM_sim);

    qCauM_comp_mean = mean(qCauM_comp);
    qCauM_comp_std = std(qCauM_comp);
    qCauM_sim_mean = mean(qCauM_sim);
    qCauM_sim_std = std(qCauM_sim);

    table1 = table(claM_comp_mean, claM_comp_std, claM_sim_mean, claM_sim_std,...
        resM_comp_mean, resM_comp_std, resM_sim_mean, resM_sim_std,...
        bCauM_comp_mean, bCauM_comp_std, bCauM_sim_mean, bCauM_sim_std,...
        qCauM_comp_mean, qCauM_comp_std, qCauM_sim_mean, qCauM_sim_std);
    
    table1.Properties.VariableNames("claM_comp_mean") = "ClaM_monitor_avg";
    table1.Properties.VariableNames("claM_comp_std") = "ClaM_monitor_stdv";
    table1.Properties.VariableNames("claM_sim_mean") = "ClaM_total_avg";
    table1.Properties.VariableNames("claM_sim_std") = "ClaM_total_stdv";
    table1.Properties.VariableNames("resM_comp_mean") = "ResM_monitor_avg";
    table1.Properties.VariableNames("resM_comp_std") = "ResM_monitor_stdv";
    table1.Properties.VariableNames("resM_sim_mean") = "ResM_total_avg";
    table1.Properties.VariableNames("resM_sim_std") = "ResM_total_stdv";
    table1.Properties.VariableNames("bCauM_comp_mean") = "BCauM_monitor_avg";
    table1.Properties.VariableNames("bCauM_comp_std") = "BCauM_monitor_stdv";
    table1.Properties.VariableNames("bCauM_sim_mean") = "BCauM_total_avg";
    table1.Properties.VariableNames("bCauM_sim_std") = "BCauM_total_stdv";
    table1.Properties.VariableNames("qCauM_comp_mean") = "QCauM_monitor_avg";
    table1.Properties.VariableNames("qCauM_comp_std") = "QCauM_monitor_stdv";
    table1.Properties.VariableNames("qCauM_sim_mean") = "QCauM_total_avg";
    table1.Properties.VariableNames("qCauM_sim_std") = "QCauM_total_stdv";

    %======display
    disp('==========Table1:');
    disp(table1);

    disp('==========Table2:');
    disp(table2);
end

function init_log()
    fileID = fopen("log.txt", "w");
    fclose(fileID);
end

function arr = read_log()
    fileID = fopen('log.txt','r');
    formats = '%f';
    arr = fscanf(fileID,formats);
end
