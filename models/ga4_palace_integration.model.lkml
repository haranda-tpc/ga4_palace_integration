connection: "@{GA4_CONNECTION}"

label: "Google Analytics Sessions"

include: "/dashboards/*.dashboard"
include: "/explores/**/*.explore.lkml"
include: "/views/*.view.lkml"

datagroup: ga4_default_datagroup {
  sql_trigger:  SELECT FLOOR(((TIMESTAMP_DIFF(CURRENT_TIMESTAMP(),'1970-01-01 00:00:00',SECOND)) - 60*60*14)/(60*60*24));; #El valor 12 es la diferencia de horas en UTC
  max_cache_age: "1 hour"
}

persist_with: ga4_default_datagroup
