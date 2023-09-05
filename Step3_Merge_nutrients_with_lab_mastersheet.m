% Script to merge nutrient data with analyzed carbonate sample bottle data from
% lab 'Mastersheets'.

% Script works on datasets for a SINGLE STATION and MULTIPLE DATES. It does not
% work for multiple stations on a single date (such as a multi-station cruise).

% * Note that this script will produce an output file that excludes additional
% nutrient data that does not have matching bottle data, either by date or
% depth. So, there may be additional bottle data available (e.g. Oct 31, 2017,
% depths 10 m to 300 m).

clearvars
format shortG

%% Read in data

% Read in nutrient data as .xlsx file downloaded from Hakai database
nuts = readtable('KC10_Nutrients.xlsx', 'Sheet', 'Hakai Data'); % data typically in sheet 3 ('Hakai Data')

% Read in 'mastersheet' as .xlsx file downloaded from Google Drive
btl = readtable('Compiled_KC10_Metadata_Mastersheet_2016_to_2022.xlsx');


%% Subset nutrient data files by shared dates

% Subset nutrient data that was collected on same day as bottle samples
nutsPaired = nuts(ismember(nuts.Date, btl.Collection_Date)==1,:);


% Subset nutrient data that has been analyzed (i.e., all nuts are not NaN)
nuts_select = nutsPaired(isnan(nutsPaired.NO2_NO3_uM_) == 0 & isnan(nutsPaired.PO4_uM_) == 0 & isnan(nutsPaired.SiO2_uM_) == 0,:);


%% Find and average triplicate nutrient samples, and set missing samples to NaN

% Set LineOutDepth values of '0' to '1' to permit accummary()
idx0 = find(nuts_select.LineOutDepth==0);
nuts_select.LineOutDepth(idx0) = 1;

vars = {'NO2_NO3_uM_', 'PO4_uM_', 'SiO2_uM_'}; % List of variables to average
nutsTable = [];
fillval = 99999; % arbitrary impossible value to separate missing nutrient values from nutrient concentrations actually 0 uM

nutDates = unique(nuts_select.Date);

for j = 1:length(nutDates)
    
    ld = nuts_select(nuts_select.Date==nutDates(j),:);
    dateArray = unique(ld.LineOutDepth); % Start array with just the depths for a given date

        % Find and average replicates for each variable above, based on shared LineOutDepth
        
        for i = 1:length(vars)

            varcol = find(strcmp(vars{i}, ld.Properties.VariableNames)==1); % get nut column #
            meanArray = accumarray(ld.LineOutDepth, ld{:,varcol}, [], @(x)mean(x, 'omitnan'), fillval);
            idxVal = find(meanArray ~= fillval); % Get index of non-0 values in accumarray output
            meanSelect = meanArray(idxVal);
            dateArray(:,i+1) = meanSelect; % i + 1 because first column is LineOutDepth
            
        end
        
    dateArray = [zeros(length(dateArray),1), dateArray]; % Add extra column for Date
    dateArray(:,1) = datenum(ld.Date(1)); % Add datenum for date of sample collection
    dateTable = array2table(dateArray); % Convert back to table
    dateTable.Properties.VariableNames = [{'Date', 'LineOutDepth'}, vars];
    nutsTable = [nutsTable; dateTable];
        
end
    
% Return all '1 m' deep samples to '0 m' depths
idx1 = find(nutsTable.LineOutDepth==1);
nutsTable.LineOutDepth(idx1) = 0;

% Adjust variable formatting and names to permit merger with bottle samples
nutsTable.Date = datetime(datevec(nutsTable.Date), 'Format', 'dd-MMM-yyyy'); % Change back to datetime for btl merge
% nutsTable.Properties.VariableNames{'Date'} = 'Collection_date';
nutsTable.Properties.VariableNames{'LineOutDepth'} = 'TargetDepth';

%% Merge (join) bottle and nutrient data
% Depending on the station / dataset -- determine the max target depth!
idxBtm = find(nutsTable.TargetDepth==650);
nutsTable.TargetDepth(idxBtm) = 650; % Create equal bottom bottle depths for matching
nutsTable.Collection_Date = nutsTable.Date; % Create identical names to act as MergeKeys
nutsTable.Date = [];

% Specific to KC10 mastersheet, looks like some rough calculations added to some
% rows in last two columns, but without column names
% btl = btl(:,1:23); % Remove partial std.dev.'s and mean's from mastersheet

% Merge mastersheet and nutrients, and adjust column names to match next script to create bottle file

% merged = outerjoin(btl, nutsTable, 'Type', 'Left'); % Include unmatched bottle samples from the left, or 'btl', table
merged = outerjoin(btl, nutsTable, 'Type', 'Left', 'MergeKeys', 1);
% merged = outerjoin(btl, nutsTable, 'MergeKeys', 1);
% merged.Properties.VariableNames(end-2:end) = {'NO3_NO2_uM', 'PO4_uM', 'SiO2_uM'};

idxNotNan = ~isnan(merged.CRMTCO2_umol_kg_); % remove rows where nutrients are available but bottle samples aren't available
mergedOut = merged(idxNotNan,:);

% Output files
% writetable(nutsTable, 'nuts.xlsx');
writetable(mergedOut, 'merged_mastersheet_and_nutrients.xlsx');










