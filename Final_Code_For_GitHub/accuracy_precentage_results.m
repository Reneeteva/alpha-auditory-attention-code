%% Accuracy and Error Analysis - exact calculation
% Each file = one participant
%
% This code calculates:
% 1. Accuracy percent in silence, slow, fast
% 2. Number of errors in silence, slow, fast
% 3. Paired graphs like the RT graphs
% 4. Spearman correlation between stimulus level and accuracy
%
% Accuracy is calculated from ALL trials in each condition:
% Accuracy = correct trials / total trials * 100
%
% error column:
% 0 = correct
% 1 = error

clear;
clc;
close all;

%% 1. Automatically use all participant files in the current MATLAB folder

path = pwd;

xlsx_files = dir(fullfile(path, '*.xlsx'));
xls_files  = dir(fullfile(path, '*.xls'));
csv_files  = dir(fullfile(path, '*.csv'));

all_files = [xlsx_files; xls_files; csv_files];

file_names = {all_files.name};

% Keep only real participant files
keep_file = contains(file_names, 'exel sub', 'IgnoreCase', true);

all_files = all_files(keep_file);

files = {all_files.name};
n_subjects = length(files);

fprintf('\nFound %d participant files:\n', n_subjects);
disp(files');

if n_subjects < 2
    error('MATLAB found fewer than 2 participant files. Check that the Current Folder contains the participant Excel files.');
end

%% 2. Prepare variables

subject_id = strings(n_subjects,1);

accuracy_silence = NaN(n_subjects,1);
accuracy_slow    = NaN(n_subjects,1);
accuracy_fast    = NaN(n_subjects,1);

errors_silence = NaN(n_subjects,1);
errors_slow    = NaN(n_subjects,1);
errors_fast    = NaN(n_subjects,1);

correct_silence = NaN(n_subjects,1);
correct_slow    = NaN(n_subjects,1);
correct_fast    = NaN(n_subjects,1);

total_silence = NaN(n_subjects,1);
total_slow    = NaN(n_subjects,1);
total_fast    = NaN(n_subjects,1);

%% 3. Analyze each participant file

for s = 1:n_subjects

    filename = fullfile(path, files{s});
    T = readtable(filename, 'VariableNamingRule', 'preserve');

    [~, name, ~] = fileparts(files{s});
    subject_id(s) = string(name);

    % Columns according to your PsyToolkit output:
    % B = auditory condition: silence / slow / fast
    % H = error: 0 = correct, 1 = error

    auditory_condition = lower(strtrim(string(T{:,2})));
    errors = str2double(string(T{:,8}));

    %% Condition indexes - ALL trials, not only valid RT trials

    idx_silence = auditory_condition == "silence";
    idx_slow    = auditory_condition == "slow";
    idx_fast    = auditory_condition == "fast";

    %% Total trials per condition

    total_silence(s) = sum(idx_silence);
    total_slow(s)    = sum(idx_slow);
    total_fast(s)    = sum(idx_fast);

    %% Correct trials per condition
    % error == 0 means correct

    correct_silence(s) = sum(idx_silence & errors == 0);
    correct_slow(s)    = sum(idx_slow & errors == 0);
    correct_fast(s)    = sum(idx_fast & errors == 0);

    %% Errors per condition
    % error == 1 means incorrect

    errors_silence(s) = sum(idx_silence & errors == 1);
    errors_slow(s)    = sum(idx_slow & errors == 1);
    errors_fast(s)    = sum(idx_fast & errors == 1);

    %% Exact accuracy percent per condition

    accuracy_silence(s) = correct_silence(s) / total_silence(s) * 100;
    accuracy_slow(s)    = correct_slow(s)    / total_slow(s)    * 100;
    accuracy_fast(s)    = correct_fast(s)    / total_fast(s)    * 100;

end

%% 4. Create results table

slow_minus_fast_accuracy    = accuracy_slow - accuracy_fast;
silence_minus_fast_accuracy = accuracy_silence - accuracy_fast;
silence_minus_slow_accuracy = accuracy_silence - accuracy_slow;

results_table = table( ...
    subject_id, ...
    total_silence, total_slow, total_fast, ...
    correct_silence, correct_slow, correct_fast, ...
    errors_silence, errors_slow, errors_fast, ...
    accuracy_silence, accuracy_slow, accuracy_fast, ...
    slow_minus_fast_accuracy, ...
    silence_minus_fast_accuracy, ...
    silence_minus_slow_accuracy);

results_table.Properties.VariableNames = { ...
    'Subject', ...
    'Total_Silence', ...
    'Total_Slow', ...
    'Total_Fast', ...
    'Correct_Silence', ...
    'Correct_Slow', ...
    'Correct_Fast', ...
    'Errors_Silence', ...
    'Errors_Slow', ...
    'Errors_Fast', ...
    'Accuracy_Silence_percent', ...
    'Accuracy_Slow_percent', ...
    'Accuracy_Fast_percent', ...
    'Slow_minus_Fast_accuracy', ...
    'Silence_minus_Fast_accuracy', ...
    'Silence_minus_Slow_accuracy'};

disp(' ');
disp('================ EXACT ACCURACY RESULTS TABLE ================');
disp(results_table);

%% 5. Save results table

output_excel = fullfile(path, 'Exact_Accuracy_and_Errors_Results.xlsx');
writetable(results_table, output_excel);

fprintf('\nSaved Excel table here:\n%s\n', output_excel);

%% 6. Spearman correlation: stimulus level and accuracy

n_subjects_final = length(accuracy_silence);

stimulus_level = repmat([1; 2; 3], n_subjects_final, 1);

accuracy_for_correlation = [];

for s = 1:n_subjects_final
    accuracy_for_correlation = [accuracy_for_correlation; ...
                                accuracy_silence(s); ...
                                accuracy_slow(s); ...
                                accuracy_fast(s)];
end

valid_corr = ~isnan(stimulus_level) & ~isnan(accuracy_for_correlation);

stimulus_level_valid = stimulus_level(valid_corr);
accuracy_valid = accuracy_for_correlation(valid_corr);

[rho_spearman, p_spearman] = corr(stimulus_level_valid, ...
                                  accuracy_valid, ...
                                  'Type', 'Spearman', ...
                                  'Rows', 'complete');

fprintf('\n================ SPEARMAN CORRELATION - ACCURACY ================\n');
fprintf('Stimulus levels: 1 = silence, 2 = slow, 3 = fast\n');
fprintf('Spearman rho = %.4f\n', rho_spearman);
fprintf('p-value = %.4f\n', p_spearman);

%% 7. Spearman visual graph for accuracy

figure;
hold on;

x = [1 2 3];

accuracy_matrix = [accuracy_silence, accuracy_slow, accuracy_fast];

jitter_amount = 0.06;

for s = 1:n_subjects_final

    jitter = (rand(1,3) - 0.5) * jitter_amount;

    plot(x + jitter, accuracy_matrix(s,:), ...
        '-', ...
        'Color', [0.75 0.75 0.75], ...
        'LineWidth', 1.2);

    scatter(x + jitter, accuracy_matrix(s,:), ...
        45, ...
        'filled', ...
        'MarkerFaceColor', [0.35 0.35 0.75], ...
        'MarkerEdgeColor', 'k');
end

group_mean_accuracy = mean(accuracy_matrix, 1, 'omitnan');

plot(x, group_mean_accuracy, ...
    '-ko', ...
    'LineWidth', 3, ...
    'MarkerSize', 9, ...
    'MarkerFaceColor', 'k');

for i = 1:3
    plot([x(i)-0.15, x(i)+0.15], ...
         [group_mean_accuracy(i), group_mean_accuracy(i)], ...
         'k-', ...
         'LineWidth', 4);
end

set(gca, 'XTick', [1 2 3], ...
         'XTickLabel', {'silence', 'slow', 'fast'});

xlabel('Auditory Stimulus Level');
ylabel('Accuracy (%)');
title('Spearman Correlation: Stimulus Level and Accuracy');

ylim([0 105]);

grid on;
box off;

result_text = sprintf('Spearman \\rho = %.3f\np = %.4f\nn = %d data points', ...
                      rho_spearman, p_spearman, length(accuracy_valid));

text(1.05, 8, result_text, ...
    'FontSize', 11, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', [0.7 0.7 0.7]);

hold off;

output_spearman_graph = fullfile(path, 'Spearman_Accuracy_Stimulus_Level.png');
saveas(gcf, output_spearman_graph);

fprintf('Saved Spearman accuracy graph here:\n%s\n', output_spearman_graph);

%% 8. Create the 3 paired accuracy graphs

make_paired_accuracy_graph(accuracy_slow, accuracy_fast, ...
    'slow', 'fast', ...
    'Graph 1: Accuracy - Slow vs Fast', ...
    fullfile(path, 'Graph_1_Accuracy_Slow_vs_Fast.png'));

make_paired_accuracy_graph(accuracy_silence, accuracy_fast, ...
    'silence', 'fast', ...
    'Graph 2: Accuracy - Silence vs Fast', ...
    fullfile(path, 'Graph_2_Accuracy_Silence_vs_Fast.png'));

make_paired_accuracy_graph(accuracy_silence, accuracy_slow, ...
    'silence', 'slow', ...
    'Graph 3: Accuracy - Silence vs Slow', ...
    fullfile(path, 'Graph_3_Accuracy_Silence_vs_Slow.png'));

fprintf('\nDONE.\n');
fprintf('Created:\n');
fprintf('1. Exact_Accuracy_and_Errors_Results.xlsx\n');
fprintf('2. Spearman_Accuracy_Stimulus_Level.png\n');
fprintf('3. Graph_1_Accuracy_Slow_vs_Fast.png\n');
fprintf('4. Graph_2_Accuracy_Silence_vs_Fast.png\n');
fprintf('5. Graph_3_Accuracy_Silence_vs_Slow.png\n');

%% ============================================================
% Function: paired graph for accuracy
%% ============================================================

function make_paired_accuracy_graph(data_A, data_B, ...
    label_A, label_B, graph_title, output_path)

    %% Keep only participants with data in both conditions

    valid = ~isnan(data_A) & ~isnan(data_B);

    data_A = data_A(valid);
    data_B = data_B(valid);

    n = length(data_A);

    fprintf('\n%s:\n', graph_title);
    fprintf('Valid participants in this graph: %d\n', n);

    if n < 2
        warning('Not enough valid participants for %s vs %s.', ...
            label_A, label_B);
        return;
    end

    %% Paired t-test

    [~, p, ~, stats] = ttest(data_A, data_B);

    mean_A = mean(data_A, 'omitnan');
    mean_B = mean(data_B, 'omitnan');

    difference = data_B - data_A;
    mean_difference = mean(difference, 'omitnan');

    %% Significance stars

    if p < 0.001
        stars = '***';
    elseif p < 0.01
        stars = '**';
    elseif p < 0.05
        stars = '*';
    else
        stars = 'n.s.';
    end

    %% Create figure with white background

    figure('Color', 'w');
    hold on;

    set(gca, ...
        'Color', 'w', ...
        'FontSize', 11, ...
        'LineWidth', 1);

    xA = 1;
    xB = 2;

    %% Jitter

    jitter_A = linspace(-0.07, 0.07, n)';
    jitter_B = linspace(-0.07, 0.07, n)';

    %% Participant lines

    for i = 1:n

        plot( ...
            [xA + jitter_A(i), xB + jitter_B(i)], ...
            [data_A(i), data_B(i)], ...
            '-', ...
            'Color', [0.70 0.70 0.70], ...
            'LineWidth', 1.3);

    end

    %% Participant dots

    scatter(xA + jitter_A, data_A, ...
        60, ...
        'filled', ...
        'MarkerFaceColor', [0.15 0.30 0.90], ...
        'MarkerEdgeColor', 'k', ...
        'LineWidth', 0.8);

    scatter(xB + jitter_B, data_B, ...
        60, ...
        'filled', ...
        'MarkerFaceColor', [0.10 0.70 0.25], ...
        'MarkerEdgeColor', 'k', ...
        'LineWidth', 0.8);

    %% Mean bars

    plot([xA - 0.18, xA + 0.18], ...
        [mean_A, mean_A], ...
        'k-', ...
        'LineWidth', 4);

    plot([xB - 0.18, xB + 0.18], ...
        [mean_B, mean_B], ...
        'k-', ...
        'LineWidth', 4);

    %% Significance line

    y_max = max([data_A; data_B]);
    y_min = min([data_A; data_B]);
    y_range = y_max - y_min;

    if y_range == 0
        y_range = 5;
    end

    y_sig = min(103.2, y_max + 0.12*y_range);

    plot([xA, xB], ...
        [y_sig, y_sig], ...
        'k-', ...
        'LineWidth', 1.5);

    text(1.5, min(104.3, y_sig + 0.04*y_range), ...
        stars, ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 18, ...
        'FontWeight', 'bold');

    %% Axes and labels

    set(gca, ...
        'XTick', [1 2], ...
        'XTickLabel', {label_A, label_B});

    xlim([0.5 2.5]);
    ylim([85 105]);

    ylabel('Accuracy (%)');
    xlabel('Auditory Condition');
    title(graph_title);

    grid on;
    box off;

    %% Results box

    result_text = sprintf([ ...
        'n = %d\n' ...
        'Mean %s = %.1f%%\n' ...
        'Mean %s = %.1f%%\n' ...
        '%s - %s = %.1f%%\n' ...
        't(%d) = %.2f\n' ...
        'p = %.4f'], ...
        n, ...
        label_A, mean_A, ...
        label_B, mean_B, ...
        label_B, label_A, mean_difference, ...
        stats.df, stats.tstat, ...
        p);

    text(0.58, 86.2, result_text, ...
        'FontSize', 10.5, ...
        'FontWeight', 'bold', ...
        'Color', 'k', ...
        'BackgroundColor', [1.00 0.85 0.25], ...
        'EdgeColor', [0.05 0.20 0.65], ...
        'LineWidth', 2, ...
        'Margin', 8);

    hold off;

    %% Save graph

    saveas(gcf, output_path);

end