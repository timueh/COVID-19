function compute_and_plot(df_cases::DataFrame, case_name::String, k_gen::Int, ylabel_R::String, ylabel_N::String)
    N_rki_nowcast_4_days, R_rki_nowcast_4_days = build_R(df_cases, k_gen - 1, 0, k_gen)
    N_rki_nowcast_7_days, R_rki_nowcast_7_days = build_R(df_cases, 5, 1, k_gen)

    N_acausal_nowcast_7_days, R_acausal_nowcast_7_days = build_R(df_cases, k_gen - 1, 3, k_gen)
    N_projected_nowcast_7_days, R_projected_nowcast_7_days = build_R_acausal(df_cases, k_gen - 1, 3, k_gen)

    gr()
    plot(R_rki_nowcast_4_days.days, R_rki_nowcast_4_days.R, label="RKI Nowcast 4 days", ylabel=ylabel_R, title="Last updated: $(today())", titlefontsize=7)
    plot!(R_acausal_nowcast_7_days.days, R_acausal_nowcast_7_days.R, label="RKI Nowcast 7 days")
    plot!(R_projected_nowcast_7_days.days, R_projected_nowcast_7_days.R, label="Projected 7 days")
    savefig("reproduction-numbers-"*case_name*".png")

    gr()
    plot(N_rki_nowcast_4_days.days, N_rki_nowcast_4_days.cases, label="RKI Nowcast 4 days", ylabel=ylabel_N, title="Last updated: $(today())", titlefontsize=7)
    plot!(N_acausal_nowcast_7_days.days, N_acausal_nowcast_7_days.cases, label="RKI Nowcast 7 days")
    plot!(N_projected_nowcast_7_days.days, N_projected_nowcast_7_days.cases, label="Projected 7 days")
    savefig("cases-"*case_name*".png")
end