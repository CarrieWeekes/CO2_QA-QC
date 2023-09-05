% Carrie Weekes - March 14th 2023

% For detailed notes of this process: KC10 Data QC Notes 2016-2022
% For all QC Figures of this process in powerpoint: KC10 Data QC

% Nutrient data updated through 2022.10.13 --> Record from 2013.04.02 to 2023
% CO2 data processed through 2022.11.26 --> Record from 2016.06.09 - 2023
% CTD data updated through 2022.11.26 --> Record from 2012.06.07 - 2023

% Flags created using following steps:
% QC Step 1 - During analysis of samples & any notes from the field sheets, flags will be assigned accordingly
% QC Step 2 - RMSE between YSI vs CTD S (8 * RMSE_CTD_YSI)
% QC Step 3 - Using the Alkalinity & Salinity Relationship to flag outliers in dataset; major deviations from relationship
% QC Step 4 - pCO2 cutoff from TA(S) RMSE sensitivity

% Quality Flags: 1 = good, 2 = replicate, 3 = questionable, 4 = NaN


%% Load KC10 merged CTD, CO2 and Nutrient file:
KC10 = load('KC10_bottle_file.txt');

% Convert excel dates to SDN (UTC)
KC10t = excel2sdn(KC10(:,11));
KC10 = [KC10, KC10t];
% SDN in column 39

xtick = [datenum(2016,1,1) datenum(2017,1,1) datenum(2018,1,1)...
    datenum(2019,1,1) datenum(2020,1,1) datenum(2021,1,1)...
    datenum(2022,1,1) datenum(2023,1,1)]; %datenum(2024,1,1)];

format long g
load zissou3
load zissou2
cmap = cbrewer('div', 'Spectral', 6, 'cubic');

%-----
% Plot QC Flags from QC Step 1:
figure
scatter(KC10(:,39), KC10(:,16), 30, KC10(:,3), 'filled')
colormap(parula(4));
set(gca, 'ydir', 'reverse')
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,'yyyy/mm'))
cb = colorbar('vert', 'eastoutside');
cb.Label.String = 'QC Flag';
cb.Ticks = [1 2 3 4];
axis([datenum(2016,1,1) datenum(2023,1,1) -inf inf])
ylabel('Depth (m)')
xlabel('Date')
title('QC Step 1 Flags');
axis square
flag = find(KC10(:,3) > 2);
% 15 samples have QC Flag = 3 or 4 ; Flagged during analysis runs: fixed at dock, pCO2 leaks, samples not fixed, samples lost


% Manually flagging all data that exceeds 6 months b/w collection & analysis
stgtime = find(KC10(:,38) > 183);
KC10(stgtime,3) = 0;
% 268 samples of 785 flagged from Storage Time > 6 months


%% NIST T & CTD T comparison
figure
plot(KC10(:,5), KC10(:,17), 'ko', 'markerfacecolor', 'b', 'markersize', 5)
axis square
title ('Temperature comparison')
xlabel ('NIST T')
ylabel ('CTD T')
box on
lsline

%-----
% RMSE for temperature data
[T_b, T_stats] = robustfit(KC10(:,5), KC10(:,17))
RMSE_CTD_NIST = T_stats.mad_s; % 0.6823
[T_a, T_r2] = regress_linear(KC10(:,5), KC10(:,17))

Tdiff = abs(KC10(:,17) - KC10(:,5));
tck = find(Tdiff > RMSE_CTD_NIST*4); % Anything > 2.7292
length(tck) % 9 flagged

% NIST T & CTD T w/ All Depths
figure
subplot(2,1,1)
scatter(KC10(:,5), KC10(:,17), 50, KC10(:,16), 'filled')
colormap(gca, flipud(zissou3))
cb1 = colorbar('vert', 'eastoutside');
cb1.Label.String = 'Depth (m)';
lsline
hold on
plot(KC10(tck,5), KC10(tck,17), 'wo', 'markersize', 5)
hold off
title ('Flagged Temperature Measurements')
xlabel ('NIST T')
ylabel ('CTD T')
box on

% NIST T & CTD T w/ 0 - 10m Depths
ck = find(KC10(:,16) < 13);
subplot(2,1,2)
scatter(KC10(ck,5), KC10(ck,17), 50, KC10(ck,16), 'filled')
colormap(gca, parula)
cb2 = colorbar('vert', 'eastoutside');
cb2.Label.String = 'Surface Depths';
lsline
hold on
plot(KC10(tck,5), KC10(tck,17), 'wo', 'markersize', 5)
hold off
xlabel ('NIST T')
ylabel ('CTD T')
box on

% Large differences between NIST T and CTD T in < 40 m samples & at higher temperatures.


%% QC Step 2 - Salinity Outliers from YSI vs CTD S

% YSI S & CTD S w/ All Depths
figure
scatter(KC10(:,4), KC10(:,18), 50, KC10(:,16), 'filled')
colormap(flipud(zissou3))
cb = colorbar('vert', 'eastoutside');
cb.Label.String = 'Depth (m)';
axis square
title('Salinity Comparison w/ All Depths')
xlabel('YSI S')
ylabel('CTD S')
lsline
box on

% YSI S and CTD S w/ 0 - 10m Depths
ck = find(KC10(:,16) < 13);
figure
scatter(KC10(ck,4), KC10(ck,18), 50, KC10(ck,16), 'filled')
colormap(gca, parula)
cb2 = colorbar('vert', 'eastoutside');
cb2.Label.String = 'Surface Depths';
axis square
title ('Salinity Comparison w/ Surface Depths')
xlabel ('YSI S')
ylabel ('CTD S')
lsline
box on

% YSI S and CTD S w/ QC Flags
figure
scatter(KC10(:,4), KC10(:,18), 50, KC10(:,3), 'filled')
colormap(parula(3))
cb = colorbar('vert', 'eastoutside');
cb.Label.String = 'QC Flag';
cb.Ticks = [1 2 3];
axis square
title('Salinity Comparison w/ QC Flags')
xlabel('YSI S')
ylabel('CTD S')
lsline
box on

%-----
% RMSE from CTD and YSI salinity data
[S_b, S_stats] = robustfit(KC10(:,18), KC10(:,4))
RMSE_CTD_YSI = S_stats.mad_s; % 0.1371
[S_a, S_r2] = regress_linear(KC10(:,4), KC10(:,18))

Sdiff = abs(KC10(:,18) - KC10(:,4));
sck = find(Sdiff > RMSE_CTD_YSI*8); % 1.0968
length(sck) % 28 flagged of 799 samples

% YSI S & CTD S w/ All Depths & Flagged Salinity Measurements
figure
subplot(2,1,1)
scatter(KC10(:,4), KC10(:,18), 50, KC10(:,16), 'filled')
colormap(gca, flipud(zissou3))
cb1 = colorbar('vert', 'eastoutside');
cb1.Label.String = 'Depth (m)';
lsline
hold on
plot(KC10(sck,4), KC10(sck,18), 'wo', 'markersize', 5)
hold off
xlabel('YSI S')
ylabel('CTD S')
title('Flagged Salinity Measurements')
box on

