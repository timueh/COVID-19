using ReproductionNumbers, DataFrames, ExcelFiles

function get_raw_number(df::DataFrame, column_name::String = "Punktschätzer der Anzahl Neuerkrankungen (ohne Glättung)")
    Vector{Int64}(df[!, column_name])
end

function get_dates(df::DataFrame, column_name::String = "Datum des Erkrankungsbeginns")
    df[!, column_name]
end

df = DataFrame(load("../data/R-Beispielrechnung.xlsx", "Nowcast_R"))

N_raw, dates = get_raw_number(df), get_dates(df)
N_raw = [308
327
452
498
763
992
1337
1987
2552
3231
3597
4368
4448
4694
5991
5262
5328
4749
5315
4491
3897
5183
4165
4407
4042
4137
3911
3351
4351
3609
4030
3771
3760
3053
2742
3344
3104
2904
2725
2334
2026
1993
1939
2007
1950
1789
1693
1473
1333
1573
1385
1331
1310
1190
1030
941
1130
944
911
913
755
747
832
982
1003
936]
dates = dates[1:length(N_raw)]
df_cases = DataFrame(days = dates, cases = N_raw)

k_gen = 4

rki_h_N, rki_h_R = build_R(df_cases; past = k_gen - 1, future = 0, k_gen = k_gen)
neu_h_N, neu_h_R = build_R(df_cases; past = 3, future = 3, k_gen = k_gen)
neu_ha_N, neu_ha_R = build_R_acausal(df_cases; past = 3, future = 4, k_gen = k_gen)
