% Script created by CB based on previous OG calculation script
clear variables
close all
%% Load the data
path_to_data = "../project_sharepoint/Data/raw/2024/OG_rig_verification_30092024/";

bg_fn = "20241003_151956_REF_CB"; % background measurement
sample_fn = "20241001_114949_SICAPRINT-01-LATTICE_CB.txt"; % sample measurement

% load data from file
bg = import_OG_file(strcat(path_to_data, bg_fn));
sample = import_OG_file(strcat(path_to_data, sample_fn));

% metadata
sample_info = parse_filename(sample_fn, "sample");
bg_info = parse_filename(bg_fn, "background");

% plot the raw data
figure(1);
raw_ax = tiledlayout(2, 1);
nexttile
plot(sample.Datetime, sample.CH2, "DisplayName", "Sample")
hold on
plot(sample.Datetime, sample.CH3, "DisplayName", "Background")
hold off
title(strcat("Raw Data: ", sample_info.sample.name, " #", ...
    string(sample_info.sample.id)))
grid on
legend()
ylabel("Pressure (mbar)")
xlabel("Datetime")
ylim([1e-6, 1e-3])
nexttile
plot(sample.Datetime, sample.T1)
hold on
plot(sample.Datetime, sample.T2)
% plot(sample.Datetime, sample.T3)
% plot(sample.Datetime, sample.T4)
% plot(sample.Datetime, sample.T5)
plot(sample.Datetime, sample.T6)
% plot(sample.Datetime, sample.T7)
% plot(sample.Datetime, sample.T8)
% plot(sample.Datetime, sample.T9)
hold off
grid on
ylabel("Temperature (\circC)")
xlabel("Datetime")
fontsize(16, "points")



%% Find start point
% start when valves closed in reference chamber
% Assumption: Valves close at the same time!
% TODO: Change this into a function

% convert to duraction
sample_dur = sample.Datetime - sample.Datetime(1);
% search for a minimum in the first 30 mins
% after valve is opened the pressure increases 
search_t = minutes(30);
search_CH3 = sample.CH3(sample_dur < search_t);

% trim to set time (15 hours)
t_diff = diff(sample_dur);
mean_diff = mean(t_diff);
max_t = hours(15);
max_idx = floor(max_t/mean_diff);

[~,start_CH3] = min(search_CH3);

% trim to region of interest (ROI)
sample_ROI = sample.CH2(start_CH3:start_CH3+max_idx);
ref_ROI = sample.CH3(start_CH3:start_CH3+max_idx);
central_ROI = sample.CH1(start_CH3:start_CH3+max_idx);
dur_ROI = sample_dur(start_CH3:start_CH3+max_idx) - sample_dur(start_CH3);

% mbar to Pa
sample_ROI = sample_ROI .* 100;
ref_ROI = ref_ROI .* 100;

% plot the trimmed data
figure(2)
plot(dur_ROI, sample_ROI, "DisplayName", "Sample")
hold on
plot(dur_ROI, ref_ROI, "DisplayName", "Reference")
hold off
title(strcat("Trimmed Data: ", sample_info.sample.name, " #", ...
    string(sample_info.sample.id)))
grid on
legend()
ylabel("Pressure (Pa)")
xlabel("Datetime")
ylim([1e-4, 1e-1])

%% Conductance Calculation
% % get temperature
% % starts at 5 as T1 is controller temp sensor
T_ROI = sample(start_CH3:start_CH3+max_idx,6:13);
% add 270 for kelvin - a vector the same size as time
mean_T_test = mean(table2array(T_ROI), 2) + 270;
% T_sample = sample(start_CH3:start_CH3+max_idx,)
T_sample = T_ROI.T2 + 270;
T_bg = T_ROI.T6 + 270;

% define constants
orf_d = 0.75e-3; % orifice diameter (m)
orf_t = 1e-3; % orifice thickness (m)
M = 0.02896; % Mean molecular mass (kg / mol) (dry air for now)
R = 8.3145; % Gas constant (J / K * mol)

C = concalc_rough(orf_d, orf_t, mean_T_test, M, R); % conductance calc
C_sample = concalc_rough(orf_d, orf_t, T_sample, M, R);
C_bg = concalc_rough(orf_d, orf_t, T_bg, M, R);
%% Background Correction
% load background and convert to pascal
% TODO: Trim this data
bg_ref = bg.CH3(start_CH3:start_CH3+max_idx) .* 100;
bg_sample = bg.CH2(start_CH3:start_CH3+max_idx) .* 100;
bg_date = bg.Datetime(start_CH3:start_CH3+max_idx);

figure(3)
plot(bg_date, bg_sample, "DisplayName", "Sample Chamber")
hold on
plot(bg_date, bg_ref, "DisplayName", "Reference Chamber")
hold off
title(strcat("Background Data"))
grid on
legend()
ylabel("Pressure (Pa)")
xlabel("Datetime")
ylim([1e-3, 1e-1])

% coefficients from background fit
back_coeff = polyfit(bg_ref, bg_sample, 3); 
corr_ref = back_coeff(1)*ref_ROI.^3 + back_coeff(2)*ref_ROI.^2 + ...
    back_coeff(3)*ref_ROI + back_coeff(4);

% plot the correction fit
backx = 0:max(bg_ref)/100:max(bg_ref);

figure(4)
hold on
plot(bg_ref, bg_sample, '.')
plot(backx, polyval(back_coeff,backx))
hold off
axis equal
grid on 
box on
xlabel('bg ref')
ylabel('bg sample')
title('background correction fitting')

%% Outgassing Calculation
% surface area
% TODO: Library of Areas
A = 18054.0 * 1e-6;
% q = C.*(sample_ROI - corr_ref)/A;
q = (C_sample.*(sample_ROI-central_ROI) - C_bg.*(corr_ref-central_ROI))/A;

% outgassing rates at 1hr and 10hrs
[~, idx_1hr] = min(abs(dur_ROI - hours(1)));
[~, idx_10hr] = min(abs(dur_ROI - hours(10)));
q_1hr = q(idx_1hr);
q_10hr = q(idx_10hr);

disp(['Sample Name: ', char(sample_info.sample.name)])
disp(['Sample ID: ', num2str(sample_info.sample.id)])
disp(['Sample measured on ', char(string(sample_info.datetime, ...
    "uuuu-MM-dd")), ' by ', char(sample_info.operator)])
disp(['Background measured on ', char(string(bg_info.datetime, ...
    "uuuu-MM-dd")), ' by ', char(bg_info.operator)])
disp(['Outgassing rate at 1hr = ', num2str(q_1hr), ' [Pa m s^{-1}]']);
disp(['Outgassing rate at 10hr = ', num2str(q_10hr), ' [Pa m s^{-1}]']);

% Plotting
figure(5)
plot(dur_ROI, q, "DisplayName", "Outgassing Rate")
hold on
scatter(dur_ROI(idx_10hr), q_10hr, "red", "filled")
scatter(dur_ROI(idx_1hr), q_1hr, "red", "filled")
xline(dur_ROI(idx_10hr), ':k')
xline(dur_ROI(idx_1hr), ':k')
ylim([0, 1e-5])
grid on
hold off
%% create the ouput file
output_struct = struct("q", q, "q1", q_1hr, "q10", q_10hr, "sample", ... 
    sample_info.sample, "sample_fn", sample_fn, "reference_fn", bg_fn);

path_to_output = "../processed_data/outgassing_rates/rig_verification/";
save(strcat(path_to_output, sample_fn, "_OGR.mat"), "-struct", "output_struct")