% YSI S & CTD S w/ 0 - 10m Depths & Flagged Salinity Measurements
subplot(2,1,2)
scatter(KC10(ck,4), KC10(ck,18), 50, KC10(ck,16), 'filled')
colormap(gca, parula)
cb2 = colorbar('vert', 'eastoutside');
cb2.Label.String = 'Surface Depths';
lsline
hold on
plot(KC10(sck,4), KC10(sck,18), 'wo', 'markersize', 5)
hold off
xlabel ('YSI S')
ylabel ('CTD S')
box on


% Date & YSI S - CTD S
figure
plot(KC10(:,39), KC10(:,4)-KC10(:,18), 'ko', 'markerfacecolor', 'b', 'markersize', 8.5)
set(gca,'xtick', xtick, 'xticklabel',datestr(xtick,'yyyy/mm'))
axis([datenum(2016,1,1) datenum(2023,1,1) -5 5])
title ('Salinity Comparison')
ylabel ('YSI - CTD Salinity')

x1 = datenum(2016,1,1);
x2 = datenum(2023,1,1);
y1 = 0.1371*24;
y2 = 0.1371*-24;
x = [x1 x2 x2 x1];
y = [y1 y1 y2 y2];
patch(x,y,'red','facecolor',[0.4 0.4 0.4],'facealpha',0.1,'edgealpha',0)

y1 = 0.1371*20;
y2 = 0.1371*-20;
x = [x1 x2 x2 x1];
y = [y1 y1 y2 y2];
patch(x,y,'red','facecolor',[0.35 0.35 0.35],'facealpha',0.1,'edgealpha',0)

y1 = 0.1371*16;
y2 = 0.1371*-16;
x = [x1 x2 x2 x1];
y = [y1 y1 y2 y2];
patch(x,y,'red','facecolor',[0.3 0.3 0.3],'facealpha',0.1,'edgealpha',0)

y1 = 0.1371*12;
y2 = 0.1371*-12;
x = [x1 x2 x2 x1];
y = [y1 y1 y2 y2];
patch(x,y,'red','facecolor',[0.2 0.2 0.2],'facealpha',0.1,'edgealpha',0)

y1 = 0.1371*8;
y2 = 0.1371*-8;
x = [x1 x2 x2 x1];
y = [y1 y1 y2 y2];
patch(x,y,'red','facecolor',[0.1 0.1 0.1],'facealpha',0.1,'edgealpha',0)


% Add in flagged salinity data (YSI S - CTD S)
hold on
plot(KC10(sck,39), KC10(sck,4)-KC10(sck,18), 'ko', 'markerfacecolor', 'r', 'markersize', 8.5)
set(gca,'xtick', xtick, 'xticklabel',datestr(xtick,'yyyy/mm'))
title('Salinity Comparison')
ylabel('YSI - CTD Salintiy')
box on
hold off

min_S = min(KC10(:,4)); % 18.3
max_S = max(KC10(:,4)); % 33.6

%%%-------
% 28 samples flagged from QC Step 2
% The large difference between YSI S and CTD S mostly occurs at the surface with some at depth (triplicate data points flagged as well)
% 17 samples flagged in the surface layer
% 4 samples flagged in the rest of the water column

% Flagging data with difference between CTD S & YSI S > (8 * RMSE_CTD_YSI)
KC10(sck,3) = 3;

% Some surface samples are being flagged from comparison but are OK - manual change of QC
ck = find(KC10(:,4) < 28);
KC10(ck,3) = 1;

% Changing a "good" triplicate back to Flag 2
ck = find(KC10(:,1) == 628);
KC10(ck,3) = 2;
ck = find(KC10(:,1) == 629);
KC10(ck,3) = 2;
ck = find(KC10(:,1) == 630);
KC10(ck,3) = 2;


%% Nutrient Data QC
% Redfield Ratio / Stoichiometry: C:N:Si:P = 106:16:15:1

%--- NO3 + NO2
figure
% Date, Depth, N+N
subplot(3,1,1)
scatter(KC10(:,39), KC10(:,16), 30, KC10(:,28), 'filled')
colormap(flipud(zissou3))
cbn = colorbar('vert', 'eastoutside')
cbn.Label.String = 'NO3+NO2'
set(gca, 'ydir', 'reverse')
set(gca,'xtick',xtick,'xticklabel',datestr(xtick,'yyyy/mm'))
ylabel('Depth (m)')
axis([datenum(2017,1,1) datenum(2023,1,1) -inf inf])
title('NO_{3} + NO_{2} (\mumol kg^{-1})')
box on

% Salinity & N+N
subplot(3,1,2)
plot(KC10(:,18), KC10(:,28), 'ko', 'markerfacecolor', 'g', 'markersize', 5)
ylabel('NO_{3} + NO_{2}')
xlabel('Salinity')
box on

% TCO2 & N+N
subplot(3,1,3)
plot(KC10(:,28), KC10(:,32), 'ko', 'markerfacecolor', 'g', 'markersize', 5)
ylabel('TCO_{2} (\mumol kg^{-1})')
xlabel('NO_{3} + NO_{2} (\mumol kg^{-1})')
box on


%--- PO4
figure
% Date, Depth, PO4
subplot(3,1,1)
scatter(KC10(:,39), KC10(:,16), 30, KC10(:,29), 'filled')
colormap(flipud(zissou3))
cbp = colorbar('vert', 'eastoutside')
cbp.Label.String = 'PO4'
set(gca, 'ydir', 'reverse')
set(gca,'xtick',xtick,'xticklabel',datestr(xtick,'yyyy/mm'))
ylabel('Depth (m)')
axis([datenum(2017,1,1) datenum(2023,1,1) -inf inf])
title('PO_{4} (\mumol kg^{-1})')
box on

% Salinity & PO4
subplot(3,1,2)
plot(KC10(:,18), KC10(:,29), 'ko', 'markerfacecolor', 'b', 'markersize', 5)
ylabel('PO_{4}')
xlabel('Salinity')
box on

% TCO2 & PO4
subplot(3,1,3)
plot(KC10(:,29), KC10(:,32), 'ko', 'markerfacecolor', 'b', 'markersize', 5)
ylabel('TCO_{2} (\mumol kg^{-1})')
xlabel('PO_{4} (\mumol kg^{-1})')
box on


%--- SiO2
figure
% Date, Depth, SiO2
subplot(3,1,1)
scatter(KC10(:,39), KC10(:,16), 30, KC10(:,30), 'filled')
colormap(flipud(zissou3))
cbs = colorbar('vert', 'eastoutside')
cbs.Label.String = 'SiO2'
set(gca, 'ydir', 'reverse')
set(gca,'xtick',xtick,'xticklabel',datestr(xtick,'yyyy/mm'))
ylabel('Depth (m)')
axis([datenum(2017,1,1) datenum(2023,1,1) -inf inf])
title('SiO_{2} (\mumol kg^{-1})')
box on

