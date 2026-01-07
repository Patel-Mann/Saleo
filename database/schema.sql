-- POS MYSQL DATABASE SCHEMA
-- multi-tenant, inventory management, POS, customer loyalty, payments, and reporting

SET FOREIGN_KEY_CHECKS = 0;
DROP DATABASE IF EXISTS erp_system;
CREATE DATABASE erp_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE erp_pos_system;

-- BUSINESS
CREATE TABLE business (
    business_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    business_code VARCHAR(10) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    business_type ENUM('retail', 'wholesale', 'restaurant', 'service') NOT NULL DEFAULT 'retail',
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Canada',
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(255),
    tax_number VARCHAR(30), -- GST/HST number
    business_license VARCHAR(50),
    default_currency_id INT UNSIGNED,
    default_timezone VARCHAR(50) DEFAULT 'America/Edmonton',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_business_code (business_code),
    INDEX idx_business_active (is_active)
) ENGINE=InnoDB;

CREATE TABLE currency (
    currency_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(3) UNIQUE NOT NULL, -- USD, CAD, EUR
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(5) NOT NULL,
    exchange_rate DECIMAL(10,6) DEFAULT 1.000000,
    is_base_currency BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_currency_code (code)
) ENGINE=InnoDB;

CREATE TABLE location (
    location_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    business_id INT UNSIGNED NOT NULL,
    code VARCHAR(10) NOT NULL,
    name VARCHAR(100) NOT NULL,
    type ENUM('warehouse', 'store', 'office') DEFAULT 'store',
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(20),
    email VARCHAR(100),
    manager_employee_id INT UNSIGNED,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_business_location_code (business_id, code),
    INDEX idx_location_business (business_id),
    INDEX idx_location_active (is_active)
) ENGINE=InnoDB;

