# Import statements
import numpy as np
import pandas as pd
import xarray as xr
import cartopy.feature as cfeat
import cartopy.crs as ccrs
from shapely.geometry import Point
from cartopy.feature import ShapelyFeature
from datetime import datetime
import metpy.calc as mpcalc
from metpy.units import units
from metpy.plots.declarative import (BarbPlot, ContourPlot, FilledContourPlot,
                                     MapPanel, PanelContainer, PlotObs)

# Ignore warnings to keep code clean, errors will still print
import warnings
warnings.filterwarnings('ignore')

nc1 = 'Slvl-avg.nc'
nc2 = 'Slvl-instant.nc'
nc3 = 'Plvl.nc'

# Sets the geographic region to just the continental United States
#Lat/Lon window of interest for North America (Change these)
x1 =    -150            # West
x2 =     -60            # East
y1 =      20            # South
y2 =      55            # North

# Open and slice the first netCDF (Single level averages)
ds1 = xr.open_dataset( nc1 )
ds1 = ds1.sel(latitude = slice( y2, y1 ),
              longitude = slice( 360 + x1, 360 + x2 ) )

# Open and slice the second netCDF (Single level instantaneous)
ds2 = xr.open_dataset( nc2 )
ds2 = ds2.sel(latitude = slice( y2, y1 ),
              longitude = slice( 360 + x1, 360 + x2 ) )

# Open and slice the third netCDF (Pressure level)
ds3 = xr.open_dataset( nc3 )
ds3 = ds3.sel(latitude = slice( y2, y1 ),
              longitude = slice( 360 + x1, 360 + x2 ) )

ds = xr.merge( [ds1, ds2, ds3] )

print(ds)

# Lat/Long reference for Charleston, SC
loc1 = [32.7833, -79.9320]

# Create a geo-referenced point of Charleston
loc_geom = Point( loc1[1], loc1[0] ).buffer(0.1)
loc_feat1 = ShapelyFeature( [loc_geom], ccrs.PlateCarree(), 
                            facecolor = 'darkslategrey' )

# Wind Shear calculations
# Using Surface to 900 hPa as its the best approximation for 0-1000m wind shear

ds['u900hPa'] = ds['u'].sel( pressure_level = 900 )
ds['v900hPa'] = ds['v'].sel( pressure_level = 900 )

ds['ushear'] = (ds['u900hPa'] - ds['u10']) * units('kts')
ds['vshear'] = (ds['v900hPa'] - ds['v10']) * units('kts')

# Use pandas to convert time coordinate into datetime object (DO NOT CHANGE)
plot_time = pd.to_datetime(ds['valid_time'].values[0])

# Convert time to string for plot tite (DO NOT CHANGE)
time_str = plot_time.strftime("%B %d, %Y %HZ") 

# Figure Name String 
plot_type = f'Sfc-2m-KEY'

# String to pass to right-hand side label (You will need to change this one!)
param_str = ( f'MSLP (hPa)\n CAPE (J/kg)\n Surface - 900 hPa shear barbs (kts)' )

#-----------------------------------------------------------------------------
# Mean surface level pressure (hPa)
#-----------------------------------------------------------------------------
# Define the contour intervals 
cntr_min = 950                        # Min value
cntr_max = 1050                       # Max value
cntr_int = 2                          # Contour interval

# Create an array of evenly-spaced values (i.e., contour values) and convert to list
cntr_interval = np.arange(cntr_min, cntr_max +
                          cntr_int, cntr_int).tolist()

# Set attributes for contours 
cntr1 = ContourPlot()                       # Contour plot object
cntr1.data = ds                             # Dataset
cntr1.field = 'msl'                          # Data array to plot 
cntr1.time = plot_time                      # Temporal coordinate
cntr1.contours = cntr_interval              # Contour interval  
cntr1.linewidth = 1                        # Contour widths
cntr1.linecolor = 'grey'                       # Contour color
cntr1.linestyle = 'solid'                   # Contour linestlye
cntr1.plot_units = 'hPa'                    # Plotting units
cntr1.clabels = True                        # Show labels logic

#-----------------------------------------------------------------------------
# Convective available potential energy (J/kg)
#-----------------------------------------------------------------------------
# Define filled contour interval
cfill_min = 100                    # Min value
cfill_max = 2500                     # Max value
cfill_int = 20                    # Contour interval

# Create an array of evenly-spaced values (i.e., contour values) and convert to list
cfill_interval = np.arange(cfill_min, cfill_max +
                           cfill_int, cfill_int).tolist()  


# Set attributes for plotting color-filled contours 
cfill = FilledContourPlot()                # Filled contour object
cfill.data = ds                            # Dataset
cfill.field = 'cape'                       # Data array
cfill.scale = 1                            # Conversion scale for data array values
cfill.time = plot_time                     # Temporal coordinate
cfill.contours = cfill_interval            # Filled contour interval
cfill.colormap = 'Oranges'                 # Filled contour colormap
cfill.colorbar = 'horizontal'              # Colorbar location
cfill.plot_units = 'J / kg'                # Plotting units

#-----------------------------------------------------------------------------
# Sfc - 900 hPa wind shear (approximates 0-1000m shear) (kts)
#-----------------------------------------------------------------------------
# Wind Barb skipping value
skip_val = 3

# Set attributes for wind barb plotting 
barbs = BarbPlot()                         # Wind Barb object
barbs.data = ds                            # Dataset
barbs.barblength = 5                       # Length of wind barbs
barbs.field = ['ushear', 'vshear']         # Vector-Component Data arrays
barbs.time = plot_time                     # Temporal coordinate
barbs.skip = (skip_val, skip_val)          # Plotting intervals of barbs
barbs.color = 'k'
barbs.plot_units = 'kt'                    # Plotting Units

#-----------------------------------------------------------------------------
# Mapping Parameters
#-----------------------------------------------------------------------------
# Set the attributes for the map and add our data to the map
panel = MapPanel()                                               # Map Panel object
panel.layout = (1,1,1)                                           # Subplot layout
panel.left_title = (f'ERA5: Hurricane Ian Reanalysis\n{time_str}' )               # Map title (left-hand side)
panel.right_title = ( param_str )                                # Map title (right-hand side)
panel.area = [-87, -73, 38, 26]                                  # Plotting extent
panel.projection = 'mer'                                         # Map projection
panel.layers = ['coastline', 'land', 'ocean',
                 'usstates', 'borders', loc_feat1]               # Cartopy features for basemap (You will need to add more here!)
panel.layers_edgecolor = ['k', 'k']                              # Cartopy feature edge color
panel.layers_linewidth = [0.5, 0.5]                              # Cartopy feature line width
panel.plots = [cntr1, cfill, barbs]                              # Plotting objects to render on map


#-----------------------------------------------------------------------------
# Pull everything together to generate the figure
#-----------------------------------------------------------------------------
# Set figure attributes to plot our data on
pc = PanelContainer()                                            # Panel Container object
pc.size = (10, 10)                                               # Figure Size (in.)
pc.panels = [panel]                                              # Panels to add to figure
pc.show()
pc.save( f'Ian Mesoscale Setup.png' )                            # Save figure to cwd