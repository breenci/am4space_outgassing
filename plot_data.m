% Specify path to processed data
path_to_data = "project_sharepoint/Data/2023/SPIE_paper_data/";

% Specify the file names
files = ["20230802_125602_bulk_Al_02.mat", "20230823_145035_bulk_Al_03", ...
    "20230808_111950_WAAM_Al_02", "20230809_114631_WAAM_Al_03", "20230811_180057_WAAM_Al_05" ...
    "20230814_173903_WAAM_Al_06", "20230815_152852_WAAM_Al_07", "20230803_131526_WAAM_Al_01"];
% Labels for the plot legend
labels = ["Bulk Al. #2", "Bulk Al. #3", "WAAM #1 (Machined)", "WAAM #2 (Machined)", "WAAM #3 (Machined)", ...
    "WAAM #5 (Raw)", "WAAM #6 (Raw)", "WAAM #7 (Raw)"];

sampling_rate = 5;
% Do the plotting
fig = figure(1);
for i = 1:length(files)
    % Load the data
    file_data = load(strcat(path_to_data, files(i)));
    % calculate duration of test in hrs
    time = sampling_rate * (1:length(file_data.q));
    time_hrs = time./(60*60);
    % plot the data with different markers
    if file_data.sample_type == 1
        plot(time_hrs, file_data.q, 'DisplayName', labels(i), 'LineStyle', ...
            '-', 'LineWidth', 1);
    elseif file_data.sample_type == 2
        plot(time_hrs, file_data.q, 'DisplayName', labels(i), 'LineStyle', ...
            '--', 'LineWidth', 1);
    elseif file_data.sample_type == 3
        plot(time_hrs, file_data.q, 'DisplayName', labels(i), 'LineStyle', ...
            ':', 'LineWidth', 1);
    end
    % Print the OG rates at 1hr and 10hrs
    disp([labels(i),file_data.hr1, file_data.hr10])
    hold on
end
% Some plotting parameters
set(gca, 'YScale', 'log', 'FontSize', 16)
legend('FontSize', 16)
ylabel("Outgassing Rate (Pa m s^{-1})", 'Fontsize', 24)
xlabel("Time (hrs)", 'FontSize', 24)
% xline([1,10], '--', {'1HR', '10HR'}, 'LineWidth', 2)
xticks(0:1:15)
grid on
hold off