using ReproductionNumbers

# setup
fig_name    =   "nowcasting"
file_name   =   "../data/raw/nowcasting-data.xlsx"
sheet_name  =   "Nowcast_R"
days_col    =   "Datum des Erkrankungsbeginns"
data_col    =   "Punktschätzer der Anzahl Neuerkrankungen (ohne Glättung)"
ylabel_R    =   "Instantaneous reproduction number R"
ylabel_N    =   "Nowcasted cases"

main_nowcasting(fig_name, file_name, sheet_name, days_col, data_col, ylabel_R, ylabel_N)