% Salinity & SiO2
subplot(3,1,2)
plot(KC10(:,18), KC10(:,30), 'ko', 'markerfacecolor', 'r', 'markersize', 5)
ylabel('SiO_{2}')
xlabel('Salinity')
box on

% TCO2 & SiO2
subplot(3,1,3)
plot(KC10(:,30), KC10(:,32), 'ko', 'markerfacecolor', 'r', 'markersize', 5)
ylabel('TCO_{2} (\mumol kg^{-1})')
xlabel('SiO_{2} (\mumol kg^{-1})')
box on


%--- Nutrient Redfield Ratio Plots

%- N+N vs. PO4
figure
subplot(3,1,1)
plot(KC10(:,29), KC10(:,28), 'ko', 'markerfacecolor', 'c', 'markersize', 5)
title('Redfield Ratio N:P')
box on

subplot(3,1,2) % w/ Depth as z-axis
scatter(KC10(:,29), KC10(:,28), 40, KC10(:,16), 'filled')
colormap(gca, flipud(zissou3))
cbnp = colorbar('vert', 'eastoutside')
cbnp.Label.String = 'Depth (m)'
ylabel('NO3 + NO2')

subplot(3,1,3) % w/ Year as z-axis
yr = unique(KC10(:,13));
scatter(KC10(:,29), KC10(:,28), 40, KC10(:,13), 'filled')
colormap(gca, parula(7));
cbnp2 = colorbar('vert', 'eastoutside')
cbnp2.Label.String = 'Year (m)'
cbnp2.Ticks = yr
xlabel('PO4')


%- N+N vs. SiO2
figure
subplot(3,1,1)
plot(KC10(:,30), KC10(:,28), 'ko', 'markerfacecolor', 'm', 'markersize', 5)
title('Redfield Ratio N:Si')
box on

subplot(3,1,2)
subplot(3,1,2) % w/ Depth as z-axis
scatter(KC10(:,30), KC10(:,28), 40, KC10(:,16), 'filled')
colormap(gca, flipud(zissou3))
cbns = colorbar('vert', 'eastoutside')
cbns.Label.String = 'Depth (m)'
ylabel('NO3 + NO2')

subplot(3,1,3) % w/ Year as z-axis
scatter(KC10(:,30), KC10(:,28), 40, KC10(:,13), 'filled')
colormap(gca, parula(7));
cbns2 = colorbar('vert', 'eastoutside')
cbns2.Label.String = 'Year (m)'
cbns2.Ticks = yr
xlabel('SiO2')


%%%-------
% Flagging nutrient data that was sampled at the wrong depths, or issues at analysis!
ck = find(KC10(:,39) == 736959.79106 & KC10(:,16) == 49.566);
KC10(ck,28) = NaN;
KC10(ck,29) = NaN;
KC10(ck,30) = NaN;

ck = find(KC10(:,39) == 737446.73469 & KC10(:,16) == 30.712);
KC10(ck,28) = NaN;
KC10(ck,29) = NaN;
KC10(ck,30) = NaN;

ck = find(KC10(:,39) == 737446.73469 & KC10(:,16) == 49.569);
KC10(ck,28) = NaN;
KC10(ck,29) = NaN;
KC10(ck,30) = NaN;

ck = find(KC10(:,39) == 737446.73469 & KC10(:,16) == 196.192);
KC10(ck,28) = NaN;
KC10(ck,29) = NaN;
KC10(ck,30) = NaN;

ck = find(KC10(:,39) == 737470.80476 & KC10(:,16) == 96.177);
KC10(ck,28) = NaN;
KC10(ck,29) = NaN;
KC10(ck,30) = NaN;

ck = find(KC10(:,39) == 738010.73477 & KC10(:,16) == 49.54);
KC10(ck,29) = NaN;
KC10(ck,30) = NaN;

ck = find(KC10(:,39) == 738282.69646 & KC10(:,16) == 190.204);
KC10(ck,28) = NaN;
KC10(ck,29) = NaN;
KC10(ck,30) = NaN;


%% Assess the spread of replicates

% rck = find(KC10(:,3) == 2); % Find samples with flag of 2
% trips = KC10(rck,:); % Create array of triplicate samples
% 
% % pCO2 & TCO2 triplicate boxplot
% G1 = (trips(:,39)); % Group 1: Date
% G2 = (trips(:,16)); % Group 2: Depth
% 
% % Based on depth alone
% figure
% subplot(2,1,1)
% boxplot(trips(:,33),{G2},'ColorGroup',{G2},'FactorSeparator',1)
% ylabel ('in-situ pCO_{2} (\muatm)')
% pbaspect([5 2 1])
% title('pCO_{2}')
% 
% subplot(2,1,2)
% boxplot(trips(:,32),{G2},'ColorGroup',{G2},'FactorSeparator',1)
% ylabel ('TCO_{2} (\mumol kg^{-1}')
% pbaspect([5 2 1])
% title('TCO_{2}')
% 
% % With both depth and date as factors controlling boxplot plotting
% figure
% subplot(2,1,1)
% boxplot(trips(:,33),{G1,G2},'ColorGroup',{G2},'FactorSeparator',1)
% ylabel ('in-situ pCO_{2} (\muatm)')
% pbaspect([5 2 1])
% title('pCO_{2}')
% 
% subplot(2,1,2)
% boxplot(trips(:,32),{G1,G2},'ColorGroup',{G2},'FactorSeparator',1)
% ylabel ('TCO_{2} (\mumol kg^{-1}')
% pbaspect([5 2 1])
% title('TCO_{2}')


%% Re-calculate carbonate parameters w/ nutrient data

%%--- All carbonate parameters previously calculated in bottle file did not have nutrients included.
    % Adding in section to script for that calculation for comparison w/o nutrient data.
    
% function [DATA,HEADERS,NICEHEADERS]=CO2SYS(PAR1,PAR2,PAR1TYPE,PAR2TYPE,SAL,TEMPIN,TEMPOUT,PRESIN,PRESOUT,SI,PO4,NH4,H2S,pHSCALEIN,K1K2CONSTANTS,KSO4CONSTANT,KFCONSTANT,BORON)
% data = TA, TCO2, PAR1#, PAR2#, YSI S, CTD T, CTD T, CTD P, CTD P, Si, PO4, NH4 = 0, H2S = 0, pH = 1, K1K2 = 15, KSO4 = 1, KF = 2, B = 1

[results,headers,nheaders] = CO2SYS(KC10(:,31), KC10(:,32), 1, 2, KC10(:,4), KC10(:,17), KC10(:,17), KC10(:,19), KC10(:,19), KC10(:,30), KC10(:,29), 0, 0, 1, 15, 1, 2, 1);
pCO2_nuts = results(:,21);
pH_nuts = results(:,20);
OmegaAr_nuts = results(:,35);
OmegaCa_nuts = results(:,34);
RF_nuts = results(:,33);


%% QC Step 3 - Using the Alkalinity & Salinity Relationship to flag erroneous outliers

% TA linear fit -- based on Queen Charlotte Sound empirical algorithm where TA = 54.2436*S + 419.2432
TA_S = KC10(:,4).*54.2436 + 419.2432;

