using Test, ReproductionNumbers, ExcelFiles, DataFrames

function get_rki_h_N_true(df::DataFrame; days_col::String="Erkrankungsdatum", cases_col::String="Neuberechnung mit Formel  NF(RKI-H)", R_col::String="Neuberechnung mit Formel R (RKI-H)")
    days = df[!, days_col]
    
    cases = df[!, cases_col]
    inds_cases = .!ismissing.(cases)
    df_cases = DataFrame(days = days[inds_cases], cases = Vector{Int64}(round.(cases[inds_cases])))

    R = df[!, R_col]
    inds_R = .!ismissing.(R)
    df_R = DataFrame(days = days[inds_R], R = R[inds_R])

    df_cases, df_R
end

df = DataFrame(load("../data/20200511_Nowcasting_Zahlen.xlsx", "Nowcast_R"))
cases, dates = df[!, "N(RKI-H)"], df[!, "Erkrankungsdatum"]
df_cases = DataFrame(days = dates, cases = cases)

k_gen = 4

rki_h_N_true, rki_h_R_true = get_rki_h_N_true(df)
rki_h_N, rki_h_R = build_R(df_cases; past = k_gen - 1, future = 0, k_gen = k_gen)

@testset "RKI-H cases" begin
    @test rki_h_N.days == rki_h_N_true.days
    @test round.(rki_h_N.cases) == rki_h_N_true.cases
end

@testset "RKI-H R" begin
    @test rki_h_R.days == rki_h_R_true.days
    @test round.(rki_h_R.R, digits=2) == round.(rki_h_R_true.R, digits=2)
end