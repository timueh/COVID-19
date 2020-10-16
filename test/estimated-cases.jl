using Test, ReproductionNumbers, ExcelFiles, DataFrames

days_col = "Erkrankungsdatum"
cases_col = "N(RKI-H)"

df = DataFrame(load("../data/nowcasting-test-data.xlsx", "Nowcast_R"))
df_cases = get_reference_data(df, days_col = days_col, data_col = cases_col, kind="cases")

NAMES       =   ["RKI-H"; "NEU-H"; "NEU-HA"]
CASES_COL   =   ["Neuberechnung mit Formel  NF(RKI-H)"; "NF(NEU-H)"; "NF(NEU-HA)"]
R_COL       =   ["Neuberechnung mit Formel R (RKI-H)"; "R(NEU-H)"; "R(NEU-HA)"]
K_GEN       =   [4; 4; 4]
PAST        =   K_GEN .- 1
FUTURE      =   [0; 3; 3]
BUILD       =   [build_R; build_R; build_R_acausal]

for (name, case_col, R_col, k_gen, past, future, build) in zip(NAMES, CASES_COL, R_COL, K_GEN, PAST, FUTURE, BUILD)
    df_N_ref = get_reference_data(df, days_col = days_col, data_col = case_col, kind = "cases")
    df_R_ref = get_reference_data(df, days_col = days_col, data_col = R_col, kind = "R")
    df_N, df_R = build(df_cases, past , future, k_gen)
    @testset "$(name): Cases" begin
        @test df_N_ref.days == df_N.days
        @test round.(df_N_ref.cases) == round.(df_N.cases)
    end

    @testset "$(name): R" begin
        @test df_R_ref.days == df_R.days
        @test round.(df_R_ref.R, digits = 2) == round.(df_R.R, digits = 2)
    end
end
