create table customer_dataset(
    customer_id varchar(50) primary key,
    customer_unique_id varchar(50),
    customer_zip_code_prefix char(5) not null,
    customer_city varchar(50),
    customer_state char(2) 
);

create table geolocations_dataset(
    geolocation_zip_code_prefix char(5),
    geolocation_lat varchar(50) not null,
    geolocation_lng varchar(50) not null,
    geolocation_city varchar(50) not null,
    geolocation_state char(2) not null
);
delete from geolocations_dataset
where geolocation_zip_code_prefix in
(
select geolocation_zip_code_prefix from (
    select geolocation_zip_code_prefix, count(1) from
           geolocations_dataset group  by 1 having count(1) > 1
           order by 2 desc) subq);

alter table geolocations_dataset add constraint pk_geolocations_dataset primary key (geolocation_zip_code_prefix);
alter table customer_dataset add foreign key (customer_zip_code_prefix) references geolocations_dataset;

select * from customer_dataset

create table orders_dataset(
    order_id varchar(50) primary key,
    customer_id varchar(50)not null,
    order_status varchar(20) not null,
    order_purchase_timestamp timestamp,
    order_approved_at timestamp,
    order_delivered_carrier_date timestamp,
    order_delivered_customer_date timestamp,
    order_estimated_delivered_date timestamp
);

create table order_reviews_dataset(
    review_id varchar(50) ,
    order_id varchar(50) not null,
    review_score int,
    review_comment_title varchar(50),
    review_comment_message varchar(255),
    review_creation_date timestamp,
    review_answer_timastamp timestamp
);

select * from order_reviews_dataset

 delete from order_reviews_dataset as x USING order_reviews_dataset as y
 where x.review_id < y.review_id 
 and x.review_id = y.review_id;

 alter table order_reviews_dataset 
 add constraint pk_order_reviews primary key(review_id);
 
 alter table order_reviews_dataset add foreign key(order_id)
 references orders_dataset

create table seller_dataset(
    seller_id varchar(50) primary key,
    seller_zip_code_prifex char(5),
    seller_city varchar(50),
    seller_state char(2)
);


create table order_items_dataset(
    order_id varchar(50) not null,
    order_item_id varchar(50) primary key,
    product_id varchar(50) not null,
    seller_id varchar(50) not null,
    shipping_limit_date timestamp,
    price numeric,
    freight_value numeric
);
alter table order_items_dataset add foreign key(product_id)
References product_dataset;
alter table order_items_dataset add foreign key(order_id)
References orders_dataset;
alter table order_items_dataset add foreign key(seller_id)
References seller_dataset;


select * from order_items_dataset

create table product_dataset(
    product_id varchar(50) primary key,
    product_category_name varchar(50),
    product_name_length numeric,
    product_description_length numeric,
    product_photos_qty numeric,
    product_weight_g numeric,
    product_length_cm numeric,
    product_height_cm numeric,
    product_width_cm numeric
    
);
 delete from product_dataset as pd1 USING product_dataset as pd2
 where pd1.product_id < pd2.product_id 
 and pd1.product_id = pd2.product_id;

 alter table product_dataset 
 add constraint pk_product_dataset primary key(product_id);

select * from product_dataset
create table payments_dataset(
    order_id varchar(50),
    payment_sequential int not null,
    payment_type varchar(50),
    payment_installments int,
    payment_value numeric
);

drop table payments_dataset
delete from payments_dataset as pd1 USING payments_dataset as pd2
 where pd1.order_id < pd2.order_id 
 and pd1.order_id = pd2.order_id;

alter table payments_dataset 
 add constraint pk_payments_dataset primary key(order_id);

select * from payments_dataset
alter table payments_dataset add foreign key(order_id)
references orders_dataset

select * from order_items_dataset