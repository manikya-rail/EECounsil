Timezone::Lookup.config(:geonames) do |c|
	c.username = APP_CONFIG['GEONAME_USERNAME']
	c.offset_etc_zones = true
end
