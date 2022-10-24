create table total_cancel_per_year as
select
    date_part('year', order_purchase_timestamp) as year,
    count(1) as num_canceled_orders
from orders_dataset
where order_status = 'canceled'
group by 1

create table top_product_category_by_revenue_per_year as
select
    year,
    product_category_name,
    revenue
from (
    select
        date_part('year', o.order_purchase_timestamp) as year,
        p.product_category_name,
        sum(oi.price + oi.freight_value) as revenue,
        rank() over(partition by date_part('year', o.order_purchase_timestamp)
                    order by sum(oi.price + oi.freight_value)desc) as rk
        from order_items_dataset oi
        join orders_dataset o on o.order_id = oi.order_id
        join product_dataset p on p.product_id = oi.product_id
        where o.order_status = 'delivered'
        group by 1,2
    ) sq
    where rk = 1

create table most_canceled_product_category_per_year as
select
    year,
    product_category_name,
    num_canceled
from (
    select
        date_part('year', o.order_purchase_timestamp) as year,
        p.product_category_name,
        count(1) as num_canceled,
        rank() over(partition by date_part('year', o.order_purchase_timestamp)
                    order by count(1)desc) as rk
        from order_items_dataset oi
        join orders_dataset o on o.order_id = oi.order_id
        join product_dataset p on p.product_id = oi.product_id
        where o.order_status = 'canceled'
        group by 1,2
    ) sq
    where rk = 1

create table total_revenue_per_year as
select 
    date_part('year', o.order_purchase_timestamp) as year,
    sum(revenue_per_order) as revenue
from (
    select
        order_id,
    sum(price+freight_value) as revenue_per_order
    from order_items_dataset
    group by 1
 ) subq
 join orders_dataset o on subq.order_id = o.order_id
 where o.order_status ='delivered'
 group by 1


select
    a.year,
    a.product_category_name as top_product_category_by_revenue,
    a.revenue as category_revenue,
    b.revenue as year_total_revenue,
    c.product_category_name as most_canceled_product_category,
    c.num_canceled as category_num_canceled,
    d.num_canceled_orders as year_total_num_canceled
from top_product_category_by_revenue_per_year a
join total_revenue_per_year b on a.year = b.year
join most_canceled_product_category_per_year c on a.year = c.year
join total_cancel_per_year d on d.year = a.year
