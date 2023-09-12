clear all
close all
% Specify path to processed data
path_to_data = "project_sharepoint/Data/2023/SPIE_paper_data/";

% two runs
run1_path = strcat(path_to_data, 'run1/');
run2_path = strcat(path_to_data, 'run2/');

% colors for plotting
colors = ["r" "b" "g" "c" "m" "#D95319" "k" "#7E2F8E" "#77AC30" "#A2142F"];

% Specify the file names
file_struct1 = dir(strcat(run1_path, '*.mat'));

files1 = {file_struct1.name};
% Labels for the plot legend

sampling_rate = 5;

% Do the plotting
% slightly overkill but for a one off plot
fig = figure(1);
tiledlayout(2,1, 'Padding', 'none', 'TileSpacing', 'compact'); 
nexttile
for i = 1:length(files1)
    % Load the data
    fn = files1{i};
    file_data = load(strcat(run1_path, fn));
    % calculate duration of test in hrs
    time = sampling_rate * (1:length(file_data.q));
    time_hrs = time./(60*60);
    sample_no = fn(end-4);
    % plot the data with different markers and colors
    % associate colors to sample names for consistency between measurements
    if file_data.sample_type == 1
        sample_name = strcat("Bulk Al Cube #", sample_no);
        sample_idx = str2num(sample_no);
        plot(time_hrs, file_data.q, 'DisplayName', sample_name, 'LineStyle', ...
            '-', 'LineWidth', 1, 'Color', colors(sample_idx));
    elseif file_data.sample_type == 2
        sample_idx = str2num(sample_no);
        sample_name = strcat("WAAM #", sample_no, ' (machined)');        
        plot(time_hrs, file_data.q, 'DisplayName', sample_name, 'LineStyle', ...
            '-', 'LineWidth', 1, 'Marker', 'o', 'MarkerIndices', 100:500:length(time_hrs), ...
            'Color', colors(sample_idx+3));
    elseif file_data.sample_type == 3
        sample_idx = str2num(sample_no);
        sample_name = strcat("WAAM #", sample_no, ' (non-machined)');        
        plot(time_hrs, file_data.q, 'DisplayName', sample_name, 'LineStyle', ...
            '-', 'LineWidth', 1, 'Marker', '*', 'MarkerIndices', 100:500:length(time_hrs),...
            'Color', colors(sample_idx+2));
    end
    % Print the OG rates at 1hr and 10hrs
    disp(["Run 1",sample_name,file_data.hr1, file_data.hr10])
    hold on
end


% Some plotting parameters
set(gca, 'YScale', 'log', 'FontSize', 16)
% legend('FontSize', 16)
ylabel("Outgassing Rate (Pa m s^{-1})", 'Fontsize', 24)
grid on
% xline([1,10], '--', {'1HR', '10HR'}, 'LineWidth', 2)
xticks(0:1:15)

% Repeat for run 2
% Specify the file names
file_struct2 = dir(strcat(run2_path, '*.mat'));
files2 = {file_struct2.name};
nexttile
for i = 1:length(files2)
    % Load the data
    fn = files2{i};
    file_data = load(strcat(run2_path, fn));
    % calculate duration of test in hrs
    time = sampling_rate * (1:length(file_data.q));
    time_hrs = time./(60*60);
    sample_no = fn(end-4);
    % plot the data with different markers
    if file_data.sample_type == 1
        sample_name = strcat("Bulk Al Cube #", sample_no);
        sample_idx = str2num(sample_no);
        plot(time_hrs, file_data.q, 'DisplayName', sample_name, 'LineStyle', ...
            '-', 'LineWidth', 1, 'Color', colors(sample_idx));
    elseif file_data.sample_type == 2
        sample_idx = str2num(sample_no);
        sample_name = strcat("WAAM #", sample_no, ' (machined)');        
        plot(time_hrs, file_data.q, 'DisplayName', sample_name, 'LineStyle', ...
            '-', 'LineWidth', 1, 'Marker', 'o', 'MarkerIndices', 100:500:length(time_hrs), ...
            'Color', colors(sample_idx+3));
    elseif file_data.sample_type == 3
        sample_idx = str2num(sample_no);
        sample_name = strcat("WAAM #", sample_no, ' (non-machined)');        
        plot(time_hrs, file_data.q, 'DisplayName', sample_name, 'LineStyle', ...
            '-', 'LineWidth', 1, 'Marker', '*', 'MarkerIndices', 100:500:length(time_hrs),...
            'Color', colors(sample_idx+2));
    end
    % Print the OG rates at 1hr and 10hrs
    disp(["Run 2", sample_name ,file_data.hr1, file_data.hr10])
    hold on
end
% Some plotting parameters
set(gca, 'YScale', 'log', 'FontSize', 16)
legend('FontSize', 12, 'Location', 'southeast')
ylabel("Outgassing Rate (Pa m s^{-1})", 'Fontsize', 24)
xlabel("Time (hrs)", 'FontSize', 24)
% xline([1,10], '--', {'1HR', '10HR'}, 'LineWidth', 2)
xticks(0:1:15)
grid on
hold off