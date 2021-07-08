showHumanReadableZone = (zoneCode) ->
  if zoneCode.match(/RE|RS|RX|RT|RM/)
    zone = { type: "Residential"}
    if zoneCode.match(/RE/)
      zone.sub = "Estate"
    if zoneCode.match(/RS/)
      zone.sub = "Single Unit"
    if zoneCode.match(/RX/)
      zone.sub = "Small Lot"
    if zoneCode.match(/RT/)
      zone.sub = "Townhouse"
    if zoneCode.match(/RM/)
      zone.sub = "Mulitple Unit"
    return zone
  if zoneCode.match(/CN|CR|CO|CV|CP/)
    return "Commercial"
  if zoneCode.match(/IP|IL|IH|IS|IBT/)
    return "Industrial"
  if zoneCode.match(/OP|OC|OR|OF/)
    return "Open Space"
  if zoneCode.match(/AG|AR/)
    return "Agricultural"
  return zoneCode
findLatLng = (address) ->
  fetch("https://api.geocod.io/v1.6/geocode?q=#{address}&&api_key=e1446acd60dc479614066cd999471e7069cbe49")
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
  )
  .error((errors) ->
    document.getElementById('find-zone').innerHTML = 'Find my zone'
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
