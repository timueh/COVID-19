using ReproductionNumbers, DataFrames, ExcelFiles, Plots, Dates

include("compute_and_plot.jl")

fig_name    =   "nowcasting"
file_name   =   "../data/nowcasting-data.xlsx"
sheet_name  =   "Nowcast_R"
days_col    =   "Datum des Erkrankungsbeginns"
data_col    =   "Punktschätzer der Anzahl Neuerkrankungen (ohne Glättung)"
ylabel_R    =   "Basic reproduction number R_0"
ylabel_N    =   "Nowcasted cases"

# download nowcasting data from RKI
run(`curl https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/Nowcasting_Zahlen.xlsx\?__blob\=publicationFile --output $file_name`)

k_gen = 4

df = DataFrame(load(file_name, sheet_name))
df_cases = get_reference_data(df, days_col = days_col, data_col = data_col, kind = "cases")

N, R = compute_and_plot(df_cases, fig_name, k_gen, ylabel_R, ylabel_N)