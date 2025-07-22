view: demographics {
  # # You can specify the table name if it's different from the view name:
  #sql_table_name: `pr-mktg-analyt-prod.ga4.demograficos` ;;

  derived_table: {
    sql: SELECT *
      FROM `pr-mktg-analyt-prod.ga4.demograficos`
      WHERE property_id = "268229233";;
  }

  dimension: demographics_primary_key {
    primary_key: yes
    sql: CONCAT(${date}, ${country}, ${hostname}, ${age}, ${gender}) ;;
    hidden: yes
  }

  dimension: date {
    type: date
    sql: TIMESTAMP(${TABLE}.date) ;;
    hidden: yes
  }

  dimension: age {
    type: string
    sql: ${TABLE}.age ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: hostname {
    type: string
    sql: ${TABLE}.hostname ;;
    hidden: yes
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
    hidden: yes
  }

  measure: sessions {
    type: sum
    sql: ${TABLE}.sessions ;;
  }

  measure: revenue {
    type: sum
    sql: ${TABLE}.revenue ;;
    value_format_name: "usd"
  }

  measure: transactions {
    type: sum
    sql: ${TABLE}.transactions ;;
  }
}
