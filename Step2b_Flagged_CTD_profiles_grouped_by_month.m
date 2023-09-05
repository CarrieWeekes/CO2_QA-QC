% Script to plot multiple depth profiles of a selected variable, separated by
% date.
clf;
clearvars

% Read in data

% if exist('df') ~= 1
    df = readtable('KC10_CTD_20120607_to_20230211.xlsx', 'Sheet', 'Acceptable_Value (AV) data');
%     df = readtable('QU39_CTD_20150318_to_20221213.xlsx', 'Sheet', 'Acceptable_Value (AV) data');
% end

varname = 'O2_umol_kg';
% varname = 'Temperature_degC';
% varname = 'Salinity_PSU';

% Select variable to plot
varcol = find(strcmp(df.Properties.VariableNames,varname),1);

% Set for loop and figure matrix parameters
months = unique(df.Month);
a = sqrt(length(months)); % approx. dimensions of matrix for all cast figures
dim1 = round(a);  % set nrow for subplot matrix
dim2 = dim1 + 1; % set ncol for subplot matrix
rows = max([dim1 dim2]);
cols = min([dim1 dim2]);

    if a > 3
        pointsize = 15; % reduce pointsize of there are many subplots on same image
        font_size = 10; % as above for font size
        else
        pointsize = 35;
        font_size = 14;
    end


x_min = min(df{:,varcol}); % for setting a-axis equal in all graphs
x_max = max(df{:,varcol}); % as above
y_min = min(df.Depth_m); % as above
y_max = max(df.Depth_m); % as above

% Set colour scheme for plotting different years of data
cmap = cbrewer('div', 'Spectral', 12, 'cubic');

set(0,'DefaultFigureWindowStyle','docked')

% Set figure title
% titleString = ['Station ', df.Station{1}];
% annotation('textbox', [0.12, 0.975 0.3, 0.02], 'String', titleString, 'FontSize', 14, 'FontWeight', 'bold', 'EdgeColor', 'none');


for i = 1:length(unique(df.Month))
   
       allDataForMonth = df(df.Month==i,:); % select all data for a given calendar month
       
       if height(allDataForMonth) > 0 % Account for years without some months, if using a single year's dataset
       
           years = unique(allDataForMonth.Year); % count number of years represented by selected monthly data

           for j = 1:length(years)

                idx = find(allDataForMonth.Year==years(j));
                singleMonthData = allDataForMonth(idx,:); % month-year data, i.e. for a single month in a single year

              if singleMonthData.Year(1) == 2012
                       color = cmap(1,:);
                   elseif singleMonthData.Year(1) == 2013
                       color = cmap(2,:);
                   elseif singleMonthData.Year(1) == 2014
                       color = cmap(3,:);
                   elseif singleMonthData.Year(1) == 2015
                       color = cmap(4,:);
                   elseif singleMonthData.Year(1) == 2016
                       color = cmap(5,:);
                   elseif singleMonthData.Year(1) == 2017
                       color = cmap(6,:);
                   elseif singleMonthData.Year(1) == 2018
                       color = cmap(7,:);
                   elseif singleMonthData.Year(1) == 2019
                       color = cmap(8,:);
                   elseif singleMonthData.Year(1) == 2020
                       color = cmap(9,:);
                   elseif singleMonthData.Year(1) == 2021
                       color = cmap(10,:);
                   elseif singleMonthData.Year(1) == 2022
                       color = cmap(11,:);
%                else
%                        color = 'y';
               end

           % plot figure
           subplot(rows,cols,i);
           fig = scatter(singleMonthData{:,varcol},singleMonthData.Depth_m, pointsize, 'filled');
           hold on   

           set(gca, 'ydir', 'reverse', 'fontsize', font_size);
           m = month(singleMonthData.StartTime_local, 'name'); % convert datetime to string
           str = m{:};
           title(str, 'interpreter', 'none'); 
%            xtitle = df.Properties.VariableNames{varcol};
           xtitle = varname;
           xlabel(xtitle, 'interpreter', 'none');
           ylabel('Depth');
           grid on;

            % Manually assign legend to months:

%            if i == 6 % June has data for years 2012 to 2022 (minus 2020)
%               legend('2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2021', '2022', 'Location', 'best');
%            end

%            if i == 7 % July has data for years 2012 to 2022
%                legend('2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', 'Location', 'best');
%            end
           end

       hold on

    % Equal-axes-graphs *** Choose this option OR the next option 
    % (Month-specific axes ranges below this section)

    %    ylim([min(y_min)-0.02*max(y_max), max(y_max)+0.02*max(y_max)]); % pad axis limits by 2%
    %    xlim([min(x_min)-0.02*x_max, max(x_max)+0.02*x_max]);

    % Month-specific axes ranges
        tempArray = table2array(singleMonthData(:,varcol));
        xlim([min(allDataForMonth{:,varcol})*0.999, max(allDataForMonth{:,varcol})*1.001]);

        % Add threshold line on graph
    %    line([min(mydata{:,varcol}) max(mydata{:,varcol})], [150 150], 'LineStyle', ':', 'Color', 'r');
       
       else
       end
end

% Set filename and print .pdf of the profiles
formatOut = 'mmddyyyy';
from = datestr(min(df.StartTime_UTC),formatOut);
to = datestr(max(df.StartTime_UTC),formatOut);
stn = df.Station{1};
filename = ['Profiles_', varname, '_', from, '_to_', to, '_', stn];

% Print output figure
print(filename, '-dpdf', '-fillpage');