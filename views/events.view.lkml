## PURPOSE: This view is for a convenient location to define dimensions and measures sourced from the event_data element in sessions.
## Event_Data represents the source event level rows from the GA Export Dataset.
## The following views are defined in this file:
##   - event_data
##   - event_data_event_params
##   - event_data_user_properties
##   - goals
##   - page_data
##   - event_path

include: "event_data_dimensions/*.view"

view: events {
  extends: [event_data_event_params, event_data_user_properties, goals, page_data, event_path]

## Custom Dimensions

  dimension: pr_channeling {
    type: string
    sql:
       CASE
          -- Direct
          WHEN ${traffic_source__source} = '(direct)'
            THEN 'Direct'
          -- Consumer Sites
          WHEN REGEXP_CONTAINS(${traffic_source__source}, r"((www|cancun|los-cabos|thegrand|jamaica|beach|sun|cozumel|playacar)\.|)(thepalacecompany|palaceresorts|moonpalace|moonpalacecancun|leblancsparesorts)\.com") = true
            THEN 'Consumer Sites'
          -- Baglioni Hotels Sites
          WHEN REGEXP_CONTAINS(${traffic_source__source}, r"((www|sardinia|puglia|london|rome|venice|florence|milan|maldives)\.|)baglionihotels\.com") = true
            THEN 'Baglioni Hotels Sites'
          -- Bookings Sites
          WHEN REGEXP_CONTAINS(${traffic_source__source}, r"(online|)(bookings|paquetes|packages|manage-reservation)(cancun|nizuc|thegrand|jamaica|cabo|beach|cozumel|playadelcarmen|sun|pr|florence|london|maldives|milan|puglia|rome|venice|sardinia|)(pr|)\.(baglionihotels|palaceresorts|moonpalace|leblancsparesorts)\.com") = true
           THEN 'Consumer Bookings'
          -- Segment Sites
          WHEN REGEXP_CONTAINS(${traffic_source__source}, r"(weddings|meetings|mvg|transfers|productions|globalsales|golf)\.(palaceresorts|thepalacecompany)\.com|(www\.|fixed\.|portal\.|)(fundacionpalace|palaceelite|palaceproagents)\.(com|org)") = true
            THEN 'Segment Sites'
          -- OTAs
          WHEN REGEXP_CONTAINS(${traffic_source__source}, r"expedia|booking\.com|tripadvisor\.") = true
            AND ${traffic_source__medium} != 'metasearch'
              THEN 'OTAs'
          -- Social Media
          WHEN REGEXP_CONTAINS(${traffic_source__source}, r"facebook|instagram|twitter|pinterest|linkedin|tiktok|youtube|lnk") = true
            AND REGEXP_CONTAINS(${traffic_source__medium}, r"referral|social") = true
              THEN 'Social Media'
          --Asksuite
          WHEN REGEXP_CONTAINS(${traffic_source__source}, r"asksuite") = true
           THEN "Asksuite"
          -- SEM
          WHEN REGEXP_CONTAINS(${traffic_source__source}, r"google|bing|yahoo|youtube|adwords|unlinked SA360") = true
           AND REGEXP_CONTAINS(${traffic_source__medium}, r"cpc|ppc|video|unlinked SA360") = true
              THEN "SEM"
          -- Paid Social Media
          WHEN REGEXP_CONTAINS(${traffic_source__source}, r"facebook|instagram|twitter|pinterest|linkedin|tiktok|x") = true
           AND REGEXP_CONTAINS(${traffic_source__medium}, r"display|paid") = true
              THEN 'Paid Social Media'
          -- Platform Self Service
          WHEN REGEXP_CONTAINS(${traffic_source__source}, r"google-my-business|gmb|tripadvisor-bl|tripadvisorbl|tripadvisor-adexpress") = true
           AND REGEXP_CONTAINS(${traffic_source__medium}, r"display|organic") = true
             THEN "Platform Self Service"
          -- Medios Externos
          WHEN REGEXP_CONTAINS(${traffic_source__source}, r"quantcast|criteo|rtb-house|sojern|groovinads|palace-app|teads|illumin|priceline|centurion|centurion-departures|ekn|trivago|vidoomy|mosaic-media|seedtag|rtbhouse|groovin-ads|arkeero|cybba|epsilon|Cybba Inc\.|logan|travelpulse|quancast|amadeus") = true
           THEN 'Medios Externos'
          -- DSP
          WHEN REGEXP_CONTAINS(${traffic_source__source}, r"safeframe.googlesyndication.com") = true
            OR REGEXP_CONTAINS(${traffic_source__medium}, r"cpm|display") = true
              THEN "DSP"
          -- Metasearch
          WHEN REGEXP_CONTAINS(${traffic_source__medium}, r"metasearch|sponsored") =true
            OR REGEXP_CONTAINS(${traffic_source__source}, r"tripadvisor|hotelfinder") = true
              THEN 'Metasearch'
          -- SEO
          WHEN ${traffic_source__medium} = 'organic'
            THEN 'SEO'
          -- Inbound
          WHEN REGEXP_CONTAINS(${traffic_source__source}, r"inbound|hubspot") = true
           AND ${traffic_source__medium} LIKE '%email%'
              THEN 'Inbound'
          -- Curacity
          WHEN ${traffic_source__source} = 'curacity'
            AND ${traffic_source__medium} LIKE '%email%'
              THEN 'Curacity'
          -- Onsite Message
          WHEN ${traffic_source__medium} = 'message'
            THEN 'Onsite Message'
          -- Affiliates
          WHEN ${traffic_source__medium} = 'affiliate'
            THEN 'Affiliates'
          --Referral/Otros
          WHEN ${traffic_source__medium} = 'referral'
            THEN 'Referral External Sites '
              ELSE 'Otros'
          END
      ;;
  }

  dimension: tipo_de_sitio {
    type: string
    sql:
    CASE
      WHEN ${device__web_info__hostname} LIKE '%reservhotel.com'
        OR ${device__web_info__hostname} LIKE 'packages%'
      THEN 'Reservhotel'

      WHEN ${device__web_info__hostname} LIKE '%booking%' THEN 'CLEVER'

      WHEN (${device__web_info__hostname} LIKE '%palaceresorts.com'
      OR ${device__web_info__hostname} LIKE '%moonpalace.com'
      OR ${device__web_info__hostname} LIKE '%moonpalacecancun.com'
      OR ${device__web_info__hostname} LIKE '%leblancsparesorts.com')
      AND ${device__web_info__hostname} NOT LIKE '%booking%'
      THEN 'Contenido'
      END
      ;;
  }

  dimension: propiedad {
    type: string
    sql:
    CASE
      WHEN ${device__web_info__hostname} IN ("www.palaceresorts.com","palaceresorts.com","onlinebookingspr.palaceresorts.com","onlinebookingspaypr.palaceresorts.com")
      THEN "Palace Resorts Brand"

      WHEN ${device__web_info__hostname} IN ("beach.palaceresorts.com","bookingsbeachpr.palaceresorts.com","bookingsbeachpaypr.palaceresorts.com")
      OR ${hotel_name_reservhotel} = "10444"
      THEN "Beach Palace"

      WHEN ${device__web_info__hostname} IN ("cozumel.palaceresorts.com","bookingscozumelpr.palaceresorts.com","bookingscozumelpaypr.palaceresorts.com")
      OR ${hotel_name_reservhotel} = "10445"
      THEN "Cozumel Palace"

      WHEN ${device__web_info__hostname} IN ("playacar.palaceresorts.com","bookingsplayadelcarmenpr.palaceresorts.com","bookingsplayadelcarmenpaypr.palaceresorts.com")
      OR ${hotel_name_reservhotel} = "10449"
      THEN "Playacar Palace"

      WHEN ${device__web_info__hostname} IN ("sun.palaceresorts.com","bookingssunpr.palaceresorts.com","bookingssunpaypr.palaceresorts.com")
      OR ${hotel_name_reservhotel} = "10450"
      THEN "Sun Palace"

      WHEN ${device__web_info__hostname} IN ("www.moonpalace.com","moonpalace.com","onlinebookingspr.moonpalace.com","onlinebookingspaypr.moonpalace.com")
      THEN "Moon Palace Brand"

      WHEN ${device__web_info__hostname} IN ("www.moonpalacecancun.com","moonpalacecancun.com","bookingscancunpr.moonpalace.com","bookingsnizucpr.moonpalace.com","bookingsnizucpaypr.moonpalace.com")
      OR ${hotel_name_reservhotel} IN ("10443","10740")
      THEN "Moon Palace Cancun"

      WHEN ${device__web_info__hostname} IN ("jamaica.moonpalace.com","bookingsjamaicapr.moonpalace.com","bookingsjamaicapaypr.moonpalace.com")
      OR ${hotel_name_reservhotel} = "10448"
      THEN "Moon Palace Jamaica"

      WHEN ${device__web_info__hostname} IN ("thegrand.moonpalace.com","bookingsthegrandpr.moonpalace.com","bookingsthegrandpaypr.moonpalace.com")
      OR ${hotel_name_reservhotel} = "10451"
      THEN "Moon Palace The Grand"

      WHEN ${device__web_info__hostname} IN ("www.leblancsparesorts.com","leblancsparesorts.com","onlinebookingspr.leblancsparesorts.com","onlinebookingspaypr.leblancsparesorts.com")
      THEN "Le Blanc Brand"

      WHEN ${device__web_info__hostname} IN ("cancun.leblancsparesorts.com","bookingscancunpr.leblancsparesorts.com","bookingscancunpaypr.leblancsparesorts.com")
      OR ${hotel_name_reservhotel} = "10447"
      THEN "Le Blanc Cancun"

      WHEN ${device__web_info__hostname} IN ("los-cabos.leblancsparesorts.com","bookingscabopr.leblancsparesorts.com","bookingscabopaypr.leblancsparesorts.com")
      OR ${hotel_name_reservhotel} = "10457"
      THEN "Le Blanc Los Cabos"
      END
      ;;
  }

  dimension: propiedad_motor {
    type: string
    sql:
    CASE
      WHEN UPPER(${hotel_name_clever}) LIKE "%BEACH PALACE%"
        THEN "Beach Palace"
      WHEN UPPER(${hotel_name_clever}) LIKE "%COZUMEL PALACE%"
        THEN "Cozumel Palace"
      WHEN UPPER(${hotel_name_clever}) LIKE "%LE BLANC SPA RESORT CANCUN%"
        THEN "Le Blanc Cancun"
      WHEN UPPER(${hotel_name_clever}) LIKE "%LE BLANC SPA RESORT LOS CABOS%"
        THEN "Le Blanc Los Cabos"
      WHEN UPPER(${hotel_name_clever}) LIKE "%MOON PALACE CANCUN%"
        OR UPPER(${hotel_name_clever}) LIKE "%MOON PALACE SUNRISE%"
          THEN "Moon Palace Cancun"
      WHEN UPPER(${hotel_name_clever}) LIKE "%MOON PALACE NIZUC%"
          THEN "Moon Palace Nizuc"
      WHEN UPPER(${hotel_name_clever}) LIKE "%MOON PALACE JAMAICA%"
        THEN "Moon Palace Jamaica"
      WHEN UPPER(${hotel_name_clever}) LIKE "%MOON PALACE THE GRAND%"
        THEN "Moon Palace The Grand"
      WHEN UPPER(${hotel_name_clever}) LIKE "%PLAYACAR PALACE%"
        THEN "Playacar Palace"
      WHEN UPPER(${hotel_name_clever}) LIKE "%SUN PALACE%"
        THEN "Sun Palace"
    END
  ;;
  }

  dimension: marca_motor {
    type: string
    sql:
    CASE
      WHEN ${propiedad_motor} IN ("Beach Palace","Cozumel Palace","Playacar Palace","Sun Palace")
        THEN "Palace Resorts"
      WHEN ${propiedad_motor} IN ("Le Blanc Cancun","Le Blanc Los Cabos")
        THEN "Le Blanc"
      WHEN ${propiedad_motor} IN ("Moon Palace Cancun","Moon Palace Jamaica","Moon Palace The Grand")
        THEN "Moon Palace"
    END
  ;;
  }

  dimension: mercado {
    type: string
    sql:
    CASE
        -- US
        WHEN REGEXP_CONTAINS(${geo__country}, r"United States|U.S. Virgin Islands")=true
          THEN 'US'
        -- MX
        WHEN ${geo__country} = 'Mexico'
          THEN 'MX'
        -- CA
        WHEN ${geo__country} = 'Canada'
          THEN 'CA'
        -- LAT
         WHEN REGEXP_CONTAINS(${geo__sub_continent}, r"South America|Central America") = true
         AND NOT ${geo__country} LIKE 'Mexico'
            THEN 'LATAM'
        -- IT
        WHEN ${geo__country} = 'Italy'
          THEN 'IT'
        -- UK
        WHEN ${geo__country} = 'United Kingdom'
          THEN 'UK'
        -- EU
        WHEN REGEXP_CONTAINS(${geo__continent}, r"Europe") = true
         AND NOT REGEXP_CONTAINS(${geo__country}, r"United Kingdom|Italy")=true
            THEN 'EU'
            ELSE 'ROW'
      END;;
  }

  dimension: hotel_name_clever {
    type: string
    sql: (SELECT value.string_value FROM UNNEST(event_params) WHERE key = "hotel_name") ;;
  }

  dimension: hotel_name_reservhotel {
    type: string
    sql: CAST((SELECT value.int_value FROM UNNEST(event_params) WHERE key = "hotel_name") AS string) ;;
  }

  dimension: number_of_nights {
    type: number
    sql: (SELECT value.int_value FROM UNNEST(event_params) WHERE key = "nights") ;;
  }

  dimension: number_of_rooms {
    type: number
    sql: (SELECT value.int_value FROM UNNEST(event_params) WHERE key = "number_of_rooms") ;;
  }

  dimension: room_nights {
    type: number
    sql: ${number_of_nights} * ${number_of_rooms} ;;
  }

  measure: sum_of_nights {
    type: sum
    sql: ${number_of_nights} ;;
  }

  measure: sum_of_rooms {
    type: sum
    sql: ${number_of_rooms} ;;
  }

  measure: sum_of_room_nights {
    type: sum
    sql: ${room_nights} ;;
  }

  dimension: marca {
    type: string
    sql:
    CASE
      WHEN ${device__web_info__hostname} LIKE '%palaceresorts.com' THEN 'Palace Resorts'
      WHEN ${device__web_info__hostname} LIKE '%moonpalace.com' OR ${device__web_info__hostname} LIKE '%moonpalacecancun.com' THEN 'Moon Palace'
      WHEN ${device__web_info__hostname} LIKE '%leblancsparesorts.com' THEN 'Le Blanc'
      ELSE 'Otros'
    END;;
  }

## Dimensions

  dimension: ed_key {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${sl_key}||${event_rank} ;;
  }

  dimension: sl_key {
    type: string
    hidden: yes
    sql: ${TABLE}.sl_key ;;
  }

  dimension: event_rank {
    label: "Event Rank"
    type: number
    sql: ${TABLE}.event_rank ;;
    description: "Event Rank in Session, 1st Event = Event Rank 1."
    full_suggestions: yes
  }

  dimension: reverse_event_rank {
    label: "Reverse Event Rank"
    type: number
    sql: ${TABLE}.reverse_event_rank ;;
    description: "Reverse Event Rank in Session. Last Event = Reverse Event Rank 1."
    full_suggestions: yes
  }

  # dimension_group: event {
  #   label: "Event"
  #   type: time
  #   timeframes: [date,day_of_month,day_of_week,day_of_week_index,day_of_year,month,month_name,month_num,fiscal_quarter,fiscal_quarter_of_year,year]
  #   sql: ${TABLE}.event_date ;;
  # }

  dimension_group: event_time {
    type: time
    timeframes: [date,day_of_month,day_of_week,day_of_week_index,day_of_year,month,month_name,month_num,fiscal_quarter,fiscal_quarter_of_year,year,time,hour,hour_of_day]
    label: "Event"
    sql: TIMESTAMP_MICROS(${TABLE}.event_timestamp) ;;
    description: "Event Date/Time from Event Timestamp."
  }

  dimension: event_timestamp { hidden: yes sql: ${TABLE}.event_timestamp ;; }

  dimension: time_to_next_event {
    label: "Time on Event"
    description: "Time user spent on Event, measured as duration from event to the subsequent event."
    sql: ${TABLE}.time_to_next_event ;;
    type: number
    value_format_name: hour_format
  }

  dimension: event_name {
    label: "Event Name"
    type: string
    sql: ${TABLE}.event_name ;;
    full_suggestions: yes
  }

  dimension: full_event {
    view_label: "Behavior"
    ## Customize with your specific event parameters that encompass the specific points of interest in your event.
    type: string
    sql: ${event_name}||': '||coalesce(${events.event_param_page},"") ;;
    full_suggestions: yes
  }

  dimension: event_bundle_sequence_id {
    type: number
    sql: ${TABLE}.event_bundle_sequence_id ;;
    full_suggestions: yes
  }

  dimension: event_dimensions__hostname {
    type: string
    sql: ${TABLE}.event_dimensions.hostname ;;
    group_label: "Event Dimensions"
    group_item_label: "Hostname"
    full_suggestions: yes
  }

  dimension: event_previous_timestamp {
    type: number
    sql: ${TABLE}.event_previous_timestamp ;;
    full_suggestions: yes
  }

  dimension: event_server_timestamp_offset {
    type: number
    sql: ${TABLE}.event_server_timestamp_offset ;;
    full_suggestions: yes
  }

  dimension: event_value_in_usd {
    type: number
    sql: ${TABLE}.event_value_in_usd ;;
    full_suggestions: yes
  }

  dimension: items {
    hidden: yes
    sql: ${TABLE}.items ;;
    ## This is the parent dimension for the items fields within the event_data_items view.
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
    full_suggestions: yes
  }
  dimension: stream_id {
    type: string
    sql: ${TABLE}.stream_id ;;
    full_suggestions: yes
  }

  ## App Info Fields
  dimension: app_info__firebase_app_id {
    type: string
    sql: ${TABLE}.app_info.firebase_app_id ;;
    full_suggestions: yes
    group_label: "App Info"
    group_item_label: "Firebase App ID"
  }

  dimension: app_info__id {
    type: string
    sql: ${TABLE}.app_info.id ;;
    full_suggestions: yes
    group_label: "App Info"
    group_item_label: "ID"
  }

  dimension: app_info__install_source {
    type: string
    sql: ${TABLE}.app_info.install_source ;;
    full_suggestions: yes
    group_label: "App Info"
    group_item_label: "Install Source"
  }

  dimension: app_info__install_store {
    type: string
    sql: ${TABLE}.app_info.install_store ;;
    full_suggestions: yes
    group_label: "App Info"
    group_item_label: "Install Store"
  }

  dimension: app_info__version {
    type: string
    sql: ${TABLE}.app_info.version ;;
    full_suggestions: yes
    group_label: "App Info"
    group_item_label: "Version"
  }


  ## Device Fields
  dimension: device__advertising_id {
    type: string
    sql: ${TABLE}.device.advertising_id ;;
    full_suggestions: yes
    group_label: "Device"
    group_item_label: "Advertising ID"
  }

  dimension: device__browser {
    type: string
    sql: ${TABLE}.device.browser ;;
    full_suggestions: yes
    group_label: "Device"
    group_item_label: "Browser"
  }

  dimension: device__browser_version {
    type: string
    sql: ${TABLE}.device.browser_version ;;
    full_suggestions: yes
    group_label: "Device"
    group_item_label: "Browser Version"
  }

  dimension: device__category {
    type: string
    sql: ${TABLE}.device.category ;;
    full_suggestions: yes
    group_label: "Device"
    group_item_label: "Category"
  }

  dimension: device__is_limited_ad_tracking {
    type: string
    sql: ${TABLE}.device.is_limited_ad_tracking ;;
    full_suggestions: yes
    group_label: "Device"
    group_item_label: "Is Limited Ad Tracking"
  }

  dimension: device__language {
    type: string
    sql: ${TABLE}.device.language ;;
    full_suggestions: yes
    group_label: "Device"
    group_item_label: "Language"
  }

  dimension: device__mobile_brand_name {
    type: string
    sql: ${TABLE}.device.mobile_brand_name ;;
    full_suggestions: yes
    group_label: "Device"
    group_item_label: "Mobile Brand Name"
  }

  dimension: device__mobile_marketing_name {
    type: string
    sql: ${TABLE}.device.mobile_marketing_name ;;
    full_suggestions: yes
    group_label: "Device"
    group_item_label: "Mobile Marketing Name"
  }

  dimension: device__mobile_model_name {
    type: string
    sql: ${TABLE}.device.mobile_model_name ;;
    full_suggestions: yes
    group_label: "Device"
    group_item_label: "Mobile Model Name"
  }

  dimension: device__mobile_os_hardware_model {
    type: string
    sql: ${TABLE}.device.mobile_os_hardware_model ;;
    full_suggestions: yes
    group_label: "Device"
    group_item_label: "Mobile OS Hardware Model"
  }

  dimension: device__operating_system {
    type: string
    sql: ${TABLE}.device.operating_system ;;
    full_suggestions: yes
    group_label: "Device"
    group_item_label: "Operating System"
  }

  dimension: device__operating_system_version {
    type: string
    sql: ${TABLE}.device.operating_system_version ;;
    full_suggestions: yes
    group_label: "Device"
    group_item_label: "Operating System Version"
  }

  dimension: device__time_zone_offset_seconds {
    type: number
    sql: ${TABLE}.device.time_zone_offset_seconds ;;
    group_label: "Device"
    group_item_label: "Time Zone Offset Seconds"
  }

  dimension: device__vendor_id {
    type: string
    sql: ${TABLE}.device.vendor_id ;;
    full_suggestions: yes
    group_label: "Device"
    group_item_label: "Vendor ID"
  }

  dimension: device__web_info__browser {
    type: string
    sql: ${TABLE}.device.web_info.browser ;;
    full_suggestions: yes
    group_label: "Device Web Info"
    group_item_label: "Browser"
  }

  dimension: device__web_info__browser_version {
    type: string
    sql: ${TABLE}.device.web_info.browser_version ;;
    full_suggestions: yes
    group_label: "Device Web Info"
    group_item_label: "Browser Version"
  }

  dimension: device__web_info__hostname {
    type: string
    sql: ${TABLE}.device.web_info.hostname ;;
    full_suggestions: yes
    group_label: "Device Web Info"
    group_item_label: "Hostname"
  }


  ## ECommerce Fields

  dimension: purchase_promo_code {
    type: string
    sql: (SELECT value.string_value FROM UNNEST(event_params) WHERE key = "coupon") ;;
    group_label: "Ecommerce"
  }

  dimension: ecommerce__purchase_revenue {
    type: number
    sql: ${TABLE}.ecommerce.purchase_revenue ;;
    group_label: "Ecommerce"
    group_item_label: "Purchase Revenue"
    value_format_name: usd
  }

  dimension: ecommerce__purchase_revenue_in_usd {
    type: number
    sql: ${TABLE}.ecommerce.purchase_revenue_in_usd ;;
    group_label: "Ecommerce"
    group_item_label: "Purchase Revenue In USD"
    value_format_name: usd
  }

  dimension: ecommerce__refund_value {
    type: number
    sql: ${TABLE}.ecommerce.refund_value ;;
    group_label: "Ecommerce"
    group_item_label: "Refund Value"
    value_format_name: usd
  }

  dimension: ecommerce__refund_value_in_usd {
    type: number
    sql: ${TABLE}.ecommerce.refund_value_in_usd ;;
    group_label: "Ecommerce"
    group_item_label: "Refund Value In USD"
    value_format_name: usd
  }

  dimension: ecommerce__shipping_value {
    type: number
    sql: ${TABLE}.ecommerce.shipping_value ;;
    group_label: "Ecommerce"
    group_item_label: "Shipping Value"
    value_format_name: usd
  }

  dimension: ecommerce__shipping_value_in_usd {
    type: number
    sql: ${TABLE}.ecommerce.shipping_value_in_usd ;;
    group_label: "Ecommerce"
    group_item_label: "Shipping Value In USD"
    value_format_name: usd
  }

  dimension: ecommerce__tax_value {
    type: number
    sql: ${TABLE}.ecommerce.tax_value ;;
    group_label: "Ecommerce"
    group_item_label: "Tax Value"
    value_format_name: usd
  }

  dimension: ecommerce__tax_value_in_usd {
    type: number
    sql: ${TABLE}.ecommerce.tax_value_in_usd ;;
    group_label: "Ecommerce"
    group_item_label: "Tax Value In USD"
    value_format_name: usd
  }

  dimension: ecommerce__total_item_quantity {
    type: number
    sql: ${TABLE}.ecommerce.total_item_quantity ;;
    group_label: "Ecommerce"
    group_item_label: "Total Item Quantity"
    value_format_name: decimal_0
  }

  dimension: ecommerce__transaction_id {
    type: string
    sql: ${TABLE}.ecommerce.transaction_id ;;
    full_suggestions: yes
    group_label: "Ecommerce"
    group_item_label: "Transaction ID"
  }

  dimension: ecommerce__unique_items {
    type: number
    sql: ${TABLE}.ecommerce.unique_items ;;
    group_label: "Ecommerce"
    group_item_label: "Unique Items"
    value_format_name: decimal_0
  }


  ## Geo Fields
  dimension: geo__city {
    type: string
    sql: ${TABLE}.geo.city ;;
    full_suggestions: yes
    group_label: "Geo"
    group_item_label: "City"
  }

  dimension: geo__continent {
    type: string
    sql: ${TABLE}.geo.continent ;;
    full_suggestions: yes
    group_label: "Geo"
    group_item_label: "Continent"
  }

  dimension: geo__country {
    type: string
    sql: ${TABLE}.geo.country ;;
    full_suggestions: yes
    group_label: "Geo"
    group_item_label: "Country"
    map_layer_name: countries
  }

  dimension: geo__metro {
    type: string
    sql: ${TABLE}.geo.metro ;;
    full_suggestions: yes
    group_label: "Geo"
    group_item_label: "Metro"
  }

  dimension: geo__region {
    type: string
    sql: ${TABLE}.geo.region ;;
    full_suggestions: yes
    group_label: "Geo"
    group_item_label: "Region"
    map_layer_name: us_states
  }

  dimension: geo__sub_continent {
    type: string
    sql: ${TABLE}.geo.sub_continent ;;
    full_suggestions: yes
    group_label: "Geo"
    group_item_label: "Sub Continent"
  }


  ## Traffic Source Fields
  dimension: traffic_source__medium {
    view_label: "Acquisition"
    type: string
    sql: ${TABLE}.traffic_source.medium ;;
    full_suggestions: yes
    group_label: "User Traffic Source"
    group_item_label: "Medium"
    description: "The medium of the traffic source for the user's original first visit (Saved up to 1 Year by Default)."
  }

  dimension: traffic_source__name {
    view_label: "Acquisition"
    type: string
    sql: ${TABLE}.traffic_source.name ;;
    full_suggestions: yes
    group_label: "User Traffic Source"
    description: "The name of the traffic source for the user's original first visit (Saved up to 1 Year by Default)."
    group_item_label: "Name"
  }

  dimension: traffic_source__source {
    view_label: "Acquisition"
    type: string
    sql: ${TABLE}.traffic_source.source ;;
    full_suggestions: yes
    group_label: "User Traffic Source"
    group_item_label: "Source"
    description: "The source of the traffic source for the user's original first visit (Saved up to 1 Year by Default)."
  }


  ## User Fields
  dimension: user_first_touch_timestamp {
    type: number
    sql: ${TABLE}.user_first_touch_timestamp ;;
  }

  dimension: user_ltv__currency {
    type: string
    sql: ${TABLE}.user_ltv.currency ;;
    full_suggestions: yes
    group_label: "User Ltv"
    group_item_label: "Currency"
  }

  dimension: user_ltv__revenue {
    type: number
    sql: ${TABLE}.user_ltv.revenue ;;
    group_label: "User Ltv"
    group_item_label: "Revenue"
  }

  dimension: user_properties {
    hidden: yes
    sql: ${TABLE}.user_properties ;;
  }

  dimension: user_pseudo_id {
    type: string
    sql: ${TABLE}.user_pseudo_id ;;
    full_suggestions: yes
  }

  # dimension: user_id

## Measures

  measure: total_events {
    view_label: "Behavior"
    group_label: "Events"
    description: "The total number of events for the session."
    type: count
    # view_label: "Metrics"
    # group_label: "Event Data"
    # label: "Total Events"
  }

  measure: total_unique_events {
    view_label: "Behavior"
    group_label: "Events"
    label: "Unique Events"
    description: "Total Unique Events (Unique by Full Event Definition)"
    #description: "Unique Events are interactions with content by a single user within a single session that can be tracked separately from pageviews or screenviews. "
    type: count_distinct
    sql: ${sl_key} ;;
  }


  measure: total_page_views {
    # view_label: "Metrics"
    # group_label: "Event Data"
    # label: "Total Page Views"
    view_label: "Behavior"
    group_label: "Pages"
    label: "Pageviews"
    description: "The total number of pageviews for the property."
    type: count
    filters: [event_name: "page_view"]
    value_format_name: formatted_number
  }

  measure: total_unique_page_views {
    # view_label: "Metrics"
    # group_label: "Event Data"
    # label: "Total Unique Page Views"
    view_label: "Behavior"
    group_label: "Pages"
    label: "Unique Pageviews"
    description: "Unique Pageviews are the number of sessions during which the specified page was viewed at least once. A unique pageview is counted for each page URL + page title combination."
    type: count_distinct
    sql: CONCAT(${event_param_ga_session_id}, ${event_param_page}, ${event_param_page_title}) ;;
    value_format_name: formatted_number
    filters: [event_name: "page_view"]
  }

  measure: total_engaged_events {
    type: count_distinct
    view_label: "Behavior"
    group_label: "Events"
    label: "Engaged Events"
    #description: ""
    filters: [event_param_engaged_session_event: ">0"]
  }

  ## ECommerce

  measure: total_transactions {
    group_label: "Ecommerce"
    label: "Transactions"
    type: count_distinct
    sql: ${ecommerce__transaction_id} ;;
    filters: [ecommerce__transaction_id: "-(not set)"]
  }

  measure: transaction_revenue_per_user {
    group_label: "Ecommerce"
    type: number
    sql: 1.0 * (${total_purchase_revenue}/NULLIF(${sessions.total_users},0)) ;;
    value_format_name: usd
  }

  measure: transaction_conversion_rate {
    group_label: "Ecommerce"
    label: "Transaction Conversion Rate"
    type: number
    sql: 1.0 * (${total_transactions}/NULLIF(${sessions.total_sessions},0)) ;;
    value_format_name: percent_2
  }

  measure: total_purchase_revenue {
    group_label: "Ecommerce"
    label: "Purchase Revenue"
    type: sum_distinct
    sql: ${ecommerce__purchase_revenue} ;;
    sql_distinct_key: ${ecommerce__transaction_id} ;;
    value_format_name: usd
  }

  measure: total_purchase_revenue_usd {
    group_label: "Ecommerce"
    label: "Purchase Revenue (USD)"
    type: sum
    sql: ${ecommerce__purchase_revenue_in_usd} ;;
    # sql_distinct_key: ${ecommerce__transaction_id} ;;
    value_format_name: usd
  }

  measure: purchase_revenue_usd_25p {
    group_label: "Ecommerce"
    label: "Purchase Revenue (USD) 25th Percentile"
    type: percentile
    percentile: 25
    sql: ${ecommerce__purchase_revenue_in_usd} ;;
    value_format_name: usd
  }

  measure: purchase_revenue_usd_75p {
    group_label: "Ecommerce"
    label: "Purchase Revenue (USD) 75th Percentile"
    type: percentile
    percentile: 75
    sql: ${ecommerce__purchase_revenue_in_usd} ;;
    value_format_name: usd
  }

  measure: total_refund_value {
    group_label: "Ecommerce"
    label: "Refund Value"
    type: sum_distinct
    sql: ${ecommerce__refund_value} ;;
    sql_distinct_key: ${ecommerce__transaction_id} ;;
    value_format_name: usd
  }

  measure: total_refund_value_usd {
    group_label: "Ecommerce"
    label: "Refund Value (USD)"
    type: sum_distinct
    sql: ${ecommerce__refund_value_in_usd} ;;
    sql_distinct_key: ${ecommerce__transaction_id} ;;
    value_format_name: usd
  }

  measure: total_shipping_value {
    group_label: "Ecommerce"
    label: "Shipping Value"
    type: sum_distinct
    sql: ${ecommerce__shipping_value} ;;
    sql_distinct_key: ${ecommerce__transaction_id} ;;
    value_format_name: usd
  }

  measure: total_shipping_value_usd {
    group_label: "Ecommerce"
    label: "Shipping Value (USD)"
    type: sum_distinct
    sql: ${ecommerce__shipping_value_in_usd} ;;
    sql_distinct_key: ${ecommerce__transaction_id} ;;
    value_format_name: usd
  }

  measure: total_tax_value {
    group_label: "Ecommerce"
    label: "Tax Value"
    type: sum_distinct
    sql: ${ecommerce__tax_value} ;;
    sql_distinct_key: ${ecommerce__transaction_id} ;;
    value_format_name: usd
  }

  measure: total_tax_value_usd {
    group_label: "Ecommerce"
    label: "Tax Value (USD)"
    type: sum_distinct
    sql: ${ecommerce__tax_value_in_usd} ;;
    sql_distinct_key: ${ecommerce__transaction_id} ;;
    value_format_name: usd
  }

  measure: total_item_quantity {
    group_label: "Ecommerce"
    label: "Transaction Items"
    type: sum_distinct
    sql: ${ecommerce__total_item_quantity} ;;
    sql_distinct_key: ${ecommerce__transaction_id} ;;
    value_format_name: decimal_0
  }

  measure: total_unique_items {
    group_label: "Ecommerce"
    label: "Unique Items"
    type: sum_distinct
    sql: ${ecommerce__unique_items} ;;
    sql_distinct_key: ${ecommerce__transaction_id} ;;
    value_format_name: decimal_0
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      event_name,
      traffic_source__name,
      device__mobile_model_name,
      device__mobile_brand_name,
      device__web_info__hostname,
      event_dimensions__hostname,
      device__mobile_marketing_name
    ]
  }
}
