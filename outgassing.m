clear all
close all
%% load the data
path_to_data = "project_sharepoint/Data/2023/Pressure_data/";
% path_to_data = "test_data/";

% File names for test and background measurements
test_fn = "20230629_150810_WAAM3_Cube.txt";
bg_fn = "20230630_141508_ref.txt";

test_fn_str = strrep(test_fn,'_', ' ');
bg_fn_str = strrep(bg_fn,'_', ' ');

sample_str = 'WAAM Mach Al 02 Cube - 8th Aug 2023 data';
sample = '_WAAM_Al_03';

sample_type = 2;

%sample_type == 1 / A = 9707.6 * 1e-6 / Surface area of machined bulk cube 
%sample_type == 2 / A = 8243.1 * 1e-6 / WAAM mach cube box
%sample_type == 3 / A = 7832.9 * 1e-6 / WAAM cube hollow 

% Load the files
test_data = import_OG_file(strcat(path_to_data, test_fn));
bg_data = import_OG_file(strcat(path_to_data, bg_fn));

%% Raw data
figure(1)
subplot(2,1,1)
hold all
plot(bg_data.CH2)
plot(bg_data.CH3)
hold off
title(bg_fn_str, 'FontSize', 16)
box on
grid on

% Temperature plot
subplot(2,1,2)
hold all
plot(bg_data.T1)
plot(bg_data.T2)
plot(bg_data.T3)
plot(bg_data.T4)
plot(bg_data.T5)
plot(bg_data.T6)
plot(bg_data.T7)
plot(bg_data.T8)
plot(bg_data.T9)
hold off
title(bg_fn_str, 'FontSize', 16)
box on
grid on

figure(2)
subplot(2,1,1)
hold all
plot(test_data.CH2)
plot(test_data.CH3)
hold off
title(test_fn_str, 'FontSize', 16)
box on
grid on

subplot(2,1,2)
hold all
plot(test_data.T1)
plot(test_data.T2)
plot(test_data.T3)
plot(test_data.T4)
plot(test_data.T5)
plot(test_data.T6)
plot(test_data.T7)
plot(test_data.T8)
plot(test_data.T9)
hold off
title(test_fn_str, 'FontSize', 16)
box on
grid on

%% Trim to ROI
sampling_rate = mean(diff(test_data.Datetime));
min_search_duration = minutes(30); % look for valve close in this time
test_end_cut = 19;
test_duration = hours(18); % length of test
time = 0:seconds(sampling_rate):(size(test_data, 1)-1).*seconds(sampling_rate); %seconds
timehr = time./(60.*60); % time in hours
timehr = timehr';
Tindex = (timehr > test_end_cut);

test_data_old = test_data;
bg_data_old = bg_data;

test_data(Tindex,:) = [];
bg_data(Tindex,:) = [];

% Find start
% Search for the minimum which corresponds to the valves being closed
search_idx = floor(min_search_duration/sampling_rate);
[~, test_min_idx] = min(test_data.CH2(1:search_idx));
[~, bg_min_idx] = min(bg_data.CH2(1:search_idx));

figure(1)
subplot(2,1,1)
hold all
plot(bg_data.CH2(bg_min_idx:end))
plot(bg_data.CH3(bg_min_idx:end))
hold off

figure(2)
subplot(2,1,1)
hold all
plot(test_data.CH2(test_min_idx:end))
plot(test_data.CH3(test_min_idx:end))
hold off

% Stop the test at 15 hours for future analysis
time_stop = 15; %hours
time_new = 0:seconds(sampling_rate):(size(test_data, 1)-1).*seconds(sampling_rate); %seconds
timehr_new = time_new./(60.*60);
timehr_new = timehr_new';
TindexN = (timehr_new > time_stop);

Tstop = (time_stop.*60.*60)./seconds(sampling_rate);

Ttrimb = hours(bg_data.Datetime(bg_min_idx:Tstop+bg_min_idx) - bg_data.Datetime(1));
Ttrims = hours(test_data.Datetime(test_min_idx:Tstop+test_min_idx) - test_data.Datetime(1));
Ttrim = mean([Ttrimb, Ttrims], 2);

figure(3)
subplot(2,1,1)
hold all
plot(Ttrim, bg_data.CH2(bg_min_idx:Tstop+bg_min_idx), 'k')
plot(Ttrim, bg_data.CH3(bg_min_idx:Tstop+bg_min_idx), 'k')
plot(Ttrim, test_data.CH2(test_min_idx:Tstop+test_min_idx), 'b')
plot(Ttrim, test_data.CH3(test_min_idx:Tstop+test_min_idx), 'b')
hold off
xlabel('hours')
box on
grid on
legend('bg', 'bg', 'test', 'test')

