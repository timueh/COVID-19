using ReproductionNumbers, DataFrames, ExcelFiles, Plots, Dates

case_name   =   "confirmed-cases"
file_name   =   "../data/20200511_Nowcasting_Zahlen.xlsx"
sheet_name  =   "Nowcast_R"
days_col    =   "Datum RKI-Tagesbericht"
data_col    =   "N_{BF} [k+3,k+4]"

case_name   =   "estimated-cases-20200511"
file_name   =   "../data/20200511_Nowcasting_Zahlen.xlsx"
sheet_name  =   "Nowcast_R"
days_col    =   "Erkrankungsdatum"
data_col    =   "N(RKI-H)"

# case_name   =   "estimated-cases"
# file_name   =   "../data/R-Beispielrechnung.xlsx"
# sheet_name  =   "Nowcast_R"
# days_col    =   "Datum des Erkrankungsbeginns"
# data_col    =   "Punktschätzer der Anzahl Neuerkrankungen (ohne Glättung)"

k_gen = 4

df = DataFrame(load(file_name, sheet_name))
df_cases = get_reference_data(df, days_col = days_col, data_col = data_col, kind = "cases")

rki_h_N, rki_h_R = build_R(df_cases, k_gen - 1, 0, k_gen)
neu_h_N, neu_h_R = build_R(df_cases, k_gen - 1, 3, k_gen)
neu_ha_N, neu_ha_R = build_R_acausal(df_cases, k_gen - 1, 3, k_gen)


gr()
plot(rki_h_R.days, rki_h_R.R, marker=:x, label="RKI-H")
plot!(neu_h_R.days, neu_h_R.R, marker=:c, label="NEU-H")
plot!(neu_ha_R.days, neu_ha_R.R, marker=:s, label="NEU-HA")
savefig("reproduction-numbers-"*case_name*".png")

gr()
plot(rki_h_N.days, rki_h_N.cases, marker=:x, label="RKI-H")
plot!(neu_h_N.days, neu_h_N.cases, marker=:c, label="NEU-H")
plot!(neu_ha_N.days, neu_ha_N.cases, marker=:s, label="NEU-HA")
savefig("cases-"*case_name*".png")