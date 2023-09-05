% Script to convert nutrients to umol_kg units, and compute the carbonate system
% *with or without nutrient data

% *** Written for CO2SYS.m; v3.1; Sept 2020

% This script also extracts only the required variables from a merged bottle and
% CTD file, and only the required variables from the CO2SYS output.
 
% The final product is a usable 'bottle file', containing measurements of bottle
% sample analyses accompanied by CTD and nutrient data. Only data corresponding
% to Niskin depths (determined by pressure transducer, where applicable) are
% included.

% *Based on the following approach from lab analyses:

% (1) Concatenated SVRC datafile carbonate sample output (lab outpout) produced from
% TA, CRM-corrected TCO2, AnalysisT, P = 0, YSI_salinity
% (2)	When merged with CTD file, carbonate sample output (btl file) produced
% from recomputed TCO2 from TA, TCO2, CTD T, YSI S, CTD P

% Time: CTD start time in UTC

clearvars
df = readtable('ctd_and_btl_data_merged.xlsx');

%% Convert NO2+NO3, PO4 and SiO2 nutrient data to umol_kg units

% Convert NO2+NO3, PO4 and SiO2 to to µmol/kg 
density_kg_L = df.rho./1000; % Using actual density, not potential density
df.NO2_NO3_umol_kg = df.NO2_NO3_uM_./density_kg_L;
df.PO4_umol_kg = df.PO4_uM_./density_kg_L;
df.SiO2_umol_kg = df.SiO2_uM_./density_kg_L;


%% Compute Carbonate System
% *** NOTE: Ensure the K1, K2 values are appropriate: currently using Waters et
% al. 2014 (i.e., # 15)

% *** Currently NOT USING NUTRIENT DATA to compute carbonate system. Users of
% final data file can re-compute the carbonate system with nutrient data if they
% require it.

% data = TA, TCO2, 1, 2, YSI S, CTD T, CTD T, CTD P, CTD P, Si = 0, PO4 = 0, NH4 = 0, H2S = 0, pH = 1, K1K2 = 15, KSO4 = 1, KF = 2, B = 1
[output, headers] = CO2SYS(df.TA_umol_kg_, df.CRMTCO2_umol_kg_, 1, 2, df.YSI_S, df.Temperature_degC, df.Temperature_degC, df.Pressure_dbar, df.Pressure_dbar, 0, 0, 0, 0, 1, 15, 1, 2, 1);
carbSys = array2table(output, 'VariableNames', headers);


%% Select output variables 
% From carbonate system
outputVarsCarb = {'TAlk', 'TCO2', 'pCO2out', 'pHout', 'OmegaCAout', 'OmegaARout', 'RFout'};
carb_out = carbSys(:,outputVarsCarb);

% From bottle file
% (for regular data files)

outputVarsBtl = {'Sample_ID', 'Niskin_depth', 'QC_Flag', 'YSI_S', 'NIST_Temp', 'AnalysisT', 'pCO2_AnalysisT', 'Adj_TCO2',...
   'Latitude', 'Longitude', 'StartTime_UTC', 'StartTime_local', 'Year', 'Month', 'Day', 'Depth_m',...
   'Temperature_degC', 'Salinity_PSU', 'Pressure_dbar', 'Conductivity_mS_cm', 'rho', 'PAR_umolM_2S_1',...
   'FluorometryChlorophyll_ug_L', 'Turbidity_FTU', 'O2_umol_kg', 'AOU_umol_kg', 'Delta_O2_umol_kg',...
   'NO2_NO3_umol_kg', 'PO4_umol_kg', 'SiO2_umol_kg'};
stgtime = {'StorageTime_days_'};
    

df_out = df(:,outputVarsBtl);
df_out1 = df(:,stgtime);

merged = [df_out, carb_out, df_out1];

fnameOut = ['KC10_bottle_file.xlsx'];

writetable(merged, fnameOut);


