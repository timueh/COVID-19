using Test, ReproductionNumbers, ExcelFiles, DataFrames


days_col = "Datum RKI-Tagesbericht"
cases_col = "N_{BF} [k+3,k+4]"

df = DataFrame(load("../data/20200511_Nowcasting_Zahlen.xlsx", "Nowcast_R"))
df_cases = get_reference_data(df, days_col = days_col, data_col = cases_col, kind="cases")

NAMES       =   ["NEU-AF7"; "NEU-A"]
CASES_COL   =   ["NF_{BF,AF7} [k+3,k+7]"; "NF(NEU-A)"]
R_COL       =   ["R_{BF,AF7} [k,k+7]"; "R(NEU-A)"]
K_GEN       =   [4; 4]
PAST        =   K_GEN .- 1
FUTURE      =   [3; 3]
BUILD       =   [build_R, build_R_acausal]

for (name, case_col, R_col, k_gen, past, future, build) in zip(NAMES, CASES_COL, R_COL, K_GEN, PAST, FUTURE, BUILD)
    df_N_ref = get_reference_data(df, days_col = days_col, data_col = case_col, kind = "cases")
    df_R_ref = get_reference_data(df, days_col = days_col, data_col = R_col, kind = "R")
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