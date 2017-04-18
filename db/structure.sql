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
-- Name: articles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE articles (
    id integer NOT NULL,
    image_url character varying,
    title character varying,
    content text,
    tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    popup boolean DEFAULT false
);


--
-- Name: articles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE articles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: articles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE articles_id_seq OWNED BY articles.id;


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
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bank_accounts (
    id integer NOT NULL,
    name character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bank_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bank_accounts_id_seq OWNED BY bank_accounts.id;


--
-- Name: carts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE carts (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: carts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE carts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: carts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE carts_id_seq OWNED BY carts.id;


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
    user_id integer,
    cache_search text
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
-- Name: categories_menus; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories_menus (
    category_id integer NOT NULL,
    menu_id integer NOT NULL
);


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
    contact_types_cache character varying,
    image character varying,
    fixed_address text,
    cache_search text
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
-- Name: customer_order_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE customer_order_details (
    id integer NOT NULL,
    customer_order_id integer,
    product_id integer,
    quantity integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    price numeric
);


--
-- Name: customer_order_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE customer_order_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_order_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE customer_order_details_id_seq OWNED BY customer_order_details.id;


--
-- Name: customer_orders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE customer_orders (
    id integer NOT NULL,
    orderer_first_name character varying,
    orderer_last_name character varying,
    orderer_company_name character varying,
    orderer_email character varying,
    orderer_address_1 character varying,
    orderer_address_2 character varying,
    orderer_phone character varying,
    orderer_fax character varying,
    orderer_message text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    orderer_tax character varying
);


--
-- Name: customer_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE customer_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE customer_orders_id_seq OWNED BY customer_orders.id;


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
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feedbacks (
    id integer NOT NULL,
    user_id integer,
    title character varying,
    content text,
    image character varying,
    status integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: feedbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feedbacks_id_seq OWNED BY feedbacks.id;


--
-- Name: line_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE line_items (
    id integer NOT NULL,
    product_id integer,
    cart_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    quantity integer DEFAULT 1
);


--
-- Name: line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE line_items_id_seq OWNED BY line_items.id;


--
-- Name: logins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE logins (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: logins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE logins_id_seq OWNED BY logins.id;


--
-- Name: manages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE manages (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: manages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE manages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: manages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE manages_id_seq OWNED BY manages.id;


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
-- Name: menus; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE menus (
    id integer NOT NULL,
    title character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    level integer
);


--
-- Name: menus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE menus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: menus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE menus_id_seq OWNED BY menus.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE messages (
    id integer NOT NULL,
    name character varying,
    email character varying,
    phone character varying,
    messages text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: newsletters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE newsletters (
    id integer NOT NULL,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: newsletters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE newsletters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsletters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE newsletters_id_seq OWNED BY newsletters.id;


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
    shipment_contact_id integer,
    cache_total numeric,
    cache_search text
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
-- Name: parent_menus; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE parent_menus (
    id integer NOT NULL,
    parent_id integer,
    menu_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: parent_menus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE parent_menus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parent_menus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE parent_menus_id_seq OWNED BY parent_menus.id;


--
-- Name: partners; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE partners (
    id integer NOT NULL,
    image_url character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    manufacturer_id integer
);


--
-- Name: partners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE partners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE partners_id_seq OWNED BY partners.id;


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
    type_name character varying,
    bank_account_id integer
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
-- Name: product_infos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE product_infos (
    id integer NOT NULL,
    image_url character varying,
    description text,
    old_price numeric,
    product_hot character varying,
    product_sale character varying,
    product_bestselled character varying,
    product_prominent character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    product_id integer,
    note text,
    product_new character varying,
    sale_off_price numeric,
    sale_price numeric,
    bonus_product text
);


--
-- Name: product_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE product_infos_id_seq OWNED BY product_infos.id;


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
    status integer DEFAULT 1,
    note text,
    cache_search text,
    intro text,
    tax_id integer,
    short_intro text,
    no_price boolean,
    erp_price_updated boolean DEFAULT false,
    erp_imported boolean DEFAULT false,
    suspended boolean DEFAULT false
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
-- Name: slide_shows; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE slide_shows (
    id integer NOT NULL,
    image_url character varying,
    description text,
    link_to character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying
);


--
-- Name: slide_shows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE slide_shows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slide_shows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE slide_shows_id_seq OWNED BY slide_shows.id;


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
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    title character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


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
    image character varying,
    is_soft boolean DEFAULT false
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

ALTER TABLE ONLY articles ALTER COLUMN id SET DEFAULT nextval('articles_id_seq'::regclass);


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

ALTER TABLE ONLY bank_accounts ALTER COLUMN id SET DEFAULT nextval('bank_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY carts ALTER COLUMN id SET DEFAULT nextval('carts_id_seq'::regclass);


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

ALTER TABLE ONLY customer_order_details ALTER COLUMN id SET DEFAULT nextval('customer_order_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY customer_orders ALTER COLUMN id SET DEFAULT nextval('customer_orders_id_seq'::regclass);


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

ALTER TABLE ONLY feedbacks ALTER COLUMN id SET DEFAULT nextval('feedbacks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY line_items ALTER COLUMN id SET DEFAULT nextval('line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY logins ALTER COLUMN id SET DEFAULT nextval('logins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY manages ALTER COLUMN id SET DEFAULT nextval('manages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY manufacturers ALTER COLUMN id SET DEFAULT nextval('manufacturers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY menus ALTER COLUMN id SET DEFAULT nextval('menus_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY newsletters ALTER COLUMN id SET DEFAULT nextval('newsletters_id_seq'::regclass);


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

ALTER TABLE ONLY parent_menus ALTER COLUMN id SET DEFAULT nextval('parent_menus_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY partners ALTER COLUMN id SET DEFAULT nextval('partners_id_seq'::regclass);


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

ALTER TABLE ONLY product_infos ALTER COLUMN id SET DEFAULT nextval('product_infos_id_seq'::regclass);


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

ALTER TABLE ONLY slide_shows ALTER COLUMN id SET DEFAULT nextval('slide_shows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY states ALTER COLUMN id SET DEFAULT nextval('states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


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
-- Name: articles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY articles
    ADD CONSTRAINT articles_pkey PRIMARY KEY (id);


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
-- Name: bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bank_accounts
    ADD CONSTRAINT bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: carts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY carts
    ADD CONSTRAINT carts_pkey PRIMARY KEY (id);


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
-- Name: customer_order_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY customer_order_details
    ADD CONSTRAINT customer_order_details_pkey PRIMARY KEY (id);


--
-- Name: customer_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY customer_orders
    ADD CONSTRAINT customer_orders_pkey PRIMARY KEY (id);


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
-- Name: feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY line_items
    ADD CONSTRAINT line_items_pkey PRIMARY KEY (id);


--
-- Name: logins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY logins
    ADD CONSTRAINT logins_pkey PRIMARY KEY (id);


--
-- Name: manages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY manages
    ADD CONSTRAINT manages_pkey PRIMARY KEY (id);


--
-- Name: manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (id);


--
-- Name: menus_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY menus
    ADD CONSTRAINT menus_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: newsletters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY newsletters
    ADD CONSTRAINT newsletters_pkey PRIMARY KEY (id);


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
-- Name: parent_menus_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY parent_menus
    ADD CONSTRAINT parent_menus_pkey PRIMARY KEY (id);


--
-- Name: partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partners
    ADD CONSTRAINT partners_pkey PRIMARY KEY (id);


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
-- Name: product_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY product_infos
    ADD CONSTRAINT product_infos_pkey PRIMARY KEY (id);


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
-- Name: slide_shows_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY slide_shows
    ADD CONSTRAINT slide_shows_pkey PRIMARY KEY (id);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


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
-- Name: index_line_items_on_cart_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_line_items_on_cart_id ON line_items USING btree (cart_id);


--
-- Name: index_line_items_on_product_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_line_items_on_product_id ON line_items USING btree (product_id);


--
-- Name: index_logins_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_logins_on_email ON logins USING btree (email);


--
-- Name: index_logins_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_logins_on_reset_password_token ON logins USING btree (reset_password_token);


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
-- Name: fk_rails_11e15d5c6b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY line_items
    ADD CONSTRAINT fk_rails_11e15d5c6b FOREIGN KEY (product_id) REFERENCES products(id);


--
-- Name: fk_rails_af645e8e5f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY line_items
    ADD CONSTRAINT fk_rails_af645e8e5f FOREIGN KEY (cart_id) REFERENCES carts(id);


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

INSERT INTO schema_migrations (version) VALUES ('20150604092249');

INSERT INTO schema_migrations (version) VALUES ('20150610035056');

INSERT INTO schema_migrations (version) VALUES ('20150716075807');

INSERT INTO schema_migrations (version) VALUES ('20150721042319');

INSERT INTO schema_migrations (version) VALUES ('20151205023701');

INSERT INTO schema_migrations (version) VALUES ('20160118011959');

INSERT INTO schema_migrations (version) VALUES ('20160118013234');

INSERT INTO schema_migrations (version) VALUES ('20160118022918');

INSERT INTO schema_migrations (version) VALUES ('20160118032810');

INSERT INTO schema_migrations (version) VALUES ('20160118032832');

INSERT INTO schema_migrations (version) VALUES ('20160118032917');

INSERT INTO schema_migrations (version) VALUES ('20160118062716');

INSERT INTO schema_migrations (version) VALUES ('20160119075810');

INSERT INTO schema_migrations (version) VALUES ('20160119080249');

INSERT INTO schema_migrations (version) VALUES ('20160119082908');

INSERT INTO schema_migrations (version) VALUES ('20160119094029');

INSERT INTO schema_migrations (version) VALUES ('20160120074431');

INSERT INTO schema_migrations (version) VALUES ('20160120074549');

INSERT INTO schema_migrations (version) VALUES ('20160121091924');

INSERT INTO schema_migrations (version) VALUES ('20160123020829');

INSERT INTO schema_migrations (version) VALUES ('20160123020937');

INSERT INTO schema_migrations (version) VALUES ('20160123024351');

INSERT INTO schema_migrations (version) VALUES ('20160123030046');

INSERT INTO schema_migrations (version) VALUES ('20160124150039');

INSERT INTO schema_migrations (version) VALUES ('20160126021420');

INSERT INTO schema_migrations (version) VALUES ('20160126032627');

INSERT INTO schema_migrations (version) VALUES ('20160131182950');

INSERT INTO schema_migrations (version) VALUES ('20160223023503');

INSERT INTO schema_migrations (version) VALUES ('20160223033404');

INSERT INTO schema_migrations (version) VALUES ('20160223081651');

INSERT INTO schema_migrations (version) VALUES ('20160224012626');

INSERT INTO schema_migrations (version) VALUES ('20160224085810');

INSERT INTO schema_migrations (version) VALUES ('20160224090006');

INSERT INTO schema_migrations (version) VALUES ('20160224090206');

INSERT INTO schema_migrations (version) VALUES ('20160226074840');

INSERT INTO schema_migrations (version) VALUES ('20160229081249');

INSERT INTO schema_migrations (version) VALUES ('20160330012847');

INSERT INTO schema_migrations (version) VALUES ('20160330021311');

INSERT INTO schema_migrations (version) VALUES ('20160507055327');

INSERT INTO schema_migrations (version) VALUES ('20160507062626');

INSERT INTO schema_migrations (version) VALUES ('20160507104735');

INSERT INTO schema_migrations (version) VALUES ('20160728094423');

INSERT INTO schema_migrations (version) VALUES ('20160811090641');

INSERT INTO schema_migrations (version) VALUES ('20160815074344');

INSERT INTO schema_migrations (version) VALUES ('20161105045331');

INSERT INTO schema_migrations (version) VALUES ('20161213073624');

INSERT INTO schema_migrations (version) VALUES ('20170324061121');

INSERT INTO schema_migrations (version) VALUES ('20170412012147');

INSERT INTO schema_migrations (version) VALUES ('20170418032535');

