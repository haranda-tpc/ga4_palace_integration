
## Connection Constants:
constant: GA4_CONNECTION {
  value: "pr-mktg-analyt-bq-conn-analytics"
  export: override_required
}

constant: GA4_SCHEMA {
  value: "pr-mktg-analyt-prod.analytics_268229233"
  export: override_required
}

constant: GA4_TABLE_VARIABLE {
  value: "events_*"
  export: override_required
}

constant: EVENT_COUNT {
  value: ""
  export: override_optional
}
constant: model_step_prediction {
  value: "60"
  #export: override_optional
}
constant: BQML_PARAMETER {
  value: "Yes"
  export: override_optional
}

constant: GA4_BQML_train_months {
  value: "12"
  # export: override_optional
}

constant: GA4_BQML_test_months {
  value: "3"
  # export: override_optional
}

constant: GA4_BQML_future_synth_months {
  value: "12"
  # export: override_optional
}
