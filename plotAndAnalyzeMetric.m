function plotAndAnalyzeMetric(users_data, users_number, users, modalities_number, ...
    procedures_number, procedure, metric_name, metric_unit, metric_scale_factor) 

global user_sus_score;

% Map procedures and modalities with identifiers numbers
modalities = 1 : modalities_number;
modalities_names = {'manual', 'autonomous'};
modalities_names_map = containers.Map(modalities, modalities_names);

procedures = 1 : procedures_number;
procedures_names = {'anastomosis', 'neobladder'};
procedures_names_map = containers.Map(procedures, procedures_names);

% Extract metric of interest to plot and analyze it
metric = zeros(users_number,numel(modalities));
for modality = modalities
    users_loop_iterator = 1;
    for user = users
        metric(users_loop_iterator, modality) = users_data{procedure, modality, user}.metrics.(metric_name);
        users_loop_iterator = users_loop_iterator + 1;
    end
end
metric = metric./metric_scale_factor;

%% Plots

% default figure properties
% https://www.mathworks.com/help/matlab/creating_plots/default-property-values.html
% https://www.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html
set(groot,'defaultFigureColor', 'w'); % instead of set(gcf,'color','white');
set(groot, 'defaultTextInterpreter', 'none');
set(groot, 'defaultTextFontSize', 15);
set(groot, 'defaultAxesFontSize', 15)

% Boxplot
fig1=figure;

% boxplot parameters
colors=[123 167 180; 222 186 87]./255; % yellow and light blu (wes anderson palette) 
median_width=0.05;
positions = [0.1 0.2];
outliers_shape_size=1;
groups = [{modalities_names_map(1)} {modalities_names_map(2)}];

boxplot(metric, groups, 'PlotStyle', 'compact', 'Colors', colors, 'MedianStyle', 'line', 'Widths', median_width, 'Positions', positions, 'OutlierSize', outliers_shape_size)

% figure properties
title(['boxplot - ', procedures_names_map(procedure), ' - ', metric_name]);
ylabel([metric_name, ' [', metric_unit, ']'])

% legend(findobj(gca, 'Tag', 'Box'), {modalities_names_map(1)}, {modalities_names_map(2)});

% fig.Color='white';
% set(gcf,'color','white');
% set(gca,'FontSize',15);
% set(plot_title,'Interpreter','none');
set(gca, 'xcolor', 'w');

% Barplot

fig2=figure;

% barplot parameters
bar_width = 0.9;
barplot = bar(metric, bar_width);

% figure properties
title(['barplot - user ranked by experience - ', procedures_names_map(procedure), ' - ', metric_name])
xlabel('users [id]')
ylabel([metric_name, ' [', metric_unit, ']'])

set(barplot(1), 'FaceColor', colors(1,:));
set(barplot(2), 'FaceColor', colors(2,:));

%% Statistical Analisis

disp('******************************************************')
disp(['statistical analysis, ranksum test (significant difference for p < 0.05) - ', procedures_names_map(procedure), ' - ', metric_name])
disp('******************************************************')
disp(' ')
[P,H] = ranksum(metric(:,1), metric(:,2));
if(P<0.05)
    disp('Significant difference')
    P
else 
    disp('No significant difference')
    P
end  

%% New statistical analysis - to be optimized

[ordered_sus_score ordered_sus_score_indeces] = sort(user_sus_score);

fig3=figure;
hold on

plot_simbols_code = {'d', 'v'};
modalities_plot_simbols_map = containers.Map(modalities, plot_simbols_code);

linear_regression_model = cell(2);
model_R_squared = zeros(2);
for modality = modalities
    % plot metric(sus_score)
    new_plot = plot(ordered_sus_score, metric(ordered_sus_score_indeces, modality), modalities_plot_simbols_map(modality), ...
        'Color', colors(modality,:), 'LineStyle', '-');
    set(new_plot, 'markerfacecolor', get(new_plot, 'color'));
    % fit a linear regression model
    linear_regression_model(modality) = {fitlm(metric(:,modality), user_sus_score)};
    % compute adjusted R squared
    disp('******************************************************')
    disp(['statistical analysis - r squared - ', procedures_names_map(procedure), ' - ', modalities_names_map(modality) ,' - ', metric_name ,'&sus_score'])
    disp('******************************************************')
    disp(' ')
    model_R_squared(modality) = linear_regression_model{modality}.Rsquared.Adjusted
end

% figure properties
title([procedures_names_map(procedure), ' - ' metric_name, '(sus_score)']);
xlabel('sus_score [%]');
ylabel([metric_name, ' [', metric_unit, ']']);

hold off

end