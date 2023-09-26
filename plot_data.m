clear all
close all
% Specify path to processed data
path_to_data = "project_sharepoint/Data/2023/SPIE_paper_data/processed/";

% two runs
run1_path = strcat(path_to_data, 'run1/');
run2_path = strcat(path_to_data, 'run2/');

% colors for plotting
colors = ["r" "b" "g" "c" "m" "#D95319" "k" "#7E2F8E" "#77AC30" "#A2142F"];

pattern = '*.mat';

% Specify the file names
file_struct = [dir(strcat(run1_path, pattern)); dir(strcat(run2_path, pattern))];
file_names = {file_struct.name};

% Define an endate to switch between experimental runs
run1_end_date = 20230630;
sampling_rate = 5;

% empty arrays to store OG rates for paper table
mats = [];
ids = [];
OG_1hr = [];
OG_10hr = [];

% Plotting
figure(1)
tiledlayout(2,1, 'Padding', 'none', 'TileSpacing', 'compact');
for i = 1:length(file_names)
    % get the filename and extract start date
    fn = file_names{i};
    start_date = str2num(fn(1:8));
    if start_date < run1_end_date
        % Load the data
        file_data = load(strcat(run1_path, fn));
        
        % plotting parameters for run 1
        nexttile(1)
        set(gca, 'YScale', 'log', 'FontSize', 16)
        ylabel("Outgassing Rate (Pa m s^{-1})", 'Fontsize', 24)
        grid on
        xticks(0:1:15)
        ylim([1e-10 1e-3])
    % repeat for run 2
    else
        file_data = load(strcat(run2_path, fn));
    
        nexttile(2)
        set(gca, 'YScale', 'log', 'FontSize', 16)
        ylabel("Outgassing Rate (Pa m s^{-1})", 'Fontsize', 24)
        grid on
        legend('FontSize', 14, 'Location', 'southeast') % legend for both plots
        ylim([1e-10 1e-3]) 
        xticks(0:1:15)
    end
    % calculate duration of test in hrs
    time = sampling_rate * (1:length(file_data.q));
    time_hrs = time./(60*60);
    hold on
    
    % Change plot color based on sample no
    % Change marker to inidate different materials
    if file_data.sample_mat == "WAAM"
        if file_data.sample_no > 4
            sample_name = strcat("WAAM #", num2str(file_data.sample_no), ...
                " (machined)");
            plot(time_hrs, file_data.q, 'DisplayName', sample_name, ...
                'Color', colors(file_data.sample_no), ... 
                    'Marker', '*', 'MarkerSize', 12, 'MarkerIndices', 100:500:length(time_hrs));
        else
            sample_name = strcat("WAAM #", num2str(file_data.sample_no), ...
                    " (non-machined)");
            plot(time_hrs, file_data.q, 'DisplayName', sample_name, ...
                    'Color', colors(file_data.sample_no), ... 
                    'Marker', 'o', 'MarkerIndices', 100:500:length(time_hrs));
        end
    elseif file_data.sample_mat == "bulk"
        nexttile(2)
        sample_name = strcat("Bulk #", num2str(file_data.sample_no), ...
                    " (machined)");
        plot(time_hrs, file_data.q, 'DisplayName', sample_name, ...
                    'Color', colors(file_data.sample_no));
        nexttile(1)
        plot(time_hrs, file_data.q, 'DisplayName', sample_name, ...
                    'Color', [.5 .5 .5]);


    end
    % Save OG rates
    mats = [mats; string(file_data.sample_mat)];
    ids = [ids; file_data.sample_no];
    OG_1hr = [OG_1hr; file_data.hr1];
    OG_10hr = [OG_10hr; file_data.hr10];
                
end
hold off
% Get the average OG rate for WAAM samples
% NOTE: bulk samples were only taken in run 1 so these are not averaged 
OG_table = table(mats, ids, OG_1hr, OG_10hr);
sort_OG_table = sortrows(OG_table);
disp("Average OG rate")
for m = ["WAAM" "bulk"]
    for id = [1 2 3 5 6 7]
        idx = sort_OG_table.mats == m & sort_OG_table.ids == id;
        fltrd_table = sort_OG_table(idx,:);
        disp([m, id, mean(fltrd_table.OG_1hr), mean(fltrd_table.OG_10hr)])
        
    end
end