-- USER MANAGEMENT & ROLES
CREATE TABLE role (
    role_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permissions JSON, -- Store permissions as JSON
    is_system_role BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE employee (
    employee_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_code VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    date_of_birth DATE,
    hire_date DATE,
    termination_date DATE,
    sin_ssn VARCHAR(20), -- Social Insurance/Security Number
    password_hash VARCHAR(255),
    pin_hash VARCHAR(255), -- For POS login
    hourly_rate DECIMAL(8,2),
    salary DECIMAL(10,2),
    commission_rate DECIMAL(5,4),
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_employee_code (employee_code),
    INDEX idx_employee_email (email),
    INDEX idx_employee_active (is_active)
) ENGINE=InnoDB;

CREATE TABLE employee_business_role (
    employee_id INT UNSIGNED,
    business_id INT UNSIGNED,
    role_id INT UNSIGNED,
    location_id INT UNSIGNED,
    assigned_date DATE DEFAULT (CURRENT_DATE),
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (employee_id, business_id, role_id),
    INDEX idx_employee_business (employee_id, business_id),
    INDEX idx_business_role (business_id, role_id)
) ENGINE=InnoDB;

-- PRODUCT MANAGEMENT
CREATE TABLE category (
    category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    business_id INT UNSIGNED NOT NULL,
    parent_category_id INT UNSIGNED,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_business_category_code (business_id, code),
    INDEX idx_category_parent (parent_category_id),
    INDEX idx_category_business (business_id)
) ENGINE=InnoDB;

CREATE TABLE brand (
    brand_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    business_id INT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    logo_url VARCHAR(500),
    website VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_brand_business (business_id),
    INDEX idx_brand_name (name)
) ENGINE=InnoDB;

CREATE TABLE unit_of_measure (
    uom_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL, -- EA, KG, LB, L, ML
    name VARCHAR(50) NOT NULL,
    type ENUM('weight', 'volume', 'length', 'each', 'time') NOT NULL,
    base_unit_id INT UNSIGNED, -- For conversions
    conversion_factor DECIMAL(10,6) DEFAULT 1.000000,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE supplier (
    supplier_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    business_id INT UNSIGNED NOT NULL,
    code VARCHAR(20) NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    fax VARCHAR(20),
    website VARCHAR(255),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    tax_number VARCHAR(30),
    payment_terms VARCHAR(50), -- Net 30, Net 60, etc.
    credit_limit DECIMAL(12,2),
    currency_id INT UNSIGNED,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_business_supplier_code (business_id, code),
    INDEX idx_supplier_business (business_id),
    INDEX idx_supplier_name (company_name)
) ENGINE=InnoDB;

CREATE TABLE product (
    product_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL,
    barcode VARCHAR(50),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    category_id INT UNSIGNED,
    brand_id INT UNSIGNED,
    supplier_id INT UNSIGNED,
    uom_id INT UNSIGNED NOT NULL,
    product_type ENUM('simple', 'variable', 'service', 'bundle') DEFAULT 'simple',
    cost_price DECIMAL(10,4) DEFAULT 0,
    markup_percentage DECIMAL(5,2) DEFAULT 0,
    selling_price DECIMAL(10,4) NOT NULL,
    min_selling_price DECIMAL(10,4),
    weight DECIMAL(8,3),
    dimensions VARCHAR(50), -- LxWxH
    color VARCHAR(50),
    size VARCHAR(50),
    material VARCHAR(100),
    warranty_period INT, -- in months
    reorder_level INT DEFAULT 0,
    reorder_quantity INT DEFAULT 0,
    max_stock_level INT,
    lead_time_days INT DEFAULT 0,
    shelf_life_days INT,
    is_serialized BOOLEAN DEFAULT FALSE,
    is_lot_tracked BOOLEAN DEFAULT FALSE,
    track_inventory BOOLEAN DEFAULT TRUE,
    allow_backorder BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    sell_online BOOLEAN DEFAULT FALSE,
    sell_in_store BOOLEAN DEFAULT TRUE,
    age_restriction INT, -- Minimum age required
    requires_prescription BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_product_category (category_id),
    INDEX idx_product_brand (brand_id),
    INDEX idx_product_supplier (supplier_id),
    INDEX idx_product_active (is_active),
    INDEX idx_product_barcode (barcode),
    FULLTEXT idx_product_search (name, description, sku)
) ENGINE=InnoDB;

CREATE TABLE product_image (
    image_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT UNSIGNED NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    sort_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_image_product (product_id)
) ENGINE=InnoDB;

-- TAX MANAGEMENT
-- CREATE TABLE tax_group (
--     tax_group_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
--     business_id INT UNSIGNED NOT NULL,
--     name VARCHAR(100) NOT NULL,
--     description TEXT,
--     is_active BOOLEAN DEFAULT TRUE,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     INDEX idx_tax_group_business (business_id)
-- ) ENGINE=InnoDB;

CREATE TABLE tax_rate (
    tax_rate_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tax_group_id INT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL, -- GST, PST, HST
    rate DECIMAL(5,4) NOT NULL, -- 0.05 for 5%
    tax_type ENUM('percentage', 'fixed') DEFAULT 'percentage',
    applies_to ENUM('selling_price', 'cost_price') DEFAULT 'selling_price',
    compound_tax BOOLEAN DEFAULT FALSE, -- Tax on tax
    sort_order INT DEFAULT 0,
    effective_date DATE,
    expiry_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tax_rate_group (tax_group_id),
    INDEX idx_tax_rate_effective (effective_date, expiry_date)
) ENGINE=InnoDB;

CREATE TABLE product_tax_group (
    product_id INT UNSIGNED,
    tax_group_id INT UNSIGNED,
    PRIMARY KEY (product_id, tax_group_id)
) ENGINE=InnoDB;

-- INVENTORY MANAGEMENT
CREATE TABLE inventory (
    inventory_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT UNSIGNED NOT NULL,
    location_id INT UNSIGNED NOT NULL,
    quantity_on_hand DECIMAL(10,3) DEFAULT 0,
    quantity_allocated DECIMAL(10,3) DEFAULT 0, -- Reserved for orders
    quantity_available DECIMAL(10,3) AS (quantity_on_hand - quantity_allocated) STORED,
    quantity_on_order DECIMAL(10,3) DEFAULT 0,
    last_cost_price DECIMAL(10,4),
    average_cost_price DECIMAL(10,4),
    last_count_date DATE,
    next_count_date DATE,
    bin_location VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_product_location (product_id, location_id),
    INDEX idx_inventory_location (location_id),
    INDEX idx_inventory_low_stock (product_id, quantity_available)
) ENGINE=InnoDB;

CREATE TABLE inventory_transaction (
    transaction_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT UNSIGNED NOT NULL,
    location_id INT UNSIGNED NOT NULL,
    transaction_type ENUM('sale', 'purchase', 'adjustment', 'transfer_in', 'transfer_out', 'return', 'waste', 'count') NOT NULL,
    reference_type ENUM('sale', 'purchase', 'adjustment', 'transfer', 'return') NOT NULL,
    reference_id INT UNSIGNED NOT NULL, -- Links to sale_id, purchase_id, etc.
    quantity_change DECIMAL(10,3) NOT NULL, -- Positive for increase, negative for decrease
    unit_cost DECIMAL(10,4),
    total_cost DECIMAL(12,4),
    batch_lot_number VARCHAR(50),
    expiry_date DATE,
    serial_number VARCHAR(100),
    employee_id INT UNSIGNED,
    notes TEXT,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_inventory_transaction_product (product_id),
    INDEX idx_inventory_transaction_location (location_id),
    INDEX idx_inventory_transaction_date (transaction_date),
    INDEX idx_inventory_transaction_reference (reference_type, reference_id)
) ENGINE=InnoDB;

-- CUSTOMER MANAGEMENT
CREATE TABLE customer_group (
    group_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    business_id INT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_customer_group_business (business_id)
) ENGINE=InnoDB;

CREATE TABLE customer (
    customer_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    business_id INT UNSIGNED NOT NULL,
    customer_code VARCHAR(20),
    customer_type ENUM('individual', 'business') DEFAULT 'individual',
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    company_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('male', 'female', 'other'),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    tax_number VARCHAR(30),
    customer_group_id INT UNSIGNED,
    credit_limit DECIMAL(12,2) DEFAULT 0,
    payment_terms VARCHAR(50),
    loyalty_points INT UNSIGNED DEFAULT 0,
    total_spent DECIMAL(12,2) DEFAULT 0,
    total_orders INT UNSIGNED DEFAULT 0,
    last_order_date DATE,
    preferred_location_id INT UNSIGNED,
    marketing_opt_in BOOLEAN DEFAULT FALSE,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_business_customer_code (business_id, customer_code),
    INDEX idx_customer_business (business_id),
    INDEX idx_customer_email (email),
    INDEX idx_customer_phone (phone),
    INDEX idx_customer_group (customer_group_id),
    FULLTEXT idx_customer_search (first_name, last_name, company_name, email, phone)
) ENGINE=InnoDB;

-- LOYALTY PROGRAM
CREATE TABLE loyalty_program (
    program_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    business_id INT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    points_per_dollar DECIMAL(5,2) DEFAULT 1.00, -- Points earned per dollar spent
    redemption_rate DECIMAL(5,2) DEFAULT 0.01, -- Dollar value per point
    minimum_redemption INT DEFAULT 100,
    point_expiry_months INT,
    welcome_bonus_points INT DEFAULT 0,
    birthday_bonus_points INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_loyalty_business (business_id)
) ENGINE=InnoDB;

CREATE TABLE loyalty_transaction (
    loyalty_transaction_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED NOT NULL,
    transaction_type ENUM('earned', 'redeemed', 'expired', 'bonus', 'adjustment') NOT NULL,
    points INT NOT NULL, -- Positive for earned, negative for redeemed
    reference_type ENUM('sale', 'return', 'bonus', 'adjustment'),
    reference_id INT UNSIGNED,
    description VARCHAR(255),
    expiry_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_loyalty_customer (customer_id),
    INDEX idx_loyalty_date (created_at)
) ENGINE=InnoDB;

-- SALES & POS REGISTER
CREATE TABLE register (
    register_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    location_id INT UNSIGNED NOT NULL,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    terminal_id VARCHAR(20),
    receipt_printer VARCHAR(100),
    cash_drawer_type VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_register_location (location_id)
) ENGINE=InnoDB;

CREATE TABLE register_session (
    session_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    register_id INT UNSIGNED NOT NULL,
    employee_id INT UNSIGNED NOT NULL,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    opening_cash DECIMAL(10,2) DEFAULT 0,
    expected_cash DECIMAL(10,2) DEFAULT 0,
    actual_cash DECIMAL(10,2) DEFAULT 0,
    cash_difference DECIMAL(10,2) AS (actual_cash - expected_cash) STORED,
    total_sales DECIMAL(12,2) DEFAULT 0,
    total_returns DECIMAL(12,2) DEFAULT 0,
    transaction_count INT DEFAULT 0,
    notes TEXT,
    status ENUM('open', 'closed') DEFAULT 'open',
    closed_by_employee_id INT UNSIGNED,
    INDEX idx_session_register (register_id),
    INDEX idx_session_employee (employee_id),
    INDEX idx_session_date (start_time)
) ENGINE=InnoDB;

CREATE TABLE sale (
    sale_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    business_id INT UNSIGNED NOT NULL,
    location_id INT UNSIGNED NOT NULL,
    register_id INT UNSIGNED,
    session_id INT UNSIGNED,
    sale_number VARCHAR(20) NOT NULL,
    customer_id INT UNSIGNED,
    employee_id INT UNSIGNED NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'completed', 'cancelled', 'refunded', 'partially_refunded') DEFAULT 'completed',
    subtotal DECIMAL(12,4) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(12,4) DEFAULT 0,
    tax_amount DECIMAL(12,4) DEFAULT 0,
    total_amount DECIMAL(12,4) NOT NULL DEFAULT 0,
    amount_paid DECIMAL(12,4) DEFAULT 0,
    change_given DECIMAL(12,4) DEFAULT 0,
    loyalty_points_earned INT DEFAULT 0,
    loyalty_points_redeemed INT DEFAULT 0,
    notes TEXT,
    receipt_printed BOOLEAN DEFAULT FALSE,
    receipt_emailed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_business_sale_number (business_id, sale_number),
    INDEX idx_sale_business (business_id),
    INDEX idx_sale_location (location_id),
    INDEX idx_sale_customer (customer_id),
    INDEX idx_sale_employee (employee_id),
    INDEX idx_sale_date (sale_date),
    INDEX idx_sale_status (status)
) ENGINE=InnoDB;

-- CREATE TABLE sale_line_item (
--     line_item_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
--     sale_id INT UNSIGNED NOT NULL,
--     product_id INT UNSIGNED NOT NULL,
--     quantity DECIMAL(10,3) NOT NULL,
--     unit_price DECIMAL(10,4) NOT NULL,
--     discount_percentage DECIMAL(5,2) DEFAULT 0,
--     discount_amount DECIMAL(10,4) DEFAULT 0,
--     line_total DECIMAL(12,4) AS (quantity * unit_price - discount_amount) STORED,
--     tax_amount DECIMAL(10,4) DEFAULT 0,
--     cost_price DECIMAL(10,4),
--     serial_number VARCHAR(100),
--     notes VARCHAR(255),
--     INDEX idx_line_item_sale (sale_id),
--     INDEX idx_line_item_product (product_id)
-- ) ENGINE=InnoDB;
--
-- CREATE TABLE sale_tax_detail (
--     tax_detail_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
--     sale_id INT UNSIGNED NOT NULL,
--     line_item_id INT UNSIGNED,
--     tax_rate_id INT UNSIGNED NOT NULL,
--     tax_name VARCHAR(100) NOT NULL,
--     tax_rate DECIMAL(5,4) NOT NULL,
--     taxable_amount DECIMAL(12,4) NOT NULL,
--     tax_amount DECIMAL(10,4) NOT NULL,
--     INDEX idx_tax_detail_sale (sale_id),
--     INDEX idx_tax_detail_line (line_item_id)
-- ) ENGINE=InnoDB;

-- PAYMENT PROCESSING
CREATE TABLE payment_method (
    payment_method_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    business_id INT UNSIGNED NOT NULL,
    name VARCHAR(50) NOT NULL, -- Cash, Credit Card, Debit, Gift Card, etc.
    type ENUM('cash', 'card', 'digital', 'check', 'store_credit', 'gift_card') NOT NULL,
    processor VARCHAR(50), -- Square, Stripe, PayPal, etc.
    account_reference VARCHAR(100),
    fee_percentage DECIMAL(5,4) DEFAULT 0,
    fee_fixed DECIMAL(8,4) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_payment_method_business (business_id)
) ENGINE=InnoDB;

CREATE TABLE payment (
    payment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_id INT UNSIGNED NOT NULL,
    payment_method_id INT UNSIGNED NOT NULL,
    amount DECIMAL(12,4) NOT NULL,
    reference_number VARCHAR(100), -- Transaction ID from processor
    authorization_code VARCHAR(50),
    card_type VARCHAR(20), -- Visa, MasterCard, etc.
    last_four_digits VARCHAR(4),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'approved', 'declined', 'refunded') DEFAULT 'approved',
    processor_response TEXT,
    fee_amount DECIMAL(8,4) DEFAULT 0,
    net_amount DECIMAL(12,4) AS (amount - fee_amount) STORED,
    INDEX idx_payment_sale (sale_id),
    INDEX idx_payment_method (payment_method_id),
    INDEX idx_payment_date (payment_date),
    INDEX idx_payment_reference (reference_number)
) ENGINE=InnoDB;




