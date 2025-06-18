import numpy as np
import matplotlib.pyplot as plt

xvar = ['Debby', 'Idalia', 'Ian', 'Florence', 'Matthew']

# ----- SWEAT Index -----

sweat = [288.0, 225.6, 320.2, 351.6, 375.5]

fig, ax = plt.subplots(figsize = (5.0, 6.5)) 

ax.bar(xvar, sweat, color='darkolivegreen')                     # Plots a bar chart
ax.axhline(np.average(sweat), color='black', linestyle='--')    # Plots a dashed line to show the mean SWEAT
ax.set_ybound(150, 400)                                         # Sets the bounds

fig.savefig('SWEAT Index.png')
plt.show()

# ----- Total Totals Index -----

tt = [41.4, 46.5, 39.4, 41.0, 39.0]

fig, ax = plt.subplots(figsize = (5.0, 6.5)) 

ax.bar(xvar, tt, color='royalblue')                             # Plots a bar chart
ax.axhline(np.average(tt), color='black', linestyle='--')       # Plots a dashed line to show the mean TT
ax.set_ybound(30, 50)                                           # Sets the bounds

fig.savefig('Total Totals Index.png')
plt.show()

# ----- K Index -----

ki = [37.9, 40.8, 34.3, 37.3, 35.3]

# Sets the plot size
fig, ax = plt.subplots(figsize = (5.0, 6.5)) 


ax.bar(xvar, ki, color='goldenrod')                             # Plots a bar chart
ax.axhline(np.average(ki), color='black', linestyle='--')       # Plots a dashed line to show the mean KI
ax.set_ybound(30, 45)                                           # Sets the bounds

fig.savefig('K Index.png')
plt.show()