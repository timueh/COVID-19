export main_nowcasting

function main_nowcasting(fig_name, file_name, sheet_name, days_col, data_col, ylabel_R, ylabel_N)
    # download nowcasting data from RKI
    # a captcha might block the download from time to time
    if !isfile(file_name)
        run(`curl https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Projekte_RKI/Nowcasting_Zahlen.xlsx\?__blob\=publicationFile --output $file_name`)
    end

    # generation time
    k_gen = 4

    # pre-processing
    df = DataFrame(load(file_name, sheet_name))
    df_cases = get_reference_data(df, days_col = days_col, data_col = data_col, kind = "cases")

    # do the math
    N, R = compute_and_plot(df_cases, fig_name, k_gen, ylabel_R, ylabel_N, "nowcasted number of cases")

    N, R, df
end