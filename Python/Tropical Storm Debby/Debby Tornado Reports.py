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
pc.save( f'Debby Tornado Reports.png' )                          # Save figure to cwd