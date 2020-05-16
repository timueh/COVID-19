using ReproductionNumbers, DataFrames, ExcelFiles, Plots

function get_raw_number(df::DataFrame; col_name::String)
    Vector{Int64}(df[!, col_name])
end

function get_dates(df::DataFrame; col_name::String)
    df[!, col_name]
end

use_verified_data = true
k_gen = 4

df, df_cases =
if use_verified_data
    df_ = DataFrame(load("../data/20200511_Nowcasting_Zahlen.xlsx", "Nowcast_R"))
    df_cases_ = DataFrame( days = get_dates(df_; col_name = "Erkrankungsdatum"),
                            cases = get_raw_number(df_; col_name = "N(RKI-H)"))  
    df_, df_cases_
else
    df_ = DataFrame(load("../data/R-Beispielrechnung.xlsx", "Nowcast_R"))
    df_cases_ = DataFrame( days = get_dates(df_; col_name = "Datum des Erkrankungsbeginns"),
                           cases = get_raw_number(df_; col_name = "Punktschätzer der Anzahl Neuerkrankungen (ohne Glättung)"))
    df_, df_cases_
end


rki_h_N, rki_h_R = build_R(df_cases; past = k_gen - 1, future = 0, k_gen = k_gen)
neu_h_N, neu_h_R = build_R(df_cases; past = k_gen - 1, future = 3, k_gen = k_gen)
neu_ha_N, neu_ha_R = build_R_acausal(df_cases; past = k_gen - 1, future = 3, k_gen = k_gen)


gr()
plot(rki_h_R.days, rki_h_R.R, marker=:x, label="RKI-H")
plot!(neu_h_R.days, neu_h_R.R, marker=:c, label="NEU-H")
plot!(neu_ha_R.days, neu_ha_R.R, marker=:s, label="NEU-HA")
savefig("ReproductionNumbers.png")

gr()
plot(rki_h_N.days, rki_h_N.cases, marker=:x, label="RKI-H")
plot!(neu_h_N.days, neu_h_N.cases, marker=:c, label="NEU-H")
plot!(neu_ha_N.days, neu_ha_N.cases, marker=:s, label="NEU-HA")
savefig("Cases.png")