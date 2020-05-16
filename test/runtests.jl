using Test, ReproductionNumbers, ExcelFiles, DataFrames

function get_reference_data(df::DataFrame; days_col::String, cases_col::String, R_col::String)
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

NAMES       = ["RKI-H"; "NEU-H"; "NEU-HA"]
CASES_COL   = ["Neuberechnung mit Formel  NF(RKI-H)"; "NF(NEU-H)"; "NF(NEU-HA)"]
R_COL       = ["Neuberechnung mit Formel R (RKI-H)"; "R(NEU-H)"; "R(NEU-HA)"]
K_GEN       = [4; 4; 4]
PAST        = K_GEN .- 1
FUTURE      = [0; 3; 3]
BUILD   = [build_R; build_R; build_R_acausal]

for (name, case_col, R_col, k_gen, past, future, build) in zip(NAMES, CASES_COL, R_COL, K_GEN, PAST, FUTURE, BUILD)
    df_N_ref, df_R_ref = get_reference_data(df, days_col = "Erkrankungsdatum", cases_col = case_col, R_col = R_col)
    df_N, df_R = build(df_cases; past = past, future = future, k_gen = k_gen)
    @testset "$(name): Cases" begin
        @test df_N_ref.days == df_N.days
        @test round.(df_N_ref.cases) == round.(df_N.cases)
    end

    @testset "$(name): R" begin
        @test df_R_ref.days == df_R.days
        @test round.(df_R_ref.R, digits = 2) == round.(df_R.R, digits = 2)
    end
end