-- PURCHASING
CREATE TABLE purchase_order (
    purchase_order_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    business_id INT UNSIGNED NOT NULL,
    supplier_id INT UNSIGNED NOT NULL,
    location_id INT UNSIGNED NOT NULL,
    po_number VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    expected_date DATE,
    received_date DATE,
    employee_id INT UNSIGNED NOT NULL,
    status ENUM('draft', 'sent', 'confirmed', 'partially_received', 'received', 'cancelled') DEFAULT 'draft',
    subtotal DECIMAL(12,4) DEFAULT 0,
    tax_amount DECIMAL(12,4) DEFAULT 0,
    shipping_cost DECIMAL(10,4) DEFAULT 0,
    total_amount DECIMAL(12,4) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_business_po_number (business_id, po_number),
    INDEX idx_po_business (business_id),
    INDEX idx_po_supplier (supplier_id),
    INDEX idx_po_status (status),
    INDEX idx_po_date (order_date)
) ENGINE=InnoDB;

CREATE TABLE purchase_order_line_item (
    line_item_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    purchase_order_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    quantity_ordered DECIMAL(10,3) NOT NULL,
    quantity_received DECIMAL(10,3) DEFAULT 0,
    unit_cost DECIMAL(10,4) NOT NULL,
    line_total DECIMAL(12,4) AS (quantity_ordered * unit_cost) STORED,
    expected_date DATE,
    notes VARCHAR(255),
    INDEX idx_po_line_po (purchase_order_id),
    INDEX idx_po_line_product (product_id)
) ENGINE=InnoDB;