% TA(S) Relationship - KC10 data w/ Queen Charlotte Sound empirical TA_S regression line included
figure
subplot(2,1,1) % CTD S
plot(KC10(:,18), KC10(:,31), 'ko', 'markerfacecolor', 'c', 'markersize', 5);
xlabel ('CTD Salinity')
ylabel ('TA')
title ('TA(S) Comparisons')
lsline
box on

% Queen Charlotte Sound empirical TA_S Relationship : TA = 54.2436*S + 419.2432
b0 = 54.2436;
b1 = 419.2432;
x = [18:34];
y = b0*x + b1;
hold on
QCS = plot(x,y,'linewidth',2)
set(QCS,'color',[0.49 0.18 0.56]) % least squares line is purple
legend([QCS], 'QCS; TA = 54.2436*S + 419.2432');

subplot(2,1,2) % YSI S
plot(KC10(:,4), KC10(:,31), 'ko', 'markerfacecolor', 'g', 'markersize', 5);
xlabel ('YSI Salinity')
ylabel ('TA')
lsline
box on
hold on
QCS = plot(x,y,'linewidth',2)
set(QCS,'color',[0.49 0.18 0.56]) % least squares line is purple
legend([QCS], 'QCS; TA = 54.2436*S + 419.2432');


% TA(S) Relationship w/ QC Flag
figure
scatter(KC10(:,4), KC10(:,31), 30, KC10(:,3), 'filled')
colormap(parula(4))
cb = colorbar('vert', 'eastoutside');
cb.Label.String = 'QC Flag';
cb.Ticks = [1 2 3 4];
axis([-inf inf -inf inf])
xlabel('Salinity')
ylabel('TA')
box on
lsline


% TA(S) Relationship w/ All Depths
figure
subplot(2,1,1) % CTD S
scatter(KC10(:,18), KC10(:,31), 30, KC10(:,16), 'filled');
colormap(gca, flipud(zissou3))
cb1 = colorbar('vert', 'eastoutside');
cb1.Label.String = 'Depth (m)';
axis([-inf inf -inf inf])
xlabel('CTD Salinity')
ylabel('TA')
title('TA(S) w/ All Depths')
box on
lsline

subplot(2,1,2) % YSI S
scatter(KC10(:,4), KC10(:,31), 30, KC10(:,16), 'filled');
colormap(gca, parula)
cb2 = colorbar('vert', 'eastoutside');
cb2.Label.String = 'Depth (m)';
axis([-inf inf -inf inf])
xlabel('YSI Salinity')
ylabel('TA')
box on
lsline


% TA(S) Relationship w/ 0 - 10m Depth
ck = find(KC10(:,16) < 13);
figure
subplot(2,1,1) % CTD S
scatter(KC10(ck,18), KC10(ck,31), 30, KC10(ck,16), 'filled');
colormap(gca, flipud(zissou3))
cb1 = colorbar('vert', 'eastoutside');
cb1.Label.String = 'Surface Depths';
axis([-inf inf -inf inf])
xlabel('CTD Salinity')
ylabel('TA')
title('TA(S) w/ Surface Depths')
box on
lsline

subplot(2,1,2) % YSI S
scatter(KC10(ck,4), KC10(ck,31), 30, KC10(ck,16), 'filled');
colormap(gca, parula)
cb2 = colorbar('vert', 'eastoutside');
cb2.Label.String = 'Surface Depths';
axis([-inf inf -inf inf])
xlabel('YSI Salinity')
ylabel('TA')
box on
lsline


% TA(S) Relationship w/ pCO2
figure
subplot(2,1,1) % CTD S
scatter(KC10(:,18), KC10(:,31), 30, KC10(:,33), 'filled');
colormap(gca, flipud(zissou3))
cb1 = colorbar('vert', 'eastoutside');
cb1.Label.String = 'pCO_{2} (\muatm)';
axis([-inf inf -inf inf])
xlabel('CTD Salinity')
ylabel('TA')
title('TA(S) w/ pCO2')
box on
lsline

subplot(2,1,2) % YSI S
scatter(KC10(:,4), KC10(:,31), 30, KC10(:,33), 'filled');
colormap(gca, parula)
cb2 = colorbar('vert', 'eastoutside');
cb2.Label.String = 'pCO_{2} (\muatm)';
axis([-inf inf -inf inf])
xlabel('YSI Salinity')
ylabel('TA')
box on
lsline


% TA(S) Relationship w/ Storage Time
figure
ax(1) = subplot(2,1,1) % CTD S
scatter(KC10(:,18), KC10(:,31), 30, KC10(:,38), 'filled');
colormap(gca, summer)
axis([-inf inf -inf inf])
xlabel('CTD Salinity')
box on
lsline

ax(2) = subplot(2,1,2) % YSI S
scatter(KC10(:,4), KC10(:,31), 30, KC10(:,38), 'filled');
colormap(gca, summer)
axis([-inf inf -inf inf])
xlabel('YSI Salinity')
box on
lsline

% Setting one colorbar for both subplots!
cb = colorbar;
set(cb, 'Position', [.8314 .11 .0581 .8150])
for i = 1:2
    pos = get(ax(i), 'Position');
    set(ax(i), 'Position', [pos(1) pos(2) 0.85*pos(3) pos(4)]);
end
cb.Label.String = 'Storage Time (days)';

% Setting one title, ylabel and xlabel for both subplots!
han = axes('visible','off');
han.Title.Visible = 'on';
% han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
ylabel(han, 'TA')
% xlabel(han, 'Month/Year')
title(han, 'TA(S) with Storage Time')


%%%-------
% Flagging outliers from TA(S) relationship
% Line of samples under TA(S) regression line has lower values of TA due to erroneous pCO2 (fixing at dock!)
ck = find(KC10(:,39) == 736776);
KC10(ck,3) = 3;


%% QC Step 3.5 - TA, pCO2 & TCO2 comparisons:

%%%-------
% pCO2 difference: pCO2(TCO2,TA(S)) @ analysis T and YSI S
% TA(S), CRM TCO2, 1, 2, YSI S, A.T, A.T, P = 0, P = 0, Si = 0, PO4 = 0, NH4 = 0, H2S = 0, pH = 1, K1K2 = 15, KSO4 = 1, KF = 2, B = 1
[output] = CO2SYS(TA_S, KC10(:,32), 1, 2, KC10(:,4), KC10(:,6), KC10(:,6), 0, 0, 0, 0, 0, 0, 1, 15, 1, 2, 1);
pCO2_calc = output(:,21);

% TCO2 difference: TCO2(TA(S),pCO2) @ CTD T, S & P
% TA(S), pCO2 in-situ, 1, 2, YSI S, CTD T, CTD T, CTD P, CTD P, Si = 0, PO4 = 0, NH4 = 0, H2S = 0, pH = 1, K1K2 = 15, KSO4 = 1, KF = 2, B = 1
[output2] = CO2SYS(TA_S, KC10(:,33), 1, 4, KC10(:,4), KC10(:,17), KC10(:,17), KC10(:,19), KC10(:,19), 0, 0, 0, 0, 1, 15, 1, 2, 1);
TCO2_calc = output2(:,2);

