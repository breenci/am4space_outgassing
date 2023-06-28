%% load the data
% path_to_data = "project_sharepoint/Data/2023/Pressure_data/";
path_to_data = "test_data/";

test_fn = "machWAM2_Cube_20230615_153801.txt";
bg_fn = "ref_20230616_134420.txt";

sample_str = 'WAAM Cube #02 - 15 Jun 2023 data';

test_data = import_OG_file(strcat(path_to_data, test_fn));
bg_data = import_OG_file(strcat(path_to_data, bg_fn));

%% Trim to ROI
sampling_rate = test_data.Datetime(2) - test_data.Datetime(1);
min_search_duration = minutes(20); % look for valve close in this time
test_duration = hours(18); % length of test

% Find start
% Search for the minimum which corresponds to the valves being closed
search_idx = floor(min_search_duration/sampling_rate);
[~, test_min_idx] = min(test_data.CH2(1:search_idx));
[~, bg_min_idx] = min(bg_data.CH2(1:search_idx));

% Start index is at the peak pressure after valve closed
[~, test_max_idx] = max(test_data.CH2(test_min_idx:end));
[~, bg_max_idx] = max(bg_data.CH2(bg_min_idx:end));

test_start_idx = test_min_idx + test_max_idx;
bg_start_idx = bg_min_idx + bg_max_idx;

% define end point from duration and sampling rate
test_end_idx = test_start_idx + floor(test_duration/sampling_rate);
bg_end_idx = bg_start_idx + floor(test_duration/sampling_rate);

% trim data
trim_test_data = test_data(test_start_idx:test_end_idx, :);
trim_bg_data = bg_data(bg_start_idx:bg_end_idx, :);
%%

% Also multiply by 100 for mbar to Pa conversion
test_sample = trim_test_data.CH2 .* 100;
test_ref = trim_test_data.CH3 .*100;

bg_sample = trim_bg_data.CH2 .* 100;
bg_ref = trim_bg_data.CH3 .* 100;

% Use this figure to find appropriate start buffer. Start at peak pressure
% after valve close
figure()
tiledlayout(2,1)
nexttile
plot(bg_sample)
% ylim([1e-7, 1e-3])
title('Background')
grid on
nexttile
plot(test_sample)
% ylim([1e-7, 1e-3])
title('Sample')
grid on

%% Get mean temperature
full_T_test = trim_test_data(:,5:12);
mean_T_test = mean(table2array(full_T_test), 2);
%% define constants
orf_d = 0.75e-3; % orifice diameter (m)
orf_t = 1e-3; % orifice thickness (m)
% temp = 293; % chamber temp (K) (approx. for now)
M = 0.02896; % Mean molecular mass (kg / mol) (dry air for now)
R = 8.3145; % Gas constant (J / K * mol)

A = 9707.6 * 1e-6; % Surface area of machined cube

%% Outgassing calculation
C = concalc_rough(orf_d, orf_t, mean_T_test, M, R); % conductance calc
back_coeff = polyfit(bg_ref, bg_sample, 3); % coefficients from background fit

% do background correction
corr_ref = back_coeff(1)*test_ref.^3 + back_coeff(2)*test_ref.^2 + back_coeff(3)*test_ref + back_coeff(4);

% calculate outgassing rate
q = C.*(test_sample - corr_ref)/A;
t = hours(trim_test_data.Datetime - trim_test_data.Datetime(1));
% t_peak = (1:length(q))/60^2;

% save file with appropriate name. Date + sample name
char_fn = char(test_fn);
date = char_fn(end-27:end-20); % get date from input file
sample = '_HRes_AM_Al_cube3';
% save(['../../../Data/2022/test_outgassing_rates/', date, sample, '.mat'], 't_peak', 'q')

%% q at 1hr and 10hr
t_min = t;
t_min = round(t_min.*180)./180; % getting an average over 20 secs

index1 = (t_min == 1) ;
index2 = (t_min == 10);
qhr = [mean(q(index1)), mean(q(index2))];
%qhr = round(qhr.*100)./100;

disp(join(['Background = ', bg_fn]));
disp(join(['Sample = ', test_fn]));
disp(sample_str);
disp(['Outgassing rate at 1hr = ', num2str(qhr(1)), ' [Pa m s^-^1]']);
disp(['Outgassing rate at 10hr = ', num2str(qhr(2)), ' [Pa m s^-^1]']);

%% Plotting
figure()
hold all
plot(t, q, 'LineWidth', 2)
% plot([1 10], qhr, 'o', 'MarkerSize',5, 'MarkerFaceColor','k', 'MarkerEdgeColor','k')
hold off
ax=gca;
ax.FontSize = 16;
ylim([0 2e-5])
xlim([0 15])
ylabel('Outgassing Rate (Pa m s^{-1})', 'FontSize', 16)
xlabel('Time (hrs)', 'FontSize', 16)
title(sample_str, 'FontSize', 16, 'FontWeight', 'bold')
grid on
box on 
%%
OGrate = [t_peak', q];
export{1,1} = OGrate;
export{2,1} = qhr;
export{3,1} = bg_fn;
export{4,1} = test_fn;
%%
out_path = "OG_data/";
test_dat = strrep(test_fn, '.', '_');
fname = join([out_path, 'OGrate_', test_dat],'');
%%
save(fname,'export');