-- ========== DISCOUNTS & PROMOTIONS ==========
CREATE TABLE discount_rule (
    discount_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    business_id INT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    type ENUM('percentage', 'fixed_amount', 'buy_x_get_y', 'bulk_pricing') NOT NULL,
    value_type ENUM('percentage', 'fixed') DEFAULT 'percentage',
    discount_value DECIMAL(10,4) NOT NULL,
    applies_to ENUM('order', 'product', 'category') NOT NULL,
    target_id INT UNSIGNED, -- product_id or category_id
    minimum_quantity DECIMAL(10,3) DEFAULT 0,
    minimum_amount DECIMAL(10,4) DEFAULT 0,
    maximum_discount DECIMAL(10,4),
    customer_group_id INT UNSIGNED, -- Restrict to customer group
    usage_limit INT,
    usage_count INT DEFAULT 0,
    start_date DATETIME,
    end_date DATETIME,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_discount_business (business_id),
    INDEX idx_discount_dates (start_date, end_date),
    INDEX idx_discount_active (is_active)
) ENGINE=InnoDB;

-- REPORTING TABLES
CREATE TABLE daily_sales_summary (
    summary_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    business_id INT UNSIGNED NOT NULL,
    location_id INT UNSIGNED NOT NULL,
    summary_date DATE NOT NULL,
    total_sales DECIMAL(12,4) DEFAULT 0,
    total_returns DECIMAL(12,4) DEFAULT 0,
    net_sales DECIMAL(12,4) AS (total_sales - total_returns) STORED,
    transaction_count INT DEFAULT 0,
    customer_count INT DEFAULT 0,
    average_transaction DECIMAL(10,4) AS (CASE WHEN transaction_count > 0 THEN net_sales / transaction_count ELSE 0 END) STORED,
    cash_sales DECIMAL(12,4) DEFAULT 0,
    card_sales DECIMAL(12,4) DEFAULT 0,
    tax_collected DECIMAL(12,4) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_business_location_date (business_id, location_id, summary_date),
    INDEX idx_summary_business (business_id),
    INDEX idx_summary_date (summary_date)
) ENGINE=InnoDB;