subplot(2,1,2)
hold all
plot(Ttrim, bg_data.CH2(bg_min_idx:Tstop+bg_min_idx), 'k')
plot(Ttrim, bg_data.CH3(bg_min_idx:Tstop+bg_min_idx), 'k')
plot(Ttrim, test_data.CH2(test_min_idx:Tstop+test_min_idx), 'b')
plot(Ttrim, test_data.CH3(test_min_idx:Tstop+test_min_idx), 'b')
hold off
xlabel('hours')
box on
grid on
xlim([0 1])
legend('bg', 'bg', 'test', 'test')

%%
% trim data
trim_test_data = test_data(test_min_idx:Tstop+test_min_idx, :);
trim_bg_data = bg_data(bg_min_idx:Tstop+bg_min_idx, :);

%%
% Also multiply by 100 for mbar to Pa conversion
test_sample = trim_test_data.CH2 .* 100;
test_ref = trim_test_data.CH3 .*100;

bg_sample = trim_bg_data.CH2 .* 100;
bg_ref = trim_bg_data.CH3 .* 100;

% Use this figure to find appropriate start buffer
figure(4)
tiledlayout(2,1)
nexttile
hold all
plot(Ttrim,bg_sample)
hold off
title('Background')
grid on
box on 
xlim([-0.1 1])
nexttile
hold all
plot(Ttrim, test_sample)
hold off
title('Sample')
grid on
box on
xlim([-0.1 1])

%% Get mean temperature
full_T_test = trim_test_data(:,5:12); %starts at 5 as T1 is controller temp sensor
mean_T_test = mean(table2array(full_T_test), 2) + 270; %add 270 for kelvin - a vector the same size as time
%% define constants
orf_d = 0.75e-3; % orifice diameter (m)
orf_t = 1e-3; % orifice thickness (m)
% temp = 293; % chamber temp (K) (approx. for now)
M = 0.02896; % Mean molecular mass (kg / mol) (dry air for now)
R = 8.3145; % Gas constant (J / K * mol)

% Sample geometries have different surface areas
if sample_type == 1
A = 9707.6 * 1e-6; % Surface area of machined bulk cube 
Sstr = 'Surface area = bulk machined cube (9707.6 * 1e-6)';
elseif sample_type == 2
A = 8243.1 * 1e-6; % WAAM mach cube box
Sstr = 'Surface area = WAAM machined cube (8243.1 * 1e-6)';
elseif sample_type == 3
A = 7832.9 * 1e-6; % WAAM cube hollow 
Sstr = 'Surface area = WAAM raw cube (7832.9 * 1e-6)';
else
    disp('error');
    return
end
%% Outgassing calculation
C = concalc_rough(orf_d, orf_t, mean_T_test, M, R); % conductance calc
back_coeff = polyfit(bg_ref, bg_sample, 3); % coefficients from background fit
backx = [0:max(bg_ref)./100:max(bg_ref)];

figure(5)
hold all
plot(bg_ref, bg_sample, '.')
plot(backx, polyval(back_coeff,backx))
hold off
axis equal
grid on 
box on
xlabel('[bg ref]')
ylabel('[bg sample]')
title('background correction fitting')

% do background correction
corr_ref = back_coeff(1)*test_ref.^3 + back_coeff(2)*test_ref.^2 + back_coeff(3)*test_ref + back_coeff(4);

% calculate outgassing rate
q = C.*(test_sample - corr_ref)/A;
t = hours(trim_test_data.Datetime - trim_test_data.Datetime(1));

%% q at 1hr and 10hr
t_min = t;
t_min = round(t_min.*180)./180; % getting an average over 20 secs

index1 = (t_min == 1) ;
index2 = (t_min == 10);
qhr = [mean(q(index1)), mean(q(index2))];

disp(join(['Background = ', bg_fn]));
disp(join(['Sample = ', test_fn]));
disp(sample_str);
disp(Sstr);
disp(['Outgassing rate at 1hr = ', num2str(qhr(1)), ' [Pa m s^-^1]']);
disp(['Outgassing rate at 10hr = ', num2str(qhr(2)), ' [Pa m s^-^1]']);

hr1 = qhr(1);
hr10 = qhr(2);

% save file with appropriate name. Date + sample name
char_fn = char(test_fn);
date = char_fn(1:15); % get date from input file
save(['project_sharepoint/Data/2023/SPIE_paper_data/run1/', date, sample, '.mat'], 'q', 'hr1', 'hr10', 'sample_type')

%% Plotting
figure(6)
hold all
plot(t, q, 'LineWidth', 2)
%plot([1 10], qhr, 'o', 'MarkerSize',5, 'MarkerFaceColor','k', 'MarkerEdgeColor','k')
plot([1 1], [1 0], ':k')
plot([10 10], [1 0], ':k')
hold off
ax=gca;
ax.FontSize = 16;
ylim([0 1e-4])
xlim([0 time_stop])
ylabel('Outgassing Rate (Pa m s^{-1})', 'FontSize', 16)
xlabel('Time (hrs)', 'FontSize', 16)
title(sample_str, 'FontSize', 16, 'FontWeight', 'bold')
grid on
box on 

