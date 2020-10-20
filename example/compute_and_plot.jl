using Plots.PlotMeasures
using CSV

# function round_values!(df::DataFrame, round::Function)
#     for i in 1:ncol(df)
#         if eltype(df[:, i]) <: Real
#             df[:, i] = round.(df[:, i])
#         end
#     end
# end

function compute_and_plot(df_cases::DataFrame, case_name::String, k_gen::Int, ylabel_R::String, ylabel_N::String)
    label_4_days = "RKI Nowcast 4 days"
    label_7_days = "RKI Nowcast 7 days"
    label_projected_7_days = "Projected 7 days"


    N_4_days, R_4_days = build_R(df_cases, k_gen - 1, 0, k_gen)
    N_7_days, R_7_days = build_R(df_cases, 5, 1, k_gen)
    N_projected_7_days, R_projected_7_days = build_R_acausal(df_cases, k_gen - 1, 3, k_gen)

    gr()
    plot(R_4_days.days, R_4_days.R, label=label_4_days, ylabel=ylabel_R, title="Last updated: $(today())", titlefontsize=7, margin=7mm)
    plot!(R_7_days.days, R_7_days.R, label=label_7_days)
    plot!(R_projected_7_days.days, R_projected_7_days.R, label=label_projected_7_days)
    savefig("reproduction-numbers-"*case_name*".png")

    gr()
    plot(N_4_days.days, N_4_days.cases, label=label_4_days, ylabel=ylabel_N, title="Last updated: $(today())", titlefontsize=7, margin=7mm)
    plot!(N_7_days.days, N_7_days.cases, label=label_7_days)
    plot!(N_projected_7_days.days, N_projected_7_days.cases, label=label_projected_7_days)
    savefig("cases-"*case_name*".png")

    Ns = [N_4_days, N_7_days, N_projected_7_days]
    Rs = [R_4_days, R_7_days, R_projected_7_days]
    labels = [label_4_days, label_7_days, label_projected_7_days]

    # rename columns
    for (label, i) in zip(labels, 1:length(Ns))
        Ns[i] = rename(Ns[i], :cases => label)
        Rs[i] = rename(Rs[i], :R => label)
    end

    # join columns based on days
    N = outerjoin(Ns...; on = :days)
    R = outerjoin(Rs...; on = :days)

    # replace missing values
    N = coalesce.(N, NaN)
    R = coalesce.(R, NaN)

    # # round values
    # N = round_values(N, n -> !isnan(n) ? round(Int, n) : n)
    # R = round_values(R, r -> round(r, digits=1))

    # write to CSV
    CSV.write("results-N-"*case_name*".csv", N, delim = ",")
    CSV.write("results-R-"*case_name*".csv", R, delim = ",")

    # return values
    N, R
end