-- SYSTEM CONFIGURATION
-- CREATE TABLE system_setting (
--     setting_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
--     business_id INT UNSIGNED,
--     setting_key VARCHAR(100) NOT NULL,
--     setting_value TEXT,
--     setting_type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
--     description TEXT,
--     is_system BOOLEAN DEFAULT FALSE,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     UNIQUE KEY uk_business_setting (business_id, setting_key),
--     INDEX idx_setting_key (setting_key)
-- ) ENGINE=InnoDB;

-- FOREIGN KEY CONSTRAINTS
ALTER TABLE business ADD CONSTRAINT fk_business_currency FOREIGN KEY (default_currency_id) REFERENCES currency(currency_id);
ALTER TABLE location ADD CONSTRAINT fk_location_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;
ALTER TABLE location ADD CONSTRAINT fk_location_manager FOREIGN KEY (manager_employee_id) REFERENCES employee(employee_id);

ALTER TABLE employee_business_role ADD CONSTRAINT fk_ebr_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE CASCADE;
ALTER TABLE employee_business_role ADD CONSTRAINT fk_ebr_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;
ALTER TABLE employee_business_role ADD CONSTRAINT fk_ebr_role FOREIGN KEY (role_id) REFERENCES role(role_id);
ALTER TABLE employee_business_role ADD CONSTRAINT fk_ebr_location FOREIGN KEY (location_id) REFERENCES location(location_id);