% pCO2 Diff
pCO2diff = KC10(:,7) - pCO2_calc;

% TA:TCO2
TA_TCO2 = KC10(:,31)./KC10(:,32);

% TA Diff
TAdiff = TA_S - KC10(:,31);

xtick = [datenum(2016,1,1) datenum(2017,1,1) datenum(2018,1,1)...
    datenum(2019,1,1) datenum(2020,1,1) datenum(2021,1,1)...
    datenum(2022,1,1) datenum(2023,1,1)]; %datenum(2024,1,1)];

%-----
% TA comparison: TA(pCO2,TCO2) vs. TA(S)
figure
subplot(3,1,1)
plot(KC10(:,39), KC10(:,31), 'k.')
hold on
plot(KC10(:,39), TA_S, 'c.')
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,29))
axis([datenum(2016,1,1) datenum(2023,1,1) -inf inf])
box on
title('TA comparison')
legend('TA(pCO2,TCO2)','TA(S)')

% TCO2 comparison: CRM TCO2 vs. TCO2(TA_S,pCO2)
subplot(3,1,2)
plot(KC10(:,39), KC10(:,32), 'k.')
hold on
plot(KC10(:,39), TCO2_calc, 'g.')
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,29))
axis([datenum(2016,1,1) datenum(2023,1,1) -inf inf])
box on
title('TCO2 comparison')
legend('CRM TCO2', 'TCO2(TA(S),pCO2)')

% pCO2 comparison: pCO2 @ analysisT vs. pCO2(TA_S,TCO2)
subplot(3,1,3)
plot(KC10(:,39), KC10(:,7), 'k.')
hold on
plot(KC10(:,39), pCO2_calc, 'm.')
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,29))
axis([datenum(2016,1,1) datenum(2023,1,1) -inf inf])
box on
title('pCO2 comparisons')
legend('pCO2 @ AT', 'pCO2(TCO2,TA(S))')


%-----
% Four Panel plot w/ TA:TCO2, TA Diff, pCO2 Diff @ AT & In-situT
% TA:TCO2 w/ Depth
figure
subplot(2,2,1)
plot(TA_TCO2, KC10(:,16), 'ko')
set(gca, 'ydir', 'reverse')
ylim = [0 325];
xlabel('TA:TCO2')
ylabel('Depth (m)')
box on
axis square

% pCO2 difference: pCO2@AT vs. pCO2@AT - pCO2(TCO2,TA(S)) w/ TA:TCO2 variable
subplot(2,2,2)
scatter(KC10(:,7), pCO2diff, 30, TA_TCO2, 'filled')
colormap(gca, parula)
cb = colorbar('vert', 'eastoutside');
cb.Label.String = 'TA:TCO2';
xlabel('pCO2 @ AT')
ylabel('pCO2 @ AT - pCO2(TCO2,TA(S))')
box on
axis square

% TA difference: TA(pCO2,TCO2) vs. TA(S) - TA(pCO2,TCO2) w/ Storage Time variable
subplot(2,2,3)
scatter(KC10(:,31), TAdiff, 30, KC10(:,16), 'filled')
colormap(gca, summer)
cb = colorbar('vert', 'eastoutside');
cb.Label.String = 'Storarge Time';
xlabel('TA(pCO2,TCO2)')
ylabel('TA(S) - TA(pCO2,TCO2)')
box on
axis square

