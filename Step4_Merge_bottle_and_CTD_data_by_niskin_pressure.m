% Extract CTD data from bottle depths indicated by Niskin pressure sensor and
% merge with bottle samples by sample depth

% To do: 

% 1. Vectorize loops to speed up script
% 
% 2. Output a notice for bottle sampling dates that don't have corresponding CTD
% data (e.g. May 17, 2016). Although rare, such dates could have additional usable bottle sample information
% 
% 3. Generate summary of differences between bottle and CTD depths.
% Discrepancies are largely confined to the bottom depth, where differences
% between Target Depth, Niskin Depth, and CTD depth may be up to 15 m. However,
% the associated CTD variables change very little over such a range at the water
% column bottom.



clearvars 

%% READ IN DATA

% Read in merged bottle and nutrient data file
btl = readtable('merged_mastersheet_and_nutrients.xlsx');

% Read in CTD file
ctd = readtable('KC10_CTD_20120607_to_20230211.xlsx', 'Sheet', 'Acceptable_Value (AV) data');
% ctd = readtable('QU39_CTD_20150318_to_20221213.xlsx', 'Sheet', 'Acceptable_Value (AV) data');


%% CREATE NISKIN DEPTH COLUMN USING SOLO DEPTHS, AND TARGET DEPTH VALUES FOR NISKINS LACKING PRESSURE DATA

btl.Niskin_depth = btl.SoloDepth; % Copy Solo pressure tranducer depth column
idx = find(btl.SoloDepth == -999); % Find NaN's in RBR solo depth
btl.Niskin_depth(idx) = btl.TargetDepth(idx); % Use target depth where solo depth unavailable


%% MATCH BOTTLE AND CTD DATE FORMATS TO PERMIT MATCHING BY SAMPLING DATE

% Strip time off bottle and CTD datetime strings to allow matching by date only

[y, m, d] = ymd(ctd.StartTime_local); % Strip out y/m/d
ctd.Collection_date = datetime(y, m, d); % Recombine with only y/m/d

% MAY NEED TO ADJUST COLUMN HEADER FOR DATE, TO MATCH STATION DATAFILE
% btl.date = datetime(btl.ExcelDate,'ConvertFrom', 'excel'); % Convert from Excel
[y, m, d] = ymd(btl.Collection_Date);
btl.date = datetime(y, m, d);

%% SUBSET BTL AND CTD DATA BY SHARED SAMPLING DATES

idx_shared_dates_ctd = find(ismember(ctd.Collection_date, btl.Collection_Date)==1); % Index where CTD dates are also bottle dates
idx_shared_dates_btl = find(ismember(btl.Collection_Date, ctd.Collection_date)==1);

% Subset bottle and CTD data by shared dates
ctddata = ctd(idx_shared_dates_ctd,:); % subset ctd data with bottle dates
btldata = btl(idx_shared_dates_btl,:); % subset btl data with ctd data

output = [];

%% Select which CTD cast to merge with bottle data
btl_dates = unique(btldata.date);

% for i = 1:1
for i = 1:length(btl_dates)
    ld_ctd = ctddata(ctddata.Collection_date==btl_dates(i),:); % Subset CTD data that matches bottle date(i)
    
    % If there's multiple CTD casts on the same date: 
    
    % First, choose the deepest one, by pressure, to ensure matching scan depths
    
      if length(unique(ld_ctd.CastPK))>1 % If there's multiple CTD casts on the same date...
          maxCTDpress = max(ld_ctd.Pressure_dbar); % find max pressure in CTD casts on selected date
          idxMaxP = find(ld_ctd.Pressure_dbar==maxCTDpress); % Row index/indices of maximum CTD pressure on selected date
          
          % If there are multiple casts with equally deep maximum pressure
          % measurements, choose the earliest cast based on start time
          
          if length(idxMaxP) > 1 % If there are > 1 idices matching the max pressure...
                  timeArray = ld_ctd.StartTime_UTC(idxMaxP);
                  firstStart = min(timeArray); % Find earliest cast start time
                  idxFirst = find(ld_ctd.StartTime_UTC==firstStart, 1, 'First' ); % Get first index row with earliest start time
                  selectedCastPK = ld_ctd.CastPK(idxFirst); % Get Cast_PK corresponding to earliest start time
          else
                  selectedCastPK = ld_ctd.CastPK(idxMaxP); % Get Cast_PK(s) corresponding to maximum CTD pressure      
          end
      
      else % If there weren't multiple casts on the same day, just use the first (and only) CastPK to subset
          selectedCastPK = ld_ctd.CastPK(1); 
      end
          
     ld_ctd = ld_ctd(ld_ctd.CastPK==selectedCastPK, :); % subset the CTD cast with the deepest and/or earliest records on selected date
    
    % subset bottle data that matches bottle date(i)
    ld_btl = btldata(btldata.date==btl_dates(i), :); 
    
    all_scans = []; % Set variable for holding retrieved scans for a single collection date
    
    
    %% Extract CTD scans closest to bottle depths
    
    for j = 1:length(ld_btl.Niskin_depth) % For every depth on this date...note this combines CTD casts taken in same day
        scan_dist = abs(ld_ctd.Depth_m - ld_btl.Niskin_depth(j)); % Compute distances of all scan depths in ctd loop data to Solo_depth_m(j)
        minDist = min(scan_dist); % ...then find the minimum distance to the solo depth
        idx_nearest  = find(scan_dist == minDist); % Get the index of the minimum distance
        scan = ld_ctd(idx_nearest,:); % Extract the corresponding CTD scans
        
        % Select one scan in (rare) cases where two scans are equally near the
        % actual bottle depth
        
        if height(scan) > 1
            scan = scan(2,:); % Choose deepest scan (arbitrarily)
        end
        
        all_scans = [all_scans; scan]; % Vert cat scans for all depths from btl loop date
    end
    
    output = [output; all_scans]; % CTD data for niskin depths based on RBR solo pressure sensors on each niskin bottle
    
end

%% Merge CTD data with bottle sample data
% Currently merge() not used due to multiplicity of date row when used as key
% variables. And sortrows() doesn't support dateime (?)
% ***Column indices below are datafile-dependent!

btldata.Properties.VariableNames(4) = {'Collection_date_btl'}; % Give unique colname to permit horizontal concatenation
btldata.Properties.VariableNames(2) = {'bottle_Stn'}; % As above
merged = [btldata, output];


%% Save output as data file
writetable(merged, 'ctd_and_btl_data_merged.xlsx');




