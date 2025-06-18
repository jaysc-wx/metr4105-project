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

nc1 = 'PLvl.nc'
nc2 = 'af3e51ab5f4cda9ada4efa51de365a9a.nc'

ds1 = xr.open_dataset(nc1)
ds2 = xr.open_dataset(nc2)

# Merge both datasets
ds = xr.merge( [ds1, ds2] )

# Display the merged dataset
ds