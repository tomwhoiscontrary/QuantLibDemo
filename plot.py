#! matplotlib.venv/bin/python

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