ALTER TABLE category ADD CONSTRAINT fk_category_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;
ALTER TABLE category ADD CONSTRAINT fk_category_parent FOREIGN KEY (parent_category_id) REFERENCES category(category_id);

ALTER TABLE brand ADD CONSTRAINT fk_brand_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;

ALTER TABLE unit_of_measure ADD CONSTRAINT fk_uom_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;
ALTER TABLE unit_of_measure ADD CONSTRAINT fk_uom_base FOREIGN KEY (base_unit_id) REFERENCES unit_of_measure(uom_id);

ALTER TABLE supplier ADD CONSTRAINT fk_supplier_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;
ALTER TABLE supplier ADD CONSTRAINT fk_supplier_currency FOREIGN KEY (currency_id) REFERENCES currency(currency_id);

ALTER TABLE product ADD CONSTRAINT fk_product_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;
ALTER TABLE product ADD CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES category(category_id);
ALTER TABLE product ADD CONSTRAINT fk_product_brand FOREIGN KEY (brand_id) REFERENCES brand(brand_id);
ALTER TABLE product ADD CONSTRAINT fk_product_supplier FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id);
ALTER TABLE product ADD CONSTRAINT fk_product_uom FOREIGN KEY (uom_id) REFERENCES unit_of_measure(uom_id);

