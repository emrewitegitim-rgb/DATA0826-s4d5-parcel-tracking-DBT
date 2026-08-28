With agg_pp AS (
    select
        parcel_id
        , Count(*) as nb_model
        , SUM(quantity) as qty
    FROM {{ ref('stg_raw__parcel_product')}}
    GROUP BY parcel_id
)

select
    p.*
    , EXTRACT(MONTH FROM date_purchase) AS month_purchase
    , CASE 
        WHEN date_cancelled is not null THEN '4 - Cancelled'
        WHEN date_delivery is not null THEN '3 - Delivered'
        WHEN date_shipping is not null THEN '2 - Shipped'
        WHEN date_purchase is not null THEN '1 - In Progress'
        ELSE NULL
      END AS status
    , DATE_DIFF(date_shipping, date_purchase, DAY) as expedition_time
    , DATE_DIFF(date_delivery, date_shipping, DAY) as transport_time
    , DATE_DIFF(date_delivery, date_purchase, DAY) as delivery_time
    , IF(DATE_DIFF(date_delivery, date_purchase, DAY)>5, (DATE_DIFF(date_delivery, date_purchase, DAY)-5), NULL) AS delay
    , app.qty
    , app.nb_model
FROM {{ ref("stg_raw__parcel")}} as p
JOIN agg_pp as app
    ON p.parcel_id = app.parcel_id