% pCO2 difference: pCO2@AT vs. pCO2@AT - pCO2(TCO2,TA(S) w/ Depth variable
subplot(2,2,4)
scatter(KC10(:,7), pCO2diff, 30, KC10(:,16), 'filled')
colormap(gca, flipud(zissou3))
cb = colorbar('vert', 'eastoutside');
cb.Label.String = 'Depth (m)';
xlabel('pCO2 @ AT')
ylabel('pCO2 diff')
box on
axis square


%%%-------
% Add flags for pCO2 outliers
ck = find(pCO2diff < -1201);
KC10(ck,3) = 3;
ck = find(pCO2diff > 451);
KC10(ck,3) = 3;


%% QC Step 4 - pCO2 cutoff from TA(S) RMSE sensitivity
% Difference in pCO2 --> TA:TCO2 vs. (pCO2@analysisT - calc pCO2)

% With Depths < 50
ck = find(KC10(:,2) < 45);
figure
scatter(TA_TCO2(ck), pCO2diff(ck), 40, KC10(ck,16), 'filled')
cb = colorbar('vert','eastoutside');
cb.Label.String = 'Depths < 50 m';
% cb.Ticks = [0 5 10 20 30 40];
colormap(parula(7));
shading faceted
xlabel('TA:TCO2')
ylabel('pCO2@analysisT - pCO2(TCO2,TA(S))')
title('QC Step 4')
box on
load TaS_pCO2_cutoff
TAtCO2 = 0.9:0.001:1.4;
hold on
plot(TAtCO2, TaS_pCO2_cutoff,'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*-1, 'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*2,'b-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*-2,'b-','linewidth',2)

% With Depths > 50
ck1 = find(KC10(:,2) > 45);
figure
scatter(TA_TCO2(ck1), pCO2diff(ck1), 40, KC10(ck1,16), 'filled')
cb = colorbar('vert','eastoutside');
cb.Label.String = 'Depths > 50 m';
% cb.Ticks = [50 75 100 150 200 300];
colormap(cmap); % Or jet(6)
shading faceted
xlabel('TA:TCO2')
ylabel('pCO2@analysisT - pCO2(TCO2,TA(S))')
title('QC Step 4')
box on
TAtCO2 = 0.9:0.001:1.4;
hold on
plot(TAtCO2, TaS_pCO2_cutoff,'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*-1, 'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*2,'b-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*-2,'b-','linewidth',2)


% With Storage Time
figure
scatter(TA_TCO2, pCO2diff, 40, KC10(:,38), 'filled')
cb = colorbar('vert','eastoutside');
cb.Label.String = 'Storage Time (days)';
colormap(flipud(summer));
shading faceted
xlabel('TA:TCO2')
ylabel('pCO2@analysisT - pCO2(TCO2,TA(S))')
title('QC Step 4')
box on
TAtCO2 = 0.9:0.001:1.4;
hold on
plot(TAtCO2, TaS_pCO2_cutoff,'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*-1, 'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*2,'b-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*-2,'b-','linewidth',2)


% QC Flags up to this final QC Step
figure
scatter(TA_TCO2, pCO2diff, 40, KC10(:,3), 'filled')
cb = colorbar('vert','eastoutside');
cb.Label.String = 'QC Flag';
set(cb, 'YTick', 1:1:4, 'TicksMode', 'manual', 'TickLabels', {'Good', 'Replicate', 'Questionable', 'NaN'}) % Sets colorbar tick bounds & increasing units... 1 to 4 [1:x:4]; increasing by 1 unit [x:1:x]
colormap(parula(4));
shading faceted
xlabel('TA:TCO2')
ylabel('pCO2@analysisT - pCO2(TCO2,TA(S))')
title('QC Step 4')
box on
TAtCO2 = 0.9:0.001:1.4;
hold on
plot(TAtCO2, TaS_pCO2_cutoff,'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*-1, 'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*2,'b-','linewidth',2) % *2 by QC protocol
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*-2,'b-','linewidth',2) % *-2 by QC protocol

% Questionable by TaS_pCO2_cutoff
for i = 1:length(TA_TCO2)
    pck = find(TAtCO2 > TA_TCO2(i) - 0.0005 & TAtCO2 < TA_TCO2(i) + 0.0005);
    thres = TaS_pCO2_cutoff(pck).*2;
    if abs(pCO2diff(i)) > thres
        KC10(i,3) = 3;
    end
end

%%------
% 105 samples flagged of 785 from QC Step 4 TaS_pCO2 cutoff routine

q_flags = find(KC10(:,3) > 2);
% 321 samples flagged as 'Questionable' or 'NaN' throughout QC routines


%% Plotting KC10 data that has passed the QC routine:
ck = find(KC10(:,3) < 3);

% QC Step 4 w/ QC Flag < 3
figure
scatter(TA_TCO2(ck), pCO2diff(ck), 40, KC10(ck,3), 'filled')
cb = colorbar('vert','eastoutside');
cb.Label.String = 'QC Flag';
set(cb, 'YTick', 1:1:2, 'TicksMode', 'manual', 'TickLabels', {'Good', 'Replicate'}) % Sets colorbar tick bounds & increasing units... 1 to 2 [1:x:2]; increasing by 1 unit [x:1:x]
colormap(parula(2));
shading faceted
xlabel('TA:TCO2')
ylabel('pCO2@analysisT - pCO2(TCO2,TA(S))')
title('QC Step 4')
box on
TAtCO2 = 0.9:0.001:1.4;
hold on
plot(TAtCO2, TaS_pCO2_cutoff,'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*-1, 'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*2,'b-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*-2,'b-','linewidth',2)


% QC Step 4 w/ Year as z-variable
yr = unique(KC10(ck,13));
figure
scatter(TA_TCO2(ck), pCO2diff(ck), 40, KC10(ck,13), 'filled')
colormap(parula(7));
xlabel('TA:TCO2')
ylabel('pCO2@analysisT - pCO2(TCO2,TA(S))')
title('QC Step 4')
box on
TAtCO2 = [0.9:0.001:1.4];
hold on
plot(TAtCO2, TaS_pCO2_cutoff,'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*-1, 'r-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*2,'b-','linewidth',2)
hold on
plot(TAtCO2, TaS_pCO2_cutoff.*-2,'b-','linewidth',2)
cb = colorbar('vert','eastoutside');
cb.Label.String = 'Year';
cb.Ticks = yr;
shading faceted


%% TA(S) Stats for KC10 Timeseries:
[KC, STATS] = robustfit(KC10(ck,4), KC10(ck,31))
[a, r2] = regress_linear(KC10(ck,4), KC10(ck,31))

% TA = 62.4316 * S + 164.8028
% RMSE = 23.7341 (robust_s)
% r2 = 0.9581


% TA(S) w/ Depth
figure
scatter(KC10(ck,4), KC10(ck,31), 40, KC10(ck,16), 'filled')
colormap(flipud(zissou3))
cb = colorbar('vert', 'eastoutside');
cb.Label.String = 'Depth (m)';
ylim = [1600 2270];
xlim = [23.6 33.6];
set(gca, 'xlim', xlim)
set(gca, 'ylim', ylim)
xlabel('Salinity')
ylabel('TA ( \mumol/kg )')
title('KC10 Alkalinity-Salinity Relationship')
box on

% Queen Charolette Sound empirical TA(S) Relationship : TA = 54.2436*S + 419.2432
b0 = 54.2436;
b1 = 419.2432;
x = [18:34];
y = b0*x + b1;

hold on
QCS = plot(x, y, 'linewidth', 1.5) % Queen Charolette Sound TA(S) line
set(QCS, 'color', [0.49 0.18 0.56]) % Least squares line is purple

[k,r] = polyfit(KC10(ck,4), KC10(ck,31), 1)
x1 = [min(KC10(ck,4)):0.1:max(KC10(ck,4))];
y1 = x1.*k(1) + k(2);

hold on
KC10_RMSE = plot(x1, y1, 'w.', 'linewidth', 0.5)

hold on
KC10_TA_S = plot(x1, y1, 'k-', 'linewidth', 1.5)

legend([QCS, KC10_TA_S, KC10_RMSE], 'QCS; TA = 54.2436*S + 419.2432','KC10; TA = 62.4316*S + 164.8029', 'KC10 RMSE = 23.7341')
hold off


% TA(S) w/ pCO2
figure
scatter(KC10(ck,4), KC10(ck,31), 40, KC10(ck,33), 'filled')
colormap(flipud(zissou3))
cb = colorbar('vert', 'eastoutside');
cb.Label.String = 'pCO_{2} (\muatm)';
axis([-inf inf -inf inf])
title('KC10 TA(S)')
xlabel('Salinity')
ylabel('TA')
box on
hold on
KC10_TA_S = plot(x1, y1, 'k-', 'linewidth', 1)


%% Creating contour plots of KC10 data that passed the QC routine

ck = find(KC10(:,3) < 3);
good_data = KC10(ck,:);
xtick = [datenum(2016,1,1) datenum(2017,1,1) datenum(2018,1,1)...
    datenum(2019,1,1) datenum(2020,1,1) datenum(2021,1,1)...
    datenum(2022,1,1) datenum(2023,1,1)]; %datenum(2024,1,1)];

%-- Contour plot: pCO2
ck = ~isnan(good_data(:,33));
pCO2 = good_data(ck,:);
x = unique(pCO2(:,39));
y = [0:300]';
[X,Y] = meshgrid(x,y);
Vq = griddata(pCO2(:,39), pCO2(:,2), pCO2(:,33), X, Y);

figure
ax(1) = subplot(2,1,1)
f = pcolor(X, Y, Vq);
shading(gca, 'interp')
set(gca, 'YDir', 'reverse')
% pbaspect([3 1 1])
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,12))
axis tight
colormap(flipud(zissou2))
% Add in pCO2 contour lines
hold on
set(gca, 'clim', [140 1350])
axis([datenum(2016,1,1) datenum(2023,1,1) 0 300])
hold on
v = [500,500,775,775,950,950,1150,1150];
[c,h] = contour(X, Y, Vq, v);
set(h, 'ShowText', 'on', 'TextStep', get(h, 'LevelStep')*2)
set(h, 'color', [0.3 0.3 0.3], 'linewidth', 0.75)
box on

ax(2) = subplot(2,1,2)
f = pcolor(X, Y, Vq);
shading(gca, 'interp')
set(gca, 'YDir', 'reverse')
% pbaspect([3 1 1])
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,12))
axis tight
colormap(flipud(zissou2))
hold on
% Add in O2 contour lines
ck = ~isnan(good_data(:,25));
O2 = good_data(ck,:);
Vq1 = griddata(O2(:,39), O2(:,16), O2(:,25), X, Y);
oxy = [80,80,100,100,130,130,200,200];
[c2,h2] = contour(X, Y, Vq1, oxy);
set(h2, 'ShowText', 'on', 'TextStep', get(h2, 'LevelStep')*2);
set(h2, 'color', [0.5 0.5 0.5], 'linewidth', 0.75);
axis([datenum(2016,1,1) datenum(2023,1,1) 0 300])
box on

