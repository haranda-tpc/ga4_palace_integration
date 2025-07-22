include: "/views/*.view.lkml"
include: "/views/*/*.view.lkml"
include: "/attributes/*.lkml"

explore: sessions {
  label: "GA4 Sessions - PR"
  description: "Explores Google Analytics sessions data."

  join: audience_cohorts {
    type: left_outer
    sql_on: ${sessions.audience_trait} = ${audience_cohorts.audience_trait} ;;
    relationship: many_to_one
  }

  join: events {
    view_label: "Events"
    sql: LEFT JOIN UNNEST(${sessions.event_data}) as events with offset as event_row ;;
    relationship: one_to_many
  }

  join: event_data_items {
    view_label: "Events"
    sql: LEFT JOIN UNNEST(${events.items}) as event_data_items  ;;
    relationship: one_to_many
    required_joins: [events]
  }

  join: user_previous_session {
    view_label: "GA4 Sessions"
    sql_on: ${sessions.sl_key} = ${user_previous_session.sl_key} ;;
    relationship: one_to_one
  }

  join: user_segment {
    type: left_outer
    sql_on: ${sessions.user_pseudo_id} = ${user_segment.user_pseudo_id} ;;
    relationship: many_to_one
  }

  join: demographics {
    type: inner
    sql_on: ${sessions.session_date} = ${demographics.date}
      AND ${events.device__web_info__hostname} = ${demographics.hostname}
      AND ${events.geo__country} = ${demographics.country};;
    relationship: many_to_one
  }

  sql_always_where:
  {% if sessions.current_date_range._is_filtered %}
  {% condition sessions.current_date_range %} ${event_raw} {% endcondition %}

    {% if sessions.previous_date_range._is_filtered or sessions.compare_to._in_query %}
    {% if sessions.comparison_periods._parameter_value == "2" %}
    or
    ${event_raw} between ${period_2_start} and ${period_2_end}

    {% elsif sessions.comparison_periods._parameter_value == "3" %}
    or
    ${event_raw} between ${period_2_start} and ${period_2_end}
    or
    ${event_raw} between ${period_3_start} and ${period_3_end}


    {% elsif sessions.comparison_periods._parameter_value == "4" %}
    or
    ${event_raw} between ${period_2_start} and ${period_2_end}
    or
    ${event_raw} between ${period_3_start} and ${period_3_end}
    or
    ${event_raw} between ${period_4_start} and ${period_4_end}

    {% else %} 1 = 1
    {% endif %}
    {% endif %}
    {% else %} 1 = 1
    {% endif %};;

  # join: future_purchase_prediction {
  #   view_label: "BQML"
  #   relationship: one_to_one
  #   sql_on: ${sessions.sl_key} = ${future_purchase_prediction.sl_key} ;;
  # }
}
