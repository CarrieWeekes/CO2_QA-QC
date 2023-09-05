%% Import CTD data downloaded from Hakai portal

% Use Jessy's tool for this!

%% May 25, 2023 -- Carrie Weekes

% MATLAB function to format processed CTD data from the Hakai database
% Currently written for CTD data with Hakai data quality flags only -- AH

% USAGE: formatCTD(fname, formatOut)
% 1 = generates output as xlsx file, 2 = csv

% Read in CTD Data:

formatCTD('KC10_raw_CTD.xlsx',1);
% formatCTD('Dean_Rivers_April_to_Oct2022.xlsx',1);
% formatCTD('QU39_raw_CTD.xlsx',1);

