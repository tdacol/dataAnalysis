%% Main

clear all
close all
clc

%% TO SET - specify metrics that you would like to plot and analyze  
% check the metric name aka the field of the metrics struct contained in the 
% .mat file (e.g. user_2_a_c.m), you can also compute new metrics from the 
% field data of the same file (like it is done in the script 
% dataExtraction.m)

metric_name = {'tot_time', 'tool_is_out_of_FOV'}; 
metric_unit = {'min', 's'};
metric_scale_factor = [60 1];

% folder_containing_data = fileparts(which('user_02_a_c')); % uncomment if
% % your path to data is different wrt to the one specified in the 
% % following command
folder_containing_data = 'data/mat_file';
addpath(genpath(folder_containing_data));

%% Values used for correlation (hardcoded, previously computed)
% to do: upload and organize surveys data

global user_sus_score;
user_sus_score = [90 100 82.5 67.5 85 92.5 45 65 72.5 32.5]';
global user_experience;
user_experience = [0 0 0 1 2 2 2 2 2 2]';

% barplot parameters
bar_width = 0.5;
barplot = bar(user_sus_score, bar_width);

% figure properties
title(['barplot - users ranked by experience - sus score'])
xlabel('users [id]')
ylabel('sus score [%]')

set(barplot, 'FaceColor', [222 186 87]./255);

%% Load data in a cell array (2 procedures x 2 modalities x 12 users (user 
% 1 and 10 are empty)) containing each one a struct with the metrics

users_number = 10;
users = [2 5 3 4 12 6 9 11 7 8]; % ranked by experience

% Map procedures and modalities with identifiers numbers
procedures = [1 2];
procedure_file_names = {'_a', '_n'};
procedures_file_names_map = containers.Map(procedures, procedure_file_names);

modalities = [1 2];
modalities_file_names = {'_c', '_e'};
modalities_file_names_map = containers.Map(modalities, modalities_file_names);

users_filename = cell(numel(procedures),numel(modalities),max(users)); % = {};
users_data = cell(numel(procedures),numel(modalities),max(users)); % maybe 
% it is better to use non scalar structure instead of cell array

% Load the data and create the cell array
% procedure_loop_iterator = 1;
for procedure = procedures
    % modalities_loop_iterator = 1;
    for modality = modalities
        % users_loop_iterator = 1;
        for user = users
            if(user<users_number)
                filename = ['user_0', num2str(user), procedures_file_names_map(procedure), ...
                    modalities_file_names_map(modality)];
                users_filename(procedure, modality, user) = {filename};
            else
                filename = ['user_', num2str(user), procedures_file_names_map(procedure), ...
                    modalities_file_names_map(modality)];
                users_filename(procedure, modality, user) = {filename};
            end
            data = load(users_filename{procedure, modality, user});
            users_data(procedure, modality, user) = {data.(users_filename{procedure, modality, user})};
            % users_loop_iterator = users_loop_iterator + 1;
        end
        % modalities_loop_iterator = modalities_loop_iterator + 1;
    end
    % procedure_loop_iterator = procedure_loop_iterator + 1;;
end

%% Plots and analysis

for procedure = procedures
    for metric = 1:numel(metric_name)
        plotAndAnalyzeMetric(users_data, users_number, users, numel(modalities), ...
            numel(procedures), procedure, metric_name{metric}, metric_unit{metric}, ...
            metric_scale_factor(metric)); % N.B. users_data is not copied if it is not
            % modified in the function
    end
end

