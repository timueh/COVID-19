using ReproductionNumbers

# setup
fig_name    =   "reported"
file_name   =   "../data/reported-cases-data.csv"
days_col    =   "Refdatum"
data_col    =   "AnzahlFall_sum"
ylabel_R    =   "Instantaneous reproduction number R"
ylabel_N    =   "Reported cases"

main_reported(fig_name, file_name, days_col, data_col, ylabel_R, ylabel_N)