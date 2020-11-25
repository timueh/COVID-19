using ReproductionNumbers

# setup
fig_name    =   "reported"
file_name   =   "../data/raw/reported-cases-data.csv" # this file is huge and is hence added to .gitignore
days_col    =   "Refdatum"
data_col    =   "AnzahlFall_sum"
ylabel_R    =   "Instantaneous reproduction number R"
ylabel_N    =   "Reported cases"
# The reported cases by RKI are changed and updated daily
# That means, cases that were not submitted on time will be added the day after etc.
# This leads to today's and yesterday's values of R and N being rather useless
# Hence, the variable `pop_days` allows to go back as many days from today as we believe are credible
# Looking at the RKI dashboard we find that today - 2 days is fine.
pop_days    =   2

N, R, df = main_reported(fig_name, file_name, days_col, data_col, ylabel_R, ylabel_N, pop_days)