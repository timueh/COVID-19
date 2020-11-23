using ReproductionNumbers

# setup
fig_name    =   "reported"
file_name   =   "../data/raw/reported-cases-data.csv" # this file is huge and is hence added to .gitignore
days_col    =   "Refdatum"
data_col    =   "AnzahlFall_sum"
ylabel_R    =   "Instantaneous reproduction number R"
ylabel_N    =   "Reported cases"

N, R, df = main_reported(fig_name, file_name, days_col, data_col, ylabel_R, ylabel_N)