showHumanReadableZone = (zoneCode) ->
  if zoneCode.match(/RE|RS|RX|RT|RM/)
    return "Residential"
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
  fetch("https://search.mapzen.com/v1/search?text=#{address}&boundary.country=USA&api_key=mapzen-Rxq2xk8")
  .then( (response) ->
    response.json()
  ).then( (data) ->
    data.features[0].geometry.coordinates
  )
findZoning = (lat, long) ->
  query = "SELECT * FROM city_zoning_sd WHERE ST_CONTAINS(the_geom,ST_SetSRID(ST_MakePoint({{long}},{{lat}}),4326))"
  sql = new cartodb.SQL({ user: 'milafrerichs' })
  sql.execute(query, { lat: lat, long: long})
  .done((data) ->
    console.log(data)
    if data.rows.length > 0
      document.getElementById('zone').innerHTML = showHumanReadableZone(data.rows[0].zone_name)
  )
  .error((errors) ->
    console.log("errors:" + errors)
  )
window.onload= () ->
  document.getElementById('find-zone').addEventListener("click", (event) ->
    event.preventDefault()
    address = document.getElementById('address').value
    unless address.match(/San Diego/)
      address += ", San Diego"
    findLatLng(address).then( (coordinates) ->
      findZoning(coordinates[1], coordinates[0])
    )
  , false)
