# CO2_QA-QC
The following repository contains written protocols and Matlab scripts to assess CO2 samples collected and analyzed at Hakai Institute.
The protocols provided are the Hakai Institute's BoL TCO2/pCO2 Analysis Protocol which provides an overview of the operation and analysis of samples on the Burke-o-Lator (BoL); Discrete TCO2/pCO2 QC for a brief overview of further QA/QC of the CO2 data (Step 6 of the Matlab scripts).
The Matlab scripts provided are for completing the CO2 SRVC sheet after sample analysis; CTD QA/QC after downloading data from Hakai EIMS Portal; merging finalized nutrients with the CO2 metadata mastersheet and QC'd CTD file.

During CO2 sample analysis, analysts will fill out the Metadata Mastersheet and SRVC CO2 sheet. "Template_Metadata_Mastersheet" and "SRVC_CO2_ver2.0_template"
Once analysis is completed, the CO2 data will be QC'd by another analyst and carbonate calculations for the CO2 data will happen. At this time the Metadata Mastersheet and SRVC CO2 sheet is completed as well. "SRVC_CO2_Carb_Calcs"
If CTD data are available for the CO2 data that were analyzed, the following scripts will be followed to obtain the QC'd CTD data. "Step1_FormatCTD", "Step2a_Profile_plots_all_CTD_casts" and "Step2b_Flagged_CTD_profiles_grouped_by_month"
If nutrient data were collected the same day as CO2 samples, the completed Metadata Mastersheet and finalized nutrient concentrations will be merged. "Step3_Merge_nutrients_with_lab_mastersheet"
Using the outputs from the CTD script and the CO2/nutrient merging script, the CTD data will be merged with the bottle data by solo transducer pressure attached to each Niskin during sample collection. "Step4_Merge_bottle_and_CTD_data_by_niskin_pressure"
After the CTD and bottle data have been merged, the nutrient concentrations are convereted from µM to µmol/kg and the carbonate calculations are recomputed using CTD information specific to each sample. "Step5_Convert_nutrients_and_compute_carbonate_system"
The final step in the CO2 QA/QC process is to assess the CO2 data for any outliers and bad data that exists within the dataset. There are multiple parts within this last step and each section in the Matlab script gives a brief summary of the QA/QC methods being applied. "Step6_KC10_data_QC_2016_2022"