% Setting one colorbar for both subplots!
cb = colorbar;
set(cb, 'Position', [.8314 .11 .0581 .8150])
for i = 1:2
    pos = get(ax(i), 'Position');
    set(ax(i), 'Position', [pos(1) pos(2) 0.85*pos(3) pos(4)]);
end
cb.Label.String = 'pCO2 (\muatm)';

% Setting one title, ylabel and xlabel for both subplots!
han = axes('visible','off');
han.Title.Visible = 'on';
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
ylabel(han, 'Depth (m)')
xlabel(han, 'Month/Year')
title(han, 'pCO2 in-situ')

%-- Contour plot: O2
% Use oxy_cmp for colormap!


%-- Contour plot: TCO2
ck = ~isnan(good_data(:,32));
TCO2 = good_data(ck,:);
x = unique(TCO2(:,39));
y = [0:300]';
[X,Y] = meshgrid(x,y);
Vq2 = griddata(TCO2(:,39), TCO2(:,2), TCO2(:,32), X, Y);

figure
subplot(2,1,1)
f = pcolor(X, Y, Vq2);
shading(gca, 'interp')
set(gca, 'YDir', 'reverse')
% pbaspect([3 1 1])
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,12))
axis tight
colormap(gca, flipud(zissou2))
cb2 = colorbar('vert', 'eastoutside')
cb2.Label.String = 'TCO2 (\mumol kg^{-1})';
% Add in TCO2 contour lines
hold on
set(gca, 'clim', [1135 2270])
axis([datenum(2016,1,1) datenum(2023,1,1) 0 300])
hold on
v = [2000,2000,2110,2110,2200,2200];
[c,h] = contour(X, Y, Vq2, v);
set(h, 'ShowText', 'on', 'TextStep', get(h, 'LevelStep')*2)
set(h, 'color', [0.3 0.3 0.3], 'linewidth', 0.75)
title('TCO2')
box on

%-- Contour plot: TA:TCO2
ck = ~isnan(good_data(:,31)./good_data(:,32));
TT = good_data(ck,:);
x = unique(TT(:,39));
y = [0:300]';
[X,Y] = meshgrid(x,y);
Vq8 = griddata(TT(:,39), TT(:,2), (TT(:,31)./TT(:,32)), X, Y);

subplot(2,1,2)
f = pcolor(X, Y, Vq8);
shading(gca, 'interp')
set(gca, 'YDir', 'reverse')
% pbaspect([3 1 1])
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,12))
axis tight
colormap(gca,flipud(parula))
cb8 = colorbar('vert', 'eastoutside')
% Add in TA:TCO2 contour lines
hold on
set(gca, 'clim', [0.93 1.1])
axis([datenum(2016,1,1) datenum(2023,1,1) 0 300])
hold on
v = [1,1,1.01,1.01,1.03,1.03,1.06,1.06];
[c,h] = contour(X, Y, Vq8, v);
set(h, 'ShowText', 'on', 'TextStep', get(h, 'LevelStep')*2)
set(h, 'color', [0.3 0.3 0.3], 'linewidth', 0.75)
title('TA:TCO2')
box on

% Setting axes for TCO2 & TA:TCO2 subplots
han = axes('visible','off');
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
ylabel(han, 'Depth (m)')
xlabel(han, 'Month/Year')


%-- Contour plot: Temperature
ck = ~isnan(good_data(:,17));
Temp = good_data(ck,:);
x = unique(Temp(:,39));
y = [0:300]';
[X,Y] = meshgrid(x,y);
Vq9 = griddata(Temp(:,39), Temp(:,2), Temp(:,17), X, Y);

figure
subplot(2,1,1)
f = pcolor(X, Y, Vq9);
shading(gca, 'interp')
set(gca, 'YDir', 'reverse')
% pbaspect([3 1 1])
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,12))
axis tight
colormap(gca, flipud(zissou3))
cb2 = colorbar('vert', 'eastoutside')
cb2.Label.String = 'Temperature (\circ C)';
% Add in Temp contour lines
hold on
set(gca, 'clim', [5.5 17])
axis([datenum(2016,1,1) datenum(2023,1,1) 0 300])
hold on
v = [7,7,8,8,11,11];
[c,h] = contour(X, Y, Vq9, v);
set(h, 'ShowText', 'on', 'TextStep', get(h, 'LevelStep')*2)
set(h, 'color', [0.7 0.7 0.7], 'linewidth', 0.75)
title('Temperature')
box on

%-- Contour plot: Salinity
ck = ~isnan(good_data(:,4));
Sal = good_data(ck,:);
x = unique(Sal(:,39));
y = [0:300]';
[X,Y] = meshgrid(x,y);
Vq10 = griddata(Sal(:,39), Sal(:,2), Sal(:,4), X, Y);

subplot(2,1,2)
f = pcolor(X, Y, Vq10);
shading(gca, 'interp')
set(gca, 'YDir', 'reverse')
% pbaspect([3 1 1])
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,12))
axis tight
colormap(gca,flipud(zissou2))
cb8 = colorbar('vert', 'eastoutside')
% Add in Salinity contour lines
hold on
set(gca, 'clim', [19 34])
axis([datenum(2016,1,1) datenum(2023,1,1) 0 300])
hold on
v = [28,28,30,30,32,32,33,33];
[c,h] = contour(X, Y, Vq10, v);
set(h, 'ShowText', 'on', 'TextStep', get(h, 'LevelStep')*2)
set(h, 'color', [0.3 0.3 0.3], 'linewidth', 0.75)
title('Salinity')
box on

% Setting axes for Temperature & Salinity subplots
han = axes('visible','off');
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
ylabel(han, 'Depth (m)')
xlabel(han, 'Month/Year')


%-- Contour plot: Calcite Saturation
ck = ~isnan(good_data(:,35));
Ca = good_data(ck,:);
x = unique(Ca(:,39));
y = [0:300]';
[X,Y] = meshgrid(x,y);
Vq6 = griddata(Ca(:,39), Ca(:,2), Ca(:,35), X, Y);

figure
subplot(2,1,1)
f = pcolor(X, Y, Vq6);
shading(gca, 'interp')
set(gca, 'YDir', 'reverse')
% pbaspect([3 1 1])
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,12))
axis tight
colormap(gca, zissou3)
cb6 = colorbar('vert', 'eastoutside')
cb6.Label.String = '\Omega_{CA}';
% Add in Calcite contour lines
hold on
set(gca, 'clim', [0.6 5.3])
axis([datenum(2016,1,1) datenum(2023,1,1) 0 300])
hold on
v = [1,1,1.2,1.2,1.5,1.5,2,2];
[c,h] = contour(X, Y, Vq6, v);
set(h, 'ShowText', 'on', 'TextStep', get(h, 'LevelStep')*2)
set(h, 'color', [0.3 0.3 0.3], 'linewidth', 0.75)
title('Calcite Saturation')
box on

