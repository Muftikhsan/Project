with
tmp as (
    select
        date_part('year', o.order_purchase_timestamp) as year,
        op.payment_type,
        count(1) as num_used
    from payments_dataset op
    join orders_dataset o on o.order_id = op.order_id
    group by 1,2   
)

select *,
    case when year_2017 = 0 then NULL
        else round((year_2018 - year_2017) / year_2017,2)
    end as pct_change_2017_2018
from (
    select
        payment_type,
        sum(case when year = '2016' then num_used else 0 end) as year_2016,
        sum(case when year = '2017' then num_used else 0 end) as year_2017,
        sum(case when year = '2018' then num_used else 0 end) as year_2018
    from tmp
    group by 1) subq
    order by 1
