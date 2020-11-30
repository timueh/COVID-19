using ReproductionNumbers

# setup
fig_name    =   "reported"
file_name   =   "../data/raw/reported-cases-data.csv" # this file is huge and is hence added to .gitignore
days_col    =   "Refdatum"
data_col    =   "AnzahlFall_sum"
ylabel_R    =   "Reproduction number R"
ylabel_N    =   "Reported cases"
# The reported cases by RKI are changed and updated daily
# That means, cases that were not submitted on time will be added the day after etc.
# This leads to today's and yesterday's values of R and N being rather useless
# Hence, the variable `pop_days` allows to go back as many days from today as we believe are credible
# Looking at the RKI dashboard we find that today - 2 days is fine.
pop_days    =   2

N, R, df_cases = main_reported(fig_name, file_name, days_col, data_col, ylabel_R, ylabel_N, "country", pop_days)

# # ## break down data for German states
# df = CSV.File(file_name) |> DataFrame

# df_filter = filter_to_relevant_cases(df)
# gdf = groupby(df_filter, :Bundesland)
# cases_dict = Dict{String, DataFrame}()

# for (i, df_state) in enumerate(gdf)
#     # get name of current state
#     state_name = unique(gdf[i].Bundesland) |> first
#     # aggregate state data by days
#     gdf_state = groupby(df_state, days_col)
#     # sum over the number of cases & sort
#     cases = combine(gdf_state, :AnzahlFall => sum) |> sort
#     # promote date column to Dates.DateFormat
#     cases[!, days_col] = Date.(cases[!, days_col], Dates.DateFormat("yyyy/mm/dd H:M:S"))
#     # standardize column names
#     df_case = get_reference_data(cases, days_col = days_col, data_col = data_col, kind = "cases")
#     df_case = df_case[df_case.days .>= Date("2020-03-15"), :]
#     cases_dict[state_name] = df_case
# end

# cases_dict = sort(cases_dict)