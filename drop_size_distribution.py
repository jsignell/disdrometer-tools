"""
Read Parsivel drop size distribution table formatted as campbellsci TOA5

Julia Signell
2015-10-16

Modified from:

Matplotlib Animation Example

author: Jake Vanderplas
email: vanderplas@astro.washington.edu
website: http://jakevdp.github.com
license: BSD
"""

import time
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from matplotlib import animation
from matplotlib.widgets import Slider
plt.style.use('ggplot')


df = pd.read_csv("C:/Users/Julia/work/LoggerNet/CR6_SN1698_P_Size.dat", skiprows=[0,2,3], index_col=[0], parse_dates=True)
df.pop('RECORD')
cols = [col for col in df.columns if len(df[col].unique())>1]
df = df[cols]
size = [int(m.strip('mm')) for m in cols]
size = np.asarray(size, float)/1000

# First set up the figure, the axis, and the plot element we want to animate
fig = plt.figure()
ax = plt.axes(xlim=(size[0], size[-1]), ylim=(1,10**5), yscale='log', )
ax.grid()
line, = ax.plot([], [], lw=2)

# initialization function: plot the background of each frame
def init():
    line.set_data([], [])
    return line,


def animate(i):
    """
    Animation function. This is called sequentially
    """
    i = int(round(i))
    x = size
    y = np.asarray(10**df.iloc[i])
    line.set_data(x, y)
    if len(df.iloc[i].unique()) != 1:
        time.sleep(.1) # delays for 5 seconds
    return line,

# call the animator.  blit=True means only re-draw the parts that have changed.
#anim = animation.FuncAnimation(fig, animate, init_func=init,
#                               frames=len(df), blit=True)

def slide(val):
    """
    This function is takes the slider value and updates
    the plot. Slider can be changed by dragging, clicking,
    or using arrows.
    """
    global i

    i = int(round(val))
    x = size
    y = np.asarray(10**df.iloc[i])
    line.set_data(x, y)

    return line,


def arrow_key_control(event):
    """
    This function takes an event from an mpl_connection
    and listens for key release events specifically from
    the keyboard arrow keys (left/right) and uses this
    input to advance/reverse to the next/previous image.
    """
    global i

    minindex = 0
    maxindex = len(df)
    if event.key == 'left':
        if i - 1 >= minindex:
            i -= 1
    elif event.key == 'right':
        if i + 1 <= maxindex:
            i += 1
    sframe.set_val(i)

plt.subplots_adjust(left=0.25, bottom=0.25)
i = 0

# make the slider
axframe = plt.axes([0.25, 0.1, 0.65, 0.03])
sframe = Slider(axframe, 'times', 0, len(df)-1, valinit=0, valfmt='%d')

sframe.on_changed(slide)
cid = fig.canvas.mpl_connect('key_release_event', arrow_key_control)

plt.show()
