--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: agents_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE agents_contacts (
    id integer NOT NULL,
    agent_id integer,
    contact_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: agents_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agents_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agents_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agents_contacts_id_seq OWNED BY agents_contacts.id;


--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assignments (
    id integer NOT NULL,
    user_id integer,
    role_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assignments_id_seq OWNED BY assignments.id;


--
-- Name: autotask_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE autotask_details (
    id integer NOT NULL,
    autotask_id integer,
    item_count integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: autotask_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE autotask_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: autotask_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE autotask_details_id_seq OWNED BY autotask_details.id;


--
-- Name: autotasks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE autotasks (
    id integer NOT NULL,
    name character varying,
    time_interval integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: autotasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE autotasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: autotasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE autotasks_id_seq OWNED BY autotasks.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    name character varying,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tmpcat integer,
    level integer,
    user_id integer
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: categories_products; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories_products (
    category_id integer,
    product_id integer
);


--
-- Name: checkinout_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE checkinout_requests (
    id integer NOT NULL,
    user_id integer,
    check_time timestamp without time zone,
    content text,
    status integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    manager_id integer
);


--
-- Name: checkinout_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE checkinout_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checkinout_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE checkinout_requests_id_seq OWNED BY checkinout_requests.id;


--
-- Name: checkinouts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE checkinouts (
    id integer NOT NULL,
    user_id integer,
    check_time timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    check_date date,
    note text,
    checkinout_request_id integer
);


--
-- Name: checkinouts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE checkinouts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checkinouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE checkinouts_id_seq OWNED BY checkinouts.id;


--
-- Name: cities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cities (
    id integer NOT NULL,
    name character varying,
    state_id integer,
    city_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cities_id_seq OWNED BY cities.id;


--
-- Name: city_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE city_types (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: city_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE city_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: city_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE city_types_id_seq OWNED BY city_types.id;


--
-- Name: combination_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE combination_details (
    id integer NOT NULL,
    combination_id integer,
    product_id integer,
    stock_before integer,
    quantity integer,
    stock_after integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    serial_numbers text
);


--
-- Name: combination_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE combination_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: combination_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE combination_details_id_seq OWNED BY combination_details.id;


--
-- Name: combinations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE combinations (
    id integer NOT NULL,
    product_id integer,
    stock_before integer,
    quantity integer,
    stock_after integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    serial_numbers text,
    user_id integer,
    combined boolean DEFAULT true
);


--
-- Name: combinations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE combinations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: combinations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE combinations_id_seq OWNED BY combinations.id;


--
-- Name: commission_programs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE commission_programs (
    id integer NOT NULL,
    name text,
    interval_type character varying,
    min_amount numeric,
    max_amount numeric,
    commission_rate numeric,
    published_at timestamp without time zone,
    unpublished_at timestamp without time zone,
    status integer DEFAULT 0,
    description text,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: commission_programs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE commission_programs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commission_programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE commission_programs_id_seq OWNED BY commission_programs.id;


--
-- Name: contact_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contact_types (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: contact_types_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contact_types_contacts (
    id integer NOT NULL,
    contact_id integer,
    contact_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contact_types_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contact_types_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_types_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contact_types_contacts_id_seq OWNED BY contact_types_contacts.id;


--
-- Name: contact_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contact_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contact_types_id_seq OWNED BY contact_types.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contacts (
    id integer NOT NULL,
    name character varying,
    phone character varying,
    mobile character varying,
    fax character varying,
    email character varying,
    address character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tax_code character varying,
    note text,
    contact_type_id integer,
    website character varying,
    account_number character varying,
    bank character varying,
    representative character varying,
    representative_role character varying,
    representative_phone character varying,
    is_mine boolean DEFAULT false,
    hotline character varying,
    user_id integer,
    city_id integer,
    contact_types_cache character varying
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contacts_id_seq OWNED BY contacts.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


--
-- Name: deliveries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE deliveries (
    id integer NOT NULL,
    order_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_id integer,
    delivery_person_id integer,
    is_return integer DEFAULT 0,
    status integer DEFAULT 1,
    delivery_date timestamp without time zone
);


--
-- Name: deliveries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE deliveries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deliveries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE deliveries_id_seq OWNED BY deliveries.id;


--
-- Name: delivery_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delivery_details (
    id integer NOT NULL,
    delivery_id integer,
    order_detail_id integer,
    quantity integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    serial_numbers text,
    product_id integer
);


--
-- Name: delivery_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delivery_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delivery_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delivery_details_id_seq OWNED BY delivery_details.id;


--
-- Name: manufacturers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE manufacturers (
    id integer NOT NULL,
    name character varying,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tmpmenu integer,
    user_id integer
);


--
-- Name: manufacturers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE manufacturers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: manufacturers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE manufacturers_id_seq OWNED BY manufacturers.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    user_id integer,
    sender_id integer,
    title text,
    description text,
    viewed integer DEFAULT 0,
    url text,
    icon text,
    type_name text,
    item_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: order_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE order_details (
    id integer NOT NULL,
    order_id integer,
    product_id integer,
    quantity integer,
    price numeric(16,2),
    product_name character varying,
    warranty integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    unit character varying,
    product_description text,
    product_price_id integer,
    discount_amount numeric,
    tip_amount numeric DEFAULT 0.0,
    shipment_amount numeric DEFAULT 0.0
);


--
-- Name: order_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE order_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE order_details_id_seq OWNED BY order_details.id;


--
-- Name: order_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE order_statuses (
    id integer NOT NULL,
    name character varying,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: order_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE order_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE order_statuses_id_seq OWNED BY order_statuses.id;


--
-- Name: order_statuses_orders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE order_statuses_orders (
    id integer NOT NULL,
    order_id integer,
    order_status_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id integer
);


--
-- Name: order_statuses_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE order_statuses_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_statuses_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE order_statuses_orders_id_seq OWNED BY order_statuses_orders.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orders (
    id integer NOT NULL,
    customer_id integer,
    supplier_id integer,
    agent_id integer,
    shipping_place character varying,
    payment_method_id integer,
    payment_deadline timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    buyer_name character varying,
    buyer_company character varying,
    buyer_tax_code character varying,
    buyer_address character varying,
    buyer_email character varying,
    buyer_phone character varying,
    buyer_fax character varying,
    tax_id integer,
    order_date timestamp without time zone,
    order_deadline timestamp without time zone,
    quotation_code character varying DEFAULT 'HK-0000-000'::character varying,
    salesperson_id integer,
    deposit integer,
    shipping_date timestamp without time zone,
    shipping_time character varying,
    warranty_place character varying,
    warranty_cost text,
    older_id integer,
    watermark text,
    order_status_id integer,
    newer_id integer,
    parent_id integer,
    purchase_manager_id integer,
    debt_date timestamp without time zone,
    delivery_status_name character varying,
    payment_status_name character varying,
    customer_po character varying,
    printed_order_number text,
    supplier_agent_id integer,
    order_status_name character varying,
    price_status_name character varying,
    user_id integer,
    tip_status_name character varying,
    purchaser_id integer,
    tip_contact_id integer,
    shipment_contact_id integer
);


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orders_id_seq OWNED BY orders.id;


--
-- Name: parent_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE parent_categories (
    id integer NOT NULL,
    category_id integer,
    parent_id integer
);


--
-- Name: parent_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE parent_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parent_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE parent_categories_id_seq OWNED BY parent_categories.id;


--
-- Name: parent_contacts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE parent_contacts (
    id integer NOT NULL,
    contact_id integer,
    parent_id integer
);


--
-- Name: parent_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE parent_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parent_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE parent_contacts_id_seq OWNED BY parent_contacts.id;


--
-- Name: payment_methods; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payment_methods (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    print_name character varying
);


--
-- Name: payment_methods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_methods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_methods_id_seq OWNED BY payment_methods.id;


--
-- Name: payment_records; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payment_records (
    id integer NOT NULL,
    order_id integer,
    accountant_id integer,
    amount numeric,
    debt_days integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    note text,
    paid_person text,
    paid_address text,
    debt_date timestamp without time zone,
    payment_method_id integer,
    is_tip boolean DEFAULT false,
    paid_date timestamp without time zone,
    status integer DEFAULT 1,
    is_custom boolean DEFAULT false,
    is_recieved boolean DEFAULT false,
    type_name character varying
);


--
-- Name: payment_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payment_records_id_seq OWNED BY payment_records.id;


--
-- Name: product_images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE product_images (
    id integer NOT NULL,
    product_id integer,
    filename character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    display_order integer
);


--
-- Name: product_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE product_images_id_seq OWNED BY product_images.id;


--
-- Name: product_parts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE product_parts (
    id integer NOT NULL,
    product_id integer,
    part_id integer,
    quantity integer DEFAULT 1,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: product_parts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_parts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_parts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE product_parts_id_seq OWNED BY product_parts.id;


--
-- Name: product_prices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE product_prices (
    id integer NOT NULL,
    product_id integer,
    price numeric,
    supplier_price numeric,
    supplier_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id integer,
    customer_id integer,
    public_price numeric DEFAULT 0.0
);


--
-- Name: product_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE product_prices_id_seq OWNED BY product_prices.id;


--
-- Name: product_stock_updates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE product_stock_updates (
    id integer NOT NULL,
    product_id integer,
    quantity integer,
    serial_numbers text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_import integer,
    user_id integer,
    note text
);


--
-- Name: product_stock_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_stock_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_stock_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE product_stock_updates_id_seq OWNED BY product_stock_updates.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE products (
    id integer NOT NULL,
    name character varying,
    description text,
    price numeric(16,2),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    product_code character varying,
    warranty character varying,
    manufacturer_id integer,
    unit character varying,
    user_id integer,
    tmpproduct integer,
    stock integer DEFAULT 0,
    serial_numbers text,
    status integer DEFAULT 1
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE products_id_seq OWNED BY products.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE states (
    id integer NOT NULL,
    name character varying,
    country_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE states_id_seq OWNED BY states.id;


--
-- Name: taxes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxes (
    id integer NOT NULL,
    name character varying,
    rate numeric,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: taxes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxes_id_seq OWNED BY taxes.id;


--
-- Name: tmpcats; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tmpcats (
    id integer NOT NULL,
    category_id text,
    category_image text,
    category_parent_id text,
    category_publish text,
    category_ordertype text,
    category_template text,
    category_ordering text,
    category_add_date text,
    products_page text,
    products_row text,
    "name_en_GB" text,
    "alias_en_GB" text,
    "short_description_en_GB" text,
    "description_en_GB" text,
    "meta_title_en_GB" text,
    "meta_description_en_GB" text,
    "meta_keyword_en_GB" text,
    "name_vi_VN" text,
    "alias_vi_VN" text,
    "short_description_vi_VN" text,
    "description_vi_VN" text,
    "meta_title_vi_VN" text,
    "meta_description_vi_VN" text,
    "meta_keyword_vi_VN" text
);


--
-- Name: tmpcats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tmpcats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tmpcats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tmpcats_id_seq OWNED BY tmpcats.id;


--
-- Name: tmpmanus; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tmpmanus (
    id integer NOT NULL,
    manufacturer_id text,
    manufacturer_url text,
    manufacturer_logo text,
    manufacturer_publish text,
    products_page text,
    products_row text,
    ordering text,
    name_en_gb text,
    alias_en_gb text,
    short_description_en_gb text,
    description_en_gb text,
    meta_title_en_gb text,
    meta_description_en_gb text,
    meta_keyword_en_gb text,
    name_vi_vn text,
    alias_vi_vn text,
    short_description_vi_vn text,
    description_vi_vn text,
    meta_title_vi_vn text,
    meta_description_vi_vn text,
    meta_keyword_vi_vn text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tmpmanus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tmpmanus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tmpmanus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tmpmanus_id_seq OWNED BY tmpmanus.id;


--
-- Name: tmpproducts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tmpproducts (
    id integer NOT NULL,
    product_id text,
    product_ean text,
    product_quantity text,
    unlimited text,
    product_availability text,
    product_date_added text,
    date_modify text,
    product_publish text,
    product_tax_id text,
    product_template text,
    product_url text,
    product_old_price text,
    product_buy_price text,
    product_price text,
    min_price text,
    different_prices text,
    product_weight text,
    product_thumb_image text,
    product_name_image text,
    product_full_image text,
    product_manufacturer_id text,
    product_is_add_price text,
    average_rating text,
    reviews_count text,
    delivery_times_id text,
    hits text,
    weight_volume_units text,
    basic_price_unit_id text,
    label_id text,
    vendor_id text,
    name_en_gb text,
    alias_en_gb text,
    short_description_en_gb text,
    description_en_gb text,
    meta_title_en_gb text,
    meta_description_en_gb text,
    meta_keyword_en_gb text,
    product_warranty text,
    name_vi_vn text,
    alias_vi_vn text,
    short_description_vi_vn text,
    description_vi_vn text,
    meta_title_vi_vn text,
    meta_description_vi_vn text,
    meta_keyword_vi_vn text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tmpproducts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tmpproducts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tmpproducts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tmpproducts_id_seq OWNED BY tmpproducts.id;


--
-- Name: tmpproducttocats; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tmpproducttocats (
    id integer NOT NULL,
    product_id text,
    category_id text,
    product_ordering text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tmpproducttocats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tmpproducttocats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tmpproducttocats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tmpproducttocats_id_seq OWNED BY tmpproducttocats.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    first_name character varying,
    last_name character varying,
    phone_ext character varying,
    mobile character varying,
    "ATT_No" character varying,
    image character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agents_contacts ALTER COLUMN id SET DEFAULT nextval('agents_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments ALTER COLUMN id SET DEFAULT nextval('assignments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY autotask_details ALTER COLUMN id SET DEFAULT nextval('autotask_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY autotasks ALTER COLUMN id SET DEFAULT nextval('autotasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY checkinout_requests ALTER COLUMN id SET DEFAULT nextval('checkinout_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY checkinouts ALTER COLUMN id SET DEFAULT nextval('checkinouts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cities ALTER COLUMN id SET DEFAULT nextval('cities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY city_types ALTER COLUMN id SET DEFAULT nextval('city_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY combination_details ALTER COLUMN id SET DEFAULT nextval('combination_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY combinations ALTER COLUMN id SET DEFAULT nextval('combinations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY commission_programs ALTER COLUMN id SET DEFAULT nextval('commission_programs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_types ALTER COLUMN id SET DEFAULT nextval('contact_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_types_contacts ALTER COLUMN id SET DEFAULT nextval('contact_types_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY deliveries ALTER COLUMN id SET DEFAULT nextval('deliveries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delivery_details ALTER COLUMN id SET DEFAULT nextval('delivery_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY manufacturers ALTER COLUMN id SET DEFAULT nextval('manufacturers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_details ALTER COLUMN id SET DEFAULT nextval('order_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_statuses ALTER COLUMN id SET DEFAULT nextval('order_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_statuses_orders ALTER COLUMN id SET DEFAULT nextval('order_statuses_orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders ALTER COLUMN id SET DEFAULT nextval('orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY parent_categories ALTER COLUMN id SET DEFAULT nextval('parent_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY parent_contacts ALTER COLUMN id SET DEFAULT nextval('parent_contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_methods ALTER COLUMN id SET DEFAULT nextval('payment_methods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_records ALTER COLUMN id SET DEFAULT nextval('payment_records_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_images ALTER COLUMN id SET DEFAULT nextval('product_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_parts ALTER COLUMN id SET DEFAULT nextval('product_parts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_prices ALTER COLUMN id SET DEFAULT nextval('product_prices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_stock_updates ALTER COLUMN id SET DEFAULT nextval('product_stock_updates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY products ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxes ALTER COLUMN id SET DEFAULT nextval('taxes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tmpcats ALTER COLUMN id SET DEFAULT nextval('tmpcats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tmpmanus ALTER COLUMN id SET DEFAULT nextval('tmpmanus_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tmpproducts ALTER COLUMN id SET DEFAULT nextval('tmpproducts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tmpproducttocats ALTER COLUMN id SET DEFAULT nextval('tmpproducttocats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: agents_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY agents_contacts
    ADD CONSTRAINT agents_contacts_pkey PRIMARY KEY (id);


--
-- Name: assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: autotask_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autotask_details
    ADD CONSTRAINT autotask_details_pkey PRIMARY KEY (id);


--
-- Name: autotasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY autotasks
    ADD CONSTRAINT autotasks_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: checkinout_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checkinout_requests
    ADD CONSTRAINT checkinout_requests_pkey PRIMARY KEY (id);


--
-- Name: checkinouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checkinouts
    ADD CONSTRAINT checkinouts_pkey PRIMARY KEY (id);


--
-- Name: cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: city_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY city_types
    ADD CONSTRAINT city_types_pkey PRIMARY KEY (id);


--
-- Name: combination_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY combination_details
    ADD CONSTRAINT combination_details_pkey PRIMARY KEY (id);


--
-- Name: combinations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY combinations
    ADD CONSTRAINT combinations_pkey PRIMARY KEY (id);


--
-- Name: commission_programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY commission_programs
    ADD CONSTRAINT commission_programs_pkey PRIMARY KEY (id);


--
-- Name: contact_types_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contact_types_contacts
    ADD CONSTRAINT contact_types_contacts_pkey PRIMARY KEY (id);


--
-- Name: contact_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contact_types
    ADD CONSTRAINT contact_types_pkey PRIMARY KEY (id);


--
-- Name: contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY deliveries
    ADD CONSTRAINT deliveries_pkey PRIMARY KEY (id);


--
-- Name: delivery_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delivery_details
    ADD CONSTRAINT delivery_details_pkey PRIMARY KEY (id);


--
-- Name: manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: order_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY order_details
    ADD CONSTRAINT order_details_pkey PRIMARY KEY (id);


--
-- Name: order_statuses_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY order_statuses_orders
    ADD CONSTRAINT order_statuses_orders_pkey PRIMARY KEY (id);


--
-- Name: order_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY order_statuses
    ADD CONSTRAINT order_statuses_pkey PRIMARY KEY (id);


--
-- Name: orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: parent_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY parent_categories
    ADD CONSTRAINT parent_categories_pkey PRIMARY KEY (id);


--
-- Name: parent_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY parent_contacts
    ADD CONSTRAINT parent_contacts_pkey PRIMARY KEY (id);


--
-- Name: payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payment_methods
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (id);


--
-- Name: payment_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payment_records
    ADD CONSTRAINT payment_records_pkey PRIMARY KEY (id);


--
-- Name: product_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (id);


--
-- Name: product_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY product_parts
    ADD CONSTRAINT product_parts_pkey PRIMARY KEY (id);


--
-- Name: product_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY product_prices
    ADD CONSTRAINT product_prices_pkey PRIMARY KEY (id);


--
-- Name: product_stock_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY product_stock_updates
    ADD CONSTRAINT product_stock_updates_pkey PRIMARY KEY (id);


--
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: taxes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxes
    ADD CONSTRAINT taxes_pkey PRIMARY KEY (id);


--
-- Name: tmpcats_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tmpcats
    ADD CONSTRAINT tmpcats_pkey PRIMARY KEY (id);


--
-- Name: tmpmanus_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tmpmanus
    ADD CONSTRAINT tmpmanus_pkey PRIMARY KEY (id);


--
-- Name: tmpproducts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tmpproducts
    ADD CONSTRAINT tmpproducts_pkey PRIMARY KEY (id);


--
-- Name: tmpproducttocats_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tmpproducttocats
    ADD CONSTRAINT tmpproducttocats_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20131109010419');

INSERT INTO schema_migrations (version) VALUES ('20131122061114');

INSERT INTO schema_migrations (version) VALUES ('20131122062816');

INSERT INTO schema_migrations (version) VALUES ('20131122063850');

INSERT INTO schema_migrations (version) VALUES ('20131122075302');

INSERT INTO schema_migrations (version) VALUES ('20140213022040');

INSERT INTO schema_migrations (version) VALUES ('20140213061224');

INSERT INTO schema_migrations (version) VALUES ('20140213063536');

INSERT INTO schema_migrations (version) VALUES ('20140214075905');

INSERT INTO schema_migrations (version) VALUES ('20140215020028');

INSERT INTO schema_migrations (version) VALUES ('20140215020559');

INSERT INTO schema_migrations (version) VALUES ('20140221012104');

INSERT INTO schema_migrations (version) VALUES ('20140221012610');

INSERT INTO schema_migrations (version) VALUES ('20140221013129');

INSERT INTO schema_migrations (version) VALUES ('20140221041317');

INSERT INTO schema_migrations (version) VALUES ('20140221070917');

INSERT INTO schema_migrations (version) VALUES ('20140222045115');

INSERT INTO schema_migrations (version) VALUES ('20140222045217');

INSERT INTO schema_migrations (version) VALUES ('20140222045430');

INSERT INTO schema_migrations (version) VALUES ('20140222045454');

INSERT INTO schema_migrations (version) VALUES ('20140222045516');

INSERT INTO schema_migrations (version) VALUES ('20140222052130');

INSERT INTO schema_migrations (version) VALUES ('20140301015947');

INSERT INTO schema_migrations (version) VALUES ('20140301025307');

INSERT INTO schema_migrations (version) VALUES ('20140301025340');

INSERT INTO schema_migrations (version) VALUES ('20140301025419');

INSERT INTO schema_migrations (version) VALUES ('20140301025510');

INSERT INTO schema_migrations (version) VALUES ('20140301025538');

INSERT INTO schema_migrations (version) VALUES ('20140301025553');

INSERT INTO schema_migrations (version) VALUES ('20140301025615');

INSERT INTO schema_migrations (version) VALUES ('20140301030531');

INSERT INTO schema_migrations (version) VALUES ('20140304014613');

INSERT INTO schema_migrations (version) VALUES ('20140304030340');

INSERT INTO schema_migrations (version) VALUES ('20140304031305');

INSERT INTO schema_migrations (version) VALUES ('20140304040449');

INSERT INTO schema_migrations (version) VALUES ('20140304042941');

INSERT INTO schema_migrations (version) VALUES ('20140304050802');

INSERT INTO schema_migrations (version) VALUES ('20140307061621');

INSERT INTO schema_migrations (version) VALUES ('20140307063529');

INSERT INTO schema_migrations (version) VALUES ('20140307071540');

INSERT INTO schema_migrations (version) VALUES ('20140307075906');

INSERT INTO schema_migrations (version) VALUES ('20140307081641');

INSERT INTO schema_migrations (version) VALUES ('20140308021800');

INSERT INTO schema_migrations (version) VALUES ('20140308063652');

INSERT INTO schema_migrations (version) VALUES ('20140308072352');

INSERT INTO schema_migrations (version) VALUES ('20140308072415');

INSERT INTO schema_migrations (version) VALUES ('20140313080139');

INSERT INTO schema_migrations (version) VALUES ('20140313080223');

INSERT INTO schema_migrations (version) VALUES ('20140313090114');

INSERT INTO schema_migrations (version) VALUES ('20140313091940');

INSERT INTO schema_migrations (version) VALUES ('20140314070155');

INSERT INTO schema_migrations (version) VALUES ('20140320014111');

INSERT INTO schema_migrations (version) VALUES ('20140320014913');

INSERT INTO schema_migrations (version) VALUES ('20140320023702');

INSERT INTO schema_migrations (version) VALUES ('20140320085550');

INSERT INTO schema_migrations (version) VALUES ('20140320093203');

INSERT INTO schema_migrations (version) VALUES ('20140322044214');

INSERT INTO schema_migrations (version) VALUES ('20140322044616');

INSERT INTO schema_migrations (version) VALUES ('20140324023313');

INSERT INTO schema_migrations (version) VALUES ('20140324033911');

INSERT INTO schema_migrations (version) VALUES ('20140324055837');

INSERT INTO schema_migrations (version) VALUES ('20140324084629');

INSERT INTO schema_migrations (version) VALUES ('20140731010224');

INSERT INTO schema_migrations (version) VALUES ('20140731064555');

INSERT INTO schema_migrations (version) VALUES ('20140731080017');

INSERT INTO schema_migrations (version) VALUES ('20140801003248');

INSERT INTO schema_migrations (version) VALUES ('20140801094257');

INSERT INTO schema_migrations (version) VALUES ('20140802025945');

INSERT INTO schema_migrations (version) VALUES ('20140802030357');

INSERT INTO schema_migrations (version) VALUES ('20140807031530');

INSERT INTO schema_migrations (version) VALUES ('20140811081940');

INSERT INTO schema_migrations (version) VALUES ('20140815013938');

INSERT INTO schema_migrations (version) VALUES ('20150116023630');

INSERT INTO schema_migrations (version) VALUES ('20150304075707');

INSERT INTO schema_migrations (version) VALUES ('20150305085608');

INSERT INTO schema_migrations (version) VALUES ('20150313042522');

INSERT INTO schema_migrations (version) VALUES ('20150316011514');

INSERT INTO schema_migrations (version) VALUES ('20150316092543');

INSERT INTO schema_migrations (version) VALUES ('20150316094333');

INSERT INTO schema_migrations (version) VALUES ('20150316094602');

INSERT INTO schema_migrations (version) VALUES ('20150317071952');

INSERT INTO schema_migrations (version) VALUES ('20150318061926');

INSERT INTO schema_migrations (version) VALUES ('20150318063306');

INSERT INTO schema_migrations (version) VALUES ('20150318072611');

INSERT INTO schema_migrations (version) VALUES ('20150320040238');

INSERT INTO schema_migrations (version) VALUES ('20150320040805');

INSERT INTO schema_migrations (version) VALUES ('20150320040824');

INSERT INTO schema_migrations (version) VALUES ('20150320092026');

INSERT INTO schema_migrations (version) VALUES ('20150323064242');

INSERT INTO schema_migrations (version) VALUES ('20150324063209');

INSERT INTO schema_migrations (version) VALUES ('20150324063654');

INSERT INTO schema_migrations (version) VALUES ('20150324094732');

INSERT INTO schema_migrations (version) VALUES ('20150325074310');

INSERT INTO schema_migrations (version) VALUES ('20150326071123');

INSERT INTO schema_migrations (version) VALUES ('20150326090135');

INSERT INTO schema_migrations (version) VALUES ('20150327035733');

INSERT INTO schema_migrations (version) VALUES ('20150327153102');

INSERT INTO schema_migrations (version) VALUES ('20150328012949');

INSERT INTO schema_migrations (version) VALUES ('20150330060446');

INSERT INTO schema_migrations (version) VALUES ('20150330070035');

INSERT INTO schema_migrations (version) VALUES ('20150401052148');

INSERT INTO schema_migrations (version) VALUES ('20150401094819');

INSERT INTO schema_migrations (version) VALUES ('20150402065427');

INSERT INTO schema_migrations (version) VALUES ('20150402130957');

INSERT INTO schema_migrations (version) VALUES ('20150403024049');

INSERT INTO schema_migrations (version) VALUES ('20150403024601');

INSERT INTO schema_migrations (version) VALUES ('20150403072850');

INSERT INTO schema_migrations (version) VALUES ('20150403072907');

INSERT INTO schema_migrations (version) VALUES ('20150403110105');

INSERT INTO schema_migrations (version) VALUES ('20150403121428');

INSERT INTO schema_migrations (version) VALUES ('20150403125715');

INSERT INTO schema_migrations (version) VALUES ('20150403125725');

INSERT INTO schema_migrations (version) VALUES ('20150404013053');

INSERT INTO schema_migrations (version) VALUES ('20150404033213');

INSERT INTO schema_migrations (version) VALUES ('20150405111259');

INSERT INTO schema_migrations (version) VALUES ('20150405112039');

INSERT INTO schema_migrations (version) VALUES ('20150406032026');

INSERT INTO schema_migrations (version) VALUES ('20150406042111');

INSERT INTO schema_migrations (version) VALUES ('20150406042130');

INSERT INTO schema_migrations (version) VALUES ('20150407033111');

INSERT INTO schema_migrations (version) VALUES ('20150408140146');

INSERT INTO schema_migrations (version) VALUES ('20150408155624');

INSERT INTO schema_migrations (version) VALUES ('20150409015540');

INSERT INTO schema_migrations (version) VALUES ('20150415043518');

INSERT INTO schema_migrations (version) VALUES ('20150416043832');

INSERT INTO schema_migrations (version) VALUES ('20150417034742');

INSERT INTO schema_migrations (version) VALUES ('20150417041617');

INSERT INTO schema_migrations (version) VALUES ('20150417080712');

INSERT INTO schema_migrations (version) VALUES ('20150420012246');

INSERT INTO schema_migrations (version) VALUES ('20150420013051');

INSERT INTO schema_migrations (version) VALUES ('20150420014251');

INSERT INTO schema_migrations (version) VALUES ('20150420021244');

INSERT INTO schema_migrations (version) VALUES ('20150420023041');

INSERT INTO schema_migrations (version) VALUES ('20150420023153');

INSERT INTO schema_migrations (version) VALUES ('20150420050835');

INSERT INTO schema_migrations (version) VALUES ('20150420065002');

INSERT INTO schema_migrations (version) VALUES ('20150423011049');

INSERT INTO schema_migrations (version) VALUES ('20150423012413');

INSERT INTO schema_migrations (version) VALUES ('20150424094205');

INSERT INTO schema_migrations (version) VALUES ('20150427010451');

INSERT INTO schema_migrations (version) VALUES ('20150505075859');

INSERT INTO schema_migrations (version) VALUES ('20150507033018');

INSERT INTO schema_migrations (version) VALUES ('20150507034707');

INSERT INTO schema_migrations (version) VALUES ('20150507064831');

INSERT INTO schema_migrations (version) VALUES ('20150507083737');

INSERT INTO schema_migrations (version) VALUES ('20150509030123');

INSERT INTO schema_migrations (version) VALUES ('20150511063535');

INSERT INTO schema_migrations (version) VALUES ('20150512015924');

INSERT INTO schema_migrations (version) VALUES ('20150512015947');

INSERT INTO schema_migrations (version) VALUES ('20150512020020');

INSERT INTO schema_migrations (version) VALUES ('20150512020037');

INSERT INTO schema_migrations (version) VALUES ('20150512025921');

INSERT INTO schema_migrations (version) VALUES ('20150512035117');

INSERT INTO schema_migrations (version) VALUES ('20150512063536');

INSERT INTO schema_migrations (version) VALUES ('20150513061215');

INSERT INTO schema_migrations (version) VALUES ('20150513061639');

INSERT INTO schema_migrations (version) VALUES ('20150513062332');

INSERT INTO schema_migrations (version) VALUES ('20150513070607');

INSERT INTO schema_migrations (version) VALUES ('20150515014950');

INSERT INTO schema_migrations (version) VALUES ('20150519023308');

INSERT INTO schema_migrations (version) VALUES ('20150521030440');

INSERT INTO schema_migrations (version) VALUES ('20150527033129');

INSERT INTO schema_migrations (version) VALUES ('20150528015743');

