param parCurrentDate string = utcNow() // default output is yyyyMMddTHHmmssZ
param parYear string = utcNow('yyyy')
param parMonth string = utcNow('MM')
param parDay string = utcNow('dd')

var varCurrentDatePlusOneYear =  dateTimeToEpoch(dateTimeAdd('${parYear}-${parMonth}-${parDay}T00:00:00Z', 'P1Y'))

output outCurrentDate string = parCurrentDate
output outDateP1YEpoch int = varCurrentDatePlusOneYear
