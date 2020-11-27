export compute_and_plot

# function round_values!(df::DataFrame, round::Function)
#     for i in 1:ncol(df)
#         if eltype(df[:, i]) <: Real
#             df[:, i] = round.(df[:, i])
#         end
#     end
# end

function compute_and_plot(df_cases::DataFrame, case_name::String, k_gen::Int, ylabel_R::String, ylabel_N::String, databasis::String, pop_days::Int=0)
    label_4_days = "RKI Nowcast 4 days"
    label_7_days = "RKI Nowcast 7 days"
    label_projected_7_days = "Projected 7 days"


    N_4_days, R_4_days = build_R(df_cases, k_gen - 1, 0, k_gen)
    N_7_days, R_7_days = build_R(df_cases, 5, 1, k_gen)
    N_projected_7_days, R_projected_7_days = build_R_acausal(df_cases, k_gen - 1, 3, k_gen)

    last_day = last(R_projected_7_days).days - Day(pop_days)

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

    # restrict to meaningful days, i.e. most recent day - Day(pop_days)
    N = N[N.days .<= last_day, :]
    R = R[R.days .<= last_day, :]

    # # round values
    # N = round_values(N, n -> !isnan(n) ? round(Int, n) : n)
    # R = round_values(R, r -> round(r, digits=1))

    # write to CSV
    CSV.write("results-N-"*case_name*".csv", N, delim = ",")
    CSV.write("results-R-"*case_name*".csv", R, delim = ",")

    # plot
    last_R_proj_7 = round(R[end, label_projected_7_days], digits=2)
    plot_df(R, "days", ylabel_R, "R based on $(databasis). R = $last_R_proj_7. (Last updated: $(today()); valid for $last_day)", "reproduction-numbers-"*case_name*".png", :topright)
    plot_df(N, "days", ylabel_N, "Number of cases based on $(databasis). (Last updated: $(today()); valid for $last_day)", "cases-"*case_name*".png", :topleft)
    
    # return values
    N, R
end

function cut_to_day!(df::DataFrame, day::Date)
    df = df[df.days .<= day, :]
end

function plot_df(df, day_col::String, ylabel::String, title::String, file_name::String, position=:topright)
    days = df[!, day_col]
    data = df[ .!(names(df) .== day_col)]

    closeall()
    gr()
    for (i, name) in enumerate(names(data))
        plot_fun = i==1 ? plot : plot!
        plot_fun(days, data[!, name], label=name, ylabel=ylabel, titlefontsize=7, margin=7mm, legend=position, title=title)
    end
    savefig(file_name)
end