ALTER TABLE product_image ADD CONSTRAINT fk_product_image_product FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE;

ALTER TABLE tax_group ADD CONSTRAINT fk_tax_group_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;

ALTER TABLE tax_rate ADD CONSTRAINT fk_tax_rate_group FOREIGN KEY (tax_group_id) REFERENCES tax_group(tax_group_id) ON DELETE CASCADE;

ALTER TABLE product_tax_group ADD CONSTRAINT fk_ptg_product FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE;
ALTER TABLE product_tax_group ADD CONSTRAINT fk_ptg_tax_group FOREIGN KEY (tax_group_id) REFERENCES tax_group(tax_group_id) ON DELETE CASCADE;

ALTER TABLE inventory ADD CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE;
ALTER TABLE inventory ADD CONSTRAINT fk_inventory_location FOREIGN KEY (location_id) REFERENCES location(location_id) ON DELETE CASCADE;

ALTER TABLE inventory_transaction ADD CONSTRAINT fk_inv_trans_product FOREIGN KEY (product_id) REFERENCES product(product_id);
ALTER TABLE inventory_transaction ADD CONSTRAINT fk_inv_trans_location FOREIGN KEY (location_id) REFERENCES location(location_id);
ALTER TABLE inventory_transaction ADD CONSTRAINT fk_inv_trans_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id);

ALTER TABLE customer_group ADD CONSTRAINT fk_customer_group_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;

ALTER TABLE customer ADD CONSTRAINT fk_customer_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;
ALTER TABLE customer ADD CONSTRAINT fk_customer_group FOREIGN KEY (customer_group_id) REFERENCES customer_group(group_id);
ALTER TABLE customer ADD CONSTRAINT fk_customer_location FOREIGN KEY (preferred_location_id) REFERENCES location(location_id);

ALTER TABLE loyalty_program ADD CONSTRAINT fk_loyalty_program_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;

ALTER TABLE loyalty_transaction ADD CONSTRAINT fk_loyalty_trans_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE;

ALTER TABLE register ADD CONSTRAINT fk_register_location FOREIGN KEY (location_id) REFERENCES location(location_id) ON DELETE CASCADE;

ALTER TABLE register_session ADD CONSTRAINT fk_session_register FOREIGN KEY (register_id) REFERENCES register(register_id);
ALTER TABLE register_session ADD CONSTRAINT fk_session_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id);
ALTER TABLE register_session ADD CONSTRAINT fk_session_closed_by FOREIGN KEY (closed_by_employee_id) REFERENCES employee(employee_id);

ALTER TABLE sale ADD CONSTRAINT fk_sale_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;
ALTER TABLE sale ADD CONSTRAINT fk_sale_location FOREIGN KEY (location_id) REFERENCES location(location_id);
ALTER TABLE sale ADD CONSTRAINT fk_sale_register FOREIGN KEY (register_id) REFERENCES register(register_id);
ALTER TABLE sale ADD CONSTRAINT fk_sale_session FOREIGN KEY (session_id) REFERENCES register_session(session_id);
ALTER TABLE sale ADD CONSTRAINT fk_sale_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id);
ALTER TABLE sale ADD CONSTRAINT fk_sale_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id);

ALTER TABLE sale_line_item ADD CONSTRAINT fk_line_item_sale FOREIGN KEY (sale_id) REFERENCES sale(sale_id) ON DELETE CASCADE;
ALTER TABLE sale_line_item ADD CONSTRAINT fk_line_item_product FOREIGN KEY (product_id) REFERENCES product(product_id);

