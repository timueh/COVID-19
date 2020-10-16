using ReproductionNumbers, DataFrames, Plots, Dates, CSV

include("compute_and_plot.jl")

fig_name    =   "reported"
file_name   =   "../data/reported-cases-data-"*string(today())*".csv"
days_col    =   "Refdatum"
data_col    =   "AnzahlFall_sum"
ylabel_R    =   "Basic reproduction number R_0"
ylabel_N    =   "Reported cases"

# download full COVID-19 data set from RKI
run(`curl https://www.arcgis.com/sharing/rest/content/items/f10774f1c63e40168479a1feb6c7ca74/data --output $file_name`)

k_gen = 4

# Pre-processing
df = CSV.read(file_name)
df_filtered = df[df["NeuerFall"] .!= -1, :]
df_temp = by(df_filtered, :Refdatum, :AnzahlFall => sum; sort=true)
df_temp.Refdatum = Date.(df_temp.Refdatum, Dates.DateFormat("yyyy/mm/dd H:M:S"))

df_cases = get_reference_data(df_temp, days_col = days_col, data_col = data_col, kind = "cases")
# account for the fact that cases were not reported properly before March 2020
df_cases = df_cases[df_cases.days .>= Date("2020-03-01"), :]

compute_and_plot(df_cases, fig_name, k_gen, ylabel_R, ylabel_N)

