import pandas as pd

simple_maps = pd.read_csv('simplemaps-worldcities-basic.csv')
german = simple_maps['iso2'] == 'DE'
simple_maps = simple_maps[german]
simple_maps = simple_maps[['city', 'lat', 'lng']]
simple_maps.to_csv('german-cities.csv', index=False)
