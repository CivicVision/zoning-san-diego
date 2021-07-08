zones = {
	"RE": {
		type: "Residential",
		sub: "Estate"
	},
	"RS": {
		type: "Residential",
		sub: "Single Unit"
	},
	"RX": {
		type: "Residential",
		sub: "Small Lot"
	},
	"RT": {
		type: "Residential",
		sub: "Townhouse"
	},
	"RM": {
		type: "Residential",
		sub: "Multiple Unit"
	},
	"CN": {
		type: "Commercial",
		sub: "Neighborhood"
	},
	"CR": {
		type: "Commercial",
		sub: "Regional"
	},
	"CO": {
		type: "Commercial",
		sub: "Office"
	},
	"CV": {
		type: "Commercial",
		sub: "Visitor"
	},
	"CP": {
		type: "Commercial",
		sub: "Parking"
	},
	"CC": {
		type: "Commercial",
		sub: "Community"
	},
	"IP": {
		type: "Industrial",
		sub: ""
	},
	"IL": {
		type: "Industrial",
		sub: ""
	},
	"IH": {
		type: "Industrial",
		sub: ""
	},
	"IS": {
		type: "Industrial",
		sub: ""
	},
	"IBT": {
		type: "Industrial",
		sub: ""
	},
	"OP": {
		type: "Open Space",
		sub: ""
	},
	"OC": {
		type: "Open Space",
		sub: ""
	},
	"OR": {
		type: "Open Space",
		sub: ""
	},
	"OF": {
		type: "Open Space",
		sub: ""
	},
	"AG": {
		type: "Agricultural",
		sub: ""
	},
	"AR": {
		type: "Agricultural",
		sub: ""
	},
}
showHumanReadableZone = (zoneCode) ->
	sub = zoneCode.slice(0,2)
	return zones[sub]

findLatLng = (address) ->
  fetch("https://api.geocod.io/v1.6/geocode?q=#{address}&&api_key=#{GEOCODE_API_KEY}")
  .then( (response) ->
    response.json()
  ).then( (data) ->
    data.results[0].location
  )

findZoning = (lat, long) ->
  query = "SELECT * FROM city_zoning_sd WHERE ST_CONTAINS(the_geom,ST_SetSRID(ST_MakePoint({{long}},{{lat}}),4326))"
  sql = new cartodb.SQL({ user: 'milafrerichs' })
  sql.execute(query, { lat: lat, long: long})
  .done((data) ->
    if data.rows.length > 0
      zoneCode = data.rows[0].zone_name
      zoneHuman = showHumanReadableZone(zoneCode)
      document.getElementById('zone').innerHTML = zoneHuman.type
      document.getElementById('sub-zone').innerHTML = zoneHuman.sub
      document.getElementById('zone-code').innerHTML = zoneCode
    document.getElementById('find-zone').innerHTML = 'Find my zone'
    document.getElementById('find-zone-example').innerHTML = 'Use example'
  )
  .error((errors) ->
    document.getElementById('find-zone').innerHTML = 'Find my zone'
    document.getElementById('find-zone-example').innerHTML = 'Use example'
    alert('Somethign went wrong. Please try again.')
  )

search = (address) ->
	unless address.match(/San Diego/)
		address += ", San Diego"
	findLatLng(address).then( (coordinates) ->
		findZoning(coordinates.lat, coordinates.lng)
	)

window.onload= () ->
  document.getElementById('find-zone').addEventListener("click", (event) ->
    this.innerHTML = 'Searching ...'
    event.preventDefault()
    address = document.getElementById('address').value
    search(address)
  , false)
  document.getElementById('find-zone-example').addEventListener("click", (event) ->
    this.innerHTML = 'Searching ...'
    event.preventDefault()
    search("1200 Third Ave")
  , false)