%-- Contour plot: Aragonite Saturation
ck = ~isnan(good_data(:,36));
Ar = good_data(ck,:);
x = unique(Ar(:,39));
y = [0:300]';
[X,Y] = meshgrid(x,y);
Vq7 = griddata(Ar(:,39), Ar(:,2), Ar(:,36), X, Y);

subplot(2,1,2)
f = pcolor(X, Y, Vq7);
shading(gca, 'interp')
set(gca, 'YDir', 'reverse')
% pbaspect([3 1 1])
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,12))
axis tight
colormap(gca, zissou3)
cb7 = colorbar('vert', 'eastoutside')
cb7.Label.String = '\Omega_{AR}';
% Add in Aragonite contour lines
hold on
set(gca, 'clim', [0.4 3.3])
axis([datenum(2016,1,1) datenum(2023,1,1) 0 300])
hold on
v = [0.5,0.5,0.7,0.7,1,1,1.5,1.5];
[c,h] = contour(X, Y, Vq7, v);
set(h, 'ShowText', 'on', 'TextStep', get(h, 'LevelStep')*2)
set(h, 'color', [0.3 0.3 0.3], 'linewidth', 0.75)
title('Aragonite Saturation')
box on

% Setting axes for calcite & aragonite subplots
han = axes('visible','off');
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
ylabel(han, 'Depth (m)')
xlabel(han, 'Month/Year')


xtick = [datenum(2017,1,1) datenum(2018,1,1) datenum(2019,1,1)...
    datenum(2020,1,1) datenum(2021,1,1) datenum(2022,1,1)...
    datenum(2023,1,1)]; %datenum(2024,1,1)];

%-- Contour plot: Nitrate + Nitrite
ck = ~isnan(good_data(:,28));
NN = good_data(ck,:);
x = unique(NN(:,39));
y = [0:300]';
[X,Y] = meshgrid(x,y);
Vq3 = griddata(NN(:,39), NN(:,2), NN(:,28), X, Y);

figure
subplot(3,1,1)
f = pcolor(X, Y, Vq3);
shading(gca, 'interp')
set(gca, 'YDir', 'reverse')
% pbaspect([3 1 1])
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,12))
axis tight
colormap(gca, summer)
cb3 = colorbar('vert', 'eastoutside')
cb3.Label.String = 'N+N (\mumol kg^{-1})';
% Add in N+N contour lines
hold on
set(gca, 'clim', [0 34])
axis([datenum(2017,1,1) datenum(2023,1,1) 0 300])
hold on
v = [15,20,25,30];
[c,h] = contour(X, Y, Vq3, v);
set(h, 'ShowText', 'on', 'TextStep', get(h, 'LevelStep')*2)
set(h, 'color', [0.3 0.3 0.3], 'linewidth', 0.75)
title('Nitrate + Nitrite')
box on

%-- Contour plot: Phosphate
ck = ~isnan(good_data(:,29));
PO4 = good_data(ck,:);
x = unique(PO4(:,39));
y = [0:300]';
[X,Y] = meshgrid(x,y);
Vq4 = griddata(PO4(:,39), PO4(:,2), PO4(:,29), X, Y);

subplot(3,1,2)
f = pcolor(X, Y, Vq4);
shading(gca, 'interp')
set(gca, 'YDir', 'reverse')
% pbaspect([3 1 1])
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,12))
axis tight
colormap(gca, winter)
cb4 = colorbar('vert', 'eastoutside')
cb4.Label.String = 'PO4 (\mumol kg^{-1})';
% Add in PO4 contour lines
hold on
set(gca, 'clim', [0 2.5])
axis([datenum(2017,1,1) datenum(2023,1,1) 0 300])
hold on
v = [1, 1.5, 2, 2.3];
[c,h] = contour(X, Y, Vq4, v);
set(h, 'ShowText', 'on', 'TextStep', get(h, 'LevelStep')*2)
set(h, 'color', [0.3 0.3 0.3], 'linewidth', 0.75)
title('Phosphate')
box on

%-- Contour plot: Silicate
ck = ~isnan(good_data(:,30));
Si = good_data(ck,:);
x = unique(Si(:,39));
y = [0:300]';
[X,Y] = meshgrid(x,y);
Vq5 = griddata(Si(:,39), Si(:,2), Si(:,30), X, Y);

subplot(3,1,3)
f = pcolor(X, Y, Vq5);
shading(gca, 'interp')
set(gca, 'YDir', 'reverse')
% pbaspect([3 1 1])
set(gca, 'xtick', xtick, 'xticklabel', datestr(xtick,12))
axis tight
colormap(gca, flipud(autumn))
cb5 = colorbar('vert', 'eastoutside')
cb5.Label.String = 'SiO2 (\mumol kg^{-1})';
% Add in SiO2 contour lines
hold on
set(gca, 'clim', [0 61])
axis([datenum(2017,1,1) datenum(2023,1,1) 0 300])
hold on
v = [25, 45, 55];
[c,h] = contour(X, Y, Vq5, v);
set(h, 'ShowText', 'on', 'TextStep', get(h, 'LevelStep')*2)
set(h, 'color', [0.3 0.3 0.3], 'linewidth', 0.75)
title('Silicate')
box on

% Setting axes for nutrients subplots
han = axes('visible','off');
han.XLabel.Visible = 'on';
han.YLabel.Visible = 'on';
ylabel(han, 'Depth (m)')
xlabel(han, 'Month/Year')


%% Save KC10 QC'd data

KC10 = KC10(:,[2:11 16:19 21:39]);
save KC10_2016_2022_data_QCd.mat KC10

% Column Headers: 
%(1) Niskin Depth
%(2) QC Flag
%(3) YSI Salinity
%(4) NIST Temp
%(5) Analysis T
%(6) pCO2 @ analysisT
%(7) Adjusted TCO2
%(8) Latitude
%(9) Longitude
%(10) CTD time UTC
%(11) Depth
%(12) CTD Temp
%(13) CTD Salinity
%(14) Pres (dbar)
%(15) Density (rho)
%(16) PAR
%(17) Fluor chlor (ug/L)
%(18) Turbidity (FTU)
%(19) O2 (umol/kg)
%(20) AOU (umol/kg)
%(21) ∆O2 (umol/kg)
%(22) NO2 + NO3 (umol/kg)
%(23) PO4 (umol/kg)
%(24) SiO2 (umol/kg)
%(25) TAlk
%(26) TCO2
%(27) pCO2out (CTD T,S,P)
%(28) pHout (CTD T,S,P)
%(29) OmegaCAout (CTD T,S,P)
%(30) OmegaARout (CTD T,S,P)
%(31) RFout (CTD T,S,P)
%(32) Storage Time (Days)
%(33) SDN (UTC Time)