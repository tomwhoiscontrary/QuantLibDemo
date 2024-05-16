To run the tool over a matrix of QuantLib and GCC versions:

    ./run.sh

To grind the results into statistics (you will need xsv installed):

    ./stats.sh

An example results file is checked in, but it is not necessarily of great quality!

You can plot the results with matplotlib. To use the Tk backend on the accursed Ubuntu, install and test the Python Tk module:

    sudo apt install python3-tk
    python -m tkinter # opens a small window in the top left of the desktop

Install matplotlib and pandas in a venv:

    python -m venv matplotlib.venv
    matplotlib.venv/bin/pip install --upgrade pip
    matplotlib.venv/bin/pip install matplotlib pandas

Then to plot the results:

    ./plot.py
