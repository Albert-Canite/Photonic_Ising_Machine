clc; clear;

%% Close and delete all possible residual GPIB/VISA objects 
allInstr = instrfind;
if ~isempty(allInstr)
    fclose(allInstr);
    delete(allInstr);
end

%% Load graph data
load('xx.mat');                 % Load the coupling matrix of the graph (for example Problem.A)
A = Problem.A;

V_graph = size(A,1);             %  Number of nodes
fprintf('Loaded graph with V = %d nodes.\n', V_graph);


V = V_graph;                    
J = -(A);                        % 
[i_idx, j_idx, w_ij] = find(triu(A, 1));  % Pre-extract edge list

%% Algorithm parameters
max_iter = 2000;

alpha = **;                       % Self-feedback coefficient (adjusted for different graphs)
beta  = **;                       % Coupling strength (adjusted for different graphs)
                
beta0  = beta;                    
r1     = **;                      % (0,1)
r2     = **;                      % (0,1)
sigma0 = 0.04;                    % Initial noise strength (typically around 0.04)

%%  Experimental hardware settings
pause_t = 0.001;                 % Time interval for spin updates (s)
re  = 0.18;                  % Measured responsivity of the on-chip photodetector (PD)

% Laser driving
I_min = **;                    % Minimum driving current defining the nonlinear curve from the measured LI curve
I_max = **;                    % Maximum driving current defining the nonlinear curve from the measured LI curve
Ispan = I_max - I_min;

% Define min/max power of the nonlinear region from the LI curve

P_lo = **;                   % Power_min
P_hi = **;                  % Power_max

%% Initialize the source measure unit (SMU)
src = gpib('ni', 0, 26);         % Address of the GPIB
fopen(src);
pause(0.2);

fprintf(src, 'reset()');
fprintf(src, 'waitcomplete()');

% Channel A: Current source for driving the laser
fprintf(src, 'smua.source.func = smua.OUTPUT_DCAMPS');
fprintf(src, 'smua.source.limitv = 6');
fprintf(src, 'smua.source.rangev = 10');
fprintf(src, 'smua.source.limiti = 0.3');
fprintf(src, 'smua.source.rangei = 3.0');
fprintf(src, 'smua.source.output = smua.OUTPUT_ON');
pause(0.1);

% Channel B: On-chip PD current measurement
fprintf(src, 'smub.source.func = smub.OUTPUT_DCVOLTS');
fprintf(src, 'smub.source.levelv = -7');
fprintf(src, 'smub.source.limiti = 0.05');   
fprintf(src, 'smub.source.rangev = 10');
fprintf(src, 'smub.measure.rangei = 1');
fprintf(src, 'smub.measure.nplc = 0.1');
fprintf(src, 'smub.source.output = smub.OUTPUT_ON');
pause(0.1);  

%%  Initialize state
x = 0.2 * randn(V,1);                % Randomly initialize spin states

cut_value      = zeros(max_iter,1);
energy_history = zeros(max_iter,1);
meanabsx       = zeros(max_iter,1);

% If you want to save discrete spins at each iteration
% spin_history = zeros(V,max_iter);

%% Loop
try
    for k = 1:max_iter

        % -------- Continuous spins --------
        sp = x;

        % -------- Robbins-Monro step size (applied to noise term or split across terms) --------
        beta_k1 = beta0 / ((k+1)^r1);
        sigma   = sigma0 / ((k+1)^r2);

        % Gradient noise
        grad_noise = sigma * randn(V,1);

        % Linear update in the iteration

        u = alpha * sp + beta_k1 * J * sp + sigma * grad_noise;

        % Laser nonlinear activation: time-multiplexed spin measurement to obtain updated x
        x_new = zeros(V,1);

        for i = 1:V

            ui = u(i);

            % Sign function (ensuring odd symmetry)
            sgn = sign(ui);
            if sgn == 0, sgn = 1; end

            % Clip amplitude to [0, 1]
            a_abs = min(abs(ui), 1);

            % Map to laser current
            I_drv = I_min + a_abs * Ispan;
            I_drv = max(min(I_drv, I_max), I_min);

            % Apply laser driving current
            fprintf(src, sprintf('smua.source.leveli = %.6f', I_drv));
            pause(pause_t);

            % Read PD current
            fprintf(src, 'print(smub.measure.i())');
            photocurrent = str2double(fscanf(src));

            % Convert photocurrent to optical power
            P = -photocurrent .* 1000 .* re;

            % Normalize values to the range [0, 1]
            m = (P - P_lo) / (P_hi - P_lo + 1e-12);
            m = max(min(m,1),0);

            
            x_new(i) = sgn * m;

        end

        % Update 
        x = x_new;

        % Discrete spin states (±1)
        s = sign(x);
        s(s==0) = 1;
        % spin_history(:,k) = s;

        % Ising energy
        energy_history(k) = -0.5 * s' * J * s;

        % MaxCut
        cut_value(k) = sum(w_ij .* (s(i_idx) ~= s(j_idx)));

        meanabsx(k) = mean(abs(x));

        fprintf('Iter %4d | Cut = %.4g | Energy = %.4g | beta_k1=%.3g | beta_k2=%.3g | mean|x|=%.3f\n', ...
            k, cut_value(k), energy_history(k), beta_k1, sigma, meanabsx(k));
    end

catch ME
    % Ensure output is turned off in case of error
    fprintf('\n[ERROR] %s\n', ME.message);
end

%% Turn off SMU output
fprintf(src, 'smua.source.output = smua.OUTPUT_OFF');
fprintf(src, 'smub.source.output = smub.OUTPUT_OFF');
fclose(src);
delete(src);

%%  
figure;
plot(cut_value, 'LineWidth', 2);
hold on;
best_cut = 13359;
yline(best_cut, '--', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5);
x_pos = round(0.6 * length(cut_value));
text(x_pos, best_cut, ' Best-known cut value = 13,359', ...
    'FontSize', 20, 'FontName', 'arial', 'FontWeight', 'normal', ...
    'VerticalAlignment', 'bottom', 'Color', [0.3 0.3 0.3]);
xlabel('Iteration');
ylabel('Cut value');
title('Experimental Evolution');
grid on;
hold off;

figure;
plot(energy_history, 'LineWidth', 2);
xlabel('Iteration'); ylabel('Ising Energy');
title('Energy Evolution');
grid on;

fprintf('\nFinal MaxCut : %.4f\n', cut_value(end));
fprintf('Final Ising Energy: %.4f\n', energy_history(end));
