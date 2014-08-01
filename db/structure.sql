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
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    name character varying(255),
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tmpcat integer,
    level integer
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
-- Name: checkinouts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE checkinouts (
    id integer NOT NULL,
    user_id integer,
    check_time timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    check_date date,
    note text
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
-- Name: contact_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contact_types (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
    name character varying(255),
    phone character varying(255),
    mobile character varying(255),
    fax character varying(255),
    email character varying(255),
    address character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tax_code character varying(255),
    note text,
    contact_type_id integer,
    website character varying(255),
    account_number character varying(255),
    bank character varying(255),
    representative character varying(255),
    representative_role character varying(255),
    representative_phone character varying(255),
    is_mine boolean DEFAULT false,
    hotline character varying(255),
    user_id integer
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
-- Name: manufacturers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE manufacturers (
    id integer NOT NULL,
    name character varying(255),
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tmpmenu integer
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
-- Name: order_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE order_details (
    id integer NOT NULL,
    order_id integer,
    product_id integer,
    quantity integer,
    price numeric(16,2),
    supplier_price numeric(16,2),
    product_name character varying(255),
    warranty integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    unit character varying(255),
    supplier_id integer,
    product_description character varying(255)
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
-- Name: orders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orders (
    id integer NOT NULL,
    customer_id integer,
    supplier_id integer,
    agent_id integer,
    shipping_place character varying(255),
    payment_method_id integer,
    payment_deadline timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    buyer_name character varying(255),
    buyer_company character varying(255),
    buyer_tax_code character varying(255),
    buyer_address character varying(255),
    buyer_email character varying(255),
    buyer_phone character varying(255),
    buyer_fax character varying(255),
    tax_id integer,
    order_date timestamp without time zone,
    order_deadline timestamp without time zone,
    quotation_code character varying(255) DEFAULT 'HK-0000-000'::character varying,
    salesperson_id integer,
    deposit integer,
    shipping_date timestamp without time zone,
    shipping_time character varying(255),
    warranty_place character varying(255),
    warranty_cost text,
    older_id integer
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
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: products; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE products (
    id integer NOT NULL,
    name character varying(255),
    description text,
    price numeric(16,2),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    product_code character varying(255),
    warranty character varying(255),
    manufacturer_id integer,
    unit character varying(255),
    user_id integer,
    tmpproduct integer
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
    name character varying(255),
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
    version character varying(255) NOT NULL
);


--
-- Name: supplier_order_details; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE supplier_order_details (
    id integer NOT NULL,
    supplier_order_id integer,
    product_id integer,
    quantity integer,
    price numeric(16,2),
    product_name character varying(255),
    warranty integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    product_description text,
    unit text
);


--
-- Name: supplier_order_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE supplier_order_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supplier_order_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE supplier_order_details_id_seq OWNED BY supplier_order_details.id;


--
-- Name: supplier_orders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE supplier_orders (
    id integer NOT NULL,
    supplier_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    salesperson_id integer,
    tax_id integer
);


--
-- Name: supplier_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE supplier_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supplier_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE supplier_orders_id_seq OWNED BY supplier_orders.id;


--
-- Name: taxes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxes (
    id integer NOT NULL,
    name character varying(255),
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
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    first_name character varying(255),
    last_name character varying(255),
    phone_ext character varying(255),
    mobile character varying(255),
    "ATT_No" character varying(255)
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

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY checkinouts ALTER COLUMN id SET DEFAULT nextval('checkinouts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contact_types ALTER COLUMN id SET DEFAULT nextval('contact_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval('contacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY manufacturers ALTER COLUMN id SET DEFAULT nextval('manufacturers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY order_details ALTER COLUMN id SET DEFAULT nextval('order_details_id_seq'::regclass);


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

ALTER TABLE ONLY products ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY supplier_order_details ALTER COLUMN id SET DEFAULT nextval('supplier_order_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY supplier_orders ALTER COLUMN id SET DEFAULT nextval('supplier_orders_id_seq'::regclass);


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
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: checkinouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checkinouts
    ADD CONSTRAINT checkinouts_pkey PRIMARY KEY (id);


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
-- Name: manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (id);


--
-- Name: order_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY order_details
    ADD CONSTRAINT order_details_pkey PRIMARY KEY (id);


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
-- Name: supplier_order_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY supplier_order_details
    ADD CONSTRAINT supplier_order_details_pkey PRIMARY KEY (id);


--
-- Name: supplier_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY supplier_orders
    ADD CONSTRAINT supplier_orders_pkey PRIMARY KEY (id);


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

INSERT INTO schema_migrations (version) VALUES ('20140528021615');

INSERT INTO schema_migrations (version) VALUES ('20140528021954');

INSERT INTO schema_migrations (version) VALUES ('20140528022742');

INSERT INTO schema_migrations (version) VALUES ('20140528023719');

INSERT INTO schema_migrations (version) VALUES ('20140528025816');

INSERT INTO schema_migrations (version) VALUES ('20140528025846');

INSERT INTO schema_migrations (version) VALUES ('20140731010224');

INSERT INTO schema_migrations (version) VALUES ('20140731064555');

INSERT INTO schema_migrations (version) VALUES ('20140731080017');

INSERT INTO schema_migrations (version) VALUES ('20140801003248');