ALTER TABLE sale_tax_detail ADD CONSTRAINT fk_tax_detail_sale FOREIGN KEY (sale_id) REFERENCES sale(sale_id) ON DELETE CASCADE;
ALTER TABLE sale_tax_detail ADD CONSTRAINT fk_tax_detail_line FOREIGN KEY (line_item_id) REFERENCES sale_line_item(line_item_id) ON DELETE CASCADE;
ALTER TABLE sale_tax_detail ADD CONSTRAINT fk_tax_detail_rate FOREIGN KEY (tax_rate_id) REFERENCES tax_rate(tax_rate_id);

ALTER TABLE payment_method ADD CONSTRAINT fk_payment_method_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;

ALTER TABLE payment ADD CONSTRAINT fk_payment_sale FOREIGN KEY (sale_id) REFERENCES sale(sale_id) ON DELETE CASCADE;
ALTER TABLE payment ADD CONSTRAINT fk_payment_method FOREIGN KEY (payment_method_id) REFERENCES payment_method(payment_method_id);

ALTER TABLE purchase_order ADD CONSTRAINT fk_po_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;
ALTER TABLE purchase_order ADD CONSTRAINT fk_po_supplier FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id);
ALTER TABLE purchase_order ADD CONSTRAINT fk_po_location FOREIGN KEY (location_id) REFERENCES location(location_id);
ALTER TABLE purchase_order ADD CONSTRAINT fk_po_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id);

ALTER TABLE purchase_order_line_item ADD CONSTRAINT fk_po_line_po FOREIGN KEY (purchase_order_id) REFERENCES purchase_order(purchase_order_id) ON DELETE CASCADE;
ALTER TABLE purchase_order_line_item ADD CONSTRAINT fk_po_line_product FOREIGN KEY (product_id) REFERENCES product(product_id);

ALTER TABLE discount_rule ADD CONSTRAINT fk_discount_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;
ALTER TABLE discount_rule ADD CONSTRAINT fk_discount_customer_group FOREIGN KEY (customer_group_id) REFERENCES customer_group(group_id);

ALTER TABLE daily_sales_summary ADD CONSTRAINT fk_summary_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;
ALTER TABLE daily_sales_summary ADD CONSTRAINT fk_summary_location FOREIGN KEY (location_id) REFERENCES location(location_id) ON DELETE CASCADE;

ALTER TABLE system_setting ADD CONSTRAINT fk_setting_business FOREIGN KEY (business_id) REFERENCES business(business_id) ON DELETE CASCADE;

-- Init Data
-- Insert base currency
INSERT INTO currency (code, name, symbol, is_base_currency, is_active) VALUES
('CAD', 'Canadian Dollar', '$', TRUE, TRUE),
('USD', 'US Dollar', '$', FALSE, TRUE),
('EUR', 'Euro', '€', FALSE, TRUE);

-- Insert default roles
INSERT INTO role (name, description, is_system_role) VALUES
('Super Admin', 'Full system access', TRUE),
('Manager', 'Store management access', TRUE),
('Cashier', 'POS and basic functions', TRUE),
('Stock Clerk', 'Inventory management', TRUE),
('Sales Associate', 'Sales and customer service', TRUE);

-- Insert default units of measure
INSERT INTO unit_of_measure (code, name, type) VALUES
('EA', 'Each', 'each'),
('KG', 'Kilogram', 'weight'),
('LB', 'Pound', 'weight'),
('L', 'Liter', 'volume'),
('ML', 'Milliliter', 'volume');

-- Additional indexes for reporting queries
CREATE INDEX idx_sale_date_business ON sale(business_id, sale_date);
CREATE INDEX idx_sale_line_item_product_date ON sale_line_item(product_id, sale_id);
CREATE INDEX idx_inventory_transaction_date ON inventory_transaction(transaction_date, product_id);
CREATE INDEX idx_customer_last_order ON customer(last_order_date, business_id);
CREATE INDEX idx_employee_active_business ON employee(is_active, business_id);
