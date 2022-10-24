with
calc_mau as(
select tahun, avg(mau) as avg_mau
from
(
select
    date_part('year', o.order_purchase_timestamp) as tahun,
    date_part('month', o.order_purchase_timestamp) as bulan,
    count(distinct customer_unique_id) as mau
from orders_dataset o
Join customer_dataset c on c.customer_id = o.customer_id
group by 1,2 
) tmpA 
    group by 1
),

calculated_newcust as (
select
    date_part('year', first_purchase_time) as tahun,
    count(distinct customer_unique_id) as new_customers
from
(
select
    c.customer_unique_id,
    min(o.order_purchase_timestamp) as first_purchase_time
from orders_dataset o
join customer_dataset c on c.customer_id = o.customer_id
group by 1
) subq
group by 1
),

calculated_repeat as(
select
    tahun,
    count(distinct customer_unique_id) as repeating_customers
    from
(
select
    date_part('year', o.order_purchase_timestamp) as tahun,
    c.customer_unique_id,
    count(1) as purchase_frequency
from orders_dataset o
join customer_dataset c on c.customer_id = o.customer_id
group by 1,2
having count(1) > 1
) subq
group by 1
    ),
calculated_aov as (   
select 
    tahun,
    round(avg(frequency_purchase),3) as avg_orders_per_customers
    from
(
select
    date_part('year', o.order_purchase_timestamp) as tahun,
    c.customer_unique_id,
    count(1) as frequency_purchase
    from orders_dataset o
    join customer_dataset c on c.customer_id = o.customer_id
    group by 1, 2
)a
group by 1
)   

select
    mau.tahun,
    mau.avg_mau,
    newc.new_customers,
    rep.repeating_customers,
    aov.avg_orders_per_customers
from calc_mau mau
join calculated_newcust newc on mau.tahun = newc.tahun
join calculated_repeat rep on rep.tahun = mau.tahun
join calculated_aov aov on aov.tahun - mau.tahun
