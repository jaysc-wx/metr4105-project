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

nc1 = 'SLvl-Accum.nc'
nc2 = 'SLvl-Instant.nc'
nc3 = 'PLvl.nc'

# Sets the geographic region to just the continental United States
# Kali driver, Ethan navigator
#Lat/Lon window of interest for North America (Change these)
x1 =    -150            # West
x2 =     -60            # East
y1 =      20            # South
y2 =      55            # North

# Open and slice the first netCDF (Pressure-Level) DO NOT CHANGE THESE
ds1 = xr.open_dataset( nc1 )
ds1 = ds1.sel(latitude = slice( y2, y1 ),
              longitude = slice( 360 + x1, 360 + x2 ) )

# Open and slice the second netCDF (Single-Level) DO NOT CHANGE THESE
ds2 = xr.open_dataset( nc2 )
ds2 = ds2.sel(latitude = slice( y2, y1 ),
              longitude = slice( 360 + x1, 360 + x2 ) )

ds3 = xr.open_dataset( nc3 )
ds3 = ds3.sel(latitude = slice( y2, y1 ),
              longitude = slice( 360 + x1, 360 + x2 ) )

ds = xr.merge( [ds1, ds2, ds3] )

print(ds)

# Lat/Long window of interest for tornado origins
loc1 = [32.5023, -80.2962]
loc2 = [32.7892, -79.7773]
loc3 = [32.4790, -80.3307]
loc4 = [32.6035, -80.0740]
loc5 = [32.8000, -80.0350]
loc6 = [32.3736, -80.5253]
loc7 = [33.2079, -79.9807]
loc8 = [32.4393, -80.6085]

# Create a geo-referenced point for each tornado report
loc_geom = Point( loc1[1], loc1[0] ).buffer(0.03)
loc_feat1 = ShapelyFeature( [loc_geom], ccrs.PlateCarree(), 
                            facecolor = 'darkturquoise' )

loc_geom = Point( loc2[1], loc2[0] ).buffer(0.03)
loc_feat2 = ShapelyFeature( [loc_geom], ccrs.PlateCarree(), 
                            facecolor = 'green' )

loc_geom = Point( loc3[1], loc3[0] ).buffer(0.03)
loc_feat3 = ShapelyFeature( [loc_geom], ccrs.PlateCarree(), 
                            facecolor = 'green' )

loc_geom = Point( loc4[1], loc4[0] ).buffer(0.03)
loc_feat4 = ShapelyFeature( [loc_geom], ccrs.PlateCarree(), 
                            facecolor = 'darkturquoise' )

loc_geom = Point( loc5[1], loc5[0] ).buffer(0.03)
loc_feat5 = ShapelyFeature( [loc_geom], ccrs.PlateCarree(), 
                            facecolor = 'darkturquoise' )

loc_geom = Point( loc6[1], loc6[0] ).buffer(0.03)
loc_feat6 = ShapelyFeature( [loc_geom], ccrs.PlateCarree(), 
                            facecolor = 'darkturquoise' )

loc_geom = Point( loc7[1], loc7[0] ).buffer(0.03)
loc_feat7 = ShapelyFeature( [loc_geom], ccrs.PlateCarree(), 
                            facecolor = 'darkturquoise' )

loc_geom = Point( loc8[1], loc8[0] ).buffer(0.03)
loc_feat8 = ShapelyFeature( [loc_geom], ccrs.PlateCarree(), 
                            facecolor = 'green' )

# Use pandas to convert time coordinate into datetime object
plot_time = pd.to_datetime(ds['valid_time'].values[0])

# Convert time to string for plot tite
time_str = plot_time.strftime("%B %d, %Y %HZ") 

# Figure Name String 
plot_type = f'Sfc-2m-KEY'

# String to pass to right-hand side label
param_str = ( f'MSLP (hPa)\n Vertically integrated moisture divergence (kg / m^-2)\n 10-meter wind barbs' )

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
# Vertical integrated moisture divergence (kg / m^-2)
#-----------------------------------------------------------------------------
# Define filled contour interval
cfill_min = -15                    # Min value
cfill_max = 15                     # Max value
cfill_int = 0.5                    # Contour interval

# Create an array of evenly-spaced values (i.e., contour values) and convert to list
cfill_interval = np.arange(cfill_min, cfill_max +
                           cfill_int, cfill_int).tolist()  


# Set attributes for plotting color-filled contours 
cfill = FilledContourPlot()                # Filled contour object
cfill.data = ds                            # Dataset
cfill.field = 'vimd'                        # Data array
cfill.scale = 1                            # Conversion scale for data array values
cfill.time = plot_time                     # Temporal coordinate
cfill.contours = cfill_interval            # Filled contour interval
cfill.colormap = 'BrBG_r'                     # Filled contour colormap
cfill.colorbar = 'horizontal'              # Colorbar location
cfill.plot_units = 'kg m^-2'                  # Plotting units

#-----------------------------------------------------------------------------
# 10 meter wind barbs (kts)
#-----------------------------------------------------------------------------
# Wind Barb skipping value
skip_val = 4

# Set attributes for wind barb plotting 
barbs = BarbPlot()                         # Wind Barb object
barbs.data = ds                            # Dataset
barbs.barblength = 5                       # Length of wind barbs
barbs.field = ['u10', 'v10']               # Vector-Component Data arrays
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
panel.left_title = (f'Tropical Storm Debby Confirmed Tornado Reports\nAugust 5-6, 2024' )               # Map title (left-hand side)
panel.area = [-82, -78, 34, 31]                                  # Plotting extent
panel.projection = 'mer'                                         # Map projection
panel.layers = ['coastline', 'land', 'ocean', 'usstates', 'borders', 'uscounties',
                loc_feat1, loc_feat2, loc_feat3, loc_feat4,
                loc_feat5, loc_feat6, loc_feat7, loc_feat8]      # Cartopy features for basemap (You will need to add more here!)
panel.layers_edgecolor = ['k', 'k']                              # Cartopy feature edge color
panel.layers_linewidth = [0.5, 0.5]                              # Cartopy feature line width
panel.plots = []                                                 # Plotting objects to render on map


#-----------------------------------------------------------------------------
# Pull everything together to generate the figure (DONT CHANGE ANYTHING BELOW HERE)
#-----------------------------------------------------------------------------
# Set figure attributes to plot our data on
pc = PanelContainer()                                            # Panel Container object
pc.size = (10, 10)                                               # Figure Size (in.)
pc.panels = [panel]                                              # Panels to add to figure
pc.show()
pc.save( f'ERA5-{time_str}-{plot_type}.png' )                    # Save figure to cwd