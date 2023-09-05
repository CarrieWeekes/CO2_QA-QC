% Plot all vertical profiles for a variable in a CTD file
% Output is a set of .pdf files with up to 12 profiles per page

% * Note - should add station name to profile figures

clf;
clearvars

if exist('df') ~=1
df = readtable('KC10_CTD_20120607_to_20230211.xlsx', 'Sheet', 'Acceptable_Value (AV) data');
%     df = readtable('QU39_CTD_20150318_to_20221213.xlsx', 'Sheet', 'Data');

end

% Choose variable to plot
var = 'O2_umol_kg';
% var = 'Temperature_degC';
% var = 'Salinity_PSU';

% Pick one year and one variable to plot
years = unique(df.Year);

for k = 1:length(years)

% Sort out data for selected year and variable
% dfyr = df(df.Year==year,:);
dfyr = df(df.Year==years(k),:);
varcol = find(strcmp(dfyr.Properties.VariableNames, var), 1);
casts = unique(dfyr.CastPK);

% Determine number of pages to ouput
a = length(casts)/12;
pages = ceil(a); % Number of pages needed at 12 profiles per page

for j = 1:pages
    
    if j < pages
        
            pageCasts = casts(1:12);
        else
            pageCasts = casts(1:end);
    end
    
    for i = 1:length(pageCasts)
            
        subplot(4,3,i)
      
            % Plot profiles for selected year and variable
            ld = dfyr(dfyr.CastPK==pageCasts(i),:);
            scatter(ld{:,varcol}, ld.Depth_m);
            set(gca, 'ydir', 'reverse', 'fontsize', 12);
            ylabel('Depth');
            xlabel(df.Properties.VariableNames{varcol}, 'Interpreter', 'none');
            str = ['CastPK_', num2str(casts(i))];
            title(str, 'Interpreter', 'none');
            line([1.4 1.4], [0 max(ld.Depth_m)], 'LineStyle', ':', 'Color', 'r'); % Hypoxia threshold
            hold on
    end
    
    fnameOut = ['CastPKs_', num2str(pageCasts(1)), '_to_', num2str(pageCasts(end))];
    print(fnameOut, '-dpdf', '-fillpage');
    clf;
    
    if j < pages
       casts = casts(13:end); % Remove the first 12 casts for next loop to start
    end
    
end
end

