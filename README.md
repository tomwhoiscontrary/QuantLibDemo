To run the tool over a matrix of QuantLib and GCC versions:

    mkdir -p tmp/results
    for ql_version in v1.31 v1.31.1 v1.32 v1.33 v1.34
    do
        for gcc_version in 7.5.0 8.5.0 9.5.0 10.5.0 11.4.0 12.3.0 13.2.0
        do
            echo -n "${ql_version} ${gcc_version} ... "
            ./build.sh -q $ql_version -g $gcc_version >tmp/results/ql.${ql_version}_gcc${gcc_version}.log 2>&1 && echo ok || echo NO
        done
    done

To grind the results into statistics (you will need xsv installed):

    {
        echo ql_version,gcc_version,min,max,mean,stddev
        for ql_version in v1.31 v1.31.1 v1.32 v1.33 v1.34
        do
            for gcc_version in 7.5.0 8.5.0 9.5.0 10.5.0 11.4.0 12.3.0 13.2.0
            do
                echo -n "${ql_version},${gcc_version},";
                sed -rn '/^iteration,/,/^20,/p' tmp/results/ql.${ql_version}_gcc${gcc_version}.log | xsv stats | egrep elapsed | xsv select 4,5,8,9
            done
        done
    } >results.csv

An example results file is checked in, but it is not necessarily of great quality!

You can plot the results with matplotlib. To use the Tk backend on the accursed Ubuntu, install and test the Python Tk module:

    sudo apt install python3-tk
    python -m tkinter # opens a small window in the top left of the desktop

Install matplotlib and pandas in a venv:

    python -m venv matplotlib.venv
    matplotlib.venv/bin/pip install --upgrade pip
    matplotlib.venv/bin/pip install matplotlib pandas

Then to plot the results, run `matplotlib.venv/bin/python` and do:

    import matplotlib
    matplotlib.use('TkAgg')
    import matplotlib.pyplot as plt
    import pandas as pd

    results = pd.read_csv('results.csv')

    results['ql_version_codes'], ql_version_uniques = results['ql_version'].factorize()
    results['gcc_version_codes'], gcc_version_uniques = results['gcc_version'].factorize()

    ax = plt.figure().add_subplot(projection='3d')
    ax.plot_trisurf(results['ql_version_codes'], results['gcc_version_codes'], results['mean'])
    ax.set_xticks(range(len(ql_version_uniques)), ql_version_uniques)
    ax.set_yticks(range(len(gcc_version_uniques)), gcc_version_uniques)

    plt.show()
