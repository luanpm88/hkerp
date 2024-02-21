--
-- PostgreSQL database dump
--

-- Dumped from database version 12.12 (Ubuntu 12.12-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.12 (Ubuntu 12.12-0ubuntu0.20.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agents_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agents_contacts (
    id integer NOT NULL,
    agent_id integer,
    contact_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: agents_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.agents_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agents_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.agents_contacts_id_seq OWNED BY public.agents_contacts.id;


--
-- Name: articles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.articles (
    id integer NOT NULL,
    image_url character varying,
    title character varying,
    content text,
    tag_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    popup boolean DEFAULT false,
    short_description text,
    meta_keywords character varying,
    meta_description character varying
);


--
-- Name: articles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.articles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: articles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.articles_id_seq OWNED BY public.articles.id;


--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assignments (
    id integer NOT NULL,
    user_id integer,
    role_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assignments_id_seq OWNED BY public.assignments.id;


--
-- Name: autotask_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.autotask_details (
    id integer NOT NULL,
    autotask_id integer,
    item_count integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: autotask_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.autotask_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: autotask_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.autotask_details_id_seq OWNED BY public.autotask_details.id;


--
-- Name: autotasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.autotasks (
    id integer NOT NULL,
    name character varying,
    time_interval integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: autotasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.autotasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: autotasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.autotasks_id_seq OWNED BY public.autotasks.id;


--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_accounts (
    id integer NOT NULL,
    name character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bank_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bank_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bank_accounts_id_seq OWNED BY public.bank_accounts.id;


--
-- Name: carts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.carts (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: carts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.carts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: carts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.carts_id_seq OWNED BY public.carts.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
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

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: categories_menus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories_menus (
    category_id integer NOT NULL,
    menu_id integer NOT NULL
);


--
-- Name: categories_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories_products (
    category_id integer,
    product_id integer
);


--
-- Name: checkinout_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checkinout_requests (
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

CREATE SEQUENCE public.checkinout_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checkinout_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checkinout_requests_id_seq OWNED BY public.checkinout_requests.id;


--
-- Name: checkinouts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checkinouts (
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

CREATE SEQUENCE public.checkinouts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checkinouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checkinouts_id_seq OWNED BY public.checkinouts.id;


--
-- Name: cities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cities (
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

CREATE SEQUENCE public.cities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cities_id_seq OWNED BY public.cities.id;


--
-- Name: city_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.city_types (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: city_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.city_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: city_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.city_types_id_seq OWNED BY public.city_types.id;


--
-- Name: combination_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.combination_details (
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

CREATE SEQUENCE public.combination_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: combination_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.combination_details_id_seq OWNED BY public.combination_details.id;


--
-- Name: combinations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.combinations (
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

CREATE SEQUENCE public.combinations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: combinations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.combinations_id_seq OWNED BY public.combinations.id;


--
-- Name: commission_programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.commission_programs (
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

CREATE SEQUENCE public.commission_programs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: commission_programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.commission_programs_id_seq OWNED BY public.commission_programs.id;


--
-- Name: contact_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contact_stats (
    id integer NOT NULL,
    contact_id integer,
    buy_last_6_months double precision,
    buy_last_1_year double precision,
    buy_last_3_years double precision,
    buy_all_time double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contact_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contact_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contact_stats_id_seq OWNED BY public.contact_stats.id;


--
-- Name: contact_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contact_types (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: contact_types_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contact_types_contacts (
    id integer NOT NULL,
    contact_id integer,
    contact_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: contact_types_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contact_types_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_types_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contact_types_contacts_id_seq OWNED BY public.contact_types_contacts.id;


--
-- Name: contact_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contact_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contact_types_id_seq OWNED BY public.contact_types.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts (
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
    cache_search text,
    active boolean DEFAULT true
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countries (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.countries_id_seq OWNED BY public.countries.id;


--
-- Name: customer_order_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_order_details (
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

CREATE SEQUENCE public.customer_order_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_order_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_order_details_id_seq OWNED BY public.customer_order_details.id;


--
-- Name: customer_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_orders (
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
    orderer_tax character varying,
    is_invoice boolean DEFAULT false
);


--
-- Name: customer_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_orders_id_seq OWNED BY public.customer_orders.id;


--
-- Name: deliveries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deliveries (
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

CREATE SEQUENCE public.deliveries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deliveries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deliveries_id_seq OWNED BY public.deliveries.id;


--
-- Name: delivery_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_details (
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

CREATE SEQUENCE public.delivery_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delivery_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delivery_details_id_seq OWNED BY public.delivery_details.id;


--
-- Name: feedbacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feedbacks (
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

CREATE SEQUENCE public.feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.feedbacks_id_seq OWNED BY public.feedbacks.id;


--
-- Name: line_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.line_items (
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

CREATE SEQUENCE public.line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.line_items_id_seq OWNED BY public.line_items.id;


--
-- Name: logins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logins (
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

CREATE SEQUENCE public.logins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.logins_id_seq OWNED BY public.logins.id;


--
-- Name: manages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.manages (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: manages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.manages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: manages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.manages_id_seq OWNED BY public.manages.id;


--
-- Name: manufacturers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.manufacturers (
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

CREATE SEQUENCE public.manufacturers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: manufacturers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.manufacturers_id_seq OWNED BY public.manufacturers.id;


--
-- Name: menus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menus (
    id integer NOT NULL,
    title character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    level integer,
    image_url character varying,
    menu_image character varying,
    name_url character varying,
    meta_keywords character varying,
    meta_description text,
    cache_category_ids text
);


--
-- Name: menus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.menus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: menus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.menus_id_seq OWNED BY public.menus.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
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

CREATE SEQUENCE public.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: newsletters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletters (
    id integer NOT NULL,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: newsletters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newsletters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsletters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newsletters_id_seq OWNED BY public.newsletters.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
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

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: order_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_details (
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

CREATE SEQUENCE public.order_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_details_id_seq OWNED BY public.order_details.id;


--
-- Name: order_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_statuses (
    id integer NOT NULL,
    name character varying,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: order_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_statuses_id_seq OWNED BY public.order_statuses.id;


--
-- Name: order_statuses_orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_statuses_orders (
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

CREATE SEQUENCE public.order_statuses_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_statuses_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_statuses_orders_id_seq OWNED BY public.order_statuses_orders.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
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
    cache_search text,
    cache_total_vat double precision
);


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: parent_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parent_categories (
    id integer NOT NULL,
    category_id integer,
    parent_id integer
);


--
-- Name: parent_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parent_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parent_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parent_categories_id_seq OWNED BY public.parent_categories.id;


--
-- Name: parent_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parent_contacts (
    id integer NOT NULL,
    contact_id integer,
    parent_id integer
);


--
-- Name: parent_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parent_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parent_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parent_contacts_id_seq OWNED BY public.parent_contacts.id;


--
-- Name: parent_menus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parent_menus (
    id integer NOT NULL,
    parent_id integer,
    menu_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: parent_menus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parent_menus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parent_menus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parent_menus_id_seq OWNED BY public.parent_menus.id;


--
-- Name: partners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partners (
    id integer NOT NULL,
    image_url character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    manufacturer_id integer
);


--
-- Name: partners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.partners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.partners_id_seq OWNED BY public.partners.id;


--
-- Name: payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_methods (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    print_name character varying
);


--
-- Name: payment_methods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_methods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_methods_id_seq OWNED BY public.payment_methods.id;


--
-- Name: payment_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_records (
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

CREATE SEQUENCE public.payment_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_records_id_seq OWNED BY public.payment_records.id;


--
-- Name: product_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_images (
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

CREATE SEQUENCE public.product_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_images_id_seq OWNED BY public.product_images.id;


--
-- Name: product_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_infos (
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

CREATE SEQUENCE public.product_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_infos_id_seq OWNED BY public.product_infos.id;


--
-- Name: product_parts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_parts (
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

CREATE SEQUENCE public.product_parts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_parts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_parts_id_seq OWNED BY public.product_parts.id;


--
-- Name: product_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_prices (
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

CREATE SEQUENCE public.product_prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_prices_id_seq OWNED BY public.product_prices.id;


--
-- Name: product_stock_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_stock_updates (
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

CREATE SEQUENCE public.product_stock_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_stock_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_stock_updates_id_seq OWNED BY public.product_stock_updates.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
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
    suspended boolean DEFAULT false,
    erp_sold_out boolean DEFAULT false,
    web_price numeric(16,2),
    cache_last_ordered timestamp without time zone,
    cache_last_priced timestamp without time zone,
    cache_thcn_url character varying,
    cache_web_search character varying,
    is_manual_price_update boolean DEFAULT false,
    cache_thcn_properties text,
    alias character varying,
    cache_display_name character varying,
    cache_price numeric,
    in_use boolean DEFAULT true,
    cache_recent_supplier_ids text,
    is_manual_cost boolean DEFAULT false,
    fixed_name character varying,
    listed_price numeric(16,2)
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: slide_shows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slide_shows (
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

CREATE SEQUENCE public.slide_shows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slide_shows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.slide_shows_id_seq OWNED BY public.slide_shows.id;


--
-- Name: states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.states (
    id integer NOT NULL,
    name character varying,
    country_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.states_id_seq OWNED BY public.states.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    title character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: taxes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.taxes (
    id integer NOT NULL,
    name character varying,
    rate numeric,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: taxes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.taxes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.taxes_id_seq OWNED BY public.taxes.id;


--
-- Name: tmpcats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmpcats (
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

CREATE SEQUENCE public.tmpcats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tmpcats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tmpcats_id_seq OWNED BY public.tmpcats.id;


--
-- Name: tmpmanus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmpmanus (
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

CREATE SEQUENCE public.tmpmanus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tmpmanus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tmpmanus_id_seq OWNED BY public.tmpmanus.id;


--
-- Name: tmpproducts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmpproducts (
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

CREATE SEQUENCE public.tmpproducts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tmpproducts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tmpproducts_id_seq OWNED BY public.tmpproducts.id;


--
-- Name: tmpproducttocats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tmpproducttocats (
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

CREATE SEQUENCE public.tmpproducttocats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tmpproducttocats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tmpproducttocats_id_seq OWNED BY public.tmpproducttocats.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
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

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: agents_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agents_contacts ALTER COLUMN id SET DEFAULT nextval('public.agents_contacts_id_seq'::regclass);


--
-- Name: articles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articles ALTER COLUMN id SET DEFAULT nextval('public.articles_id_seq'::regclass);


--
-- Name: assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments ALTER COLUMN id SET DEFAULT nextval('public.assignments_id_seq'::regclass);


--
-- Name: autotask_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autotask_details ALTER COLUMN id SET DEFAULT nextval('public.autotask_details_id_seq'::regclass);


--
-- Name: autotasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autotasks ALTER COLUMN id SET DEFAULT nextval('public.autotasks_id_seq'::regclass);


--
-- Name: bank_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_accounts ALTER COLUMN id SET DEFAULT nextval('public.bank_accounts_id_seq'::regclass);


--
-- Name: carts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carts ALTER COLUMN id SET DEFAULT nextval('public.carts_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: checkinout_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkinout_requests ALTER COLUMN id SET DEFAULT nextval('public.checkinout_requests_id_seq'::regclass);


--
-- Name: checkinouts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkinouts ALTER COLUMN id SET DEFAULT nextval('public.checkinouts_id_seq'::regclass);


--
-- Name: cities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities ALTER COLUMN id SET DEFAULT nextval('public.cities_id_seq'::regclass);


--
-- Name: city_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.city_types ALTER COLUMN id SET DEFAULT nextval('public.city_types_id_seq'::regclass);


--
-- Name: combination_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.combination_details ALTER COLUMN id SET DEFAULT nextval('public.combination_details_id_seq'::regclass);


--
-- Name: combinations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.combinations ALTER COLUMN id SET DEFAULT nextval('public.combinations_id_seq'::regclass);


--
-- Name: commission_programs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commission_programs ALTER COLUMN id SET DEFAULT nextval('public.commission_programs_id_seq'::regclass);


--
-- Name: contact_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_stats ALTER COLUMN id SET DEFAULT nextval('public.contact_stats_id_seq'::regclass);


--
-- Name: contact_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_types ALTER COLUMN id SET DEFAULT nextval('public.contact_types_id_seq'::regclass);


--
-- Name: contact_types_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_types_contacts ALTER COLUMN id SET DEFAULT nextval('public.contact_types_contacts_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries ALTER COLUMN id SET DEFAULT nextval('public.countries_id_seq'::regclass);


--
-- Name: customer_order_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_order_details ALTER COLUMN id SET DEFAULT nextval('public.customer_order_details_id_seq'::regclass);


--
-- Name: customer_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_orders ALTER COLUMN id SET DEFAULT nextval('public.customer_orders_id_seq'::regclass);


--
-- Name: deliveries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deliveries ALTER COLUMN id SET DEFAULT nextval('public.deliveries_id_seq'::regclass);


--
-- Name: delivery_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_details ALTER COLUMN id SET DEFAULT nextval('public.delivery_details_id_seq'::regclass);


--
-- Name: feedbacks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks ALTER COLUMN id SET DEFAULT nextval('public.feedbacks_id_seq'::regclass);


--
-- Name: line_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.line_items ALTER COLUMN id SET DEFAULT nextval('public.line_items_id_seq'::regclass);


--
-- Name: logins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logins ALTER COLUMN id SET DEFAULT nextval('public.logins_id_seq'::regclass);


--
-- Name: manages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.manages ALTER COLUMN id SET DEFAULT nextval('public.manages_id_seq'::regclass);


--
-- Name: manufacturers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.manufacturers ALTER COLUMN id SET DEFAULT nextval('public.manufacturers_id_seq'::regclass);


--
-- Name: menus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menus ALTER COLUMN id SET DEFAULT nextval('public.menus_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: newsletters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletters ALTER COLUMN id SET DEFAULT nextval('public.newsletters_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: order_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_details ALTER COLUMN id SET DEFAULT nextval('public.order_details_id_seq'::regclass);


--
-- Name: order_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_statuses ALTER COLUMN id SET DEFAULT nextval('public.order_statuses_id_seq'::regclass);


--
-- Name: order_statuses_orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_statuses_orders ALTER COLUMN id SET DEFAULT nextval('public.order_statuses_orders_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: parent_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_categories ALTER COLUMN id SET DEFAULT nextval('public.parent_categories_id_seq'::regclass);


--
-- Name: parent_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_contacts ALTER COLUMN id SET DEFAULT nextval('public.parent_contacts_id_seq'::regclass);


--
-- Name: parent_menus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_menus ALTER COLUMN id SET DEFAULT nextval('public.parent_menus_id_seq'::regclass);


--
-- Name: partners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partners ALTER COLUMN id SET DEFAULT nextval('public.partners_id_seq'::regclass);


--
-- Name: payment_methods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods ALTER COLUMN id SET DEFAULT nextval('public.payment_methods_id_seq'::regclass);


--
-- Name: payment_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_records ALTER COLUMN id SET DEFAULT nextval('public.payment_records_id_seq'::regclass);


--
-- Name: product_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images ALTER COLUMN id SET DEFAULT nextval('public.product_images_id_seq'::regclass);


--
-- Name: product_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_infos ALTER COLUMN id SET DEFAULT nextval('public.product_infos_id_seq'::regclass);


--
-- Name: product_parts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_parts ALTER COLUMN id SET DEFAULT nextval('public.product_parts_id_seq'::regclass);


--
-- Name: product_prices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_prices ALTER COLUMN id SET DEFAULT nextval('public.product_prices_id_seq'::regclass);


--
-- Name: product_stock_updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_stock_updates ALTER COLUMN id SET DEFAULT nextval('public.product_stock_updates_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: slide_shows id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slide_shows ALTER COLUMN id SET DEFAULT nextval('public.slide_shows_id_seq'::regclass);


--
-- Name: states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.states ALTER COLUMN id SET DEFAULT nextval('public.states_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: taxes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taxes ALTER COLUMN id SET DEFAULT nextval('public.taxes_id_seq'::regclass);


--
-- Name: tmpcats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tmpcats ALTER COLUMN id SET DEFAULT nextval('public.tmpcats_id_seq'::regclass);


--
-- Name: tmpmanus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tmpmanus ALTER COLUMN id SET DEFAULT nextval('public.tmpmanus_id_seq'::regclass);


--
-- Name: tmpproducts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tmpproducts ALTER COLUMN id SET DEFAULT nextval('public.tmpproducts_id_seq'::regclass);


--
-- Name: tmpproducttocats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tmpproducttocats ALTER COLUMN id SET DEFAULT nextval('public.tmpproducttocats_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: agents_contacts agents_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agents_contacts
    ADD CONSTRAINT agents_contacts_pkey PRIMARY KEY (id);


--
-- Name: articles articles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_pkey PRIMARY KEY (id);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: autotask_details autotask_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autotask_details
    ADD CONSTRAINT autotask_details_pkey PRIMARY KEY (id);


--
-- Name: autotasks autotasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autotasks
    ADD CONSTRAINT autotasks_pkey PRIMARY KEY (id);


--
-- Name: bank_accounts bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_accounts
    ADD CONSTRAINT bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: carts carts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: checkinout_requests checkinout_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkinout_requests
    ADD CONSTRAINT checkinout_requests_pkey PRIMARY KEY (id);


--
-- Name: checkinouts checkinouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkinouts
    ADD CONSTRAINT checkinouts_pkey PRIMARY KEY (id);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: city_types city_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.city_types
    ADD CONSTRAINT city_types_pkey PRIMARY KEY (id);


--
-- Name: combination_details combination_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.combination_details
    ADD CONSTRAINT combination_details_pkey PRIMARY KEY (id);


--
-- Name: combinations combinations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.combinations
    ADD CONSTRAINT combinations_pkey PRIMARY KEY (id);


--
-- Name: commission_programs commission_programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.commission_programs
    ADD CONSTRAINT commission_programs_pkey PRIMARY KEY (id);


--
-- Name: contact_stats contact_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_stats
    ADD CONSTRAINT contact_stats_pkey PRIMARY KEY (id);


--
-- Name: contact_types_contacts contact_types_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_types_contacts
    ADD CONSTRAINT contact_types_contacts_pkey PRIMARY KEY (id);


--
-- Name: contact_types contact_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contact_types
    ADD CONSTRAINT contact_types_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: customer_order_details customer_order_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_order_details
    ADD CONSTRAINT customer_order_details_pkey PRIMARY KEY (id);


--
-- Name: customer_orders customer_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_orders
    ADD CONSTRAINT customer_orders_pkey PRIMARY KEY (id);


--
-- Name: deliveries deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_pkey PRIMARY KEY (id);


--
-- Name: delivery_details delivery_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_details
    ADD CONSTRAINT delivery_details_pkey PRIMARY KEY (id);


--
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (id);


--
-- Name: line_items line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.line_items
    ADD CONSTRAINT line_items_pkey PRIMARY KEY (id);


--
-- Name: logins logins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logins
    ADD CONSTRAINT logins_pkey PRIMARY KEY (id);


--
-- Name: manages manages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.manages
    ADD CONSTRAINT manages_pkey PRIMARY KEY (id);


--
-- Name: manufacturers manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (id);


--
-- Name: menus menus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: newsletters newsletters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletters
    ADD CONSTRAINT newsletters_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: order_details order_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_pkey PRIMARY KEY (id);


--
-- Name: order_statuses_orders order_statuses_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_statuses_orders
    ADD CONSTRAINT order_statuses_orders_pkey PRIMARY KEY (id);


--
-- Name: order_statuses order_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_statuses
    ADD CONSTRAINT order_statuses_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: parent_categories parent_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_categories
    ADD CONSTRAINT parent_categories_pkey PRIMARY KEY (id);


--
-- Name: parent_contacts parent_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_contacts
    ADD CONSTRAINT parent_contacts_pkey PRIMARY KEY (id);


--
-- Name: parent_menus parent_menus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_menus
    ADD CONSTRAINT parent_menus_pkey PRIMARY KEY (id);


--
-- Name: partners partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partners
    ADD CONSTRAINT partners_pkey PRIMARY KEY (id);


--
-- Name: payment_methods payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (id);


--
-- Name: payment_records payment_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_records
    ADD CONSTRAINT payment_records_pkey PRIMARY KEY (id);


--
-- Name: product_images product_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (id);


--
-- Name: product_infos product_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_infos
    ADD CONSTRAINT product_infos_pkey PRIMARY KEY (id);


--
-- Name: product_parts product_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_parts
    ADD CONSTRAINT product_parts_pkey PRIMARY KEY (id);


--
-- Name: product_prices product_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_prices
    ADD CONSTRAINT product_prices_pkey PRIMARY KEY (id);


--
-- Name: product_stock_updates product_stock_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_stock_updates
    ADD CONSTRAINT product_stock_updates_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: slide_shows slide_shows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slide_shows
    ADD CONSTRAINT slide_shows_pkey PRIMARY KEY (id);


--
-- Name: states states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: taxes taxes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taxes
    ADD CONSTRAINT taxes_pkey PRIMARY KEY (id);


--
-- Name: tmpcats tmpcats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tmpcats
    ADD CONSTRAINT tmpcats_pkey PRIMARY KEY (id);


--
-- Name: tmpmanus tmpmanus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tmpmanus
    ADD CONSTRAINT tmpmanus_pkey PRIMARY KEY (id);


--
-- Name: tmpproducts tmpproducts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tmpproducts
    ADD CONSTRAINT tmpproducts_pkey PRIMARY KEY (id);


--
-- Name: tmpproducttocats tmpproducttocats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tmpproducttocats
    ADD CONSTRAINT tmpproducttocats_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_line_items_on_cart_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_line_items_on_cart_id ON public.line_items USING btree (cart_id);


--
-- Name: index_line_items_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_line_items_on_product_id ON public.line_items USING btree (product_id);


--
-- Name: index_logins_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_logins_on_email ON public.logins USING btree (email);


--
-- Name: index_logins_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_logins_on_reset_password_token ON public.logins USING btree (reset_password_token);


--
-- Name: index_products_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_status ON public.products USING btree (status);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: line_items fk_rails_11e15d5c6b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.line_items
    ADD CONSTRAINT fk_rails_11e15d5c6b FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: line_items fk_rails_af645e8e5f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.line_items
    ADD CONSTRAINT fk_rails_af645e8e5f FOREIGN KEY (cart_id) REFERENCES public.carts(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

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

INSERT INTO schema_migrations (version) VALUES ('20170627072130');

INSERT INTO schema_migrations (version) VALUES ('20170711031435');

INSERT INTO schema_migrations (version) VALUES ('20171109081645');

INSERT INTO schema_migrations (version) VALUES ('20171110064450');

INSERT INTO schema_migrations (version) VALUES ('20171110070138');

INSERT INTO schema_migrations (version) VALUES ('20171113040128');

INSERT INTO schema_migrations (version) VALUES ('20171114064708');

INSERT INTO schema_migrations (version) VALUES ('20171114064800');

INSERT INTO schema_migrations (version) VALUES ('20171114073658');

INSERT INTO schema_migrations (version) VALUES ('20171115035800');

INSERT INTO schema_migrations (version) VALUES ('20171117042839');

INSERT INTO schema_migrations (version) VALUES ('20171125035952');

INSERT INTO schema_migrations (version) VALUES ('20180109063726');

INSERT INTO schema_migrations (version) VALUES ('20180110071730');

INSERT INTO schema_migrations (version) VALUES ('20180110072056');

INSERT INTO schema_migrations (version) VALUES ('20180116024329');

INSERT INTO schema_migrations (version) VALUES ('20180707020744');

INSERT INTO schema_migrations (version) VALUES ('20180707030916');

INSERT INTO schema_migrations (version) VALUES ('20181005014031');

INSERT INTO schema_migrations (version) VALUES ('20190725014919');

INSERT INTO schema_migrations (version) VALUES ('20190920021522');

INSERT INTO schema_migrations (version) VALUES ('20200806164620');

INSERT INTO schema_migrations (version) VALUES ('20200807014217');

INSERT INTO schema_migrations (version) VALUES ('20200810072705');

INSERT INTO schema_migrations (version) VALUES ('20210521014201');

INSERT INTO schema_migrations (version) VALUES ('20210607015220');

INSERT INTO schema_migrations (version) VALUES ('20220926030222');

